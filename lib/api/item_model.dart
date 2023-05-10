class ItemModel {
  int? id;
  int? itemId;
  String? name;
  String? arabicname;
  String? suppliers;
  double? vat;
  String? unit;
  int? stock;
  int? isactive;

  ItemModel(
      {this.id,
      this.itemId,
      this.name,
      this.arabicname,
      this.suppliers,
      this.vat,
      this.unit,
      this.stock,
      this.isactive});

  ItemModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    itemId = json['itemId'];
    name = json['name'];
    arabicname = json['arabicname'];
    suppliers = json['suppliers'];
    vat = json['vat'];
    unit = json['unit'];
    stock = json['stock'];
    isactive = json['isactive'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['itemId'] = itemId;
    data['name'] = name;
    data['arabicname'] = arabicname;
    data['suppliers'] = suppliers;
    data['vat'] = vat;
    data['unit'] = unit;
    data['stock'] = stock;
    data['isactive'] = isactive;
    return data;
  }
}
