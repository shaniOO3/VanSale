class CustomerSupplierModel {
  int? id;
  int? csId;
  String? name;
  String? aname;
  String? address;
  String? aaddress;
  String? vatNo;
  double? cbalance;
  int? isactive;

  CustomerSupplierModel(
      {this.id,
      this.csId,
      this.name,
      this.aname,
      this.address,
      this.aaddress,
      this.vatNo,
      this.cbalance,
      this.isactive});

  CustomerSupplierModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    csId = json['csId'];
    name = json['name'];
    aname = json['aname'];
    address = json['address'];
    aaddress = json['aaddress'];
    vatNo = json['vatNo'];
    cbalance = json['cbalance'];
    isactive = json['isactive'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['csId'] = csId;
    data['name'] = name;
    data['aname'] = aname;
    data['address'] = address;
    data['aaddress'] = aaddress;
    data['vatNo'] = vatNo;
    data['cbalance'] = cbalance;
    data['isactive'] = isactive;
    return data;
  }
}
