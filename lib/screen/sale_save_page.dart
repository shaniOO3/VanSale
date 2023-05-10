import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:printing/printing.dart';
import 'package:vansales/api/api.dart';
import 'package:vansales/api/customer_supplier_model.dart';
import 'package:vansales/pdf/invoice_model.dart';
import 'package:vansales/pdf/pdf_invoice.dart';
import 'package:vansales/pdf/pdf_main.dart';
import 'package:image/image.dart' as Imag;
import 'package:vansales/pdf/thermal_printer.dart';
import 'package:vansales/popups/thermal_printer_popup.dart';
import 'package:vansales/pdf/thermal.dart';
import 'package:vansales/widgets/NotificationBody.dart';
import 'package:vansales/widgets/responsive_text_field.dart';

import '../utils.dart';

class SaleSavePage extends StatefulWidget {
  final CustomerSupplierModel customer;
  final itemlist;
  final date;

  const SaleSavePage(
      {Key? key,
      required this.customer,
      required this.itemlist,
      required this.date})
      : super(key: key);

  @override
  _SaleSavePageState createState() =>
      _SaleSavePageState(customer, itemlist, date);
}

class ItemList {
  int id;
  String name;
  String nameA;
  int quantity;
  double vat;
  String unit;
  double price;

  ItemList({
    required this.id,
    required this.name,
    required this.nameA,
    required this.quantity,
    required this.vat,
    required this.unit,
    required this.price,
  });
}

class _SaleSavePageState extends State<SaleSavePage> {
  _SaleSavePageState(CustomerSupplierModel _customer, _itemlist, _date) {
    customer = _customer;
    itemlist = _itemlist;
    date = _date;

    print(itemlist);
    for (int i = 0; i < itemlist.length; i++) {
      itemlist1.add(ItemList(
          id: itemlist[i]['id'],
          name: itemlist[i]['name'],
          nameA: itemlist[i]['arabicname'],
          quantity: itemlist[i]['quantity'],
          vat: itemlist[i]['vat'],
          unit: itemlist[i]['unit'],
          price: itemlist[i]['price']));

      itemlist2.add(ItemList(
          id: itemlist[i]['id'],
          name: itemlist[i]['name'],
          nameA: itemlist[i]['arabicname'],
          quantity: itemlist[i]['quantity'],
          vat: itemlist[i]['vat'],
          unit: itemlist[i]['unit'],
          price: itemlist[i]['price']));

      totalquantity =
          totalquantity + int.parse(itemlist[i]['quantity'].toString());
    }

    for (int i = 0; i < itemlist.length; i++) {
      if (Preferences.getIncludingVat()) {
        btotal = btotal +
            ((itemlist[i]['price'] -
                    (itemlist[i]['vat'] * itemlist[i]['price'])) *
                itemlist[i]['quantity']);
      } else {
        btotal = btotal + (itemlist[i]['price'] * itemlist[i]['quantity']);
      }
    }
    priceCalc();
  }

  late CustomerSupplierModel customer;
  late List itemlist;
  int lastid = 1000;

  List<ItemList> itemlist1 = <ItemList>[];
  List<ItemList> itemlist2 = <ItemList>[];
  int totalquantity = 0;

  TextEditingController discount = TextEditingController();
  TextEditingController amount = TextEditingController();

  // DateTime dateTime = DateTime.now();

  late var date;
  late var time;
  late int id;

  bool _isPressed = false;

  double actualdiscount = 0;

  double btotal = 0;
  double idiscount = 0;
  double itotal = 0;
  double inet = 0;
  double ivat = 0;
  double irecived = 0;
  double ibalance = 0;
  double itotbalance = 0;

