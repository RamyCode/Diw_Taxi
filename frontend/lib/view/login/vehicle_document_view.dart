import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:taxi_app/common/color_extension.dart';
import 'package:taxi_app/common/common_extension.dart';
import 'package:taxi_app/common/globs.dart';
import 'package:taxi_app/common/service_call.dart';
import 'package:taxi_app/common_widget/document_row.dart';
import 'package:taxi_app/common_widget/image_picker_view.dart';
import 'package:taxi_app/common_widget/popup_layout.dart';
import 'package:http/http.dart' as http;

class VehicleDocumentUploadView extends StatefulWidget {
  final Map obj;
  const VehicleDocumentUploadView({super.key, required this.obj});

  @override
  State<VehicleDocumentUploadView> createState() =>
      _VehicleDocumentUploadViewState();
}

class _VehicleDocumentUploadViewState extends State<VehicleDocumentUploadView> {
  List documentList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    apiList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
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
          "Vehicle Document",
          style: TextStyle(
              color: TColor.primaryText,
              fontSize: 25,
              fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 30,
              ),
              ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    var dObj = documentList[index] as Map? ?? {};
                    return DocumentRow(
                      dObj: dObj,
                      onPressed: () {},
                      onInfo: () {
                        showModalBottomSheet(
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            context: context,
                            builder: (context) {
                              return Container(
                                width: context.width,
                                height: context.height - 100,
                                margin: const EdgeInsets.symmetric(
                                    vertical: 46, horizontal: 20),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 20),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Colors.black12, blurRadius: 3),
                                    ]),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dObj["name"] as String? ?? "",
                                      style: TextStyle(
                                          color: TColor.primaryText,
                                          fontSize: 23,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: Text(
                                          "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged.\n\n It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.\n\n It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.leap into electronic typesetting, remaining essentially unchanged.\n\n It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.\n\n It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
                                          style: TextStyle(
                                            color: TColor.secondaryText,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            context.pop();
                                          },
                                          child: Text(
                                            "OKAY",
                                            style: TextStyle(
                                                color: TColor.primary,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              );
                            });
                      },
                      onUpload: () async {
                        await Navigator.push(context, PopupLayout(
                            child: ImagePickerView(didSelect: (imagePath) {
                          var image = File(imagePath);

                          apiUploadDoc({
                            "doc_id": dObj["doc_id"].toString(),
                            "zone_doc_id": dObj["zone_doc_id"].toString(),
                            "user_car_id": widget.obj["user_car_id"].toString(),
                            "expriry_date": DateTime.now()
                                .add(const Duration(days: 365))
                                .stringFormat()
                          }, {
                            'image': image
                          });
                        })));
                      },
                      onAction: () {},
                    );
                  },
                  itemCount: documentList.length),
              const SizedBox(
                height: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }

  //TODO: ApiCalling
  void apiList() {
    Globs.showHUD();
    ServiceCall.post(
      {"user_car_id": widget.obj["user_car_id"].toString()},
      SVKey.svCarDocumentList,
      isTokenApi: true,
      withSuccess: (responseObj) async {
        Globs.hideHUD();
        if (responseObj[KKey.status] == "1") {
          documentList = responseObj[KKey.payload] as List? ?? [];
          if (mounted) {
            setState(() {});
          }
        } else {
          mdShowAlert(
              "Error", responseObj[KKey.message] as String? ?? MSG.fail, () {});
        }
      },
      failure: (error) async {
        Globs.hideHUD();
        mdShowAlert("Error", error.toString(), () {});
      },
    );
  }

  void apiUploadDoc(
      Map<String, String> parameter, Map<String, File> imgObj) async {
    var request =
        http.MultipartRequest('POST', Uri.parse(SVKey.svDriverUploadDocument));
    request.headers['Authorization'] =
        "Bearer ${Globs.udValue(Globs.userPayload)['auth_token']}";

    parameter.forEach((key, value) {
      request.fields[key] = value;
    });

    var file =
        await http.MultipartFile.fromPath('image', imgObj['image']!.path);
    request.files.add(file);

    Globs.showHUD(status: "Uploading...");

    try {
      var response = await request.send();
      Globs.hideHUD();

      if (response.statusCode == 200) {
        var body = await response.stream.bytesToString();
        var jsonResponse = json.decode(body);
        if (jsonResponse[KKey.status] == "1") {
          mdShowAlert("Success", jsonResponse[KKey.message], () {});
          apiList();
        } else {
          mdShowAlert("Error", jsonResponse[KKey.message], () {});
        }
      } else {
        mdShowAlert(
            "Error", "Upload failed with code ${response.statusCode}", () {});
      }
    } catch (e) {
      Globs.hideHUD();
      mdShowAlert("Error", e.toString(), () {});
    }
  }
}
