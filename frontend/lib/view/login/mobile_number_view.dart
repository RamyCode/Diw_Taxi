import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:taxi_app/common/color_extension.dart';
import 'package:taxi_app/common_widget/round_button.dart';
import 'package:taxi_app/view/login/otp_view.dart';

class MobileNumberView extends StatefulWidget {
  const MobileNumberView({super.key});

  @override
  State<MobileNumberView> createState() => _MobileNumberViewState();
}

class _MobileNumberViewState extends State<MobileNumberView> {
  FlCountryCodePicker countryCodePicker = const FlCountryCodePicker();
  TextEditingController txtMobile = TextEditingController();
  late CountryCode countryCode;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    countryCode = countryCodePicker.countryCodes
        .firstWhere((element) => element.name == "Iraq");
  }

  @override
/*************  ✨ Codeium Command ⭐  *************/
  /// Builds the UI for the mobile number input screen, allowing users to
  /// select their country code and enter their mobile number. It also
  /// provides options to login as a driver or user, and includes terms
  /// and conditions and privacy policy notices. When a country is tapped,
  /// a country code picker is displayed. The login buttons navigate
  /// to the OTP verification screen with the entered mobile number.

/******  787a7f6d-2a1d-40bc-842f-6a007eae327d  *******/
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter mobile number",
              style: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 25,
                  fontWeight: FontWeight.w800),
            ),
            const SizedBox(
              height: 30,
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
                        style:
                            TextStyle(color: TColor.primaryText, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                Expanded(
                  child: TextField(
                    controller: txtMobile,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      hintText: "9876543210",
                    ),
                  ),
                )
              ],
            ),
            const Divider(),
            const SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "By continuing, I confirm that i have read & agree to the",
                  style: TextStyle(
                    color: TColor.secondaryText,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Terms & conditions",
                  style: TextStyle(
                    color: TColor.primaryText,
                    fontSize: 11,
                  ),
                ),
                Text(
                  " and ",
                  style: TextStyle(
                    color: TColor.secondaryText,
                    fontSize: 11,
                  ),
                ),
                Text(
                  "Privacy policy",
                  style: TextStyle(
                    color: TColor.primaryText,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            RoundButton(
              onPressed: () {
                context.push(OTPView(
                    number: txtMobile.text, code: countryCode.dialCode));
              },
              title: "Login AS Driver",
            ),
            const SizedBox(
              height: 15,
            ),
            RoundButton(
              onPressed: () {
                context.push(OTPView(
                  number: txtMobile.text,
                  code: countryCode.dialCode,
                  isDriver: false,
                ));
              },
              title: "Login AS USER",
            )
          ],
        ),
      ),
    );
  }
}
