import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:vansales/api/api.dart';
import 'package:vansales/api/customer_supplier_model.dart';
import 'package:vansales/pdf/invoice_model.dart';
import 'package:vansales/pdf/pdf_main.dart';
import 'package:vansales/utils.dart';

class PdfInvoice {
  static String name = '';
  static String companyName = '';
  static String companyNameA = '';
  static String address = '';
  static String addressA = '';
  static String vatNo = '';
  static String phone = '';

  static Uint8List fontData = File('Almarai-Regular.ttf').readAsBytesSync();
  var data = fontData.buffer.asByteData();
  static var myStyle;
  static var myStyle1;
  DateTime dateTime = DateTime.now();

  static double textSize = 10;

  static Future<File> generate(Invoice invoice) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    String? phoneno = _auth.currentUser!.phoneNumber;
    phone = phoneno!;
    late Uri getUri =
        Uri.parse(apiRootAddress + "/user/get/byPhone/" + phoneno);

    try {
      final response = await get(getUri);
      final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        name = jsonData['name'];
        companyName = jsonData['companyName'];
        companyNameA = jsonData['companyNameInArabic'];
        address = jsonData['address'];
        addressA = jsonData['addressInArabic'];
        vatNo = jsonData['vatNo'];
        print(name);
      } else {
        print('ooopppp');
      }
    } on HttpException catch (e) {
      print(e);
    }

    final pdf = Document();

    var data = await rootBundle.load("assets/fonts/Almarai-Regular.ttf");
    var myFont = Font.ttf(data);
    myStyle = TextStyle(
      font: myFont,
    );
    myStyle1 = TextStyle(
      font: myFont,
      fontSize: textSize,
    );

    pdf.addPage(
      MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
          build: (context) => [
                buildHeader(invoice),
                SizedBox(height: 0.5 * PdfPageFormat.cm),
                buildInvoice(invoice),
                Expanded(child: SizedBox()),
                Divider(),
                buildTotal(invoice),
              ]),
    );

    return PdfMain.saveDocument(name: 'INV ${invoice.id}', pdf: pdf);
  }

  static Widget buildHeader(Invoice invoice) {
    // final companynamelength = companyName.codeUnits.length.toString();
    // final qrrcode;

    final tag1no = Uint8List.fromList([1]);
    final tag1len = Uint8List.fromList([companyName.length]);
    final tag1 = utf8.encode(companyName);

    final tag2no = Uint8List.fromList([2]);
    final tag2len = Uint8List.fromList([vatNo.length]);
    final tag2 = utf8.encode(vatNo);

    final tag3no = Uint8List.fromList([3]);
    final tag3len = Uint8List.fromList(
        [invoice.date.length + ' '.length + invoice.time.length]);
    final tag3 = utf8.encode('${invoice.date} ${invoice.time}');

    final tag4no = Uint8List.fromList([4]);
    final tag4len =
        Uint8List.fromList([invoice.price.netamt.toStringAsFixed(2).length]);
    final tag4 = utf8.encode(invoice.price.netamt.toStringAsFixed(2));

    final tag5no = Uint8List.fromList([5]);
    final tag5len =
        Uint8List.fromList([invoice.price.vat.toStringAsFixed(2).length]);
    final tag5 = utf8.encode(invoice.price.vat.toStringAsFixed(2));

    final added = tag1no +
        tag1len +
        tag1 +
        tag2no +
        tag2len +
        tag2 +
        tag3no +
        tag3len +
        tag3 +
        tag4no +
        tag4len +
        tag4 +
        tag5no +
        tag5len +
        tag5;

    // DateTime dateTime = DateTime.now();
    // final datetim = inn.DateFormat('dd-MM-yyyy hh:mm aa').format(dateTime);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildShopAddress(),
        SizedBox(height: 0.6 * PdfPageFormat.cm),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('Tax Invoice '),
          Text('فاتورة ضريبية',
              style: myStyle, textDirection: TextDirection.rtl)
        ]),
        SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildCustomerAddress(invoice.id, invoice.customer),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  height: 50,
                  width: 50,
                  child: BarcodeWidget(
                    barcode: Barcode.qrCode(),
                    data: base64Encode(added),
                  ),
                ),
                SizedBox(height: 7),
                Row(
                  children: [
                    Text(
                      'Date: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('${invoice.date} ${invoice.time}'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static Widget buildShopAddress() => Container(
      height: 80,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(border: Border.all(color: PdfColors.black)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(companyName),
              Text(address, style: myStyle, textDirection: TextDirection.rtl),
              Text('Vat No: $vatNo'),
            ]),
        Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(companyNameA,
                  style: myStyle, textDirection: TextDirection.rtl),
              Text(addressA, style: myStyle, textDirection: TextDirection.rtl),
              Row(children: [
                Text('$vatNo :'),
                Text('رقم الضريبي',
                    style: myStyle, textDirection: TextDirection.rtl),
              ]),
            ]),
      ]));

  static Widget buildCustomerAddress(id, CustomerSupplierModel customer) =>
      Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Text('Bill No: ', style: TextStyle(fontWeight: FontWeight.bold)),
              Text("$id"),
            ]),
            SizedBox(height: 10),
            Row(children: [
              Text('Customer Name: ',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${customer.name}',
                  style: myStyle, textDirection: TextDirection.rtl),
            ]),
            SizedBox(height: 10),
            Row(children: [
              Text('Vat No: ', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${customer.vatNo}'),
            ]),
          ]);

  static Widget buildCustomerAddresss(CustomerSupplierModel customer) =>
      Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Bill No: ', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 7),
          Text('Customer Name: ',
              style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 7),
          Text('Vat No: ', style: TextStyle(fontWeight: FontWeight.bold)),
        ]),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('1001'),
          SizedBox(height: 7),
          Text('${customer.name}'),
          SizedBox(height: 7),
          Text('${customer.vatNo}'),
        ]),
      ]);

  static Widget buildInvoice(Invoice invoice) {
    return Table(children: [
      TableRow(
          decoration: const BoxDecoration(color: PdfColors.grey300),
          verticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            SizedBox(
              height: 25,
              width: 3,
            ),
            Text(
              "SR.No",
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Description",
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Unit",
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Quantity",
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Unit Price",
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Vat",
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Total",
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 25,
              width: 3,
            ),
          ]),
      TableRow(children: [
        SizedBox(height: 5),
      ]),
      ...getdatas(invoice)
    ]);
  }

  static List<TableRow> getdatas(Invoice invoice) {
    List<TableRow> data = [];
    for (var item in invoice.items) {
      double total;
      if (Preferences.getIncludingVat()) {
        total = item.quantity * (item.unitprice - (item.vat * item.unitprice));
      } else {
        total = item.quantity * (item.unitprice + (item.vat * item.unitprice));
      }
      data.add(TableRow(
          verticalAlignment: TableCellVerticalAlignment.full,
          children: [
            SizedBox(
              width: 3,
            ),
            Text(
              "${item.no}",
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: textSize),
            ),
            Column(children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  item.description,
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: textSize),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  item.descriptionA,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: myStyle1,
                ),
              ),
            ]),
            Text(
              item.unit,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: textSize),
            ),
            Text(
              "${item.quantity}",
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: textSize),
            ),
            Text(
              Preferences.getIncludingVat()
                  ? (item.unitprice - (item.vat * item.unitprice))
                      .toStringAsFixed(2)
                  : item.unitprice.toStringAsFixed(2),
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: textSize),
            ),
            Text(
              ((item.vat * item.unitprice).toStringAsFixed(2)),
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: textSize),
            ),
            Text(
              (total.toStringAsFixed(2)),
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: textSize),
            ),
            SizedBox(
              width: 3,
            ),
          ]));
    }
    return data;
  }

  // static Widget buildInvoice(Invoice invoice) {
  //   final headers = [
  //     'SR.No',
  //     'Description',
  //     'Quantity',
  //     'Unit Price',
  //     'Vat',
  //     'Total'
  //   ];
  //   final data = invoice.items.map((item) {
  //     final total =
  //         item.quantity * (item.unitprice + (item.vat * item.unitprice));

  //     return [
  //       item.no,
  //       item.description + "\n" + item.descriptionA,
  //       item.quantity,
  //       (item.unitprice.toStringAsFixed(2)),
  //       ((item.vat * item.unitprice).toStringAsFixed(2)),
  //       (total.toStringAsFixed(2)),
  //     ];
  //   }).toList();

  //   return Table.fromTextArray(
  //     headers: headers,
  //     data: data,
  //     border: null,
  //     headerStyle: TextStyle(fontWeight: FontWeight.bold),
  //     headerDecoration: const BoxDecoration(color: PdfColors.grey300),
  //     // border: TableBorder(bottom: BorderSide(width: 1, color: PdfColors.black, style: BorderStyle.solid)),
  //     cellHeight: 30,
  //     cellAlignments: {
  //       0: Alignment.centerLeft,
  //       1: Alignment.centerLeft,
  //       2: Alignment.centerRight,
  //       3: Alignment.centerRight,
  //       4: Alignment.centerRight,
  //       5: Alignment.centerRight,
  //     },
  //     cellStyle: myStyle,
  //   );
  // }

  static Widget buildTotal(Invoice invoice) {
    // final netTotal = invoice.items
    //     .map((item) => item.unitprice * item.quantity)
    //     .reduce((item1, item2) => item1 + item2);
    // final vatPercent = invoice.items.first.vat;
    // final vat = netTotal * vatPercent;
    // final total = netTotal + vat;

    return Container(
        alignment: Alignment.centerRight,
        child: Row(children: [
          Spacer(flex: 6),
          Expanded(
              flex: 4,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildText(
                      title: 'Total',
                      value: invoice.price.totalamt.toStringAsFixed(2),
                      unite: true,
                    ),
                    buildText(
                      title: 'Discount',
                      value: invoice.price.discount.toStringAsFixed(2),
                      unite: true,
                    ),
                    buildText(
                      title: 'AFT Discount',
                      value: invoice.price.aft.toStringAsFixed(2),
                      unite: true,
                    ),
                    buildText(
                      title: 'Vat',
                      value: invoice.price.vat.toStringAsFixed(2),
                      unite: true,
                    ),
                    Divider(),
                    buildText(
                      title: 'Net total',
                      titleStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      value: invoice.price.netamt.toStringAsFixed(2),
                      unite: true,
                    ),
                    SizedBox(height: 2 * PdfPageFormat.mm),
                    Container(height: 1, color: PdfColors.grey400),
                    SizedBox(height: 0.5 * PdfPageFormat.mm),
                    Container(height: 1, color: PdfColors.grey400),
                  ]))
        ]));
  }

  static buildText({
    required String title,
    required String value,
    double width = double.infinity,
    TextStyle? titleStyle,
    bool unite = false,
  }) {
    final style = titleStyle ?? TextStyle(fontWeight: FontWeight.bold);

    return Container(
      width: width,
      child: Row(
        children: [
          Expanded(child: Text(title, style: style)),
          Text(value, style: unite ? style : null),
        ],
      ),
    );
  }
}
