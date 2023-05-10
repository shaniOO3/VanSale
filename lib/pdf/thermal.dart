import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:vansales/pdf/invoice_model.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../utils.dart';

class Thermal {
  // static Uint8List fontData = File('Almarai-Regular.ttf').readAsBytesSync();
  // var data = fontData.buffer.asByteData();
  static var arabFont;

  static Future<Uint8List> generate(
      Invoice invoice,
      String name,
      String companyName,
      String companyNameA,
      String addressA,
      String vatNo,
      String phone) async {
    final pdf = Document();

    // DateTime dateTime = DateTime.now();
    // final date = DateFormat('dd-MM-yyyy').format(dateTime);
    // final time = DateFormat('hh:mm aa').format(dateTime);

    var data = await rootBundle.load("assets/fonts/Almarai-Regular.ttf");
    arabFont = Font.ttf(data);

    // final tag1 = utf8.encode('$companyName ');
    // final tag2 = utf8.encode('$vatNo ');
    // final tag3 = utf8.encode('${invoice.date} ${invoice.time} ');
    // final tag4 = utf8.encode('${invoice.price.netamt} ');
    // final tag5 = utf8.encode('${invoice.price.vat}');

    final tag1no = Uint8List.fromList([1]);
    final tag1len = Uint8List.fromList([utf8.encode(companyNameA).length]);
    final tag1 = utf8.encode(companyNameA);

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

    pdf.addPage(
      Page(
        pageFormat: PdfPageFormat.roll80,
        //margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        build: (context) => Container(
          //padding: const EdgeInsets.all(10),
          //decoration: BoxDecoration(border: Border.all(color: PdfColors.black)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.center,
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text(
                        companyNameA,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            font: arabFont,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text(
                        addressA,
                        style: TextStyle(
                          font: arabFont,
                          fontSize: 9,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$vatNo :',
                            style: const TextStyle(
                              fontSize: 9,
                            ),
                          ),
                          Text(
                            'رقم الضريبي',
                            style: TextStyle(
                              font: arabFont,
                              fontSize: 9,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$phone :',
                            style: const TextStyle(
                              fontSize: 9,
                            ),
                          ),
                          Text(
                            'رقم الجوال',
                            style: TextStyle(
                              font: arabFont,
                              fontSize: 9,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'فاتورة ضريبة مبسطة',
                      style: TextStyle(
                        font: arabFont,
                        fontSize: 9,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    // Text('_______________________'),
                    Text('-------------------------------------------------'),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            Text(
                              '${invoice.id} :',
                              style: TextStyle(
                                font: arabFont,
                                fontSize: 9,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                            Text(
                              'رقم الفتورة',
                              style: TextStyle(
                                font: arabFont,
                                fontSize: 9,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ]),
                          Row(children: [
                            Text(
                              '${invoice.time} :',
                              style: TextStyle(
                                font: arabFont,
                                fontSize: 9,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                            Text(
                              'الوقت',
                              style: TextStyle(
                                font: arabFont,
                                fontSize: 9,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ]),
                        ]),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            Text(
                              '${invoice.date} :',
                              style: TextStyle(
                                font: arabFont,
                                fontSize: 9,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                            Text(
                              'التاريخ',
                              style: TextStyle(
                                font: arabFont,
                                fontSize: 9,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ]),
                          Text(
                            name,
                            style: TextStyle(
                              font: arabFont,
                              fontSize: 9,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ]),
                    Text('-------------------------------------------------'),
                    Row(children: [
                      Text(
                        'Customer Name: ',
                        style: TextStyle(
                          font: arabFont,
                          fontSize: 9,
                        ),
                      ),
                      Text(
                        invoice.customer.name!,
                        style: TextStyle(
                          font: arabFont,
                          fontSize: 9,
                        ),
                      ),
                    ]),
                    Row(children: [
                      Text(
                        'Vat No: ',
                        style: TextStyle(
                          font: arabFont,
                          fontSize: 9,
                        ),
                      ),
                      Text(
                        invoice.customer.vatNo!,
                        style: TextStyle(
                          font: arabFont,
                          fontSize: 9,
                        ),
                      ),
                    ]),
                    Text('-------------------------------------------------'),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'الرقم',
                            style: TextStyle(
                              font: arabFont,
                              fontSize: 9,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                          Text(
                            'كمية',
                            style: TextStyle(
                              font: arabFont,
                              fontSize: 9,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                          Text(
                            'السعر',
                            style: TextStyle(
                              font: arabFont,
                              fontSize: 9,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                          Text(
                            'الاجمالية',
                            style: TextStyle(
                              font: arabFont,
                              fontSize: 9,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ]),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'No',
                            style: TextStyle(
                              font: arabFont,
                              fontSize: 9,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                          Text(
                            'Qty',
                            style: TextStyle(
                              font: arabFont,
                              fontSize: 9,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                          Text(
                            'Price',
                            style: TextStyle(
                              font: arabFont,
                              fontSize: 9,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                          Text(
                            'Total',
                            style: TextStyle(
                              font: arabFont,
                              fontSize: 9,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ]),
                    Text('-------------------------------------------------'),
                  ]),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: getItems(invoice),
              ),
              Text('-------------------------------------------------'),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Text(
                    'Total Amount / ',
                    style: TextStyle(
                      font: arabFont,
                      fontSize: 9,
                    ),
                  ),
                  Text(
                    'اجمالي الفاتورة',
                    style: TextStyle(
                      font: arabFont,
                      fontSize: 9,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ]),
                Text(
                  (invoice.price.totalamt).toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 9,
                  ),
                ),
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Text(
                    'AFT Discount / ',
                    style: const TextStyle(
                      fontSize: 9,
                    ),
                  ),
                  Text(
                    'المجموع بعد الخصم',
                    style: TextStyle(
                      font: arabFont,
                      fontSize: 9,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ]),
                Text(
                  (invoice.price.aft).toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 9,
                  ),
                ),
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Text(
                    'Vat Amount / ',
                    style: TextStyle(
                      font: arabFont,
                      fontSize: 9,
                    ),
                  ),
                  Text(
                    'قيمة الضريبة',
                    style: TextStyle(
                      font: arabFont,
                      fontSize: 9,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ]),
                Text(
                  (invoice.price.vat).toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 9,
                  ),
                ),
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Text(
                    'Net Amount / ',
                    style: TextStyle(
                      font: arabFont,
                      fontSize: 9,
                    ),
                  ),
                  Text(
                    'المبلغ الصافي',
                    style: TextStyle(
                      font: arabFont,
                      fontSize: 9,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ]),
                Text(
                  (invoice.price.netamt).toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 9,
                  ),
                ),
              ]),
              Text('-------------------------------------------------'),
              Container(
                height: 50,
                width: 50,
                child: BarcodeWidget(
                  barcode: Barcode.qrCode(),
                  data: base64Encode(added),
                ),
              ),
              Text('-------------------------------------------------'),
              Text('Thank you for visit, Come again',
                  style: const TextStyle(fontSize: 9)),
              Text('-------------------------------------------------'),
              Text('-------------------------------------------------'),
            ],
          ),
        ),
      ),
    );

    return pdf.save();
    // return PdfMain.saveDocument(name: 'sale ${DateTime.now().minute}', pdf: pdf);
  }

  static List<Widget> getItems(Invoice invoice) {
    List<Widget> listitems = [];

    for (var item in invoice.items) {
      listitems.add(
        Column(children: [
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              item.descriptionA,
              style: TextStyle(
                font: arabFont,
                fontSize: 9,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              item.description,
              style: const TextStyle(
                fontSize: 9,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
              '${item.no}',
              style: TextStyle(
                font: arabFont,
                fontSize: 9,
              ),
              textDirection: TextDirection.rtl,
            ),
            Text(
              '${item.quantity}',
              style: TextStyle(
                font: arabFont,
                fontSize: 9,
              ),
              textDirection: TextDirection.rtl,
            ),
            Text(
              Preferences.getIncludingVat()
                  ? (item.unitprice - (item.vat * item.unitprice))
                      .toStringAsFixed(2)
                  : item.unitprice.toStringAsFixed(2),
              style: TextStyle(
                font: arabFont,
                fontSize: 9,
              ),
              textDirection: TextDirection.rtl,
            ),
            Text(
              Preferences.getIncludingVat()
                  ? (item.quantity *
                          (item.unitprice - (item.vat * item.unitprice)))
                      .toStringAsFixed(2)
                  : (item.quantity * item.unitprice).toStringAsFixed(2),
              style: TextStyle(
                font: arabFont,
                fontSize: 9,
              ),
              textDirection: TextDirection.rtl,
            ),
          ]),
        ]),
      );
    }

    return listitems;
  }
}
