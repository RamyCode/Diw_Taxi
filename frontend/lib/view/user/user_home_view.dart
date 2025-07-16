// // ✅ تم التعديل: حساب السعر يتم من السيرفر فقط
// import 'dart:async';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:maps_toolkit/maps_toolkit.dart';
// import 'package:taxi_app/common/color_extension.dart';
// import 'package:taxi_app/common/common_extension.dart';
// import 'package:taxi_app/common/globs.dart';
// import 'package:taxi_app/common/service_call.dart';
// import 'package:taxi_app/common/socket_manager.dart';
// import 'package:taxi_app/common_widget/location_select_button.dart';
// import 'package:taxi_app/common_widget/round_button.dart';
// import 'package:taxi_app/model/price_detail_mode.dart';
// import 'package:taxi_app/model/zone_list_model.dart';
// import 'package:taxi_app/view/menu/menu_view.dart';
// import 'package:taxi_app/view/user/car_service_select_view.dart';
// import 'package:taxi_app/view/user/user_run_ride_view.dart';

// class UserHomeView extends StatefulWidget {
//   const UserHomeView({super.key});

//   @override
//   State<UserHomeView> createState() => _UserHomeViewState();
// }

// class _UserHomeViewState extends State<UserHomeView> {
//   bool isOpen = true;
//   bool isSelectPickup = true;
//   bool isLock = false;
//   bool isLocationChange = true;

//   GeoPoint? pickupLocation;
//   Placemark? pickupAddressObj;
//   String pickupAddressString = "";

//   GeoPoint? dropLocation;
//   Placemark? dropAddressObj;
//   String dropAddressString = "";

//   List<ZoneListModel> zoneListArr = [];
//   ZoneListModel? selectZone;

//   List servicePriceArr = [];

//   double estTimesInMin = 0.0;
//   double estKm = 0.0;

//   MapController controller = MapController(
//     initPosition: GeoPoint(latitude: 31.9752453, longitude: 44.9355841),
//   );

//   Timer? _debounce;
//   GeoPoint? _lastCenterPoint;

//   GeoPoint? _pickupMarkerPoint;
//   GeoPoint? _dropMarkerPoint;

//   @override
//   void initState() {
//     super.initState();
//     changeLocation();

//     controller.listenerRegionIsChanging.addListener(() {
//       if (controller.listenerRegionIsChanging.value != null) {
//         if (isLock && !isLocationChange) {
//           return;
//         }

//         controller.centerMap.then((centerMap) {
//           if (_lastCenterPoint != null) {
//             final distance = _calculateDistance(_lastCenterPoint!, centerMap);
//             if (distance < 0.0001) {
//               return;
//             }
//           }

//           _lastCenterPoint = centerMap;

//           if (_debounce?.isActive ?? false) _debounce?.cancel();

//           _debounce = Timer(const Duration(milliseconds: 600), () {
//             getSelectLocation(isSelectPickup);
//           });
//         });
//       }
//     });

//     SocketManager.shared.socket?.on("user_request_accept", (data) {
//       if (data[KKey.status] == "1") {
//         apiHome();
//       }
//     });

//     apiHome();
//   }

//   @override
//   void dispose() {
//     controller.dispose();
//     _debounce?.cancel();
//     super.dispose();
//   }

//   void changeLocation() async {
//     await Future.delayed(const Duration(milliseconds: 4000));
//     controller
//         .goToLocation(GeoPoint(latitude: 31.9752453, longitude: 44.9355841));
//     zoneListArr = await ZoneListModel.getActiveList();
//   }

//   double _calculateDistance(GeoPoint p1, GeoPoint p2) {
//     final latDiff = (p1.latitude - p2.latitude).abs();
//     final lngDiff = (p1.longitude - p2.longitude).abs();
//     return latDiff + lngDiff;
//   }

//   void getSelectLocation(bool isPickup) async {
//     GeoPoint centerMap = await controller.centerMap;

//     List<Placemark> addressArr =
//         await placemarkFromCoordinates(centerMap.latitude, centerMap.longitude);

//     if (addressArr.isNotEmpty) {
//       if (isPickup) {
//         pickupLocation = centerMap;
//         pickupAddressObj = addressArr.first;
//         pickupAddressString =
//             "${pickupAddressObj?.name}, ${pickupAddressObj?.street}, ${pickupAddressObj?.subLocality}, ${pickupAddressObj?.subAdministrativeArea}, ${pickupAddressObj?.administrativeArea}, ${pickupAddressObj?.postalCode}";
//       } else {
//         dropLocation = centerMap;
//         dropAddressObj = addressArr.first;
//         dropAddressString =
//             "${dropAddressObj?.name}, ${dropAddressObj?.street}, ${dropAddressObj?.subLocality}, ${dropAddressObj?.subAdministrativeArea}, ${dropAddressObj?.administrativeArea}, ${dropAddressObj?.postalCode}";
//       }

