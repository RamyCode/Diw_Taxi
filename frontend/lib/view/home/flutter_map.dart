// lib/view/home/flutter_map.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class FlutterMapUtils {
  // إنشاء مارك للموقع الحالي
  static Marker createCurrentLocationMarker(LatLng position) {
    return Marker(
      point: position,
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
    );
  }

  // إنشاء مارك للمواقع العامة
  static Marker createCustomMarker(
    LatLng position,
    Widget child, {
    double width = 40,
    double height = 40,
  }) {
    return Marker(
      point: position,
      width: width,
      height: height,
      child: child,
    );
  }

  // إنشاء خط بين نقطتين
  static Polyline createPolyline(
    List<LatLng> points,
    Color color, {
    double strokeWidth = 5.0,
  }) {
    return Polyline(
      points: points,
      color: color,
      strokeWidth: strokeWidth,
    );
  }

  // حساب المسافة بين نقطتين
  static double calculateDistance(LatLng point1, LatLng point2) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Kilometer, point1, point2);
  }

  // إنشاء bounds للخريطة
  static LatLngBounds createBounds(List<LatLng> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (LatLng point in points) {
      minLat = minLat < point.latitude ? minLat : point.latitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      minLng = minLng < point.longitude ? minLng : point.longitude;
      maxLng = maxLng > point.longitude ? maxLng : point.longitude;
    }

    return LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );
  }

  // إنشاء دائرة حول نقطة
  static CircleMarker createCircleMarker(
    LatLng center,
    double radius,
    Color color, {
    Color? borderColor,
    double borderStrokeWidth = 1.0,
  }) {
    return CircleMarker(
      point: center,
      radius: radius,
      color: color,
      borderColor: borderColor ?? Colors.white,
      borderStrokeWidth: borderStrokeWidth,
    );
  }
}
