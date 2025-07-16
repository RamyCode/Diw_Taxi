// lib/common/mapbox_helper.dart

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';

class MapboxHelper {
  // ضع هنا الـ Access Token الخاص بك
  static const String accessToken =
      'pk.eyJ1IjoiZW5ncmFteTk1IiwiYSI6ImNtZDNnbnI4cDA0M24yanFueTc4Nm5wZ3AifQ.39gyS3LGMyMInFMs2mFV4Q';

  // أنماط Mapbox المختلفة
  static const String streets = 'mapbox/streets-v11';
  static const String satellite = 'mapbox/satellite-v9';
  static const String satelliteStreets = 'mapbox/satellite-streets-v11';
  static const String light = 'mapbox/light-v10';
  static const String dark = 'mapbox/dark-v10';
  static const String outdoors = 'mapbox/outdoors-v11';
  static const String navigationDay = 'mapbox/navigation-day-v1';
  static const String navigationNight = 'mapbox/navigation-night-v1';

  // قائمة بأسماء الأنماط باللغة العربية
  static const Map<String, String> styleNames = {
    streets: 'الشوارع',
    satellite: 'الأقمار الصناعية',
    satelliteStreets: 'الأقمار الصناعية + الشوارع',
    light: 'فاتح',
    dark: 'داكن',
    outdoors: 'في الهواء الطلق',
    navigationDay: 'ملاحة النهار',
    navigationNight: 'ملاحة الليل',
  };

  // دالة لإنشاء URL للتايل
  static String getTileUrl(String style) {
    return 'https://api.mapbox.com/styles/v1/$style/tiles/{z}/{x}/{y}@2x?access_token=$accessToken';
  }

  // دالة لإنشاء TileLayer بسيطة وعملية
  static TileLayer createTileLayer(String style, {String? userAgent}) {
    return TileLayer(
      urlTemplate: getTileUrl(style),
      userAgentPackageName: userAgent ?? 'com.ramy.taxiapp',
      maxZoom: 18,
      minZoom: 1,
      tileSize: 512,
      zoomOffset: -1,
      errorTileCallback: (tile, error, stackTrace) {
        debugPrint('❌ Error loading Mapbox tile: $error');
      },
      tileProvider: NetworkTileProvider(),
    );
  }

  // دالة للحصول على اسم النمط باللغة العربية
  static String getStyleName(String style) {
    return styleNames[style] ?? 'نمط غير معروف';
  }

  // دالة للحصول على جميع الأنماط المتاحة
  static List<String> getAllStyles() {
    return styleNames.keys.toList();
  }

  // دالة للحصول على النمط الافتراضي
  static String getDefaultStyle() {
    return streets;
  }

  // دالة للتحقق من صحة الـ Access Token
  static bool isValidAccessToken() {
    return accessToken.isNotEmpty && accessToken.startsWith('pk.');
  }

  // دالة لإنشاء أيقونة حسب النمط
  static IconData getStyleIcon(String style) {
    switch (style) {
      case streets:
        return Icons.map;
      case satellite:
        return Icons.satellite;
      case satelliteStreets:
        return Icons.satellite_alt;
      case light:
        return Icons.light_mode;
      case dark:
        return Icons.dark_mode;
      case outdoors:
        return Icons.terrain;
      case navigationDay:
        return Icons.navigation;
      case navigationNight:
        return Icons.nights_stay;
      default:
        return Icons.map;
    }
  }

  // دالة لإنشاء Attribution للخريطة
  static Widget buildAttribution() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        '© Mapbox © OpenStreetMap',
        style: TextStyle(
          fontSize: 10,
          color: Colors.black54,
        ),
      ),
    );
  }
}

// فئة لإدارة حالة الخريطة
class MapboxState {
  static String _currentStyle = MapboxHelper.getDefaultStyle();
  static bool _isInitialized = false;

  static String get currentStyle => _currentStyle;
  static bool get isInitialized => _isInitialized;

  static void setStyle(String style) {
    if (MapboxHelper.getAllStyles().contains(style)) {
      _currentStyle = style;
      debugPrint(
          '🎨 Mapbox style changed to: ${MapboxHelper.getStyleName(style)}');
    }
  }

  static void initialize() {
    if (!MapboxHelper.isValidAccessToken()) {
      debugPrint('⚠️ Warning: Invalid Mapbox access token!');
      return;
    }

    _isInitialized = true;
    debugPrint('✅ Mapbox initialized successfully');
  }

  static void reset() {
    _currentStyle = MapboxHelper.getDefaultStyle();
    _isInitialized = false;
  }
}