//       updateView();
//     }

//     if (isPickup) {
//       selectZone = null;
//       for (var zmObj in zoneListArr) {
//         if (PolygonUtil.containsLocation(
//             LatLng(centerMap.latitude, centerMap.longitude),
//             zmObj.zonePathArr,
//             true)) {
//           selectZone = zmObj;
//           break;
//         }
//       }
//     }

//     drawRoadPickupToDrop();
//   }

//   void drawRoadPickupToDrop() async {
//     await controller.clearAllRoads();

//     if (pickupLocation != null &&
//         dropLocation != null &&
//         pickupLocation?.latitude != dropLocation?.latitude &&
//         pickupLocation?.longitude != dropLocation?.longitude) {
//       RoadInfo roadObj = await controller.drawRoad(
//         pickupLocation!,
//         dropLocation!,
//         roadType: RoadType.car,
//         roadOption: RoadOption(
//           roadColor: TColor.secondary,
//           roadWidth: 10,
//           zoomInto: false,
//         ),
//       );

//       estTimesInMin = (roadObj.duration ?? 0) / 60.0;
//       estKm = roadObj.distance ?? 0.0;

//       if (kDebugMode) {
//         print("EST Duration in Sec : ${roadObj.duration ?? 0.0} sec");
//         print("EST Distance in Km : ${roadObj.distance ?? 0.0} km");
//       }

//       if (selectZone != null) {
//         List<Map<String, dynamic>> priceList = List<Map<String, dynamic>>.from(
//             await PriceDetailModel.getSelectZoneGetServiceAndPriceList(
//                 selectZone!.zoneId));

//         servicePriceArr =
//             priceList.map((e) => Map<String, dynamic>.from(e)).toList();
//       }
//     }
//   }

//   void updateView() {
//     if (mounted) {
//       setState(() {});
//     }
//   }

//   Future<void> addMarkerLocation(GeoPoint point, String icon,
//       {required bool isPickup}) async {
//     if (isPickup && _pickupMarkerPoint != null) {
//       await controller.removeMarker(_pickupMarkerPoint!);
//     } else if (!isPickup && _dropMarkerPoint != null) {
//       await controller.removeMarker(_dropMarkerPoint!);
//     }

//     await controller.addMarker(point,
//         markerIcon: MarkerIcon(
//           iconWidget: Image.asset(
//             icon,
//             width: 100,
//             height: 100,
//           ),
//         ));

//     if (isPickup) {
//       _pickupMarkerPoint = point;
//     } else {
//       _dropMarkerPoint = point;
//     }
//   }

//   Future<void> removeMarkerLocation(GeoPoint point,
//       {required bool isPickup}) async {
//     await controller.removeMarker(point);
//     if (isPickup) {
//       _pickupMarkerPoint = null;
//     } else {
//       _dropMarkerPoint = null;
//     }
//   }

//   Future<void> _showSearchLocationDialog() async {
//     final TextEditingController searchController = TextEditingController();

//     await showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Search Location'),
//           content: TextField(
//             controller: searchController,
//             autofocus: true,
//             decoration: const InputDecoration(
//               hintText: 'Enter location name or address',
//               prefixIcon: Icon(Icons.search),
//             ),
//             onSubmitted: (_) {
//               Navigator.of(context).pop();
//             },
//           ),
//           actions: [
//             TextButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 child: const Text('Cancel')),
//             TextButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 child: const Text('Search')),
//           ],
//         );
//       },
//     );

//     final query = searchController.text.trim();
//     if (query.isEmpty) return;

//     try {
//       List<Location> locations = await locationFromAddress(query);
//       if (locations.isNotEmpty) {
//         final loc = locations.first;
//         GeoPoint geoPoint =
//             GeoPoint(latitude: loc.latitude, longitude: loc.longitude);

//         // اذهب الى الموقع الجديد وحدث عنوانه
//         await controller.goToLocation(geoPoint);

//         List<Placemark> placemarks = await placemarkFromCoordinates(
//             geoPoint.latitude, geoPoint.longitude);

