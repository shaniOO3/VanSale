import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:vansales/api/api.dart';
import 'package:vansales/api/customer_supplier_model.dart';
import 'package:vansales/widgets/NotificationBody.dart';
import 'package:vansales/widgets/responsive_text_field.dart';

import '../utils.dart';

class PurchaseSavePage extends StatefulWidget {
  final CustomerSupplierModel supplier;
  final itemlist;

  const PurchaseSavePage({
    Key? key,
    required this.supplier,
    required this.itemlist,
  }) : super(key: key);

  @override
  _PurchaseSavePageState createState() =>
      _PurchaseSavePageState(supplier, itemlist);
}

class ItemList {
  int id;
  String name;
  int quantity;
  double vat;
  double price;

  ItemList({
    required this.id,
    required this.name,
    required this.quantity,
    required this.vat,
    required this.price,
  });
}

class _PurchaseSavePageState extends State<PurchaseSavePage> {
  _PurchaseSavePageState(CustomerSupplierModel _supplier, _itemlist) {
    supplier = _supplier;
    itemlist = _itemlist;

    for (int i = 0; i < itemlist.length; i++) {
      itemlist1.add(ItemList(
          id: itemlist[i]['id'],
          name: itemlist[i]['name'],
          quantity: itemlist[i]['quantity'],
          vat: itemlist[i]['vat'],
          price: itemlist[i]['price']));

      itemlist2.add(ItemList(
          id: itemlist[i]['id'],
          name: itemlist[i]['name'],
          quantity: itemlist[i]['quantity'],
          vat: itemlist[i]['vat'],
          price: itemlist[i]['price']));

      totalquantity =
          totalquantity + int.parse(itemlist[i]['quantity'].toString());

      //btotal = btotal + (int.parse(itemlist[i]['price']) * int.parse(itemlist[i]['quantity']));
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

  late CustomerSupplierModel supplier;
  late List itemlist;
  int lastid = 2000;

  List<ItemList> itemlist1 = <ItemList>[];
  List<ItemList> itemlist2 = <ItemList>[];
  int totalquantity = 0;

  TextEditingController discount = TextEditingController();
  TextEditingController amount = TextEditingController();

  DateTime dateTime = DateTime.now();

  double actualdiscount = 0;
  double btotal = 0;
  double idiscount = 0;
  double itotal = 0;
  double inet = 0;
  double ivat = 0;
  double irecived = 0;
  double ibalance = 0;
  double itotbalance = 0;

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

  void fetchPurchases() async {
    final endPointUri = Uri.parse(
        apiRootAddress + "/purchase/get/all/userId/${Preferences.getUserId()}");

    try {
      final response = await get(endPointUri);
      final jsonData = jsonDecode(response.body) as List;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (jsonData.isNotEmpty) {
          setState(() {
            lastid = jsonData[0]['purchaseId'];
          });
          print(lastid);
        }
      }
    } catch (err) {
      InAppNotification.show(
          child: NotificationBody(
            title: 'Error',
            body: "Can't connect to the Database",
            isError: true,
          ),
          context: context,
          duration: const Duration(seconds: 3),
          curve: Curves.decelerate);
    }
  }

  void postPurchase() async {
    final endPointUri = Uri.parse(apiRootAddress + "/purchase/Add");
    final currentDate = DateFormat('yyyy-MM-dd').format(dateTime);
    print(currentDate);

    int id = int.parse(lastid.toString().substring(3));
    id = id + 1;

    try {
      var body = jsonEncode([
        {
          "purchaseId": "200$id",
          "supplierId": "${supplier.csId}",
          "itemList": json.encode(itemlist),
          "totalAmount": "$btotal",
          "discount": "$idiscount",
          "aftDiscount": "$itotal",
          "netAmount": "$inet",
          "paidAmount": "$irecived",
          "balance": "$ibalance",
          "totalBalance": "$itotbalance",
          "vat": "$ivat",
          "tdate": currentDate,
          "userId": '${Preferences.getUserId()}',
        }
      ]);

      final response = await post(endPointUri,
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body: body);

      print(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        for (int i = 0; i < itemlist.length; i++) {
          final itemUpdateUri =
              Uri.parse(apiRootAddress + "/item/update/addstock");
          var body1 = jsonEncode({
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
        }

        final customerUpdateUri =
            Uri.parse(apiRootAddress + "/supplier/update/balance");
        var body2 = jsonEncode({'id': supplier.id, 'cbalance': itotbalance});
        final response2 = await post(customerUpdateUri,
            headers: {
              "Accept": "application/json",
              "content-type": "application/json"
            },
            body: body2);

        InAppNotification.show(
            child: NotificationBody(
              title: 'Data added successfully',
            ),
            context: context,
            duration: const Duration(seconds: 3),
            curve: Curves.decelerate);
        int count = 0;
        Navigator.of(context).popUntil((_) => count++ >= 3);
        // ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(content: Text("New purchase added successfully"))
        // );
      } else {
        InAppNotification.show(
            child: NotificationBody(
              title: 'Failed',
              body: "try again later",
              isError: true,
            ),
            context: context,
            duration: const Duration(seconds: 3),
            curve: Curves.decelerate);
        // ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(content: Text("Failed! try again later"))
        // );
      }
    } catch (err) {
      InAppNotification.show(
          child: NotificationBody(
            title: 'Error',
            body: "Can't connect to the Database",
            isError: true,
          ),
          context: context,
          duration: const Duration(seconds: 3),
          curve: Curves.decelerate);
    }
  }

  @override
  void initState() {
    fetchPurchases();
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
                                label: 'Paying amount',
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
                                'Paying Amount',
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
                                (ibalance = double.parse(
                                        (inet - irecived).toStringAsFixed(2)))
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
                                (itotbalance = supplier.cbalance! + ibalance)
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
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    margin:
                        const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        postPurchase();
                      },
                      child: const Text('SAVE'),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return SafeArea(
  //     child: Scaffold(
  //       resizeToAvoidBottomInset: false,
  //       body: Container(
  //         color: Colors.white,
  //         child: Column(
  //           children: [
  //             Container(
  //               padding: const EdgeInsets.only(top: 10, left: 20, bottom: 10),
  //               // decoration: BoxDecoration(
  //               //   color: Colors.white,
  //               //     boxShadow: [
  //               //       BoxShadow(
  //               //           color: Colors.indigo.withOpacity(0.2), blurRadius: 10.0),
  //               //     ]
  //               // ),
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Row(
  //                     children: [
  //                       InkWell(
  //                         onTap: () {
  //                           Navigator.pop(context);
  //                         },
  //                         child: Container(
  //                             child: Row(
  //                               children: [
  //                                 Icon(
  //                                   Icons.arrow_back_ios_outlined,
  //                                   color: Colors.indigo,
  //                                 ),
  //                                 SizedBox(
  //                                   width: 10,
  //                                 ),
  //                                 Text(
  //                                   "BILL",
  //                                   style: TextStyle(
  //                                       fontSize: 18,
  //                                       color: Colors.indigo,
  //                                       fontWeight: FontWeight.bold),
  //                                 ),
  //                               ],
  //                             )),
  //                       ),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             Container(
  //               margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
  //               height: 190,
  //               width: MediaQuery.of(context).size.width,
  //               decoration: BoxDecoration(
  //                   color: Colors.white.withOpacity(0.9),
  //                   borderRadius: BorderRadius.circular(12),
  //                   boxShadow: [BoxShadow(
  //                       color: Colors.indigo.withOpacity(0.4),
  //                       blurRadius: 20
  //                   )]
  //               ),
  //               child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Text(
  //                     'Net Amount',
  //                     style: TextStyle(
  //                         fontSize: 25,
  //                         fontWeight: FontWeight.w600,
  //                         color: Colors.grey
  //                     ),
  //                   ),
  //                   SizedBox(
  //                     height: 10,
  //                   ),
  //                   Text(
  //                     'DH ${(btotal - (discount.text.isEmpty ? 0 : int.parse(discount.text))) +
  //                         (double.parse((0.05 * (btotal - (discount.text.isEmpty ? 0 : int.parse(discount.text)))).toStringAsFixed(2)))}',
  //                     style: TextStyle(
  //                       fontSize: 35,
  //                       fontWeight: FontWeight.w800,
  //
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             Divider(),
  //             Container(
  //               padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     'Payment Detail',
  //                     textAlign: TextAlign.start,
  //                     style: TextStyle(
  //                         fontSize: 18,
  //                         fontWeight: FontWeight.bold
  //                     ),
  //                   ),
  //                   SizedBox(
  //                     height: 20,
  //                   ),
  //                   Row(
  //                     children: [
  //                       Expanded(
  //                         child: ResponsiveTextField(
  //                           label: 'Discount',
  //                           controller: discount,
  //                           type: TextInputType.numberWithOptions(decimal: true),
  //                         ),
  //                       ),
  //                       SizedBox(
  //                         width: 20,
  //                       ),
  //                       Expanded(
  //                         child: ResponsiveTextField(
  //                           label: 'Paying amount',
  //                           controller: amount,
  //                           type: TextInputType.numberWithOptions(decimal: true),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   SizedBox(
  //                     height: 10,
  //                   ),
  //                   Divider(),
  //                   SizedBox(
  //                     height: 10,
  //                   ),
  //                   Text(
  //                     'Summary',
  //                     textAlign: TextAlign.start,
  //                     style: TextStyle(
  //                         fontSize: 18,
  //                         fontWeight: FontWeight.bold
  //                     ),
  //                   ),
  //                   SizedBox(
  //                     height: 10,
  //                   ),
  //                   Row(
  //                     children: [
  //                       Expanded(
  //                         child: Text(
  //                           'Discount',
  //                           textAlign: TextAlign.start,
  //                           style: TextStyle(
  //                               fontSize: 18
  //                           ),
  //                         ),
  //                       ),
  //                       Expanded(
  //                         child: SizedBox(),
  //                       ),
  //                       Expanded(
  //                         child: Text(
  //                           'DH ${idiscount = discount.text.isEmpty ? 0.0 : double.parse(discount.text)}',
  //                           textAlign: TextAlign.start,
  //                           style: TextStyle(
  //                               fontSize: 18
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   SizedBox(
  //                     height: 10,
  //                   ),
  //                   Row(
  //                     children: [
  //                       Expanded(
  //                         child: Text(
  //                           'Total Amount',
  //                           textAlign: TextAlign.start,
  //                           style: TextStyle(
  //                               fontSize: 18
  //                           ),
  //                         ),
  //                       ),
  //                       Expanded(
  //                         child: SizedBox(),
  //                       ),
  //                       Expanded(
  //                         child: Text(
  //                           'DH ${total1 = btotal - (discount.text.isEmpty ? 0 : int.parse(discount.text))}',
  //                           textAlign: TextAlign.start,
  //                           style: TextStyle(
  //                               fontSize: 18
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   SizedBox(
  //                     height: 10,
  //                   ),
  //                   Row(
  //                     children: [
  //                       Expanded(
  //                         child: Text(
  //                           'Vat (5%)',
  //                           textAlign: TextAlign.start,
  //                           style: TextStyle(
  //                               fontSize: 18
  //                           ),
  //                         ),
  //                       ),
  //                       Expanded(
  //                         child: SizedBox(),
  //                       ),
  //                       Expanded(
  //                         child: Text(
  //                           'DH ${bvat = double.parse((0.05 * total1).toStringAsFixed(2))}',
  //                           textAlign: TextAlign.start,
  //                           style: TextStyle(
  //                               fontSize: 18
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   SizedBox(
  //                     height: 10,
  //                   ),
  //                   Row(
  //                     children: [
  //                       Expanded(
  //                         child: Text(
  //                           'Net Amount',
  //                           textAlign: TextAlign.start,
  //                           style: TextStyle(
  //                               fontSize: 18
  //                           ),
  //                         ),
  //                       ),
  //                       Expanded(
  //                         child: SizedBox(),
  //                       ),
  //                       Expanded(
  //                         child: Text(
  //                           'DH ${bnet = total1 + bvat}',
  //                           textAlign: TextAlign.start,
  //                           style: TextStyle(
  //                               fontSize: 18
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   SizedBox(
  //                     height: 10,
  //                   ),
  //                   Row(
  //                     children: [
  //                       Expanded(
  //                         child: Text(
  //                           'Paying Amount',
  //                           textAlign: TextAlign.start,
  //                           style: TextStyle(
  //                               fontSize: 18
  //                           ),
  //                         ),
  //                       ),
  //                       Expanded(
  //                         child: SizedBox(),
  //                       ),
  //                       Expanded(
  //                         child: Text(
  //                           'DH ${brecived = amount.text.isEmpty ? bnet : double.parse(amount.text)}',
  //                           textAlign: TextAlign.start,
  //                           style: TextStyle(
  //                               fontSize: 18
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   SizedBox(
  //                     height: 10,
  //                   ),
  //                   Divider(),
  //                   SizedBox(
  //                     height: 10,
  //                   ),
  //                   Row(
  //                     children: [
  //                       Expanded(
  //                         child: Text(
  //                           'Balance',
  //                           textAlign: TextAlign.start,
  //                           style: TextStyle(
  //                               fontSize: 18
  //                           ),
  //                         ),
  //                       ),
  //                       Expanded(
  //                         child: SizedBox(),
  //                       ),
  //                       Expanded(
  //                         child: Text(
  //                           'DH ${bbalance = double.parse((bnet - brecived).toStringAsFixed(2))}',
  //                           textAlign: TextAlign.start,
  //                           style: TextStyle(
  //                               fontSize: 18
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   SizedBox(
  //                     height: 10,
  //                   ),
  //                   Row(
  //                     children: [
  //                       Expanded(
  //                         child: Text(
  //                           'Total Balance',
  //                           textAlign: TextAlign.start,
  //                           style: TextStyle(
  //                               fontSize: 18
  //                           ),
  //                         ),
  //                       ),
  //                       Expanded(
  //                         child: SizedBox(),
  //                       ),
  //                       Expanded(
  //                         child: Text(
  //                           'DH ${btotbalance = supplier.cbalance! + bbalance}',
  //                           textAlign: TextAlign.start,
  //                           style: TextStyle(
  //                               fontSize: 18
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   SizedBox(
  //                     height: 10,
  //                   ),
  //                   Divider(),
  //                 ],
  //               ),
  //             ),
  //
  //             Container(
  //                 height: 50,
  //                 width: MediaQuery.of(context).size.width,
  //                 margin: EdgeInsets.symmetric(horizontal: 20),
  //                 clipBehavior: Clip.hardEdge,
  //                 decoration: BoxDecoration(
  //                   borderRadius: BorderRadius.circular(12),
  //                 ),
  //                 child: ElevatedButton(
  //                   onPressed: () {
  //                     postPurchase();
  //                     int count = 0;
  //                     Navigator.of(context).popUntil((_) => count++ >= 2);
  //                   },
  //                   child: const Text(
  //                       'SAVE'
  //                   ),
  //                 )
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

}
