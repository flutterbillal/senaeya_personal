class AdditionalUserModel {
  String? sId;
  String? name;
  String? providerWorkShopId;
  String? contact;
  String? status;
  String? createdAt;
  String? updatedAt;

  AdditionalUserModel(
      {this.sId,
      this.name,
      this.providerWorkShopId,
      this.contact,
      this.status,
      this.createdAt,
      this.updatedAt});

  AdditionalUserModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    providerWorkShopId = json['providerWorkShopId'];
    contact = json['contact'];
    status = json['status'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    // ignore: prefer_collection_literals
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['_id'] = sId;
    data['name'] = name;
    data['providerWorkShopId'] = providerWorkShopId;
    data['contact'] = contact;
    data['status'] = status;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}
