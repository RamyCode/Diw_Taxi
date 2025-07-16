// 📦 Imports
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:taxi_app/common/common_extension.dart';
import 'package:taxi_app/common/globs.dart';
import 'package:taxi_app/common/service_call.dart';
import 'package:taxi_app/common/socket_manager.dart';

class LocationHelper {
  static final LocationHelper _singleton = LocationHelper._internal();
  factory LocationHelper() => _singleton;
  LocationHelper._internal();
  static LocationHelper shared() => _singleton;

  final GeolocatorPlatform geolocatorPlatform = GeolocatorPlatform.instance;

  StreamSubscription<Position>? positionStreamSub;
  StreamSubscription<ServiceStatus>? serviceStatusStreamSub;
  bool positionStreamStarted = false;

  Position? lastLocation;
  bool isSaveFileLocation = false;
  int bookingId = 0;

  String saveFilePath = "";

  void startInit() async {
    debugPrint("StartInit Called");
    bool isAccess = await handlePermission();
    if (!isAccess) {
      debugPrint("🚫 Location permission not granted");
      return;
    }

    saveFilePath = (await getSavePath()).path;

    if (serviceStatusStreamSub == null) {
      final serviceStatusStream = geolocatorPlatform.getServiceStatusStream();
      serviceStatusStreamSub = serviceStatusStream.handleError((error) {
        serviceStatusStreamSub?.cancel();
        serviceStatusStreamSub = null;
      }).listen((serviceStatus) {
        if (serviceStatus == ServiceStatus.enabled && !positionStreamStarted) {
          locationChangeListening();
        } else if (serviceStatus == ServiceStatus.disabled) {
          positionStreamSub?.cancel();
          positionStreamSub = null;
          debugPrint("❌ Position Stream has been canceled");
        }
        debugPrint("📡 Location service has been ${serviceStatus.name}");
      });
    }

    locationChangeListening();
    sendCurrentLocationImmediately();
  }

  void sendCurrentLocationImmediately() async {
    try {
      Position position = await geolocatorPlatform.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
        ),
      );
      debugPrint(
          "📍 First location on login: ${position.latitude}, ${position.longitude}");
      apiCallingLocationUpdate(position);
    } catch (e) {
      debugPrint("❌ Failed to get current position: $e");
    }
  }

  void locationSendPause() {
    positionStreamSub?.cancel();
    positionStreamSub = null;
    positionStreamStarted = false;
  }

  void locationSendStart() {
    if (!positionStreamStarted) {
      locationChangeListening();
    }
  }

  Future<bool> handlePermission() async {
    if (!await geolocatorPlatform.isLocationServiceEnabled()) {
      return false;
    }

    LocationPermission permission = await geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    if (permission == LocationPermission.deniedForever) return false;

    return true;
  }

  void locationChangeListening() {
    debugPrint("📡 Listening to position updates...");
    if (positionStreamSub == null) {
      final positionStream = geolocatorPlatform.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 15,
        ),
      );

      positionStreamSub = positionStream.handleError((error) {
        positionStreamSub?.cancel();
        positionStreamSub = null;
      }).listen((position) {
        debugPrint(
            "📍 New Location: ${position.latitude}, ${position.longitude}");

        if (isSaveFileLocation && bookingId != 0) {
          try {
            File("$saveFilePath/$bookingId.txt").writeAsStringSync(
              ',{"latitude":${position.latitude},"longitude":${position.longitude},"time":"${DateTime.now().stringFormat(format: "yyyy-MM-dd HH:mm:ss")}"}',
              mode: FileMode.append,
            );
            debugPrint("💾 Location saved to file");
          } catch (e) {
            debugPrint("❌ Failed saving to file: $e");
          }
        }

        apiCallingLocationUpdate(position);
      });

      positionStreamStarted = true;
    }
  }

  void apiCallingLocationUpdate(Position pos) {
    if (ServiceCall.userType != 2) {
      debugPrint("⚠️ Not a driver, userType: ${ServiceCall.userType}");
      return;
    }

    // ✅ Avoid sending duplicate location
    if (lastLocation != null) {
      final distance = Geolocator.distanceBetween(
        lastLocation!.latitude,
        lastLocation!.longitude,
        pos.latitude,
        pos.longitude,
      );

      if (distance < 5) {
        debugPrint(
            "🔁 Duplicate location ignored (distance = ${distance.toStringAsFixed(2)} m)");
        return;
      }
    }

    lastLocation = pos;

    debugPrint("📤 Sending driver location to server");
    ServiceCall.post({
      "latitude": pos.latitude.toString(),
      "longitude": pos.longitude.toString(),
      "socket_id": SocketManager.shared.socket?.id ?? ""
    }, SVKey.svUpdateLocationDriver, isTokenApi: true,
        withSuccess: (responseObj) async {
      if (responseObj[KKey.status] == "1") {
        debugPrint("✅ Location update successful");
      } else {
        debugPrint("❌ Location update failed: ${responseObj[KKey.message]}");
      }
    }, failure: (error) async {
      debugPrint("❌ Location update failed: $error");
    });
  }

  void startRideLocationSave(int bId, Position position) {
    bookingId = bId;
    isSaveFileLocation = true;

    try {
      File("$saveFilePath/$bookingId.txt").writeAsStringSync(
        '{"latitude":${position.latitude},"longitude":${position.longitude},"time":"${DateTime.now().stringFormat(format: "yyyy-MM-dd HH:mm:ss")}"}',
        mode: FileMode.append,
      );
      debugPrint("📂 Ride location log started");
    } catch (e) {
      debugPrint("❌ Failed to start ride logging: $e");
    }
  }

  void stopRideLocationSave() {
    isSaveFileLocation = false;
    bookingId = 0;
    debugPrint("🛑 Ride location logging stopped");
  }

  Future<Directory> getSavePath() async {
    return Platform.isAndroid
        ? getTemporaryDirectory()
        : getApplicationCacheDirectory();
  }

  String getRideSaveLocationJsonString(int bookingId) {
    try {
      return "[${File("$saveFilePath/$bookingId.txt").readAsStringSync()}]";
    } catch (e) {
      debugPrint("❌ Failed to read ride log: $e");
      return "[]";
    }
  }
}
