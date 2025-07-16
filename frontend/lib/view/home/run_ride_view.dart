// import 'dart:ui';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
// import 'package:taxi_app/common/color_extension.dart';
// import 'package:taxi_app/common/common_extension.dart';
// import 'package:taxi_app/common/globs.dart';
// import 'package:taxi_app/common/location_helper.dart';
// import 'package:taxi_app/common/service_call.dart';
// import 'package:taxi_app/common/socket_manager.dart';
// import 'package:taxi_app/common_widget/icon_title_button.dart';
// import 'package:taxi_app/common_widget/round_button.dart';
// import 'package:taxi_app/view/home/support/support_message_view.dart';

// class RunRideView extends StatefulWidget {
//   final Map rObj;
//   const RunRideView({super.key, required this.rObj});

//   @override
//   State<RunRideView> createState() => _RunRideViewState();
// }

// const bsPending = 0;
// const bsAccept = 1;
// const bsGoUser = 2;
// const bsWaitUser = 3;
// const bsStart = 4;
// const bsComplete = 5;
// const bsCancel = 6;

// class _RunRideViewState extends State<RunRideView> with OSMMixinObserver {
//   bool isOpen = true;

//   Map rideObj = {};

//   TextEditingController txtOTP = TextEditingController();
//   TextEditingController txtToll = TextEditingController();

//   //1 = Accept Ride
//   //2 = Start
//   //4 = Complete

//   late MapController controller;
//   //23.02756018230479, 72.58131973941731
//   //23.02726396414328, 72.5851928489523

//   String timeCount = "...";
//   String km = "...";
//   double ratingVal = 5.0;
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();

//     rideObj = widget.rObj;

//     if (rideObj["booking_status"] < bsStart) {
//       controller = MapController(
//         initPosition: GeoPoint(
//             latitude: double.tryParse(rideObj["pickup_lat"].toString()) ?? 0.0,
//             longitude:
//                 double.tryParse(rideObj["pickup_long"].toString()) ?? 0.0),
//       );
//     } else {
//       controller = MapController(
//         initPosition: GeoPoint(
//             latitude: double.tryParse(rideObj["drop_lat"].toString()) ?? 0.0,
//             longitude: double.tryParse(rideObj["drop_long"].toString()) ?? 0.0),
//       );
//     }

//     controller.addObserver(this);

//     SocketManager.shared.socket?.on("user_cancel_ride", (data) {
//       print("user_cancel_ride socket get : ${data.toString()}");
//       if (data[KKey.status] == "1") {
//         if (data[KKey.payload]["booking_id"] == rideObj["booking_id"]) {
//           openUserRideCancelPopup();
//         }
//       }
//     });
//   }

//   void openUserRideCancelPopup() async {
//     mdShowAlert("Ride Cancel", "User cancel ride", () {
//       context.pop();
//     }, isForce: true);
//   }

//   @override
//   void dispose() {
//     // TODO: implement dispose
//     super.dispose();
//     controller.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     var showPickUp = rideObj["booking_status"] < bsStart;