  void fetchSales() async {
    final endPointUri = Uri.parse(
        apiRootAddress + "/sales/get/all/userId/${Preferences.getUserId()}");
    try {
      final response = await get(endPointUri);
      final jsonData = jsonDecode(response.body) as List;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (jsonData.isNotEmpty) {
          setState(() {
            lastid = jsonData[0]['saleId'];
          });
        }
        print(lastid);
      }
    } catch (err) {
      print(err);
      InAppNotification.show(
          child: NotificationBody(
            title: 'Error',
            body: "Can't connect to the Database",
            isError: true,
          ),
          context: context,
          duration: const Duration(seconds: 2),
          curve: Curves.decelerate);
    }
  }

  void priceCalc() {
    ivat = 0;
    itotal = 0;
    inet = 0;

    for (int i = 0; i < itemlist2.length; i++) {
      ivat = ivat +
          (itemlist2[i].quantity * (itemlist2[i].vat * itemlist2[i].price));

      if (Preferences.getIncludingVat()) {
        itotal = itotal +
            ((itemlist2[i].price - (itemlist2[i].vat * itemlist2[i].price)) *
                itemlist2[i].quantity);
      } else {
        itotal = itotal + (itemlist2[i].price * itemlist2[i].quantity);
      }
    }
    inet = itotal + ivat;
  }

  void printInvoice(bool isPrint, bool isThermal) async {
    List<InvoiceItem> invoiceitems = <InvoiceItem>[];
    print(itemlist2.length);
    //print(itemlist[2]['name']);
    for (int i = 0; i < itemlist1.length; i++) {
      invoiceitems.add(InvoiceItem(
          no: i + 1,
          description: itemlist1[i].name,
          descriptionA: itemlist1[i].nameA,
          quantity: itemlist1[i].quantity,
          vat: itemlist1[i].vat,
          unit: itemlist1[i].unit,
          unitprice: itemlist1[i].price));
      //print(invoiceitems[i].description);
      print(i);
    }

    InvoicePrice price = InvoicePrice(
        totalamt: btotal,
        discount: idiscount,
        vat: ivat,
        netamt: inet,
        aft: itotal);

    final invoice = Invoice(
        customer: customer,
        items: invoiceitems,
        price: price,
        id: id,
        time: time,
        date: date);

    if (isPrint && !isThermal) {
      final pdfFile = await PdfInvoice.generate(invoice);
      print(pdfFile);
      PdfMain.openFile(pdfFile);
    }

    if (isPrint && isThermal) {
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return ThermalPrinterPopup(invoice: invoice);
          });
    }
  }

  void postSale() async {
    final endPointUri = Uri.parse(apiRootAddress + "/sales/Add");
    // final currentDate = DateFormat('yyyy-MM-dd').format(dateTime);
    DateTime dateTime = DateTime.now();
    // date = DateFormat('yyyy-MM-dd').format(dateTime);
    time = DateFormat('HH:mm').format(dateTime);

    final endPointUriId = Uri.parse(
        apiRootAddress + "/sales/get/all/userId/${Preferences.getUserId()}");
    try {
      final response = await get(endPointUriId);
      final jsonData = jsonDecode(response.body) as List;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (jsonData.isNotEmpty) {
          setState(() {
            lastid = jsonData[0]['saleId'];
          });
        }
        id = lastid + 1;
        print(lastid);
        try {
          var body = jsonEncode([
            {
              "saleId": "$id",
              "customerId": "${customer.csId}",
              "itemList": json.encode(itemlist),
              "totalAmount": "${btotal.toStringAsFixed(2)}",
              "discount": "${idiscount.toStringAsFixed(2)}",
              "aftDiscount": "${itotal.toStringAsFixed(2)}",
              "netAmount": "${inet.toStringAsFixed(2)}",
              "recievedAmount": "${irecived.toStringAsFixed(2)}",
              "balance": "${ibalance.toStringAsFixed(2)}",
              "totalBalance": "${itotbalance.toStringAsFixed(2)}",
              "vat": "${ivat.toStringAsFixed(2)}",
              "userId": '${Preferences.getUserId()}',
              "tdate": date,
              "ttime": time
            }
          ]);

          print(body);

          final response = await post(endPointUri,
              headers: {
                "Accept": "application/json",
                "content-type": "application/json"
              },
              body: body);

          if (response.statusCode >= 200 && response.statusCode < 300) {
            for (int i = 0; i < itemlist.length; i++) {
              final itemUpdateUri =
                  Uri.parse(apiRootAddress + "/item/update/substock");
              var body1 = jsonEncode({
                // 'id': '${itemlist[i]['id']}',
                'itemId': '${itemlist[i]['id']}',
                'stock': '${itemlist[i]['quantity']}',
                'userId': '${Preferences.getUserId()}'
              });
              final response1 = await post(itemUpdateUri,
                  headers: {
                    "Accept": "application/json",
                    "content-type": "application/json"
                  },
                  body: body1);
              print('stock update code :- ${response1.statusCode}');
            }

            final customerUpdateUri =
                Uri.parse(apiRootAddress + "/customer/update/balance");
            var body2 =
                jsonEncode({'id': customer.id, 'cbalance': itotbalance});
            final response2 = await post(customerUpdateUri,
                headers: {
                  "Accept": "application/json",
                  "content-type": "application/json"
                },
                body: body2);
            print('balance update code :- ${response2.statusCode}');
            print(body);
            print("date of invoice :-" + date);

            InAppNotification.show(
                child: NotificationBody(title: 'Data added successfully'),
                context: context,
                duration: const Duration(seconds: 2),
                curve: Curves.decelerate);

            showCupertinoModalPopup(
                barrierDismissible: false,
                context: context,
                builder: buildActionSheet);
          } else {
            InAppNotification.show(
                child: NotificationBody(
                  title: 'Failed',
                  body: response.body,
                  isError: true,
                ),
                context: context,
                duration: const Duration(seconds: 3),
                curve: Curves.decelerate);

            setState(() {
              _isPressed = false;
            });
          }
        } on HttpException catch (err) {
          InAppNotification.show(
              child: NotificationBody(
                title: 'Error',
                body: err.message,
                isError: true,
              ),
              context: context,
              duration: const Duration(seconds: 3),
              curve: Curves.decelerate);

          setState(() {
            _isPressed = false;
          });
        }
      }
    } catch (err) {
      print(err);
      InAppNotification.show(
          child: NotificationBody(
            title: 'Error',
            body: "Can't connect to the Database",
            isError: true,
          ),
          context: context,
          duration: const Duration(seconds: 2),
          curve: Curves.decelerate);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 5,
                child: Container(
                  padding: const EdgeInsets.only(top: 10, left: 20, bottom: 10),
                  // decoration: BoxDecoration(
                  //   color: Colors.white,
                  //     boxShadow: [
                  //       BoxShadow(
                  //           color: Colors.indigo.withOpacity(0.2), blurRadius: 10.0),
                  //     ]
                  // ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                                child: Row(
                              children: const [
                                Icon(
                                  Icons.arrow_back_ios_outlined,
                                  color: Colors.indigo,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "BILL",
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.indigo,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            )),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 40,
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      height: 170,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.indigo.withOpacity(0.4),
                                blurRadius: 20)
                          ]),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Net Amount',
                            style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            inet.toStringAsFixed(2),
                            // '${(btotal - (discount.text.isEmpty ? 0 : int.parse(discount.text))) +
                            //     (double.parse((0.05 * (btotal - (discount.text.isEmpty ? 0 : int.parse(discount.text)))).toStringAsFixed(2)))}',
                            style: const TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 270,
                bottom: 70,
                child: Container(
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, bottom: 20, top: 10),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Payment Detail',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: ResponsiveTextField(
                                label: 'Discount',
                                controller: discount,
                                action: TextInputAction.done,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp("[0-9%.]"))
                                ],
                                onChanged: (e) {
                                  if (discount.text.isNotEmpty) {
                                    List<String> splitDiscount =
                                        discount.text.split('');
                                    if (splitDiscount.last == '%') {
                                      splitDiscount.removeLast();
                                      double newDiscountpercent =
                                          double.parse(splitDiscount.join());
                                      actualdiscount =
                                          (newDiscountpercent / 100) * btotal;
                                    } else {
                                      actualdiscount =
                                          double.parse(discount.text);
                                      print(actualdiscount);
                                    }
                                  }
                                  double eachDis = (discount.text.isEmpty
                                          ? 0
                                          : actualdiscount) /
                                      totalquantity;
                                  for (int i = 0; i < itemlist1.length; i++) {
                                    double price = itemlist1[i].price;
                                    itemlist2[i].price = price - eachDis;
                                  }
                                  priceCalc();
                                },
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Expanded(
                              child: ResponsiveTextField(
                                label: 'Reciving amount',
                                controller: amount,
                                type: const TextInputType.numberWithOptions(
                                    decimal: true),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Divider(),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          'Summary',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Total Amount',
                                textAlign: TextAlign.start,
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            const Expanded(
                              child: SizedBox(),
                            ),
                            Expanded(
                              child: Text(
                                btotal.toStringAsFixed(2),
                                // '${itotal = btotal - (discount.text.isEmpty ? 0 : int.parse(discount.text))}',
                                textAlign: TextAlign.start,
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Discount',
                                textAlign: TextAlign.start,
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            const Expanded(
                              child: SizedBox(),
                            ),
                            Expanded(
                              child: Text(
                                (idiscount = (discount.text.isEmpty
                                        ? 0.0
                                        : actualdiscount))
                                    .toStringAsFixed(2),
                                textAlign: TextAlign.start,
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'AFT Discount',
                                textAlign: TextAlign.start,
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            const Expanded(
                              child: SizedBox(),
                            ),
                            Expanded(
                              child: Text(
                                itotal.toStringAsFixed(2),
                                textAlign: TextAlign.start,
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Vat',
                                textAlign: TextAlign.start,
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            const Expanded(
                              child: SizedBox(),
                            ),
                            Expanded(
                              child: Text(
                                ivat.toStringAsFixed(2),
                                // '${ivat = double.parse((0.05 * itotal).toStringAsFixed(2))}',
                                textAlign: TextAlign.start,
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Net Amount',
                                textAlign: TextAlign.start,
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            const Expanded(
                              child: SizedBox(),
                            ),
                            Expanded(
                              child: Text(
                                inet.toStringAsFixed(2),
                                textAlign: TextAlign.start,
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Reciving Amount',
                                textAlign: TextAlign.start,
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            const Expanded(
                              child: SizedBox(),
                            ),
                            Expanded(
                              child: Text(
                                (irecived = amount.text.isEmpty
                                        ? inet
                                        : double.parse(amount.text))
                                    .toStringAsFixed(2),
                                textAlign: TextAlign.start,
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Divider(),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Balance',
                                textAlign: TextAlign.start,
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            const Expanded(
                              child: SizedBox(),
                            ),
                            Expanded(
                              child: Text(
                                (ibalance = (inet > irecived
                                        ? double.parse((inet - irecived)
                                            .toStringAsFixed(2))
                                        : 0))
                                    .toStringAsFixed(2),
                                textAlign: TextAlign.start,
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Total Balance',
                                textAlign: TextAlign.start,
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            const Expanded(
                              child: SizedBox(),
                            ),
                            Expanded(
                              child: Text(
                                (itotbalance = customer.cbalance! +
                                        double.parse((inet - irecived)
                                            .toStringAsFixed(2)))
                                    .toStringAsFixed(2),
                                textAlign: TextAlign.start,
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Divider(),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: Container(
                    height: 50,
                    width: (MediaQuery.of(context).size.width / 2) - 30,
                    //margin: const EdgeInsets.only(left: 10, right: 20),
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_isPressed == false) {
                          setState(() {
                            _isPressed = true;
                          });
                          postSale();
                        }
                      },
                      style: _isPressed
                          ? ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Colors.indigo.shade300))
                          : null,
                      child: _isPressed
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.indigo.shade800,
                              ))
                          : const Text('SAVE & PRINT'),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildActionSheet(BuildContext context) => WillPopScope(
        onWillPop: () async {
          InAppNotification.show(
              child: NotificationBody(
                  title: 'Invoice saved already', body: "Please press 'CLOSE'"),
              context: context,
              duration: const Duration(seconds: 3),
              curve: Curves.decelerate);
          return false;
        },
        child: CupertinoActionSheet(
          actions: [
            // CupertinoActionSheetAction(
            //     onPressed: () {
            //       if (_isSaved){
            //         InAppNotification.show(
            //             child: NotificationBody(title: 'Invoice already saved',body: "Please press 'CLOSE' to view all sales", isError: true,),
            //             context: context,
            //             duration: const Duration(seconds: 3),
            //             curve: Curves.decelerate
            //         );
            //       }else{
            //       postSale(false,false);
            //       }
            //     },
            //     child: Text('Save')
            // ),
            CupertinoActionSheetAction(
                onPressed: () => printInvoice(true, false),
                child: const Text('Generate PDF Invoice')),
            CupertinoActionSheetAction(
                onPressed: () => printInvoice(true, true),
                child: const Text('Generate Thermal Invoice')),
            // CupertinoActionSheetAction(
            //     onPressed: () {
            //       int count = 0;
            //       Navigator.of(context).popUntil((_) => count++ >= 4);
            //     },
            //     child: Text('Close')
            // ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              // if(_isSaved){
              //   InAppNotification.show(
              //       child: NotificationBody(title: 'Invoice saved',body: "Please press 'CLOSE' to view all sales"),
              //       context: context,
              //       duration: const Duration(seconds: 3),
              //       curve: Curves.decelerate
              //   );
              // }else {
              //   Navigator.pop(context);
              // }

              int count = 0;
              Navigator.of(context).popUntil((_) => count++ >= 4);
            },
            child: const Text('Close'),
          ),
        ),
      );
}