//         if (placemarks.isNotEmpty) {
//           if (isSelectPickup) {
//             pickupLocation = geoPoint;
//             pickupAddressObj = placemarks.first;
//             pickupAddressString =
//                 "${pickupAddressObj?.name}, ${pickupAddressObj?.street}, ${pickupAddressObj?.subLocality}, ${pickupAddressObj?.subAdministrativeArea}, ${pickupAddressObj?.administrativeArea}, ${pickupAddressObj?.postalCode}";
//             await addMarkerLocation(
//                 pickupLocation!, "assets/img/pickup_pin.png",
//                 isPickup: true);
//           } else {
//             dropLocation = geoPoint;
//             dropAddressObj = placemarks.first;
//             dropAddressString =
//                 "${dropAddressObj?.name}, ${dropAddressObj?.street}, ${dropAddressObj?.subLocality}, ${dropAddressObj?.subAdministrativeArea}, ${dropAddressObj?.administrativeArea}, ${dropAddressObj?.postalCode}";
//             await addMarkerLocation(dropLocation!, "assets/img/drop_pin.png",
//                 isPickup: false);
//           }
//           updateView();
//           drawRoadPickupToDrop();
//         }
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print("Error searching location: $e");
//       }
//       mdShowAlert("Error", "Location not found, please try again.", () {});
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         alignment: Alignment.center,
//         children: [
//           OSMFlutter(
//               controller: controller,
//               osmOption: OSMOption(
//                 userTrackingOption: const UserTrackingOption(
//                   enableTracking: false,
//                   unFollowUser: false,
//                 ),
//                 zoomOption: const ZoomOption(
//                   initZoom: 13,
//                   minZoomLevel: 3,
//                   maxZoomLevel: 19,
//                   stepZoom: 1.0,
//                 ),
//                 userLocationMarker: UserLocationMaker(
//                   personMarker: const MarkerIcon(
//                     icon: Icon(
//                       Icons.location_history_rounded,
//                       color: Colors.red,
//                       size: 48,
//                     ),
//                   ),
//                   directionArrowMarker: const MarkerIcon(
//                     icon: Icon(
//                       Icons.double_arrow,
//                       size: 48,
//                     ),
//                   ),
//                 ),
//                 roadConfiguration: const RoadOption(
//                   roadColor: Colors.yellowAccent,
//                 ),
//                 markerOption: MarkerOption(
//                     defaultMarker: const MarkerIcon(
//                   icon: Icon(
//                     Icons.person_pin_circle,
//                     color: Colors.blue,
//                     size: 56,
//                   ),
//                 )),
//               )),
//           Image.asset(
//             isSelectPickup
//                 ? "assets/img/pickup_pin.png"
//                 : "assets/img/drop_pin.png",
//             width: 100,
//             height: 100,
//           ),
//           Column(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     // زر الموقع الحالي
//                     InkWell(
//                       borderRadius: BorderRadius.circular(20),
//                       onTap: () async {
//                         final userLocation = await controller.myLocation();
//                         if (userLocation != null) {
//                           isLocationChange = false;
//                           await controller.goToLocation(userLocation);
//                           isLocationChange = true;
//                         }
//                       },
//                       child: Container(
//                         width: 50,
//                         height: 50,
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(35),
//                             boxShadow: const [
//                               BoxShadow(
//                                 color: Colors.black12,
//                                 blurRadius: 10,
//                                 offset: Offset(0, 5),
//                               ),
//                             ]),
//                         child: Image.asset(
//                           "assets/img/current_location.png",
//                           width: 50,
//                           height: 50,
//                         ),
//                       ),
//                     ),

//                     const SizedBox(width: 10),

//                     // زر بحث عن موقع
//                     InkWell(
//                       borderRadius: BorderRadius.circular(20),
//                       onTap: () async {
//                         await _showSearchLocationDialog();
//                       },
//                       child: Container(
//                         width: 50,
//                         height: 50,
//                         decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(35),
//                             boxShadow: const [
//                               BoxShadow(
//                                 color: Colors.black12,
//                                 blurRadius: 10,
//                                 offset: Offset(0, 5),
//                               ),
//                             ]),
//                         child: const Icon(
//                           Icons.search,
//                           size: 30,
//                           color: Colors.black54,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(
//                 height: 15,
//               ),
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
//                 decoration: const BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(10),
//                         topRight: Radius.circular(10)),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black12,
//                         blurRadius: 10,
//                         offset: Offset(0, -5),
//                       ),
//                     ]),
//                 child: Column(
//                   children: [
//                     LocationSelectButton(
//                         title: "Pickup",
//                         placeholder: "Select Pickup Location",
//                         color: TColor.secondary,
//                         value: pickupAddressString,
//                         isSelect: isSelectPickup,
//                         onPressed: () async {
//                           setState(() {
//                             isSelectPickup = true;
//                           });

//                           if (dropAddressString.isNotEmpty &&
//                               dropLocation != null) {
//                             await addMarkerLocation(
//                                 dropLocation!, "assets/img/drop_pin.png",
//                                 isPickup: false);
//                           }