//     return Scaffold(
//       body: Stack(
//         children: [
//           OSMFlutter(
//             controller: controller,
//             osmOption: OSMOption(
//                 enableRotationByGesture: true,
//                 zoomOption: const ZoomOption(
//                   initZoom: 15,
//                   minZoomLevel: 3,
//                   maxZoomLevel: 19,
//                   stepZoom: 1.0,
//                 ),
//                 staticPoints: [],
//                 roadConfiguration: const RoadOption(
//                   roadColor: Colors.blueAccent,
//                 ),
//                 markerOption: MarkerOption(
//                   defaultMarker: const MarkerIcon(
//                     icon: Icon(
//                       Icons.person_pin_circle,
//                       color: Colors.blue,
//                       size: 56,
//                     ),
//                   ),
//                 ),
//                 showDefaultInfoWindow: false),
//             onMapIsReady: (isReady) {
//               if (isReady) {
//                 print("map is ready");
//               }
//             },
//             onLocationChanged: (myLocation) {
//               print("user location :$myLocation");
//             },
//             onGeoPointClicked: (myLocation) {
//               print("GeoPointClicked location :$myLocation");
//             },
//           ),
//           if (rideObj["booking_status"] != bsComplete)
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 if (rideObj["booking_status"] == bsWaitUser)
//                   // Ride Arrived Status
//                   Container(
//                     margin: const EdgeInsets.all(20),
//                     padding: const EdgeInsets.symmetric(
//                         vertical: 10, horizontal: 25),
//                     decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(50),
//                         boxShadow: const [
//                           BoxShadow(
//                             color: Colors.black12,
//                             blurRadius: 10,
//                             offset: Offset(0, -5),
//                           ),
//                         ]),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Stack(
//                           alignment: Alignment.bottomCenter,
//                           children: [
//                             TimerCountdown(
//                               format: CountDownTimerFormat.minutesSeconds,
//                               endTime: DateTime.now().add(
//                                 const Duration(
//                                   minutes: 2,
//                                 ),
//                               ),
//                               onEnd: () {
//                                 print("Timer finished");
//                               },
//                               timeTextStyle: TextStyle(
//                                 color: TColor.secondary,
//                                 fontWeight: FontWeight.w800,
//                                 fontSize: 25,
//                               ),
//                               colonsTextStyle: TextStyle(
//                                 color: TColor.secondary,
//                                 fontWeight: FontWeight.w800,
//                                 fontSize: 25,
//                               ),
//                               spacerWidth: 0,
//                               daysDescription: "",
//                               hoursDescription: "",
//                               minutesDescription: "",
//                               secondsDescription: "",
//                             ),
//                             Text(
//                               "Waiting for rider",
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 color: TColor.secondaryText,
//                                 fontSize: 16,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 // if (rideObj["booking_status"] == bsStart)
//                 //   // Ride Started Status
//                 //   Container(
//                 //     margin: const EdgeInsets.all(20),
//                 //     padding: const EdgeInsets.symmetric(
//                 //         vertical: 10, horizontal: 25),
//                 //     decoration: BoxDecoration(
//                 //         color: Colors.white,
//                 //         borderRadius: BorderRadius.circular(50),
//                 //         boxShadow: const [
//                 //           BoxShadow(
//                 //             color: Colors.black12,
//                 //             blurRadius: 10,
//                 //             offset: Offset(0, -5),
//                 //           ),
//                 //         ]),
//                 //     child: Column(
//                 //       mainAxisSize: MainAxisSize.min,
//                 //       children: [
//                 //         Stack(
//                 //           alignment: Alignment.bottomCenter,
//                 //           children: [
//                 //             TimerCountdown(
//                 //               format: CountDownTimerFormat.minutesSeconds,
//                 //               endTime: DateTime.now().add(
//                 //                 const Duration(
//                 //                   minutes: 2,
//                 //                 ),
//                 //               ),
//                 //               onEnd: () {
//                 //                 print("Timer finished");
//                 //               },
//                 //               timeTextStyle: TextStyle(
//                 //                 color: TColor.secondary,
//                 //                 fontWeight: FontWeight.w800,
//                 //                 fontSize: 25,
//                 //               ),
//                 //               colonsTextStyle: TextStyle(
//                 //                 color: TColor.secondary,
//                 //                 fontWeight: FontWeight.w800,
//                 //                 fontSize: 25,
//                 //               ),
//                 //               spacerWidth: 0,
//                 //               daysDescription: "",
//                 //               hoursDescription: "",
//                 //               minutesDescription: "",
//                 //               secondsDescription: "",
//                 //             ),
//                 //             Text(
//                 //               "Arrived at dropoff",
//                 //               textAlign: TextAlign.center,
//                 //               style: TextStyle(
//                 //                 color: TColor.secondaryText,
//                 //                 fontSize: 16,
//                 //               ),
//                 //             ),
//                 //           ],
//                 //         ),
//                 //       ],
//                 //     ),
//                 //   ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(vertical: 15),
//                   decoration: const BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.only(
//                           topLeft: Radius.circular(10),
//                           topRight: Radius.circular(10)),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black12,
//                           blurRadius: 10,
//                           offset: Offset(0, -5),
//                         ),
//                       ]),
//                   child: Column(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 15),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             IconButton(
//                               onPressed: () {
//                                 setState(() {
//                                   isOpen = !isOpen;
//                                 });
//                               },
//                               icon: Image.asset(
//                                 isOpen
//                                     ? "assets/img/open_btn.png"
//                                     : "assets/img/close_btn.png",
//                                 width: 15,
//                                 height: 15,
//                               ),
//                             ),
//                             Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Text(
//                                   "$timeCount min",
//                                   style: TextStyle(
//                                       color: TColor.primaryText,
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.w800),
//                                 ),
//                                 const SizedBox(
//                                   width: 15,
//                                 ),
//                                 ClipRRect(
//                                   borderRadius: BorderRadius.circular(17.5),
//                                   child: CachedNetworkImage(
//                                     imageUrl: rideObj["image"] as String? ?? "",
//                                     width: 35,
//                                     height: 35,
//                                     fit: BoxFit.contain,
//                                   ),
//                                 ),
//                                 const SizedBox(
//                                   width: 15,
//                                 ),
//                                 Text(
//                                   "$km km",
//                                   style: TextStyle(
//                                       color: TColor.primaryText,
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.w800),
//                                 ),
//                               ],
//                             ),
//                             IconButton(
//                               onPressed: () {},
//                               icon: Image.asset(
//                                 "assets/img/call.png",
//                                 width: 30,
//                                 height: 30,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Text(
//                         "${statusName()} ${rideObj["name"] ?? ""}",
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           color: TColor.secondaryText,
//                           fontSize: 16,
//                         ),
//                       ),
//                       if (isOpen)
//                         const SizedBox(
//                           height: 8,
//                         ),
//                       if (isOpen)
//                         const Divider(
//                           height: 0.5,
//                           endIndent: 20,
//                           indent: 20,
//                         ),
//                       if (isOpen)
//                         const SizedBox(
//                           height: 8,
//                         ),
//                       if (isOpen &&
//                           (rideObj["booking_status"] == bsWaitUser ||
//                               rideObj["booking_status"] == bsStart))
//                         Padding(
//                           padding: const EdgeInsets.all(15),
//                           child: Row(
//                             children: [
//                               ClipRRect(
//                                 borderRadius: BorderRadius.circular(5),
//                                 child: CachedNetworkImage(
//                                   imageUrl: rideObj["image"] as String? ?? "",
//                                   width: 50,
//                                   height: 50,
//                                   fit: BoxFit.contain,
//                                 ),
//                               ),
//                               const SizedBox(
//                                 width: 15,
//                               ),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Text(
//                                           rideObj["name"] as String? ?? "",
//                                           style: const TextStyle(
//                                               fontSize: 16,
//                                               fontWeight: FontWeight.w700),
//                                         ),
//                                         Text(
//                                           statusText(),
//                                           style: TextStyle(
//                                               color: statusColor(),
//                                               fontSize: 20,
//                                               fontWeight: FontWeight.w700),
//                                         ),
//                                       ],
//                                     ),
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Text(
//                                           "${rideObj["mobile_code"] as String? ?? ""} ${rideObj["mobile"] as String? ?? ""}",
//                                           style: TextStyle(
//                                               color: TColor.secondaryText,
//                                               fontSize: 14),
//                                         ),
//                                         Text(
//                                           (rideObj["payment_type"] ?? 1) == 1
//                                               ? "COD"
//                                               : "Online",
//                                           style: TextStyle(
//                                             color: TColor.secondaryText,
//                                             fontSize: 20,
//                                             fontWeight: FontWeight.w700,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               )
//                             ],
//                           ),
//                         ),
//                       if (isOpen &&
//                           (rideObj["booking_status"] == bsWaitUser ||
//                               rideObj["booking_status"] == bsStart))
//                         const Divider(
//                           height: 0.5,
//                           endIndent: 20,
//                           indent: 20,
//                         ),
//                       if (isOpen &&
//                           (rideObj["booking_status"] == bsWaitUser ||
//                               rideObj["booking_status"] == bsStart))
//                         const SizedBox(
//                           height: 8,
//                         ),
//                       if (isOpen)
//                         Padding(
//                           padding: const EdgeInsets.all(15),
//                           child: Row(
//                             children: [
//                               ClipRRect(
//                                 borderRadius: BorderRadius.circular(5),
//                                 child: CachedNetworkImage(
//                                   imageUrl: rideObj["icon"] as String? ?? "",
//                                   width: 50,
//                                   height: 50,
//                                   fit: BoxFit.contain,
//                                 ),
//                               ),
//                               const SizedBox(
//                                 width: 15,
//                               ),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       "${rideObj["brand_name"] as String? ?? ""} - ${rideObj["model_name"] as String? ?? ""} - ${rideObj["series_name"] as String? ?? ""}",
//                                       style: const TextStyle(
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.w700),
//                                     ),
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Text(
//                                           "No Plat: ${rideObj["car_number"] as String? ?? ""}",
//                                           style: TextStyle(
//                                               color: TColor.secondaryText,
//                                               fontSize: 14),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               )
//                             ],
//                           ),
//                         ),
//                       if (isOpen)
//                         const Divider(
//                           height: 0.5,
//                           endIndent: 20,
//                           indent: 20,
//                         ),
//                       if (isOpen)
//                         const SizedBox(
//                           height: 8,
//                         ),
//                       if (isOpen)
//                         Row(
//                           children: [
//                             Expanded(
//                               child: IconTitleButton(
//                                 icon: "assets/img/chat.png",
//                                 title: "Chat",
//                                 onPressed: () {
//                                   context.push(SupportMessageView(uObj: {
//                                     "user_id": rideObj["user_id"],
//                                     "name": rideObj["name"],
//                                     "image": rideObj["image"]
//                                   }));
//                                 },
//                               ),
//                             ),
//                             Expanded(
//                               child: IconTitleButton(
//                                 icon: "assets/img/message.png",
//                                 title: "Message",
//                                 onPressed: () {},
//                               ),
//                             ),
//                             Expanded(
//                               child: IconTitleButton(
//                                 icon: "assets/img/cancel_trip.png",
//                                 title: "Cancel Tip",
//                                 onPressed: () async {
//                                   await showModalBottomSheet(
//                                       backgroundColor: Colors.transparent,
//                                       barrierColor: Colors.transparent,
//                                       isScrollControlled: true,
//                                       context: context,
//                                       builder: (context) {
//                                         return Stack(
//                                             alignment: Alignment.bottomCenter,
//                                             children: [
//                                               BackdropFilter(
//                                                 filter: ImageFilter.blur(
//                                                     sigmaX: 5, sigmaY: 5),
//                                                 child: Container(
//                                                   color: Colors.black38,
//                                                 ),
//                                               ),
//                                               Container(
//                                                 padding:
//                                                     const EdgeInsets.symmetric(
//                                                         vertical: 20,
//                                                         horizontal: 20),
//                                                 decoration: const BoxDecoration(
//                                                     color: Colors.white,
//                                                     borderRadius:
//                                                         BorderRadius.only(
//                                                             topLeft: Radius
//                                                                 .circular(10),
//                                                             topRight:
//                                                                 Radius.circular(
//                                                                     10)),
//                                                     boxShadow: [
//                                                       BoxShadow(
//                                                         color: Colors.black12,
//                                                         blurRadius: 10,
//                                                         offset: Offset(0, -5),
//                                                       ),
//                                                     ]),
//                                                 child: Column(
//                                                   mainAxisSize:
//                                                       MainAxisSize.min,
//                                                   children: [
//                                                     Text(
//                                                       "Cancel ${rideObj["name"] ?? ""} trip?",
//                                                       style: TextStyle(
//                                                           color: TColor
//                                                               .primaryText,
//                                                           fontSize: 18,
//                                                           fontWeight:
//                                                               FontWeight.w800),
//                                                     ),
//                                                     const SizedBox(
//                                                       height: 15,
//                                                     ),
//                                                     const Divider(),
//                                                     const SizedBox(
//                                                       height: 15,
//                                                     ),
//                                                     RoundButton(
//                                                         title: "YES, CANCEL",
//                                                         type:
//                                                             RoundButtonType.red,
//                                                         onPressed: () {
//                                                           context.pop();

//                                                           apiCancelRide();

//                                                           // context.push(
//                                                           //     const ReasonView());
//                                                         }),
//                                                     const SizedBox(
//                                                       height: 15,
//                                                     ),
//                                                     RoundButton(
//                                                         title: "NO",
//                                                         type: RoundButtonType
//                                                             .boarded,
//                                                         onPressed: () {
//                                                           context.pop();
//                                                         }),
//                                                     const SizedBox(
//                                                       height: 15,
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ]);
//                                       });
//                                 },
//                               ),
//                             ),
//                           ],
//                         ),
//                       const SizedBox(
//                         height: 15,
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 20),
//                         child: RoundButton(
//                             title: rideObj["booking_status"] == bsGoUser
//                                 ? "ARRIVED"
//                                 : rideObj["booking_status"] == bsWaitUser
//                                     ? "START"
//                                     : "COMPLETE",
//                             onPressed: () async {
//                               if (rideObj["booking_status"] == bsGoUser) {
//                                 // Api Calling Waiting For User
//                                 apiWaitingForUser();
//                               } else if (rideObj["booking_status"] ==
//                                   bsWaitUser) {
//                                 await showDialog(
//                                     context: context,
//                                     barrierColor: const Color(0xff32384D)
//                                         .withOpacity(0.4),
//                                     builder: (context) {
//                                       return Dialog(
//                                         shape: RoundedRectangleBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(10)),
//                                         child: Container(
//                                           padding: const EdgeInsets.all(15),
//                                           width: context.width - 50,
//                                           height: 190,
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Text(
//                                                 "Enter OTP",
//                                                 textAlign: TextAlign.center,
//                                                 style: TextStyle(
//                                                     color: TColor.primaryText,
//                                                     fontSize: 23,
//                                                     fontWeight:
//                                                         FontWeight.w600),
//                                               ),
//                                               Text(
//                                                 "Please enter OTP",
//                                                 textAlign: TextAlign.center,
//                                                 style: TextStyle(
//                                                     color: TColor.secondaryText,
//                                                     fontSize: 8),
//                                               ),
//                                               TextField(
//                                                 controller: txtOTP,
//                                                 keyboardType:
//                                                     TextInputType.number,
//                                                 style: TextStyle(
//                                                   color: TColor.primaryText,
//                                                   fontSize: 16,
//                                                 ),
//                                                 decoration: InputDecoration(
//                                                   enabledBorder:
//                                                       InputBorder.none,
//                                                   focusedBorder:
//                                                       InputBorder.none,
//                                                   hintText: "----",
//                                                   hintStyle: TextStyle(
//                                                     color: TColor.secondaryText,
//                                                     fontSize: 16,
//                                                   ),
//                                                 ),
//                                               ),
//                                               const Divider(),
//                                               Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment.end,
//                                                 children: [
//                                                   TextButton(
//                                                     onPressed: () {
//                                                       context.pop();
//                                                     },
//                                                     child: Text(
//                                                       "CANCEL",
//                                                       textAlign:
//                                                           TextAlign.center,
//                                                       style: TextStyle(
//                                                           color: TColor.red,
//                                                           fontSize: 16,
//                                                           fontWeight:
//                                                               FontWeight.w600),
//                                                     ),
//                                                   ),
//                                                   TextButton(
//                                                     onPressed: () async {
//                                                       apiRideStart(); // استدعاء الدالة أولًا وانتظارها
//                                                       context
//                                                           .pop(); // ثم إغلاق الحوار بعد نجاحها أو حتى دائماً
//                                                     },
//                                                     child: Text(
//                                                       "RIDE START",
//                                                       textAlign:
//                                                           TextAlign.center,
//                                                       style: TextStyle(
//                                                           color: TColor.primary,
//                                                           fontSize: 16,
//                                                           fontWeight:
//                                                               FontWeight.w600),
//                                                     ),
//                                                   )
//                                                 ],
//                                               )
//                                             ],
//                                           ),
//                                         ),
//                                       );
//                                     });
//                               } else if (rideObj["booking_status"] == bsStart) {
//                                 await showDialog(
//                                     context: context,
//                                     barrierColor: const Color(0xff32384D)
//                                         .withOpacity(0.4),
//                                     builder: (context) {
//                                       return Dialog(
//                                         shape: RoundedRectangleBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(10)),
//                                         child: Container(
//                                           padding: const EdgeInsets.all(15),
//                                           width: context.width - 50,
//                                           height: 190,
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Text(
//                                                 "Enter Toll Amount",
//                                                 textAlign: TextAlign.center,
//                                                 style: TextStyle(
//                                                     color: TColor.primaryText,
//                                                     fontSize: 23,
//                                                     fontWeight:
//                                                         FontWeight.w600),
//                                               ),
//                                               Text(
//                                                 "Please enter toll amount",
//                                                 textAlign: TextAlign.center,
//                                                 style: TextStyle(
//                                                     color: TColor.secondaryText,
//                                                     fontSize: 8),
//                                               ),
//                                               TextField(
//                                                 controller: txtToll,
//                                                 keyboardType:
//                                                     TextInputType.number,
//                                                 style: TextStyle(
//                                                   color: TColor.primaryText,
//                                                   fontSize: 16,
//                                                 ),
//                                                 decoration: InputDecoration(
//                                                   enabledBorder:
//                                                       InputBorder.none,
//                                                   focusedBorder:
//                                                       InputBorder.none,
//                                                   hintText: "\$0",
//                                                   hintStyle: TextStyle(
//                                                     color: TColor.secondaryText,
//                                                     fontSize: 16,
//                                                   ),
//                                                 ),
//                                               ),
//                                               const Divider(),
//                                               Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment.end,
//                                                 children: [
//                                                   TextButton(
//                                                     onPressed: () {
//                                                       context.pop();
//                                                     },
//                                                     child: Text(
//                                                       "CANCEL",
//                                                       textAlign:
//                                                           TextAlign.center,
//                                                       style: TextStyle(
//                                                           color: TColor.red,
//                                                           fontSize: 16,
//                                                           fontWeight:
//                                                               FontWeight.w600),
//                                                     ),
//                                                   ),
//                                                   TextButton(
//                                                     onPressed: () {
//                                                       context.pop();
//                                                       apiRideStop();
//                                                     },
//                                                     child: Text(
//                                                       "DONE",
//                                                       textAlign:
//                                                           TextAlign.center,
//                                                       style: TextStyle(
//                                                           color: TColor.primary,
//                                                           fontSize: 16,
//                                                           fontWeight:
//                                                               FontWeight.w600),
//                                                     ),
//                                                   )
//                                                 ],
//                                               )
//                                             ],
//                                           ),
//                                         ),
//                                       );
//                                     });
//                               }
//                             }),
//                       ),
//                       const SizedBox(
//                         height: 25,
//                       ),
//                     ],
//                   ),
//                 )
//               ],
//             )
//           else
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.symmetric(vertical: 15),
//                   decoration: const BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.only(
//                           topLeft: Radius.circular(10),
//                           topRight: Radius.circular(10)),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black12,
//                           blurRadius: 10,
//                           offset: Offset(0, -5),
//                         ),
//                       ]),
//                   child: Column(
//                     children: [
//                       const SizedBox(
//                         height: 15,
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 15),
//                         child: Text(
//                           "How was your rider?",
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                               color: TColor.primaryText, fontSize: 18),
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 15,
//                       ),
//                       Text(
//                         rideObj["name"] as String? ?? "",
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           color: TColor.primaryText,
//                           fontSize: 25,
//                           fontWeight: FontWeight.w800,
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 8,
//                       ),
//                       RatingBar.builder(
//                         initialRating: ratingVal,
//                         minRating: 1,
//                         direction: Axis.horizontal,
//                         allowHalfRating: true,
//                         itemCount: 5,
//                         itemPadding:
//                             const EdgeInsets.symmetric(horizontal: 4.0),
//                         itemBuilder: (context, _) => const Icon(
//                           Icons.star,
//                           color: Colors.amber,
//                         ),
//                         onRatingUpdate: (rating) {
//                           ratingVal = rating;
//                           print(rating);
//                         },
//                       ),
//                       const SizedBox(
//                         height: 30,
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 20),
//                         child: RoundButton(
//                             title: "RATE RIDER",
//                             onPressed: () {
//                               apiSubmitRate();
//                               // context.push(const TipDetailsView());
//                             }),
//                       ),
//                       const SizedBox(
//                         height: 25,
//                       ),
//                     ],
//                   ),
//                 )
//               ],
//             ),
//           SafeArea(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                   child: InkWell(
//                     onTap: () {
//                       context.pop();
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 15, horizontal: 25),
//                       decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(50),
//                           boxShadow: const [
//                             BoxShadow(
//                               color: Colors.black26,
//                               blurRadius: 10,
//                             ),
//                           ]),
//                       child: Row(
//                         children: [
//                           Image.asset(
//                             showPickUp
//                                 ? "assets/img/pickup_pin_1.png"
//                                 : "assets/img/drop_pin_1.png",
//                             width: 30,
//                             height: 30,
//                           ),
//                           const SizedBox(
//                             width: 8,
//                           ),
//                           Expanded(
//                             child: Text(
//                               rideObj[showPickUp
//                                       ? "pickup_address"
//                                       : "drop_address"] as String? ??
//                                   "",
//                               style: TextStyle(
//                                 color: TColor.primaryText,
//                                 fontSize: 15,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   void addMarker() async {
//     await controller.setMarkerOfStaticPoint(
//       id: "pickup",
//       markerIcon: MarkerIcon(
//         iconWidget: Image.asset(
//           "assets/img/pickup_pin.png",
//           width: 80,
//           height: 80,
//         ),
//       ),
//     );

