import 'package:vansales/api/customer_supplier_model.dart';

class Invoice {
  final CustomerSupplierModel customer;
  final List<InvoiceItem> items;
  final InvoicePrice price;
  final int id;
  final String date;
  final String time;

  const Invoice(
      {required this.customer,
      required this.items,
      required this.price,
      required this.id,
      required this.date,
      required this.time});
}

class InvoiceItem {
  final int no;
  final String description;
  final String descriptionA;
  final int quantity;
  final double vat;
  final String unit;
  final double unitprice;

  InvoiceItem(
      {required this.no,
      required this.description,
      required this.descriptionA,
      required this.quantity,
      required this.vat,
      required this.unit,
      required this.unitprice});
}

class InvoicePrice {
  final double totalamt;
  final double discount;
  final double aft;
  final double vat;
  final double netamt;

  InvoicePrice({
    required this.totalamt,
    required this.discount,
    required this.aft,
    required this.vat,
    required this.netamt,
  });
}
