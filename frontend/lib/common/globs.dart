import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:taxi_app/main.dart';

class Globs {
  static const appName = "Taxi Driver";
  static OverlayEntry? _progressOverlay;
  static const userPayload = "user_payload";
  static const userLogin = "user_login";

  static String? fcmToken;

  static String? onSignalToken;

  static void showProgress(double progress) {
    hideProgress(); // إزالة القديم إذا كان موجود
    _progressOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: 100,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 5)
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Uploading...",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(value: progress),
              ],
            ),
          ),
        ),
      ),
    );
    navigatorKey.currentState?.overlay?.insert(_progressOverlay!);
  }

  static void hideProgress() {
    _progressOverlay?.remove();
    _progressOverlay = null;
  }

  static void showHUD({String status = "loading ...."}) async {
    await Future.delayed(const Duration(milliseconds: 1));
    EasyLoading.show(status: status);
  }

  static void hideHUD() {
    EasyLoading.dismiss();
  }

  static void udSet(dynamic data, String key) {
    var jsonStr = json.encode(data);
    prefs?.setString(key, jsonStr);
  }

  static void udStringSet(String data, String key) {
    prefs?.setString(key, data);
  }

  static void udBoolSet(bool data, String key) {
    prefs?.setBool(key, data);
  }

  static void udIntSet(int data, String key) {
    prefs?.setInt(key, data);
  }

  static void udDoubleSet(double data, String key) {
    prefs?.setDouble(key, data);
  }

  static dynamic udValue(String key) {
    return json.decode(prefs?.get(key) as String? ?? "{}");
  }

  static String udValueString(String key) {
    return prefs?.getString(key) ?? "";
  }

  static bool udValueBool(String key) {
    return prefs?.getBool(key) ?? false;
  }

  static bool udValueTrueBool(String key) {
    return prefs?.getBool(key) ?? true;
  }

  static int udValueInt(String key) {
    return prefs?.getInt(key) ?? 0;
  }

  static double udValueDouble(String key) {
    return prefs?.getDouble(key) ?? 0.0;
  }

  static void udRemove(String key) {
    prefs?.remove(key);
  }

  static Future<String> timeZone() async {
    try {
      return await FlutterTimezone.getLocalTimezone();
    } catch (e) {
      return "";
    }
  }
}

class SVKey {
  //static const mainUrl = "http://localhost:3001";
  static const mainUrl = "https://engramy.org"; // أو أي دومين خاص بك

  static const baseUrl = '$mainUrl/api/';
  static const nodeUrl = mainUrl;

// ✅ لحساب السعر النهائي من السيرفر بناءً على المسافة والمدة
  static const svEstimateFare = "${baseUrl}estimate_fare";

  static const svLogin = "${baseUrl}login";
  static const svProfileImageUpload = "${baseUrl}profile_image";
  static const svServiceAndZoneList = "${baseUrl}service_and_zone_list";
  static const svProfileUpdate = "${baseUrl}profile_update";

  static const svBankDetail = "${baseUrl}bank_detail";
  static const svDriverBankDetailUpdate = "${baseUrl}driver_bank_update";

  static const svBrandList = "${baseUrl}brand_list";
  static const svModelList = "${baseUrl}model_list";
  static const svSeriesList = "${baseUrl}series_list";
  static const svAddCar = "${baseUrl}add_car";
  static const svCarList = "${baseUrl}car_list";

  static const svDeleteCar = "${baseUrl}car_delete";
  static const svSetRunningCar = "${baseUrl}set_running_car";

  static const svSupportList = "${baseUrl}support_user_list";
  static const svSupportConnect = "${baseUrl}support_connect";
  static const svSupportSendMessage = "${baseUrl}support_message";
  static const svSupportClear = "${baseUrl}support_clear";

  static const svStaticData = "${baseUrl}static_data";

  static const svBookingRequest = "${baseUrl}booking_request";
  static const svUpdateLocationDriver = "${baseUrl}update_location";
  static const svDriverGoOnline = "${baseUrl}driver_online";

  static const svDriverRideAccept = "${baseUrl}ride_request_accept";
  static const svDriverRideDecline = "${baseUrl}ride_request_decline";

  static const svHome = "${baseUrl}home";
  static const svDriverWaitUser = "${baseUrl}driver_wait_user";
  static const svRideStart = "${baseUrl}ride_start";
  static const svRideStop = "${baseUrl}ride_stop";
  static const svRideCancel = "${baseUrl}driver_cancel_ride";
  static const svUserRideCancel = "${baseUrl}user_cancel_ride";

  static const svUserAllRides = "${baseUrl}user_all_ride_list";
  static const svDriverAllRides = "${baseUrl}driver_all_ride_list";

  static const svRideRating = "${baseUrl}ride_rating";
  static const svBookingDetail = "${baseUrl}booking_detail";

  static const svDriverSummary = "${baseUrl}driver_summary";

  static const svPersonalDocumentList = "${baseUrl}personal_document_list";
  static const svDriverUploadDocument = "${baseUrl}driver_update_document";
  static const svCarDocumentList = "${baseUrl}car_document_list";

  static const svChangePassword = "${baseUrl}change_password";
  static const svContactUs = "${baseUrl}contact_us";
}

class KKey {
  static const payload = "payload";
  static const status = "status";
  static const message = "message";

  static const authToken = "auth_token";
}

class MSG {
  static const success = "success";
  static const fail = "fail";
}
