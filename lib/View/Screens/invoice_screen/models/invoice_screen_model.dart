import 'dart:convert';

class InvoiceScreenModel {
  bool? success;
  String? message;
  dynamic statusCode;
  Data? data;

  InvoiceScreenModel({this.success, this.message, this.statusCode, this.data});

  factory InvoiceScreenModel.fromRawJson(String str) =>
      InvoiceScreenModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory InvoiceScreenModel.fromJson(Map<String, dynamic> json) =>
      InvoiceScreenModel(
        success: json["success"],
        message: json["message"],
        statusCode: json["statusCode"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "statusCode": statusCode,
        "data": data?.toJson(),
      };
}

class Data {
  String? id;
  String? trxId;
  dynamic v;
  dynamic amountPaid;
  String? contact;
  String? title;
  String? coupon;
  dynamic recieptNumber;
  DateTime? createdAt;
  DateTime? currentPeriodEnd;
  DateTime? currentPeriodStart;
  String? package;
  dynamic price;
  String? status;
  DateTime? updatedAt;
  Workshop? workshop;
  String? qrImage;

  Data({
    this.id,
    this.trxId,
    this.v,
    this.amountPaid,
    this.contact,
    this.coupon,
    this.title,
    this.createdAt,
    this.recieptNumber,
    this.currentPeriodEnd,
    this.currentPeriodStart,
    this.package,
    this.price,
    this.status,
    this.updatedAt,
    this.workshop,
    this.qrImage,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["_id"],
        trxId: json["trxId"],
        v: json["__v"],
        amountPaid: json["amountPaid"],
        contact: json["contact"],
        coupon: json["coupon"],
        recieptNumber: json["recieptNumber"],
        title: json["title"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        currentPeriodEnd: json["currentPeriodEnd"] == null
            ? null
            : DateTime.parse(json["currentPeriodEnd"]),
        currentPeriodStart: json["currentPeriodStart"] == null
            ? null
            : DateTime.parse(json["currentPeriodStart"]),
        package: json["package"],
        price: json["price"],
        status: json["status"],
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        workshop: json["workshop"] == null
            ? null
            : Workshop.fromJson(json["workshop"]),
        qrImage: json["subscription_qr_code"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "trxId": trxId,
        "__v": v,
        "amountPaid": amountPaid,
        "contact": contact,
        "coupon": coupon,
        "recieptNumber": recieptNumber,
        "createdAt": createdAt?.toIso8601String(),
        "currentPeriodEnd": currentPeriodEnd?.toIso8601String(),
        "currentPeriodStart": currentPeriodStart?.toIso8601String(),
        "package": package,
        "price": price,
        "status": status,
        "updatedAt": updatedAt?.toIso8601String(),
        "workshop": workshop?.toJson(),
        "subscription_qr_code": qrImage,
      };
}

class Workshop {
  WorkshopGeoLocation? workshopGeoLocation;
  String? id;
  String? workshopNameEnglish;
  String? workshopNameArabic;
  String? contact;
  String? unn;
  String? crn;
  String? mln;
  String? address;
  String? taxVatNumber;
  String? bankAccountNumber;
  bool? isAvailableMobileWorkshop;
  WorkingSchedule? regularWorkingSchedule;
  WorkingSchedule? ramadanWorkingSchedule;
  String? ownerId;
  String? helperUserId;
  bool? isDeleted;
  dynamic generatedInvoiceCount;
  String? subscribedPackage;
  String? subscriptionId;
  bool? isUsedTrial;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic v;
  String? nationality;
  String? preferredLanguage;

  Workshop({
    this.workshopGeoLocation,
    this.id,
    this.workshopNameEnglish,
    this.workshopNameArabic,
    this.contact,
    this.unn,
    this.crn,
    this.mln,
    this.address,
    this.taxVatNumber,
    this.bankAccountNumber,
    this.isAvailableMobileWorkshop,
    this.regularWorkingSchedule,
    this.ramadanWorkingSchedule,
    this.ownerId,
    this.helperUserId,
    this.isDeleted,
    this.generatedInvoiceCount,
    this.subscribedPackage,
    this.subscriptionId,
    this.isUsedTrial,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.nationality,
    this.preferredLanguage,
  });

  factory Workshop.fromJson(Map<String, dynamic> json) => Workshop(
        workshopGeoLocation: json["workshopGEOlocation"] == null
            ? null
            : WorkshopGeoLocation.fromJson(json["workshopGEOlocation"]),
        id: json["_id"],
        workshopNameEnglish: json["workshopNameEnglish"],
        workshopNameArabic: json["workshopNameArabic"],
        contact: json["contact"],
        unn: json["unn"],
        crn: json["crn"],
        mln: json["mln"],
        address: json["address"],
        taxVatNumber: json["taxVatNumber"],
        bankAccountNumber: json["bankAccountNumber"],
        isAvailableMobileWorkshop: json["isAvailableMobileWorkshop"],
        regularWorkingSchedule: json["regularWorkingSchedule"] == null
            ? null
            : WorkingSchedule.fromJson(json["regularWorkingSchedule"]),
        ramadanWorkingSchedule: json["ramadanWorkingSchedule"] == null
            ? null
            : WorkingSchedule.fromJson(json["ramadanWorkingSchedule"]),
        ownerId: json["ownerId"],
        helperUserId: json["helperUserId"],
        isDeleted: json["isDeleted"],
        generatedInvoiceCount: json["generatedInvoiceCount"],
        subscribedPackage: json["subscribedPackage"],
        subscriptionId: json["subscriptionId"],
        isUsedTrial: json["isUsedTrial"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        nationality: json["nationality"],
        preferredLanguage: json["preferredLanguage"],
      );

  Map<String, dynamic> toJson() => {
        "workshopGEOlocation": workshopGeoLocation?.toJson(),
        "_id": id,
        "workshopNameEnglish": workshopNameEnglish,
        "workshopNameArabic": workshopNameArabic,
        "contact": contact,
        "unn": unn,
        "crn": crn,
        "mln": mln,
        "address": address,
        "taxVatNumber": taxVatNumber,
        "bankAccountNumber": bankAccountNumber,
        "isAvailableMobileWorkshop": isAvailableMobileWorkshop,
        "regularWorkingSchedule": regularWorkingSchedule?.toJson(),
        "ramadanWorkingSchedule": ramadanWorkingSchedule?.toJson(),
        "ownerId": ownerId,
        "helperUserId": helperUserId,
        "isDeleted": isDeleted,
        "generatedInvoiceCount": generatedInvoiceCount,
        "subscribedPackage": subscribedPackage,
        "subscriptionId": subscriptionId,
        "isUsedTrial": isUsedTrial,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "nationality": nationality,
        "preferredLanguage": preferredLanguage,
      };
}

class WorkshopGeoLocation {
  String? type;
  List<double>? coordinates;

  WorkshopGeoLocation({this.type, this.coordinates});

  factory WorkshopGeoLocation.fromJson(Map<String, dynamic> json) =>
      WorkshopGeoLocation(
        type: json["type"],
        coordinates: json["coordinates"] == null
            ? []
            : List<double>.from(json["coordinates"].map((x) => x.toDouble())),
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "coordinates": coordinates == null
            ? []
            : List<dynamic>.from(coordinates!.map((x) => x)),
      };
}

class WorkingSchedule {
  String? startDay;
  String? endDay;
  String? startTime;
  String? endTime;

  WorkingSchedule({this.startDay, this.endDay, this.startTime, this.endTime});

  factory WorkingSchedule.fromJson(Map<String, dynamic> json) =>
      WorkingSchedule(
        startDay: json["startDay"],
        endDay: json["endDay"],
        startTime: json["startTime"],
        endTime: json["endTime"],
      );

  Map<String, dynamic> toJson() => {
        "startDay": startDay,
        "endDay": endDay,
        "startTime": startTime,
        "endTime": endTime,
      };
}
