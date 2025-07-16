import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxi_app/common/color_extension.dart';
import 'package:taxi_app/common/db_helper.dart';
import 'package:taxi_app/common/globs.dart';
import 'package:taxi_app/common/my_http_overrides.dart';
import 'package:taxi_app/common/service_call.dart';
import 'package:taxi_app/common/socket_manager.dart';
import 'package:taxi_app/cubit/login_cubit.dart';
import 'package:taxi_app/view/login/sign_in_view.dart';
import 'package:taxi_app/view/login/splash_view.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> initPushToken() async {
  final fcmToken = await FirebaseMessaging.instance.getToken();
  print("📱 FCM Token: $fcmToken");

  /// خزّنه في متغير عام أو في SharedPreferences إذا أردت استخدامه لاحقًا
  Globs.fcmToken = fcmToken; // مثال لو عندك متغير عام في Globs
}

SharedPreferences? prefs;

Future<void> initOneSignal() async {
  // ✅ 1. تعيين App ID
  OneSignal.shared.setAppId("d8808a92-c4df-4c8b-a405-ae5822a0c946");

  // ✅ 2. طلب الإذن من المستخدم
  await OneSignal.shared.promptUserForPushNotificationPermission();

  // ✅ 3. انتظر قليلاً
  await Future.delayed(const Duration(seconds: 2));

  // ✅ 4. احصل على حالة الجهاز
  OSDeviceState? deviceState = await OneSignal.shared.getDeviceState();

  // ✅ 5. خزّن Player ID
  Globs.onSignalToken = deviceState?.userId;

  // ✅ 6. إعادة المحاولة إن لم يتم استلام Player ID
  if (Globs.onSignalToken == null) {
    print("⚠️ OneSignal Player ID is null... retrying");
    await Future.delayed(const Duration(seconds: 3));
    deviceState = await OneSignal.shared.getDeviceState();
    Globs.onSignalToken = deviceState?.userId;
  }

  print("📱 OneSignal Player ID: ${Globs.onSignalToken}");
}

Future<void> checkNotificationPermissionAndShowDialog(
    BuildContext context) async {
  final status = await Permission.notification.status;

  if (status.isDenied || status.isPermanentlyDenied) {
    // 🛑 المستخدم رفض أو عطّل الإشعارات تمامًا
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("الإشعارات غير مفعّلة"),
        content: const Text(
            "يرجى تفعيل الإشعارات من إعدادات الهاتف لتصلك تنبيهات الرحلات."),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await openAppSettings(); // يفتح إعدادات التطبيق مباشرة
            },
            child: const Text("فتح الإعدادات"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text("إلغاء"),
          ),
        ],
      ),
    );

    // ✨ تحقق بعد العودة إن تغيّرت الحالة
    final afterStatus = await Permission.notification.status;
    if (afterStatus.isGranted) {
      // مثلاً تحديث الواجهة أو إظهار إشعار
      print("✅ تم تفعيل الإشعارات");
    } else {
      print("❌ لم يتم تفعيل الإشعارات");
    }
  }
}

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();

  DBHelper.shared().db;

  prefs = await SharedPreferences.getInstance();
  await Firebase.initializeApp();

  await initPushToken(); // ✅ الآن يتم تنفيذها فعلاً
  await initOneSignal();

  if (Globs.udValueBool(Globs.userLogin)) {
    ServiceCall.userObj = Globs.udValue(Globs.userPayload) as Map? ?? {};
    ServiceCall.userType = ServiceCall.userObj["user_type"] as int? ?? 1;
  }
  SocketManager.shared.initSocket();

  runApp(const MyApp());
  configLoading();
  ServiceCall.getStaticDateApi();
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void configLoading() {
  EasyLoading.instance
    ..indicatorType = EasyLoadingIndicatorType.ring
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 45.0
    ..radius = 5.0
    ..progressColor = TColor.primaryText
    ..backgroundColor = TColor.primary
    ..indicatorColor = Colors.white
    ..textColor = TColor.primaryText
    ..userInteractions = false
    ..dismissOnTap = false;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (context) => LoginCubit())],
      child: MaterialApp(
        title: 'Taxi Driver',
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: "NunitoSans",
          scaffoldBackgroundColor: TColor.bg,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          colorScheme: ColorScheme.fromSeed(seedColor: TColor.primary),
          useMaterial3: false,
        ),
        home: const SignInView(),
        builder: EasyLoading.init(),
      ),
    );
  }
}
