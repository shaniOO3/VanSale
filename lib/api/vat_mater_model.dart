class VatMasterModel {
  int? id;
  String? vat;

  VatMasterModel({
    this.id,
    this.vat
});

  VatMasterModel.fromJson(Map<String, dynamic> json) {
        id = json['id'];
        vat = json['vat'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['vat'] = vat;
    return data;
  }

}