//     await controller.setMarkerOfStaticPoint(
//       id: "dropoff",
//       markerIcon: MarkerIcon(
//         iconWidget: Image.asset(
//           "assets/img/drop_pin.png",
//           width: 80,
//           height: 80,
//         ),
//       ),
//     );

//     loadMapRoad();
//   }

//   void loadMapRoad() async {
//     await controller.clearAllRoads();
//     if (rideObj["booking_status"] == bsGoUser ||
//         rideObj["booking_status"] == bsWaitUser) {
//       // Current to Pickup Location Road Draw
//       await controller.setStaticPosition([
//         GeoPoint(
//             latitude: double.tryParse(rideObj["pickup_lat"].toString()) ?? 0.0,
//             longitude:
//                 double.tryParse(rideObj["pickup_long"].toString()) ?? 0.0)
//       ], "pickup");

//       var roadInfo = await controller.drawRoad(
//           GeoPoint(
//               latitude: LocationHelper.shared().lastLocation?.latitude ?? 0.0,
//               longitude:
//                   LocationHelper.shared().lastLocation?.longitude ?? 0.0),
//           GeoPoint(
//               latitude:
//                   double.tryParse(rideObj["pickup_lat"].toString()) ?? 0.0,
//               longitude:
//                   double.tryParse(rideObj["pickup_long"].toString()) ?? 0.0),
//           roadType: RoadType.car,
//           roadOption: const RoadOption(
//               roadColor: Colors.blueAccent, roadBorderWidth: 3));

