import 'dart:convert';

class ProfileModel {
    bool? success;
    String? message;
    int? statusCode;
    Data? data;

    ProfileModel({
        this.success,
        this.message,
        this.statusCode,
        this.data,
    });

    factory ProfileModel.fromRawJson(String str) => ProfileModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
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

class HelperUserId {
  String? id;
  String? contact;

  HelperUserId({this.id, this.contact});

  factory HelperUserId.fromJson(Map<String, dynamic> json) => HelperUserId(
        id: json["_id"],
        contact: json["contact"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "contact": contact,
      };
}

class Data {
    String? id;
    String? name;
    String? role;
    String? email;
    String? contact;
    String? image;
    String? status;
    bool? verified;
    bool? isDeleted;
    String? stripeCustomerId;
    dynamic helperUserId; // HelperUserId, List<HelperUserId>, or HelperUserId?
    List<HelperUserId> get helperUserList {
      if (helperUserId == null) return [];
      if (helperUserId is List<HelperUserId>) return helperUserId as List<HelperUserId>;
      if (helperUserId is HelperUserId) return [helperUserId as HelperUserId];
      return [];
    }
    DateTime? createdAt;
    DateTime? updatedAt;
    int? v;

    Data({
        this.id,
        this.name,
        this.role,
        this.email,
        this.contact,
        this.image,
        this.status,
        this.verified,
        this.isDeleted,
        this.stripeCustomerId,
        this.helperUserId,
        this.createdAt,
        this.updatedAt,
        this.v,
    });

    factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["_id"],
        name: json["name"],
        role: json["role"],
        email: json["email"],
        contact: json["contact"],
        image: json["image"],
        status: json["status"],
        verified: json["verified"],
        isDeleted: json["isDeleted"],
        stripeCustomerId: json["stripeCustomerId"],
        helperUserId: json["helperUserId"] == null
            ? (json["helperUserIds"] != null && json["helperUserIds"] is List
                ? (json["helperUserIds"] as List).map((x) => HelperUserId.fromJson(x)).toList()
                : null)
            : (json["helperUserId"] is List
                ? (json["helperUserId"] as List).map((x) => HelperUserId.fromJson(x)).toList()
                : HelperUserId.fromJson(json["helperUserId"])),
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "role": role,
        "email": email,
        "contact": contact,
        "image": image,
        "status": status,
        "verified": verified,
        "isDeleted": isDeleted,
        "stripeCustomerId": stripeCustomerId,
        "helperUserId": helperUserId is List
            ? (helperUserId as List<HelperUserId>).map((x) => x.toJson()).toList()
            : (helperUserId is HelperUserId ? (helperUserId as HelperUserId).toJson() : null),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
    };
}