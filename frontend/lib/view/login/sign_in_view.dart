import 'dart:io';

import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:taxi_app/common/color_extension.dart';
import 'package:taxi_app/common/common_extension.dart';
import 'package:taxi_app/common/globs.dart';
import 'package:taxi_app/common/service_call.dart';
import 'package:taxi_app/common/socket_manager.dart';
import 'package:taxi_app/common_widget/line_text_field.dart';
import 'package:taxi_app/common_widget/round_button.dart';
import 'package:taxi_app/main.dart';
import 'package:taxi_app/view/home/home_view.dart';
import 'package:taxi_app/view/user/user_home_view.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  FlCountryCodePicker countryCodePicker = const FlCountryCodePicker();
  TextEditingController txtMobile = TextEditingController();
  late CountryCode countryCode;
  TextEditingController txtPassword = TextEditingController();

  @override
  void initState() {
    super.initState();
    countryCode = countryCodePicker.countryCodes
        .firstWhere((element) => element.name == "Iraq");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkNotificationPermissionAndShowDialog(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                "Sign In",
                style: TextStyle(
                    color: TColor.primaryText,
                    fontSize: 25,
                    fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 30),
              Text(
                "Mobile Number",
                style: TextStyle(color: TColor.placeholder, fontSize: 14),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () async {
                      final code =
                          await countryCodePicker.showPicker(context: context);
                      if (code != null) {
                        countryCode = code;
                        setState(() {});
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 30,
                          height: 20,
                          child: countryCode.flagImage(),
                        ),
                        Text(
                          "  ${countryCode.dialCode}",
                          style: TextStyle(
                              color: TColor.primaryText, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextField(
                      controller: txtMobile,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        hintText: "0700000000",
                      ),
                    ),
                  )
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              LineTextField(
                title: "Password",
                hintText: "******",
                controller: txtPassword,
                obscureText: true,
                right: IconButton(
                  onPressed: () {},
                  icon: Image.asset(
                    "assets/img/password_show.png",
                    width: 25,
                    height: 25,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              RoundButton(
                title: "SIGN IN",
                onPressed: () {
                  if (txtMobile.text.isEmpty || txtPassword.text.isEmpty) {
                    mdShowAlert("Error",
                        "Please enter phone number and password", () {});
                    return;
                  }

                  Globs.showHUD(status: "Signing in...");

                  final loginParams = {
                    "user_type": "1", //للمستخدم =1 //للسائق =2
                    "mobile_code": countryCode.dialCode,
                    "mobile": txtMobile.text.trim(),
                    "os_type": Platform.isAndroid ? "a" : "i",
                    "push_token": Globs.onSignalToken ?? "",
                    "socket_id": "",
                  };

                  ServiceCall.post(
                    loginParams,
                    SVKey.svLogin,
                    withSuccess: (responseObj) async {
                      Globs.hideHUD();

                      if (responseObj[KKey.status] == "1" &&
                          (responseObj[KKey.payload] != null &&
                              responseObj[KKey.payload]["user_id"] != null)) {
                        var payload = responseObj[KKey.payload] ?? {};

                        Globs.udSet(payload, Globs.userPayload);
                        Globs.udBoolSet(true, Globs.userLogin);
                        Globs.udStringSet(
                            payload[KKey.authToken] ?? "", KKey.authToken);

                        ServiceCall.userObj = payload;
                        ServiceCall.userType =
                            int.tryParse("${payload["user_type"]}") ?? 1;

                        SocketManager.shared.updateSocketIdApi();

                        // ✅ هنا نقرر الصفحة حسب نوع المستخدم:
                        if (ServiceCall.userType == 1) {
                          // المستخدم العادي
                          context.push(const UserHomeView());
                        } else {
                          // السائق
                          context.push(const HomeView());
                        }
                      } else if (responseObj[KKey.status] == "2") {
                        Globs.hideHUD();
                        mdShowAlert(
                          "Login Faijjjled",
                          "This number is not registered. Please create an account first.",
                          () {},
                        );
                      } else {
                        mdShowAlert(
                          "Login Failssssed",
                          //responseObj[KKey.message] ?? "Something went wrong",
                          "خطا حبيبي ماعندك حساب",
                          () {},
                        );
                      }
                    },
                    failure: (error) async {
                      Globs.hideHUD();
                      mdShowAlert("Error", "Network error: $error", () {});
                    },
                  );
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "FORGOT PASSWORD",
                      style: TextStyle(
                        color: TColor.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