//       timeCount = ((roadInfo.duration ?? 0.0) / 60.0).toStringAsFixed(1);
//       km = ((roadInfo.distance ?? 0.0)).toStringAsFixed(1);

//       timeCount = ((roadInfo.duration ?? 0.0) / 60.0).toStringAsFixed(1);
//       km = ((roadInfo.distance ?? 0.0)).toStringAsFixed(1);
//     } else {
//       // Current Location to Drop Off Location Draw Road
//       await controller.setStaticPosition([
//         GeoPoint(
//             latitude: double.tryParse(rideObj["drop_lat"].toString()) ?? 0.0,
//             longitude: double.tryParse(rideObj["drop_long"].toString()) ?? 0.0)
//       ], "dropoff");

//       var roadInfo = await controller.drawRoad(
//           GeoPoint(
//               latitude: LocationHelper.shared().lastLocation?.latitude ?? 0.0,
//               longitude:
//                   LocationHelper.shared().lastLocation?.longitude ?? 0.0),
//           GeoPoint(
//               latitude: double.tryParse(rideObj["drop_lat"].toString()) ?? 0.0,
//               longitude:
//                   double.tryParse(rideObj["drop_long"].toString()) ?? 0.0),
//           roadType: RoadType.car,
//           roadOption: const RoadOption(
//               roadColor: Colors.blueAccent, roadBorderWidth: 3));
//       timeCount = ((roadInfo.duration ?? 0.0) / 60.0).toStringAsFixed(1);
//       km = ((roadInfo.distance ?? 0.0)).toStringAsFixed(1);
//     }

