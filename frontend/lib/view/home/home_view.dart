// import 'package:flutter/material.dart';
// import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
// import 'package:taxi_app/common/color_extension.dart';
// import 'package:taxi_app/common/common_extension.dart';
// import 'package:taxi_app/common/globs.dart';
// import 'package:taxi_app/common/location_helper.dart';
// import 'package:taxi_app/common/service_call.dart';
// import 'package:taxi_app/common/socket_manager.dart';
// import 'package:taxi_app/common_widget/Icon_title_subtitle_button.dart';
// import 'package:taxi_app/view/home/run_ride_view.dart';
// import 'package:taxi_app/view/home/tip_request_view.dart';
// import 'package:taxi_app/view/menu/menu_view.dart';

// class HomeView extends StatefulWidget {
//   const HomeView({super.key});

//   @override
//   State<HomeView> createState() => _HomeViewState();
// }

// class _HomeViewState extends State<HomeView> {
//   bool isOpen = true;

//   bool isDriverOnline = false;

//   MapController controller = MapController(
//     initPosition: GeoPoint(latitude: 47.4358055, longitude: 8.4737324),
//   );

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();

//     apiHome();
//     isDriverOnline = Globs.udValueBool("is_online");

//     if (ServiceCall.userType == 2) {
//       LocationHelper.shared().startInit();

//       // Received Message In Socket On Event
//       SocketManager.shared.socket?.on("new_ride_request", (data) async {
//         print("new_ride_request socket get :${data.toString()} ");
//         if (data[KKey.status] == "1") {
//           var bArr = data[KKey.payload] as List? ?? [];

//           if (mounted && bArr.isNotEmpty) {
//             await context.push(TipRequestView(bObj: bArr[0]));
//             apiHome();
//           }
//         }
//       });
//     }
//   }

//   @override
//   void dispose() {
//     // TODO: implement dispose
//     super.dispose();
//     controller.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           OSMFlutter(
//               controller: controller,
//               osmOption: OSMOption(
//                 userTrackingOption: const UserTrackingOption(
//                   enableTracking: true,
//                   unFollowUser: false,
//                 ),
//                 zoomOption: const ZoomOption(
//                   initZoom: 8,
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
//           Column(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     const SizedBox(
//                       width: 50,
//                       height: 50,
//                     ),
//                     InkWell(
//                       borderRadius: BorderRadius.circular(35),
//                       onTap: () {
//                         isDriverOnline = !isDriverOnline;