//                           if (pickupLocation != null) {
//                             isLocationChange = false;
//                             await controller.goToLocation(pickupLocation!);
//                             await Future.delayed(
//                                 const Duration(milliseconds: 500));
//                             isLocationChange = true;

//                             await removeMarkerLocation(pickupLocation!,
//                                 isPickup: true);
//                           }
//                         }),
//                     const SizedBox(
//                       height: 8,
//                     ),
//                     LocationSelectButton(
//                         title: "DropOff",
//                         placeholder: "Select DropOff Location",
//                         color: TColor.primary,
//                         value: dropAddressString,
//                         isSelect: !isSelectPickup,
//                         onPressed: () async {
//                           setState(() {
//                             isSelectPickup = false;
//                           });

//                           if (pickupAddressString.isNotEmpty &&
//                               pickupLocation != null) {
//                             await addMarkerLocation(
//                                 pickupLocation!, "assets/img/pickup_pin.png",
//                                 isPickup: true);
//                           }

//                           if (dropAddressString.isEmpty) {
//                             getSelectLocation(isSelectPickup);
//                           } else {
//                             isLocationChange = false;
//                             await controller.goToLocation(dropLocation!);
//                             isLocationChange = true;
//                             await removeMarkerLocation(dropLocation!,
//                                 isPickup: false);
//                           }
//                         }),
//                     const SizedBox(
//                       height: 20,
//                     ),
//                     RoundButton(
//                         title: "Continue",
//                         onPressed: () {
//                           openCarService();
//                         }),
//                     const SizedBox(
//                       height: 25,
//                     )
//                   ],
//                 ),
//               )
//             ],
//           ),
//           SafeArea(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(15),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       SizedBox(
//                         width: 60,
//                         child: Stack(
//                           alignment: Alignment.bottomLeft,
//                           children: [
//                             InkWell(
//                               onTap: () {
//                                 context.push(const MenuView());
//                               },
//                               child: Container(
//                                 margin: const EdgeInsets.only(left: 10),
//                                 padding: const EdgeInsets.all(2),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(30),
//                                 ),
//                                 child: ClipRRect(
//                                   borderRadius: BorderRadius.circular(20),
//                                   child: Image.asset(
//                                     "assets/img/u1.png",
//                                     width: 40,
//                                     height: 40,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 8, vertical: 1),
//                               decoration: BoxDecoration(
//                                 color: Colors.red,
//                                 borderRadius: BorderRadius.circular(30),
//                               ),
//                               constraints: const BoxConstraints(minWidth: 15),
//                               child: const Text(
//                                 "3",
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 10,
//                                 ),
//                               ),
//                             )
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 )
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   void openCarService() async {
//     if (pickupLocation == null) {
//       mdShowAlert("Select", "Please your pickup location", () {});
//       return;
//     }

//     if (dropLocation == null) {
//       mdShowAlert("Select", "Please your drop off location", () {});
//       return;
//     }

//     if (selectZone == null) {
//       mdShowAlert("", "Not provide any service in this area", () {});
//       return;
//     }

//     if (servicePriceArr.isEmpty) {
//       mdShowAlert("", "Not provide any service in this area", () {});
//       return;
//     }

//     Globs.showHUD();

//     for (var service in servicePriceArr) {
//       try {
//         final estimateResponse = await ServiceCall.postWithResponse({
//           "price_id": service["price_id"].toString(),
//           "zone_id": selectZone!.zoneId.toString(),
//           "service_id": service["service_id"].toString(),
//           "est_total_distance": estKm.toString(),
//           "est_duration": estTimesInMin.toString(),
//         }, SVKey.svEstimateFare, isTokenApi: true);

//         if (estimateResponse[KKey.status] == "1") {
//           service["total_estimated_amount"] = estimateResponse["total_amount"];
//         } else {
//           service["total_estimated_amount"] = "0";
//         }
//       } catch (e) {
//         service["total_estimated_amount"] = "0";
//         debugPrint("Estimate fare error: $e");
//       }
//     }

//     Globs.hideHUD();

//     showModalBottomSheet(
//       backgroundColor: Colors.transparent,
//       context: context,
//       builder: (context) {
//         return CarServiceSelectView(
//           serviceArr: servicePriceArr,
//           didSelect: (selectObj) {
//             if (kDebugMode) {
//               print(selectObj);
//             }

//             apiBookingRequest({
//               "pickup_latitude": "${pickupLocation?.latitude ?? 0.0}",
//               "pickup_longitude": "${pickupLocation?.longitude ?? 0.0}",
//               "pickup_address": pickupAddressString,
//               "drop_latitude": "${dropLocation?.latitude ?? 0.0}",
//               "drop_longitude": "${dropLocation?.longitude ?? 0.0}",
//               "drop_address": dropAddressString,
//               "pickup_date":
//                   DateTime.now().stringFormat(format: "yyyy-MM-dd HH:mm:ss"),
//               "payment_type": "1",
//               "card_id": "",
//               "price_id": selectObj["price_id"].toString(),
//               "service_id": selectObj["service_id"].toString(),
//               "est_total_distance": estKm.toStringAsFixed(2),
//               "est_duration": estTimesInMin.toString(),
//               "amount": selectObj["total_estimated_amount"].toString(),
//             });
//           },
//         );
//       },
//     );
//   }

//   void apiBookingRequest(Map<String, String> parameter) {
//     Globs.showHUD();
//     ServiceCall.post(parameter, SVKey.svBookingRequest, isTokenApi: true,
//         withSuccess: (responseObj) async {
//       Globs.hideHUD();
//       if (responseObj[KKey.status] == "1") {
//         mdShowAlert(Globs.appName,
//             responseObj[KKey.message] as String? ?? MSG.success, () {});
//       } else {
//         mdShowAlert(
//             "Error", responseObj[KKey.message] as String? ?? MSG.fail, () {});
//       }
//     }, failure: (err) async {
//       Globs.hideHUD();
//       debugPrint(err.toString());
//     });
//   }

//   void apiHome() {
//     Globs.showHUD();
//     ServiceCall.post({}, SVKey.svHome, isTokenApi: true,
//         withSuccess: (responseObj) async {
//       Globs.hideHUD();

//       if (responseObj[KKey.status] == "1") {
//         var rObj =
//             (responseObj[KKey.payload] as Map? ?? {})["running"] as Map? ?? {};

//         if (rObj.keys.isNotEmpty) {
//           context.push(UserRunRideView(rObj: rObj));
//         }
//       } else {
//         mdShowAlert(
//             "Error", responseObj[KKey.message] as String? ?? MSG.fail, () {});
//       }
//     }, failure: (error) async {
//       Globs.hideHUD();
//       mdShowAlert(Globs.appName, error.toString(), () {});
//     });
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'package:http/http.dart' as http;
import 'package:taxi_app/common/color_extension.dart';
import 'package:taxi_app/common/common_extension.dart';
import 'package:taxi_app/common/globs.dart';
import 'package:taxi_app/common/service_call.dart';
import 'package:taxi_app/common/socket_manager.dart';
import 'package:taxi_app/common_widget/location_select_button.dart';
import 'package:taxi_app/common_widget/round_button.dart';
import 'package:taxi_app/model/price_detail_mode.dart';
import 'package:taxi_app/model/zone_list_model.dart';
import 'package:taxi_app/view/menu/menu_view.dart';
import 'package:taxi_app/view/user/car_service_select_view.dart';
import 'package:taxi_app/view/user/user_run_ride_view.dart';
import 'package:latlong2/latlong.dart' show LatLng; // لـ flutter_map
import 'package:maps_toolkit/maps_toolkit.dart'
    as maps_toolkit; // للحسابات الجغرافية

class UserHomeView extends StatefulWidget {
  const UserHomeView({super.key});

  @override
  State<UserHomeView> createState() => _UserHomeViewState();
}

class _UserHomeViewState extends State<UserHomeView> {
  bool isOpen = true;
  bool isSelectPickup = true;
  bool isLock = false;
  bool isLocationChange = true;

  LatLng? pickupLocation;
  Placemark? pickupAddressObj;
  String pickupAddressString = "";

  LatLng? dropLocation;
  Placemark? dropAddressObj;
  String dropAddressString = "";

  List<ZoneListModel> zoneListArr = [];
  ZoneListModel? selectZone;

  List servicePriceArr = [];

  double estTimesInMin = 0.0;
  double estKm = 0.0;

  final MapController mapController = MapController();
  final List<Polyline> polylines = [];
  final List<Marker> markers = [];

  Timer? _debounce;
  LatLng? _lastCenterPoint;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _determinePosition().then((_) {
      changeLocation();
    });

    mapController.mapEventStream.listen((event) {
      if (event is MapEventMove && !isLocationChange) {
        return;
      }

      if (event is MapEventMove) {
        final center = mapController.center;
        if (_lastCenterPoint != null) {
          final distance = _calculateDistance(_lastCenterPoint!, center);
          if (distance < 0.0001) {
            return;
          }
        }

        _lastCenterPoint = center;

        if (_debounce?.isActive ?? false) _debounce?.cancel();

        _debounce = Timer(const Duration(milliseconds: 600), () {
          getSelectLocation(isSelectPickup);
        });
      }
    });

    SocketManager.shared.socket?.on("user_request_accept", (data) {
      if (data[KKey.status] == "1") {
        apiHome();
      }
    });

    apiHome();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    _currentPosition = await Geolocator.getCurrentPosition();
  }

  void changeLocation() async {
    await Future.delayed(const Duration(milliseconds: 4000));
    final initialLocation = _currentPosition != null
        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
        : LatLng(31.9752453, 44.9355841);
    mapController.move(initialLocation, 13);
    zoneListArr = await ZoneListModel.getActiveList();
  }

  double _calculateDistance(LatLng p1, LatLng p2) {
    return Geolocator.distanceBetween(
          p1.latitude,
          p1.longitude,
          p2.latitude,
          p2.longitude,
        ) /
        1000;
  }

  void getSelectLocation(bool isPickup) async {
    LatLng centerMap = mapController.center; // LatLng من latlong2

    try {
      List<Placemark> addressArr = await placemarkFromCoordinates(
          centerMap.latitude, centerMap.longitude);

      if (addressArr.isNotEmpty) {
        if (isPickup) {
          pickupLocation = centerMap;
          pickupAddressObj = addressArr.first;
          pickupAddressString =
              "${pickupAddressObj?.name}, ${pickupAddressObj?.street}, ${pickupAddressObj?.subLocality}, ${pickupAddressObj?.subAdministrativeArea}, ${pickupAddressObj?.administrativeArea}, ${pickupAddressObj?.postalCode}";
        } else {
          dropLocation = centerMap;
          dropAddressObj = addressArr.first;
          dropAddressString =
              "${dropAddressObj?.name}, ${dropAddressObj?.street}, ${dropAddressObj?.subLocality}, ${dropAddressObj?.subAdministrativeArea}, ${dropAddressObj?.administrativeArea}, ${dropAddressObj?.postalCode}";
        }

        updateView();
      }

      if (isPickup) {
        selectZone = null;
        for (var zmObj in zoneListArr) {
          // تحويل List<LatLng> إلى List<maps_toolkit.LatLng>
          final zonePath = zmObj.zonePathArr
              .map((p) => maps_toolkit.LatLng(p.latitude, p.longitude))
              .toList();

          if (maps_toolkit.PolygonUtil.containsLocation(
              maps_toolkit.LatLng(centerMap.latitude, centerMap.longitude),
              zonePath,
              true)) {
            selectZone = zmObj;
            break;
          }
        }
      }

      drawRoadPickupToDrop();
    } catch (e) {
      if (kDebugMode) {
        print("Error getting location: $e");
      }
    }
  }

  Future<void> drawRoadPickupToDrop() async {
    polylines.clear();

    if (pickupLocation != null &&
        dropLocation != null &&
        (pickupLocation?.latitude != dropLocation?.latitude ||
            pickupLocation?.longitude != dropLocation?.longitude)) {
      try {
        final route = await getRouteFromOpenRouteService(
          pickupLocation!,
          dropLocation!,
        );

        if (route != null) {
          final coordinates = route['geometry']['coordinates'] as List;
          final points = coordinates
              .map((coord) => LatLng(coord[1].toDouble(), coord[0].toDouble()))
              .toList();

          estTimesInMin = (route['properties']['duration'] ?? 0) / 60.0;
          estKm = (route['properties']['distance'] ?? 0) / 1000.0;

          if (kDebugMode) {
            print(
                "EST Duration in Sec : ${route['properties']['duration'] ?? 0.0} sec");
            print("EST Distance in Km : ${estKm} km");
          }

          setState(() {
            polylines.add(Polyline(
              points: points,
              color: TColor.secondary,
              strokeWidth: 10,
            ));
          });

          if (selectZone != null) {
            List<Map<String, dynamic>> priceList =
                List<Map<String, dynamic>>.from(
                    await PriceDetailModel.getSelectZoneGetServiceAndPriceList(
                        selectZone!.zoneId));

            servicePriceArr =
                priceList.map((e) => Map<String, dynamic>.from(e)).toList();
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error getting route: $e");
        }
      }
    }

    updateMarkers();
  }

  Future<Map<String, dynamic>?> getRouteFromOpenRouteService(
    LatLng start,
    LatLng end,
  ) async {
    const apiKey =
        'eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6ImM2ZGM3YTdjNmY2NDRjYjk4NjljMDk4MTU5M2Y1NDkyIiwiaCI6Im11cm11cjY0In0=';
    final url = Uri.parse(
      'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apiKey&start=${start.longitude},${start.latitude}&end=${end.longitude},${end.latitude}',
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

  void updateView() {
    if (mounted) {
      setState(() {});
    }
  }

  void updateMarkers() {
    markers.clear();

    if (pickupLocation != null) {
      markers.add(Marker(
        point: pickupLocation!,
        width: 80,
        height: 80,
        child: Image.asset(
          // تغيير من builder إلى child
          "assets/img/pickup_pin.png",
          width: 80,
          height: 80,
        ),
      ));
    }

    if (dropLocation != null) {
      markers.add(Marker(
        point: dropLocation!,
        width: 80,
        height: 80,
        child: Image.asset(
          // تغيير من builder إلى child
          "assets/img/drop_pin.png",
          width: 80,
          height: 80,
        ),
      ));
    }

    updateView();
  }

  Future<void> _showSearchLocationDialog() async {
    final TextEditingController searchController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search Location'),
          content: TextField(
            controller: searchController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter location name or address',
              prefixIcon: Icon(Icons.search),
            ),
            onSubmitted: (_) {
              Navigator.of(context).pop();
            },
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel')),
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Search')),
          ],
        );
      },
    );

    final query = searchController.text.trim();
    if (query.isEmpty) return;

    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        LatLng latLng = LatLng(loc.latitude, loc.longitude);

        await mapController.move(latLng, mapController.zoom);

        List<Placemark> placemarks =
            await placemarkFromCoordinates(latLng.latitude, latLng.longitude);

        if (placemarks.isNotEmpty) {
          if (isSelectPickup) {
            pickupLocation = latLng;
            pickupAddressObj = placemarks.first;
            pickupAddressString =
                "${pickupAddressObj?.name}, ${pickupAddressObj?.street}, ${pickupAddressObj?.subLocality}, ${pickupAddressObj?.subAdministrativeArea}, ${pickupAddressObj?.administrativeArea}, ${pickupAddressObj?.postalCode}";
          } else {
            dropLocation = latLng;
            dropAddressObj = placemarks.first;
            dropAddressString =
                "${dropAddressObj?.name}, ${dropAddressObj?.street}, ${dropAddressObj?.subLocality}, ${dropAddressObj?.subAdministrativeArea}, ${dropAddressObj?.administrativeArea}, ${dropAddressObj?.postalCode}";
          }
          updateView();
          drawRoadPickupToDrop();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error searching location: $e");
      }
      mdShowAlert("Error", "Location not found, please try again.", () {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              center: _currentPosition != null
                  ? LatLng(
                      _currentPosition!.latitude, _currentPosition!.longitude)
                  : LatLng(31.9752453, 44.9355841),
              zoom: 13.0,
              minZoom: 3.0,
              maxZoom: 19.0,
              onMapReady: () {
                // Map is ready
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://api.maptiler.com/maps/0197fa01-8fcc-7d3f-be31-57ccc562bee7/style.json?key=prpYpgEFoJMbwQZoCR3I',
                userAgentPackageName: 'com.example.taxi_app',
              ),
              PolylineLayer(polylines: polylines),
              MarkerLayer(markers: markers),
            ],
          ),
          if (isSelectPickup)
            Image.asset(
              "assets/img/pickup_pin.png",
              width: 40,
              height: 40,
            )
          else
            Image.asset(
              "assets/img/drop_pin.png",
              width: 40,
              height: 40,
            ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Current location button
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () async {
                        if (_currentPosition != null) {
                          isLocationChange = false;
                          await mapController.move(
                              LatLng(_currentPosition!.latitude,
                                  _currentPosition!.longitude),
                              mapController.zoom);
                          isLocationChange = true;
                        }
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(35),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ]),
                        child: Image.asset(
                          "assets/img/current_location.png",
                          width: 50,
                          height: 50,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Search location button
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () async {
                        await _showSearchLocationDialog();
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(35),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ]),
                        child: const Icon(
                          Icons.search,
                          size: 30,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -5),
                      ),
                    ]),
                child: Column(
                  children: [
                    LocationSelectButton(
                        title: "Pickup",
                        placeholder: "Select Pickup Location",
                        color: TColor.secondary,
                        value: pickupAddressString,
                        isSelect: isSelectPickup,
                        onPressed: () async {
                          setState(() {
                            isSelectPickup = true;
                          });

                          if (pickupLocation != null) {
                            isLocationChange = false;
                            mapController.move(
                                pickupLocation!, mapController.zoom);
                            await Future.delayed(
                                const Duration(milliseconds: 500));
                            isLocationChange = true;
                          }
                        }),
                    const SizedBox(height: 8),
                    LocationSelectButton(
                        title: "DropOff",
                        placeholder: "Select DropOff Location",
                        color: TColor.primary,
                        value: dropAddressString,
                        isSelect: !isSelectPickup,
                        onPressed: () async {
                          setState(() {
                            isSelectPickup = false;
                          });

                          if (dropAddressString.isEmpty) {
                            getSelectLocation(isSelectPickup);
                          } else {
                            isLocationChange = false;
                            if (dropLocation != null) {
                              mapController.move(
                                  dropLocation!, mapController.zoom);
                            }
                            isLocationChange = true;
                          }
                        }),
                    const SizedBox(height: 20),
                    RoundButton(
                        title: "Continue",
                        onPressed: () {
                          openCarService();
                        }),
                    const SizedBox(height: 25)
                  ],
                ),
              )
            ],
          ),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 60,
                        child: Stack(
                          alignment: Alignment.bottomLeft,
                          children: [
                            InkWell(
                              onTap: () {
                                context.push(const MenuView());
                              },
                              child: Container(
                                margin: const EdgeInsets.only(left: 10),
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.asset(
                                    "assets/img/u1.png",
                                    width: 40,
                                    height: 40,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              constraints: const BoxConstraints(minWidth: 15),
                              child: const Text(
                                "3",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void openCarService() async {
    if (pickupLocation == null) {
      mdShowAlert("Select", "Please your pickup location", () {});
      return;
    }

    if (dropLocation == null) {
      mdShowAlert("Select", "Please your drop off location", () {});
      return;
    }

    if (selectZone == null) {
      mdShowAlert("", "Not provide any service in this area", () {});
      return;
    }

    if (servicePriceArr.isEmpty) {
      mdShowAlert("", "Not provide any service in this area", () {});
      return;
    }

    Globs.showHUD();

    for (var service in servicePriceArr) {
      try {
        final estimateResponse = await ServiceCall.postWithResponse({
          "price_id": service["price_id"].toString(),
          "zone_id": selectZone!.zoneId.toString(),
          "service_id": service["service_id"].toString(),
          "est_total_distance": estKm.toString(),
          "est_duration": estTimesInMin.toString(),
        }, SVKey.svEstimateFare, isTokenApi: true);

        if (estimateResponse[KKey.status] == "1") {
          service["total_estimated_amount"] = estimateResponse["total_amount"];
        } else {
          service["total_estimated_amount"] = "0";
        }
      } catch (e) {
        service["total_estimated_amount"] = "0";
        debugPrint("Estimate fare error: $e");
      }
    }

    Globs.hideHUD();

    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return CarServiceSelectView(
          serviceArr: servicePriceArr,
          didSelect: (selectObj) {
            if (kDebugMode) {
              print(selectObj);
            }

            apiBookingRequest({
              "pickup_latitude": "${pickupLocation?.latitude ?? 0.0}",
              "pickup_longitude": "${pickupLocation?.longitude ?? 0.0}",
              "pickup_address": pickupAddressString,
              "drop_latitude": "${dropLocation?.latitude ?? 0.0}",
              "drop_longitude": "${dropLocation?.longitude ?? 0.0}",
              "drop_address": dropAddressString,
              "pickup_date":
                  DateTime.now().stringFormat(format: "yyyy-MM-dd HH:mm:ss"),
              "payment_type": "1",
              "card_id": "",
              "price_id": selectObj["price_id"].toString(),
              "service_id": selectObj["service_id"].toString(),
              "est_total_distance": estKm.toStringAsFixed(2),
              "est_duration": estTimesInMin.toString(),
              "amount": selectObj["total_estimated_amount"].toString(),
            });
          },
        );
      },
    );
  }

  void apiBookingRequest(Map<String, String> parameter) {
    Globs.showHUD();
    ServiceCall.post(parameter, SVKey.svBookingRequest, isTokenApi: true,
        withSuccess: (responseObj) async {
      Globs.hideHUD();
      if (responseObj[KKey.status] == "1") {
        mdShowAlert(Globs.appName,
            responseObj[KKey.message] as String? ?? MSG.success, () {});
      } else {
        mdShowAlert(
            "Error", responseObj[KKey.message] as String? ?? MSG.fail, () {});
      }
    }, failure: (err) async {
      Globs.hideHUD();
      debugPrint(err.toString());
    });
  }

  void apiHome() {
    Globs.showHUD();
    ServiceCall.post({}, SVKey.svHome, isTokenApi: true,
        withSuccess: (responseObj) async {
      Globs.hideHUD();

      if (responseObj[KKey.status] == "1") {
        var rObj =
            (responseObj[KKey.payload] as Map? ?? {})["running"] as Map? ?? {};

        if (rObj.keys.isNotEmpty) {
          context.push(UserRunRideView(rObj: rObj));
        }
      } else {
        mdShowAlert(
            "Error", responseObj[KKey.message] as String? ?? MSG.fail, () {});
      }
    }, failure: (error) async {
      Globs.hideHUD();
      mdShowAlert(Globs.appName, error.toString(), () {});
    });
  }
}