//     if (mounted) {
//       setState(() {});
//     }
//   }

//   @override
//   Future<void> mapIsReady(bool isReady) async {
//     if (isReady) {
//       addMarker();
//     }
//   }

//   //TODO: ApiCalling

//   void apiWaitingForUser() {
//     Globs.showHUD();
//     ServiceCall.post({"booking_id": rideObj["booking_id"].toString()},
//         SVKey.svDriverWaitUser, isTokenApi: true,
//         withSuccess: (responseObj) async {
//       Globs.hideHUD();

//       if (responseObj[KKey.status] == "1") {
//         rideObj = responseObj[KKey.payload] as Map? ?? {};
//         if (mounted) {
//           setState(() {});
//         }
//       } else {
//         mdShowAlert(Globs.appName,
//             responseObj[KKey.message] as String? ?? MSG.fail, () {});
//       }
//     }, failure: (err) async {
//       Globs.hideHUD();
//       mdShowAlert(Globs.appName, err.toString(), () {});
//     });
//   }

//   void apiCancelRide() {
//     Globs.showHUD();
//     ServiceCall.post({
//       "booking_id": rideObj["booking_id"].toString(),
//       "booking_status": rideObj["booking_status"].toString()
//     }, SVKey.svRideCancel, isTokenApi: true, withSuccess: (responseObj) async {
//       Globs.hideHUD();

//       if (responseObj[KKey.status] == "1") {
//         mdShowAlert(
//             Globs.appName, responseObj[KKey.message] as String? ?? MSG.success,
//             () {
//           context.pop();
//         });
//       } else {
//         mdShowAlert(Globs.appName,
//             responseObj[KKey.message] as String? ?? MSG.fail, () {});
//       }
//     }, failure: (err) async {
//       Globs.hideHUD();
//       mdShowAlert(Globs.appName, err.toString(), () {});
//     });
//   }

//   void apiRideStart() {
//     if (txtOTP.text.length != 4) {
//       mdShowAlert("Error", "Pleas valid OTP", () {});
//       return;
//     }

//     var startLocation = LocationHelper.shared().lastLocation;

//     if (startLocation == null) {
//       return;
//     }

//     Globs.showHUD();
//     ServiceCall.post({
//       "booking_id": rideObj["booking_id"].toString(),
//       "pickup_latitude": "${startLocation.latitude}",
//       "pickup_longitude": "${startLocation.longitude}",
//       "otp_code": txtOTP.text
//     }, SVKey.svRideStart, isTokenApi: true, withSuccess: (responseObj) async {
//       Globs.hideHUD();

//       if (responseObj[KKey.status] == "1") {
//         rideObj = responseObj[KKey.payload] as Map? ?? {};
//         LocationHelper.shared().startRideLocationSave(
//             rideObj["booking_id"] as int? ?? 0, startLocation);
//         loadMapRoad();
//       } else {
//         mdShowAlert(Globs.appName,
//             responseObj[KKey.message] as String? ?? MSG.fail, () {});
//       }
//     }, failure: (err) async {
//       Globs.hideHUD();
//       mdShowAlert(Globs.appName, err.toString(), () {});
//     });
//   }

//   void apiRideStop() {
//     var endLocation = LocationHelper.shared().lastLocation;

//     if (endLocation == null) {
//       return;
//     }
//     LocationHelper.shared().stopRideLocationSave();
//     Globs.showHUD();
//     ServiceCall.post({
//       "booking_id": rideObj["booking_id"].toString(),
//       "drop_latitude": "${endLocation.latitude}",
//       "drop_longitude": "${endLocation.longitude}",
//       "ride_location": LocationHelper.shared()
//           .getRideSaveLocationJsonString(rideObj["booking_id"] as int? ?? 0),
//       "toll_tax": txtToll.text == "" ? "0" : txtToll.text
//     }, SVKey.svRideStop, isTokenApi: true, withSuccess: (responseObj) async {
//       Globs.hideHUD();

//       if (responseObj[KKey.status] == "1") {
//         rideObj = responseObj[KKey.payload] as Map? ?? {};
//         if (mounted) {
//           setState(() {});
//         }

//         mdShowAlert("Ride Completed",
//             responseObj[KKey.message] as String? ?? MSG.success, () {});
//       } else {
//         mdShowAlert(Globs.appName,
//             responseObj[KKey.message] as String? ?? MSG.fail, () {});
//       }
//     }, failure: (err) async {
//       Globs.hideHUD();
//       mdShowAlert(Globs.appName, err.toString(), () {});
//     });
//   }

//   void apiSubmitRate() {
//     Globs.showHUD();
//     ServiceCall.post(
//       {
//         "booking_id": rideObj["booking_id"].toString(),
//         "rating": ratingVal.toString(),
//         "comment": "",
//       },
//       SVKey.svRideRating,
//       isTokenApi: true,
//       withSuccess: (responseObj) async {
//         Globs.hideHUD();
//         if (responseObj[KKey.status] == "1") {
//           mdShowAlert(Globs.appName,
//               responseObj[KKey.message] as String? ?? MSG.success, () {
//             context.pop();
//           });
//         } else {
//           mdShowAlert(Globs.appName,
//               responseObj[KKey.message] as String? ?? MSG.fail, () {});
//         }
//       },
//       failure: (err) async {
//         Globs.hideHUD();
//         mdShowAlert(Globs.appName, err.toString(), () {});
//       },
//     );
//   }

//   String statusName() {
//     switch (rideObj["booking_status"]) {
//       case 2:
//         return "Pickup Up ";
//       case 3:
//         return "Waiting For ";
//       case 4:
//         return "Ride Started With";
//       case 5:
//         return "Ride Complete With";
//       case 6:
//         return "Ride Cancel";
//       default:
//         return "Finding Driver Near By";
//     }
//   }

//   String statusText() {
//     switch (rideObj["booking_status"]) {
//       case 2:
//         return "On Way";
//       case 3:
//         return "Waiting";
//       case 4:
//         return "Started";
//       case 5:
//         return "Completed";
//       case 6:
//         return "Cancel";
//       case 7:
//         return "No Drivers";
//       default:
//         return "Pending";
//     }
//   }

//   Color statusColor() {
//     switch (rideObj["booking_status"]) {
//       case 2:
//         return Colors.green;
//       case 3:
//         return Colors.orange;
//       case 4:
//         return Colors.green;
//       case 5:
//         return Colors.green;
//       case 6:
//         return Colors.red;
//       case 7:
//         return Colors.red;
//       default:
//         return Colors.blue;
//     }
//   }
// }

import 'dart:convert';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' as latlong;
import 'package:taxi_app/common/color_extension.dart';
import 'package:taxi_app/common/common_extension.dart';
import 'package:taxi_app/common/globs.dart';
import 'package:taxi_app/common/location_helper.dart';
import 'package:taxi_app/common/service_call.dart';
import 'package:taxi_app/common/socket_manager.dart';
import 'package:taxi_app/common_widget/icon_title_button.dart';
import 'package:taxi_app/common_widget/round_button.dart';
import 'package:taxi_app/view/home/support/support_message_view.dart';

