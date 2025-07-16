import 'package:taxi_app/common/db_helper.dart';
import 'package:taxi_app/common/service_call.dart';

class PriceDetailModel {
  String priceId = "";
  String zoneId = "";
  String serviceId = "";
  String baseCharge = "";
  String perKmCharge = "";
  String perMinCharge = "";
  String bookingCharge = "";
  String miniFair = "";
  String miniKm = "";
  String cancelCharge = "";
  String status = "";
  String createdDate = "";
  String modifyDate = "";

  PriceDetailModel.map(dynamic obj) {
    priceId = obj["price_id"].toString();
    zoneId = obj["zone_id"].toString();
    serviceId = obj["service_id"].toString();
    baseCharge = obj["base_charge"].toString();
    perKmCharge = obj["per_km_charge"].toString();
    perMinCharge = obj["per_min_charge"].toString();
    bookingCharge = obj["booking_charge"].toString();
    miniFair = obj["mini_fair"].toString();
    miniKm = obj["mini_km"].toString();
    cancelCharge = obj["cancel_charge"].toString();
    status = obj["status"].toString();
    createdDate = obj["created_date"].toString();
    modifyDate = obj["modify_date"].toString();
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> obj = {};
    obj["price_id"] = priceId;
    obj["zone_id"] = zoneId;
    obj["service_id"] = serviceId;
    obj["base_charge"] = baseCharge;
    obj["per_km_charge"] = perKmCharge;
    obj["per_min_charge"] = perMinCharge;
    obj["booking_charge"] = bookingCharge;
    obj["mini_fair"] = miniFair;
    obj["mini_km"] = miniKm;
    obj["cancel_charge"] = cancelCharge;
    obj["status"] = status;
    obj["created_date"] = createdDate;
    obj["modify_date"] = modifyDate;

    return obj;
  }

  static Future<List> getList() async {
    var db = await DBHelper.shared().db;
    if (db != null) {
      List<Map> list = await db.rawQuery(
          'SELECT * FROM `${DBHelper.tbPriceDetail}` WHERE `${DBHelper.status}` = 1',
          []);
      return list;
    } else {
      return [];
    }
  }

  static Future<List> getSelectZoneGetServiceAndPriceList(String zoneId) async {
    var db = await DBHelper.shared().db;

    if (db != null) {
      List<Map> list = await db.rawQuery(
        'SELECT `sd`.`service_id`, `pd`.`price_id`, `pd`.`base_charge`, `pd`.`per_km_charge`, `pd`.`per_min_charge`, `pd`.`booking_charge`, `pd`.`mini_fair`, `pd`.`mini_km`, `sd`.`service_name`, `sd`.`color`, `sd`.`icon` '
        'FROM `${DBHelper.tbServiceDetail}` AS `sd` '
        'INNER JOIN `${DBHelper.tbPriceDetail}` AS `pd` '
        'ON `pd`.`${DBHelper.serviceId}` = `sd`.`${DBHelper.serviceId}` '
        'AND `sd`.`${DBHelper.status}` = 1 '
        'AND `pd`.`${DBHelper.status}` = 1 '
        'AND (`sd`.`${DBHelper.gender}` LIKE ?) '
        'WHERE `pd`.`${DBHelper.zoneId}` = ?',
        ["%${ServiceCall.userObj["gender"]}%", zoneId],
      );

      List<Map<String, dynamic>> updatedList = [];

      for (var item in list) {
        var mutableItem =
            Map<String, dynamic>.from(item); // ✅ نسخة قابلة للتعديل

        try {
          final estDistance = ServiceCall.userObj["est_total_distance"] ?? "0";
          final estDuration = ServiceCall.userObj["est_duration"] ?? "0";

          final res = await ServiceCall.postWithResponse({
            "price_id": mutableItem["price_id"].toString(),
            "zone_id": zoneId,
            "service_id": mutableItem["service_id"].toString(),
            "est_total_distance": estDistance,
            "est_duration": estDuration,
          }, "estimate_fare", isTokenApi: true);

          if (res != null && res["status"] == "1") {
            print("✅ RES DEBUG: $res");
            mutableItem["est_price"] = res["total_amount"]?.toString() ?? "0";
          } else {
            mutableItem["est_price"] = "0";
          }
          print("🚨 TOTAL_AMOUNT DEBUG: ${res["total_amount"]}");
        } catch (_) {
          mutableItem["est_price"] = "0";
        }

        updatedList.add(mutableItem); // ✅ أضف العنصر المعدل
      }

      return updatedList;
    } else {
      return [];
    }
  }
}
