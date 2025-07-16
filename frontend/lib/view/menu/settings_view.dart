import 'package:flutter/material.dart';
import 'package:taxi_app/common/color_extension.dart';
import 'package:taxi_app/common_widget/setting_row.dart';
import 'package:taxi_app/main.dart';
import 'package:taxi_app/view/home/support/support_list_view.dart';
import 'package:taxi_app/view/login/bank_detail_view.dart';
import 'package:taxi_app/view/login/document_upload_view.dart';
import 'package:taxi_app/view/menu/change_password_view.dart';
import 'package:taxi_app/view/menu/contact_us_view.dart';
import 'package:taxi_app/view/menu/my_profile_view.dart';
import 'package:taxi_app/view/menu/my_vehicle_view.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late Future<PermissionStatus> _notificationStatus;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // سيتم تنفيذها كل مرة ترجع فيها الصفحة بعد فتح إعدادات النظام
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkNotificationAndRefresh();
    });
  }

  @override
  void initState() {
    super.initState();
    _notificationStatus = Permission.notification.status;
  }

  Future<void> _checkNotificationAndRefresh() async {
    await checkNotificationPermissionAndShowDialog(context);

    final newStatus = await Permission.notification.status;
    setState(() {
      _notificationStatus = Future.value(newStatus);
    });

    if (newStatus.isGranted) {
      // ✅ إشعار SnackBar بعد التفعيل
      if (context.mounted) {
        // وكأن الزر تم ضغطه
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text("تم تفعيل الإشعارات بنجاح ✅"),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: Image.asset(
            "assets/img/back.png",
            width: 25,
            height: 25,
          ),
        ),
        centerTitle: true,
        title: Text(
          "Settings",
          style: TextStyle(
            color: TColor.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      backgroundColor: TColor.lightWhite,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 8,
            ),
            SettingRow(
                title: "My Profile",
                icon: "assets/img/sm_profile.png",
                onPressed: () {
                  context.push(const MyProfileView());
                }),
            SettingRow(
                title: "My Vehicle",
                icon: "assets/img/sm_my_vehicle.png",
                onPressed: () {
                  context.push(const MyVehicleView());
                }),
            SettingRow(
                title: "Personal Documents",
                icon: "assets/img/sm_document.png",
                onPressed: () {
                  context.push(
                      const DocumentUploadView(title: "Personal Document"));
                }),
            SettingRow(
                title: "Bank details",
                icon: "assets/img/sm_bank.png",
                onPressed: () {
                  context.push(const BankDetailView());
                }),
            SettingRow(
                title: "Change Password",
                icon: "assets/img/sm_password.png",
                onPressed: () {
                  context.push(const ChangePasswordView());
                }),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text("الإشعارات"),
              subtitle: FutureBuilder<PermissionStatus>(
                future: _notificationStatus,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text("جارٍ التحقق...");
                  } else if (snapshot.hasData && snapshot.data!.isGranted) {
                    return const Text("مفعّلة");
                  } else {
                    return const Text("غير مفعّلة - اضغط لتفعيلها");
                  }
                },
              ),
              onTap: _checkNotificationAndRefresh,
            ),
            const SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                "HELP",
                style: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            SettingRow(
                title: "Terms & Conditions",
                icon: "assets/img/sm_document.png",
                onPressed: () {}),
            SettingRow(
                title: "Privacy Policies",
                icon: "assets/img/sm_document.png",
                onPressed: () {}),
            SettingRow(
                title: "About",
                icon: "assets/img/sm_document.png",
                onPressed: () {}),
            SettingRow(
                title: "Contact us",
                icon: "assets/img/sm_profile.png",
                onPressed: () {
                  context.push(const ContactUsView());
                }),
            SettingRow(
                title: "Supports",
                icon: "assets/img/sm_profile.png",
                onPressed: () {
                  context.push(const SupportListView());
                }),
          ],
        ),
      ),
    );
  }
}