class RunRideView extends StatefulWidget {
  final Map rObj;
  const RunRideView({super.key, required this.rObj});

  @override
  State<RunRideView> createState() => _RunRideViewState();
}

const bsPending = 0;
const bsAccept = 1;
const bsGoUser = 2;
const bsWaitUser = 3;
const bsStart = 4;
const bsComplete = 5;
const bsCancel = 6;

class _RunRideViewState extends State<RunRideView> {
  bool isOpen = true;
  Map rideObj = {};
  TextEditingController txtOTP = TextEditingController();
  TextEditingController txtToll = TextEditingController();

  late final MapController mapController;
  final List<Marker> markers = [];
  final List<Polyline> polylines = [];

  String timeCount = "...";
  String km = "...";
  double ratingVal = 5.0;

  // API Keys
  final String openRouteServiceApiKey =
      'eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6ImM2ZGM3YTdjNmY2NDRjYjk4NjljMDk4MTU5M2Y1NDkyIiwiaCI6Im11cm11cjY0In0=';
  final String flutterMapApiKey = 'prpYpgEFoJMbwQZoCR3I';

  @override
  void initState() {
    super.initState();
    rideObj = widget.rObj;

    // Initialize map controller
    mapController = MapController();
    _initializeMapPosition();

    SocketManager.shared.socket?.on("user_cancel_ride", (data) {
      if (data[KKey.status] == "1" &&
          data[KKey.payload]["booking_id"] == rideObj["booking_id"]) {
        openUserRideCancelPopup();
      }
    });
  }

  void _initializeMapPosition() {
    final initialPosition = rideObj["booking_status"] < bsStart
        ? latlong.LatLng(
            double.tryParse(rideObj["pickup_lat"].toString()) ?? 0.0,
            double.tryParse(rideObj["pickup_long"].toString()) ?? 0.0)
        : latlong.LatLng(double.tryParse(rideObj["drop_lat"].toString()) ?? 0.0,
            double.tryParse(rideObj["drop_long"].toString()) ?? 0.0);

    mapController.move(initialPosition, 15.0);
  }