//                         apiGoOnline();
//                         //context.push(const TipRequestView());
//                       },
//                       child: Stack(
//                         alignment: Alignment.center,
//                         children: [
//                           Container(
//                             width: 70,
//                             height: 70,
//                             decoration: BoxDecoration(
//                                 color: isDriverOnline
//                                     ? TColor.red
//                                     : TColor.primary,
//                                 borderRadius: BorderRadius.circular(35),
//                                 boxShadow: const [
//                                   BoxShadow(
//                                     color: Colors.black12,
//                                     blurRadius: 10,
//                                     offset: Offset(0, 5),
//                                   ),
//                                 ]),
//                           ),
//                           Container(
//                             width: 60,
//                             height: 60,
//                             decoration: BoxDecoration(
//                               border:
//                                   Border.all(color: Colors.white, width: 1.5),
//                               borderRadius: BorderRadius.circular(35),
//                             ),
//                             alignment: Alignment.center,
//                             child: Text(
//                               isDriverOnline ? "OFF" : "GO",
//                               style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 22,
//                                   fontWeight: FontWeight.w800),
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                     InkWell(
//                       borderRadius: BorderRadius.circular(20),
//                       onTap: () {},
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
//                   ],
//                 ),
//               ),
//               const SizedBox(
//                 height: 15,
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(vertical: 15),
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
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         IconButton(
//                           onPressed: () {
//                             setState(() {
//                               isOpen = !isOpen;
//                             });
//                           },
//                           icon: Image.asset(
//                             isOpen
//                                 ? "assets/img/open_btn.png"
//                                 : "assets/img/close_btn.png",
//                             width: 15,
//                             height: 15,
//                           ),
//                         ),
//                         Text(
//                           isDriverOnline ? "You're online" : "You're offline",
//                           style: TextStyle(
//                               color: TColor.primaryText,
//                               fontSize: 18,
//                               fontWeight: FontWeight.w800),
//                         ),
//                         const SizedBox(
//                           width: 50,
//                           height: 50,
//                         ),
//                       ],
//                     ),
//                     if (isOpen)
//                       Container(
//                         height: 0.5,
//                         width: double.maxFinite,
//                         color: TColor.placeholder.withOpacity(0.5),
//                       ),
//                     if (isOpen)
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Expanded(
//                             child: IconTitleSubtitleButton(
//                                 title: "95.0%",
//                                 subtitle: "Acceptance",
//                                 icon: "assets/img/acceptance.png",
//                                 onPressed: () {}),
//                           ),
//                           Container(
//                             height: 100,
//                             width: 0.5,
//                             color: TColor.placeholder.withOpacity(0.5),
//                           ),
//                           Expanded(
//                             child: IconTitleSubtitleButton(
//                                 title: "4.75",
//                                 subtitle: "Rating",
//                                 icon: "assets/img/rate.png",
//                                 onPressed: () {}),
//                           ),
//                           Container(
//                             height: 100,
//                             width: 0.5,
//                             color: TColor.placeholder.withOpacity(0.5),
//                           ),
//                           Expanded(
//                             child: IconTitleSubtitleButton(
//                                 title: "2.0%",
//                                 subtitle: "Cancelleation",
//                                 icon: "assets/img/cancelleation.png",
//                                 onPressed: () {}),
//                           ),
//                         ],
//                       ),
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
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const SizedBox(
//                         width: 60,
//                       ),
//                       Container(
//                           padding: const EdgeInsets.symmetric(
//                               vertical: 8, horizontal: 25),
//                           decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(30),
//                               boxShadow: const [
//                                 BoxShadow(
//                                   color: Colors.black26,
//                                   blurRadius: 10,
//                                 ),
//                               ]),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 "\$",
//                                 style: TextStyle(
//                                     color: TColor.secondary,
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w800),
//                               ),
//                               const SizedBox(
//                                 width: 8,
//                               ),
//                               Text(
//                                 "157.75",
//                                 style: TextStyle(
//                                     color: TColor.primaryText,
//                                     fontSize: 25,
//                                     fontWeight: FontWeight.w800),
//                               ),
//                             ],
//                           )),
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

//   //MARK: ApiCalling
//   void apiGoOnline() {
//     Globs.showHUD();
//     ServiceCall.post(
//         {"is_online": isDriverOnline ? "1" : "0"}, SVKey.svDriverGoOnline,
//         isTokenApi: true, withSuccess: (responseObj) async {
//       Globs.hideHUD();

//       if (responseObj[KKey.status] == "1") {
//         Globs.udBoolSet(isDriverOnline, "is_online");

//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//             content:
//                 Text(responseObj[KKey.message] as String? ?? MSG.success)));

//         if (mounted) {
//           setState(() {});
//         }
//       } else {
//         isDriverOnline = !isDriverOnline;
//         mdShowAlert(
//             "Error", responseObj[KKey.message] as String? ?? MSG.fail, () {});
//       }
//     }, failure: (error) async {
//       Globs.hideHUD();
//       mdShowAlert(Globs.appName, error.toString(), () {});
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
//           context.push(RunRideView(rObj: rObj));
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
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:taxi_app/common/color_extension.dart';
import 'package:taxi_app/common/common_extension.dart';
import 'package:taxi_app/common/globs.dart';
import 'package:taxi_app/common/location_helper.dart';
import 'package:taxi_app/common/service_call.dart';
import 'package:taxi_app/common/socket_manager.dart';
import 'package:taxi_app/view/home/mapbox_helper.dart';
import 'package:taxi_app/common_widget/Icon_title_subtitle_button.dart';

import 'package:taxi_app/view/home/run_ride_view.dart';
import 'package:taxi_app/view/home/tip_request_view.dart';
import 'package:taxi_app/view/menu/menu_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  bool isOpen = true;
  bool isDriverOnline = false;
  final MapController mapController = MapController();
  late final List<Marker> markers = [];
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  String currentMapStyle = MapboxHelper.streets;

  // إحداثيات بغداد، العراق
  static const double defaultLat = 33.3152;
  static const double defaultLng = 44.3661;

  @override
  void initState() {
    super.initState();

    // تهيئة Mapbox
    MapboxState.initialize();
    currentMapStyle = MapboxState.currentStyle;

    // إعداد الرسوم المتحركة
    _setupAnimations();

    // تهيئة الواجهة
    _initializeUI();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.repeat(reverse: true);
    _slideController.forward();
  }

  void _initializeUI() {
    apiHome();
    isDriverOnline = Globs.udValueBool("is_online");

    if (ServiceCall.userType == 2) {
      LocationHelper.shared().startInit();

      SocketManager.shared.socket?.on("new_ride_request", (data) async {
        print("🚗 New ride request received: ${data.toString()}");
        if (data[KKey.status] == "1") {
          var bArr = data[KKey.payload] as List? ?? [];

          if (mounted && bArr.isNotEmpty) {
            await context.push(TipRequestView(bObj: bArr[0]));
            apiHome();
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _slideController.dispose();
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildMapSection(),
          _buildBottomSection(),
          _buildTopSection(),
        ],
      ),
    );
  }

  // قسم الخريطة
  Widget _buildMapSection() {
    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: latlong.LatLng(defaultLat, defaultLng),
            initialZoom: 12.0,
            minZoom: 3.0,
            maxZoom: 18.0,
            onMapReady: () {
              print("🗺️ Mapbox Map is ready!");
              _addCurrentLocationMarker();
            },
            onMapEvent: (event) {
              // يمكن إضافة معالجة أحداث الخريطة هنا
            },
          ),
          children: [
            MapboxHelper.createTileLayer(currentMapStyle),
            MarkerLayer(markers: markers),
            // إضافة Attribution
            Positioned(
              bottom: 10,
              left: 10,
              child: MapboxHelper.buildAttribution(),
            ),
          ],
        ),
        // تدرج علوي للخريطة
        Container(
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }

  // قسم الأزرار السفلية
  Widget _buildBottomSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildControlButtons(),
        const SizedBox(height: 20),
        _buildBottomSheet(),
      ],
    );
  }

  // أزرار التحكم
  Widget _buildControlButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(width: 60, height: 60),
          _buildOnlineButton(),
          _buildLocationButton(),
        ],
      ),
    );
  }

  // زر الحالة (متصل/غير متصل)
  Widget _buildOnlineButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isDriverOnline ? _pulseAnimation.value : 1.0,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(45),
              boxShadow: [
                BoxShadow(
                  color: (isDriverOnline ? Colors.red : TColor.primary)
                      .withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                  offset: const Offset(0, 8),
                ),
                const BoxShadow(
                  color: Colors.black12,
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(45),
                onTap: () {
                  setState(() {
                    isDriverOnline = !isDriverOnline;
                  });
                  apiGoOnline();
                },
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDriverOnline
                          ? [Colors.red.shade400, Colors.red.shade700]
                          : [TColor.primary, TColor.primary.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(45),
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isDriverOnline ? Icons.power_off : Icons.power,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isDriverOnline ? "OFF" : "GO",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // زر الموقع
  Widget _buildLocationButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () {
            mapController.move(latlong.LatLng(defaultLat, defaultLng), 12.0);
          },
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.grey.shade50],
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.blue.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.my_location,
              color: Colors.blue,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  // القسم العلوي
  Widget _buildTopSection() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildTopButton(
              Icons.layers,
              TColor.primary,
              () => _showMapStyleBottomSheet(context),
            ),
            _buildEarningsDisplay(),
            _buildProfileButton(),
          ],
        ),
      ),
    );
  }

  // زر في الشريط العلوي
  Widget _buildTopButton(IconData icon, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: onTap,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.grey.shade50],
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
        ),
      ),
    );
  }

  // عرض الأرباح
  Widget _buildEarningsDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey.shade50],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.attach_money,
              color: Colors.green.shade600,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "157.75",
            style: TextStyle(
              color: TColor.primaryText,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // زر الملف الشخصي
  Widget _buildProfileButton() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(25),
              onTap: () => context.push(const MenuView()),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.asset(
                    "assets/img/u1.png",
                    width: 44,
                    height: 44,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              TColor.primary.withOpacity(0.3),
                              TColor.primary.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Icon(
                          Icons.person,
                          size: 24,
                          color: TColor.primary,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.red, Colors.redAccent],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
            child: const Text(
              "3",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  // الحاوية السفلية
  Widget _buildBottomSheet() {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey.shade50],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              spreadRadius: 5,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildSheetHandle(),
            _buildSheetHeader(),
            _buildSheetContent(),
          ],
        ),
      ),
    );
  }

  // مقبض الحاوية
  Widget _buildSheetHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  // رأس الحاوية
  Widget _buildSheetHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                isOpen = !isOpen;
              });
            },
            icon: AnimatedRotation(
              turns: isOpen ? 0 : 0.5,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                Icons.keyboard_arrow_up,
                size: 24,
                color: TColor.primary,
              ),
            ),
          ),
          _buildStatusIndicator(),
          const SizedBox(width: 50),
        ],
      ),
    );
  }

  // مؤشر الحالة
  Widget _buildStatusIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDriverOnline ? Colors.green.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDriverOnline ? Colors.green.shade200 : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isDriverOnline ? Colors.green : Colors.grey,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isDriverOnline ? "متصل" : "غير متصل",
            style: TextStyle(
              color:
                  isDriverOnline ? Colors.green.shade700 : Colors.grey.shade600,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // محتوى الحاوية
  Widget _buildSheetContent() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: isOpen ? null : 0,
      child: isOpen
          ? Column(
              children: [
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.grey.shade300,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildStatisticsCard(),
                const SizedBox(height: 20),
              ],
            )
          : null,
    );
  }

  // بطاقة الإحصائيات
  Widget _buildStatisticsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              "95.0%",
              "معدل القبول",
              Icons.check_circle_outline,
              Colors.green,
            ),
          ),
          Container(
            height: 60,
            width: 1,
            color: Colors.grey.shade200,
          ),
          Expanded(
            child: _buildStatCard(
              "4.75",
              "التقييم",
              Icons.star_outline,
              Colors.orange,
            ),
          ),
          Container(
            height: 60,
            width: 1,
            color: Colors.grey.shade200,
          ),
          Expanded(
            child: _buildStatCard(
              "2.0%",
              "الإلغاء",
              Icons.cancel_outlined,
              Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  // بطاقة إحصائية واحدة
  Widget _buildStatCard(
      String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: TColor.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: TColor.secondaryText,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // إضافة علامة الموقع الحالي
  void _addCurrentLocationMarker() {
    markers.add(
      Marker(
        point: latlong.LatLng(defaultLat, defaultLng),
        width: 40,
        height: 40,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 3,
              ),
            ],
          ),
          child: const Icon(
            Icons.my_location,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  // إظهار قائمة أنماط الخريطة
  void _showMapStyleBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      useSafeArea: true,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            minHeight: 300,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Color(0xFFF8F9FA)],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // مقبض السحب
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // العنوان
              Container(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: TColor.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.layers,
                        color: TColor.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'اختر نمط الخريطة',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // خط فاصل
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                color: Colors.grey.shade200,
              ),
              // قائمة الأنماط
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: MapboxHelper.getAllStyles().length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    final style = MapboxHelper.getAllStyles()[index];
                    return _buildMapStyleTile(
                      MapboxHelper.getStyleName(style),
                      style,
                      MapboxHelper.getStyleIcon(style),
                    );
                  },
                ),
              ),
              // مساحة آمنة في الأسفل
              SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
            ],
          ),
        );
      },
    );
  }

  // بناء عنصر نمط الخريطة
  Widget _buildMapStyleTile(String title, String style, IconData icon) {
    bool isSelected = currentMapStyle == style;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  TColor.primary.withOpacity(0.1),
                  TColor.primary.withOpacity(0.05),
                ],
              )
            : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? TColor.primary : Colors.grey.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: TColor.primary.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            setState(() {
              currentMapStyle = style;
              MapboxState.setStyle(style);
            });
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? TColor.primary.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? TColor.primary : Colors.grey.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? TColor.primary : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: TColor.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // API calls
  void apiGoOnline() {
    Globs.showHUD();
    ServiceCall.post(
      {"is_online": isDriverOnline ? "1" : "0"},
      SVKey.svDriverGoOnline,
      isTokenApi: true,
      withSuccess: (responseObj) async {
        Globs.hideHUD();

        if (responseObj[KKey.status] == "1") {
          Globs.udBoolSet(isDriverOnline, "is_online");

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  responseObj[KKey.message] as String? ?? MSG.success,
                ),
                backgroundColor: Colors.green,
              ),
            );
          }

          if (mounted) {
            setState(() {});
          }
        } else {
          setState(() {
            isDriverOnline = !isDriverOnline;
          });
          if (mounted) {
            mdShowAlert(
              "خطأ",
              responseObj[KKey.message] as String? ?? MSG.fail,
              () {},
            );
          }
        }
      },
      failure: (error) async {
        Globs.hideHUD();
        setState(() {
          isDriverOnline = !isDriverOnline;
        });
        if (mounted) {
          mdShowAlert(Globs.appName, error.toString(), () {});
        }
      },
    );
  }

  void apiHome() {
    Globs.showHUD();
    ServiceCall.post(
      {},
      SVKey.svHome,
      isTokenApi: true,
      withSuccess: (responseObj) async {
        Globs.hideHUD();

        if (responseObj[KKey.status] == "1") {
          var rObj =
              (responseObj[KKey.payload] as Map? ?? {})["running"] as Map? ??
                  {};

          if (rObj.keys.isNotEmpty && mounted) {
            context.push(RunRideView(rObj: rObj));
          }
        } else {
          if (mounted) {
            mdShowAlert(
              "خطأ",
              responseObj[KKey.message] as String? ?? MSG.fail,
              () {},
            );
          }
        }
      },
      failure: (error) async {
        Globs.hideHUD();
        if (mounted) {
          mdShowAlert(Globs.appName, error.toString(), () {});
        }
      },
    );
  }
}