  void openUserRideCancelPopup() {
    mdShowAlert("Ride Cancel", "User cancel ride", () {
      context.pop();
    }, isForce: true);
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var showPickUp = rideObj["booking_status"] < bsStart;

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              center: rideObj["booking_status"] < bsStart
                  ? latlong.LatLng(
                      double.tryParse(rideObj["pickup_lat"].toString()) ?? 0.0,
                      double.tryParse(rideObj["pickup_long"].toString()) ?? 0.0)
                  : latlong.LatLng(
                      double.tryParse(rideObj["drop_lat"].toString()) ?? 0.0,
                      double.tryParse(rideObj["drop_long"].toString()) ?? 0.0),
              zoom: 15.0,
              onMapReady: () => addMarker(),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.taxi_app',
              ),
              MarkerLayer(markers: markers),
              PolylineLayer(polylines: polylines),
            ],
          ),

          // Top Address Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: InkWell(
                onTap: () => context.pop(),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 10)
                    ],
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        showPickUp
                            ? "assets/img/pickup_pin_1.png"
                            : "assets/img/drop_pin_1.png",
                        width: 30,
                        height: 30,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          rideObj[showPickUp
                                  ? "pickup_address"
                                  : "drop_address"] as String? ??
                              "",
                          style: TextStyle(
                              color: TColor.primaryText, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom Panel
          if (rideObj["booking_status"] != bsComplete)
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (rideObj["booking_status"] == bsWaitUser)
                  _buildTimerWidget(),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, -5))
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildTopBar(),
                      if (isOpen)
                        const Divider(height: 0.5, indent: 20, endIndent: 20),
                      if (isOpen) const SizedBox(height: 8),
                      if (isOpen &&
                          (rideObj["booking_status"] == bsWaitUser ||
                              rideObj["booking_status"] == bsStart))
                        _buildRiderInfo(),
                      if (isOpen &&
                          (rideObj["booking_status"] == bsWaitUser ||
                              rideObj["booking_status"] == bsStart))
                        const Divider(height: 0.5, indent: 20, endIndent: 20),
                      if (isOpen) _buildCarInfo(),
                      if (isOpen)
                        const Divider(height: 0.5, indent: 20, endIndent: 20),
                      if (isOpen) _buildActionButtons(),
                      const SizedBox(height: 15),
                      _buildMainActionButton(),
                      const SizedBox(height: 25),
                    ],
                  ),
                ),
              ],
            )
          else
            _buildRatingPanel(),
        ],
      ),
    );
  }

  Widget _buildTimerWidget() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              TimerCountdown(
                format: CountDownTimerFormat.minutesSeconds,
                endTime: DateTime.now().add(const Duration(minutes: 2)),
                onEnd: () => print("Timer finished"),
                timeTextStyle: TextStyle(
                    color: TColor.secondary,
                    fontWeight: FontWeight.w800,
                    fontSize: 25),
                colonsTextStyle: TextStyle(
                    color: TColor.secondary,
                    fontWeight: FontWeight.w800,
                    fontSize: 25),
                spacerWidth: 0,
                daysDescription: "",
                hoursDescription: "",
                minutesDescription: "",
                secondsDescription: "",
              ),
              Text(
                "Waiting for rider",
                textAlign: TextAlign.center,
                style: TextStyle(color: TColor.secondaryText, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => setState(() => isOpen = !isOpen),
            icon: Image.asset(
              isOpen ? "assets/img/open_btn.png" : "assets/img/close_btn.png",
              width: 15,
              height: 15,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("$timeCount min",
                  style: TextStyle(
                      color: TColor.primaryText,
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),
              const SizedBox(width: 15),
              ClipRRect(
                borderRadius: BorderRadius.circular(17.5),
                child: CachedNetworkImage(
                  imageUrl: rideObj["image"] as String? ?? "",
                  width: 35,
                  height: 35,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 15),
              Text("$km km",
                  style: TextStyle(
                      color: TColor.primaryText,
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),
            ],
          ),
          IconButton(
            onPressed: () {}, // Call functionality
            icon: Image.asset("assets/img/call.png", width: 30, height: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildRiderInfo() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: CachedNetworkImage(
              imageUrl: rideObj["image"] as String? ?? "",
              width: 50,
              height: 50,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(rideObj["name"] as String? ?? "",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    Text(statusText(),
                        style: TextStyle(
                            color: statusColor(),
                            fontSize: 20,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        "${rideObj["mobile_code"] as String? ?? ""} ${rideObj["mobile"] as String? ?? ""}",
                        style: TextStyle(
                            color: TColor.secondaryText, fontSize: 14)),
                    Text((rideObj["payment_type"] ?? 1) == 1 ? "COD" : "Online",
                        style: TextStyle(
                            color: TColor.secondaryText,
                            fontSize: 20,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCarInfo() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: CachedNetworkImage(
              imageUrl: rideObj["icon"] as String? ?? "",
              width: 50,
              height: 50,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    "${rideObj["brand_name"] as String? ?? ""} - ${rideObj["model_name"] as String? ?? ""} - ${rideObj["series_name"] as String? ?? ""}",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("No Plat: ${rideObj["car_number"] as String? ?? ""}",
                        style: TextStyle(
                            color: TColor.secondaryText, fontSize: 14)),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: IconTitleButton(
            icon: "assets/img/chat.png",
            title: "Chat",
            onPressed: () {
              context.push(SupportMessageView(uObj: {
                "user_id": rideObj["user_id"],
                "name": rideObj["name"],
                "image": rideObj["image"]
              }));
            },
          ),
        ),
        Expanded(
          child: IconTitleButton(
            icon: "assets/img/message.png",
            title: "Message",
            onPressed: () {},
          ),
        ),
        Expanded(
          child: IconTitleButton(
            icon: "assets/img/cancel_trip.png",
            title: "Cancel Tip",
            onPressed: () => _showCancelConfirmationDialog(),
          ),
        ),
      ],
    );
  }

  Widget _buildMainActionButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: RoundButton(
        title: rideObj["booking_status"] == bsGoUser
            ? "ARRIVED"
            : rideObj["booking_status"] == bsWaitUser
                ? "START"
                : "COMPLETE",
        onPressed: () {
          if (rideObj["booking_status"] == bsGoUser) {
            apiWaitingForUser();
          } else if (rideObj["booking_status"] == bsWaitUser) {
            _showOtpDialog();
          } else if (rideObj["booking_status"] == bsStart) {
            _showTollDialog();
          }
        },
      ),
    );
  }

  Widget _buildRatingPanel() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  "How was your rider?",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: TColor.primaryText, fontSize: 18),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                rideObj["name"] as String? ?? "",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              RatingBar.builder(
                initialRating: ratingVal,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) =>
                    const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (rating) => setState(() => ratingVal = rating),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: RoundButton(
                  title: "RATE RIDER",
                  onPressed: () => apiSubmitRate(),
                ),
              ),
              const SizedBox(height: 25),
            ],
          ),
        )
      ],
    );
  }

  void _showCancelConfirmationDialog() async {
    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.black38),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -5))
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Cancel ${rideObj["name"] ?? ""} trip?",
                    style: TextStyle(
                        color: TColor.primaryText,
                        fontSize: 18,
                        fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 15),
                  const Divider(),
                  const SizedBox(height: 15),
                  RoundButton(
                    title: "YES, CANCEL",
                    type: RoundButtonType.red,
                    onPressed: () {
                      context.pop();
                      apiCancelRide();
                    },
                  ),
                  const SizedBox(height: 15),
                  RoundButton(
                    title: "NO",
                    type: RoundButtonType.boarded,
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showOtpDialog() async {
    await showDialog(
      context: context,
      barrierColor: const Color(0xff32384D).withOpacity(0.4),
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Container(
            padding: const EdgeInsets.all(15),
            width: context.width - 50,
            height: 190,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Enter OTP",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: TColor.primaryText,
                      fontSize: 23,
                      fontWeight: FontWeight.w600),
                ),
                Text(
                  "Please enter OTP",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: TColor.secondaryText, fontSize: 8),
                ),
                TextField(
                  controller: txtOTP,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: TColor.primaryText, fontSize: 16),
                  decoration: InputDecoration(
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: "----",
                    hintStyle:
                        TextStyle(color: TColor.secondaryText, fontSize: 16),
                  ),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => context.pop(),
                      child: Text(
                        "CANCEL",
                        style: TextStyle(
                            color: TColor.red,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        apiRideStart();
                        context.pop();
                      },
                      child: Text(
                        "RIDE START",
                        style: TextStyle(
                            color: TColor.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTollDialog() async {
    await showDialog(
      context: context,
      barrierColor: const Color(0xff32384D).withOpacity(0.4),
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Container(
            padding: const EdgeInsets.all(15),
            width: context.width - 50,
            height: 190,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Enter Toll Amount",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: TColor.primaryText,
                      fontSize: 23,
                      fontWeight: FontWeight.w600),
                ),
                Text(
                  "Please enter toll amount",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: TColor.secondaryText, fontSize: 8),
                ),
                TextField(
                  controller: txtToll,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: TColor.primaryText, fontSize: 16),
                  decoration: InputDecoration(
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: "\$0",
                    hintStyle:
                        TextStyle(color: TColor.secondaryText, fontSize: 16),
                  ),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => context.pop(),
                      child: Text(
                        "CANCEL",
                        style: TextStyle(
                            color: TColor.red,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.pop();
                        apiRideStop();
                      },
                      child: Text(
                        "DONE",
                        style: TextStyle(
                            color: TColor.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // MARK: - Map Functions
  void addMarker() {
    markers.clear();

    // Add pickup marker
    markers.add(
      Marker(
        point: latlong.LatLng(
          double.tryParse(rideObj["pickup_lat"].toString()) ?? 0.0,
          double.tryParse(rideObj["pickup_long"].toString()) ?? 0.0,
        ),
        width: 80,
        height: 80,
        child: Image.asset("assets/img/pickup_pin.png", width: 80, height: 80),
      ),
    );

    // Add dropoff marker if ride has started
    if (rideObj["booking_status"] >= bsStart) {
      markers.add(
        Marker(
          point: latlong.LatLng(
            double.tryParse(rideObj["drop_lat"].toString()) ?? 0.0,
            double.tryParse(rideObj["drop_long"].toString()) ?? 0.0,
          ),
          width: 80,
          height: 80,
          child: Image.asset("assets/img/drop_pin.png", width: 80, height: 80),
        ),
      );
    }

    loadMapRoad();
  }

  Future<void> loadMapRoad() async {
    polylines.clear();

    try {
      if (rideObj["booking_status"] == bsGoUser ||
          rideObj["booking_status"] == bsWaitUser) {
        await _drawRouteToPickup();
      } else if (rideObj["booking_status"] >= bsStart) {
        await _drawRouteToDropoff();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error drawing route: $e");
      }
    }
  }

  Future<void> _drawRouteToPickup() async {
    final currentLocation = LocationHelper.shared().lastLocation;
    if (currentLocation == null) return;

    final pickupPoint = latlong.LatLng(
      double.tryParse(rideObj["pickup_lat"].toString()) ?? 0.0,
      double.tryParse(rideObj["pickup_long"].toString()) ?? 0.0,
    );

    final route = await _getRouteFromOpenRouteService(
      latlong.LatLng(currentLocation.latitude, currentLocation.longitude),
      pickupPoint,
    );

    if (route != null) {
      final coordinates = route['geometry']['coordinates'] as List;
      final points = coordinates
          .map((coord) =>
              latlong.LatLng(coord[1].toDouble(), coord[0].toDouble()))
          .toList();

      setState(() {
        polylines.add(Polyline(
          points: points,
          color: Colors.blueAccent,
          strokeWidth: 4,
        ));

        timeCount =
            ((route['properties']['duration'] ?? 0) / 60).toStringAsFixed(1);
        km = ((route['properties']['distance'] ?? 0) / 1000).toStringAsFixed(1);
      });
    }
  }

  Future<void> _drawRouteToDropoff() async {
    final currentLocation = LocationHelper.shared().lastLocation;
    if (currentLocation == null) return;

    final dropPoint = latlong.LatLng(
      double.tryParse(rideObj["drop_lat"].toString()) ?? 0.0,
      double.tryParse(rideObj["drop_long"].toString()) ?? 0.0,
    );

    final route = await _getRouteFromOpenRouteService(
      latlong.LatLng(currentLocation.latitude, currentLocation.longitude),
      dropPoint,
    );

    if (route != null) {
      final coordinates = route['geometry']['coordinates'] as List;
      final points = coordinates
          .map((coord) =>
              latlong.LatLng(coord[1].toDouble(), coord[0].toDouble()))
          .toList();

      setState(() {
        polylines.add(Polyline(
          points: points,
          color: Colors.blueAccent,
          strokeWidth: 4,
        ));

        timeCount =
            ((route['properties']['duration'] ?? 0) / 60).toStringAsFixed(1);
        km = ((route['properties']['distance'] ?? 0) / 1000).toStringAsFixed(1);
      });
    }
  }

  Future<Map<String, dynamic>?> _getRouteFromOpenRouteService(
    latlong.LatLng start,
    latlong.LatLng end,
  ) async {
    final url = Uri.parse(
      'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$openRouteServiceApiKey'
      '&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body)['features'][0];
      } else {
        if (kDebugMode) {
          print('Failed to load route: ${response.statusCode}');
          print('Response: ${response.body}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching route: $e');
      }
      return null;
    }
  }

  // MARK: - API Functions (keep all your existing API methods)
  void apiWaitingForUser() {
    Globs.showHUD();
    ServiceCall.post(
      {"booking_id": rideObj["booking_id"].toString()},
      SVKey.svDriverWaitUser,
      isTokenApi: true,
      withSuccess: (responseObj) async {
        Globs.hideHUD();
        if (responseObj[KKey.status] == "1") {
          setState(() => rideObj = responseObj[KKey.payload] as Map? ?? {});
        } else {
          mdShowAlert(Globs.appName,
              responseObj[KKey.message] as String? ?? MSG.fail, () {});
        }
      },
      failure: (err) async {
        Globs.hideHUD();
        mdShowAlert(Globs.appName, err.toString(), () {});
      },
    );
  }

  void apiCancelRide() {
    Globs.showHUD();
    ServiceCall.post(
      {
        "booking_id": rideObj["booking_id"].toString(),
        "booking_status": rideObj["booking_status"].toString()
      },
      SVKey.svRideCancel,
      isTokenApi: true,
      withSuccess: (responseObj) async {
        Globs.hideHUD();
        if (responseObj[KKey.status] == "1") {
          mdShowAlert(Globs.appName,
              responseObj[KKey.message] as String? ?? MSG.success, () {
            context.pop();
          });
        } else {
          mdShowAlert(Globs.appName,
              responseObj[KKey.message] as String? ?? MSG.fail, () {});
        }
      },
      failure: (err) async {
        Globs.hideHUD();
        mdShowAlert(Globs.appName, err.toString(), () {});
      },
    );
  }

  void apiRideStart() {
    if (txtOTP.text.length != 4) {
      mdShowAlert("Error", "Please enter valid OTP", () {});
      return;
    }

    var startLocation = LocationHelper.shared().lastLocation;
    if (startLocation == null) return;

    Globs.showHUD();
    ServiceCall.post(
      {
        "booking_id": rideObj["booking_id"].toString(),
        "pickup_latitude": "${startLocation.latitude}",
        "pickup_longitude": "${startLocation.longitude}",
        "otp_code": txtOTP.text
      },
      SVKey.svRideStart,
      isTokenApi: true,
      withSuccess: (responseObj) async {
        Globs.hideHUD();
        if (responseObj[KKey.status] == "1") {
          setState(() => rideObj = responseObj[KKey.payload] as Map? ?? {});
          LocationHelper.shared().startRideLocationSave(
              rideObj["booking_id"] as int? ?? 0, startLocation);
          loadMapRoad();
        } else {
          mdShowAlert(Globs.appName,
              responseObj[KKey.message] as String? ?? MSG.fail, () {});
        }
      },
      failure: (err) async {
        Globs.hideHUD();
        mdShowAlert(Globs.appName, err.toString(), () {});
      },
    );
  }

  void apiRideStop() {
    var endLocation = LocationHelper.shared().lastLocation;
    if (endLocation == null) return;

    LocationHelper.shared().stopRideLocationSave();

    Globs.showHUD();
    ServiceCall.post(
      {
        "booking_id": rideObj["booking_id"].toString(),
        "drop_latitude": "${endLocation.latitude}",
        "drop_longitude": "${endLocation.longitude}",
        "ride_location": LocationHelper.shared()
            .getRideSaveLocationJsonString(rideObj["booking_id"] as int? ?? 0),
        "toll_tax": txtToll.text == "" ? "0" : txtToll.text
      },
      SVKey.svRideStop,
      isTokenApi: true,
      withSuccess: (responseObj) async {
        Globs.hideHUD();
        if (responseObj[KKey.status] == "1") {
          setState(() => rideObj = responseObj[KKey.payload] as Map? ?? {});
          mdShowAlert("Ride Completed",
              responseObj[KKey.message] as String? ?? MSG.success, () {});
        } else {
          mdShowAlert(Globs.appName,
              responseObj[KKey.message] as String? ?? MSG.fail, () {});
        }
      },
      failure: (err) async {
        Globs.hideHUD();
        mdShowAlert(Globs.appName, err.toString(), () {});
      },
    );
  }

  void apiSubmitRate() {
    Globs.showHUD();
    ServiceCall.post(
      {
        "booking_id": rideObj["booking_id"].toString(),
        "rating": ratingVal.toString(),
        "comment": "",
      },
      SVKey.svRideRating,
      isTokenApi: true,
      withSuccess: (responseObj) async {
        Globs.hideHUD();
        if (responseObj[KKey.status] == "1") {
          mdShowAlert(Globs.appName,
              responseObj[KKey.message] as String? ?? MSG.success, () {
            context.pop();
          });
        } else {
          mdShowAlert(Globs.appName,
              responseObj[KKey.message] as String? ?? MSG.fail, () {});
        }
      },
      failure: (err) async {
        Globs.hideHUD();
        mdShowAlert(Globs.appName, err.toString(), () {});
      },
    );
  }

  // MARK: - Helper Functions
  String statusName() {
    switch (rideObj["booking_status"]) {
      case 2:
        return "Pickup Up ";
      case 3:
        return "Waiting For ";
      case 4:
        return "Ride Started With";
      case 5:
        return "Ride Complete With";
      case 6:
        return "Ride Cancel";
      default:
        return "Finding Driver Near By";
    }
  }

  String statusText() {
    switch (rideObj["booking_status"]) {
      case 2:
        return "On Way";
      case 3:
        return "Waiting";
      case 4:
        return "Started";
      case 5:
        return "Completed";
      case 6:
        return "Cancel";
      case 7:
        return "No Drivers";
      default:
        return "Pending";
    }
  }

  Color statusColor() {
    switch (rideObj["booking_status"]) {
      case 2:
        return Colors.green;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.green;
      case 5:
        return Colors.green;
      case 6:
        return Colors.red;
      case 7:
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
