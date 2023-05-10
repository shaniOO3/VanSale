import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:vansales/api/api.dart';
import 'package:vansales/api/customer_supplier_model.dart';
import 'package:vansales/loadingskeleton/sales_purchase_list_skeleton.dart';
import 'package:vansales/pdf/invoice_model.dart';
import 'package:vansales/pdf/pdf_invoice.dart';
import 'package:vansales/pdf/pdf_main.dart';
import 'package:vansales/popups/sale_add_popup.dart';
import 'package:vansales/popups/thermal_printer_popup.dart';
import 'package:vansales/utils.dart';
import 'package:vansales/widgets/NotificationBody.dart';
import 'package:vansales/widgets/blinking_add_button.dart';
import 'package:http/http.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({Key? key}) : super(key: key);

  @override
  _SalesPageState createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  late bool _isLoading;
  late bool _isError;
  List<Widget> salesData = [];
  final endPointUri = Uri.parse(
      apiRootAddress + "/sales/get/all/userId/${Preferences.getUserId()}");
  var _postsJson = [];

  final List<CustomerSupplierModel> _customers = <CustomerSupplierModel>[];
  List<CustomerSupplierModel> _customersDisplay = <CustomerSupplierModel>[];

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    fetchSales();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()

    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  void fetchSales() async {
    try {
      await fetchCustomers(false).then((value) {
        setState(() {
          _customers.addAll(value);
          _customersDisplay = _customers;
        });
      });
      final response = await get(endPointUri);
      final jsonData = jsonDecode(utf8.decode(response.bodyBytes)) as List;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        setState(() {
          _postsJson = jsonData;
          _isLoading = false;
        });
        getSalesData();
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
      setState(() {
        _isLoading = false;
        _isError = true;
      });
    }
  }

  void getSalesData() {
    List<dynamic> responseList = _postsJson;
    List<Widget> listItems = [];
    for (var sale in responseList) {
      int i;
      for (i = 0; i < _customersDisplay.length; i++) {
        if (sale['customerId'] == _customersDisplay[i].csId) {
          CustomerSupplierModel customerSupplierModel = _customersDisplay[i];

          listItems.add(
            Container(
              height: 100,
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              padding: const EdgeInsets.only(
                left: 20,
              ),
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.indigo.withOpacity(0.2),
                        blurRadius: 10.0),
                  ]),
              child: Slidable(
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      autoClose: true,
                      onPressed: (s) async {
                        // List itemslist = [];
                        // itemslist.add({
                        //   "id": itemId,
                        //   "name": item.text,
                        //   "quantity": int.parse(quantity.text),
                        //   "vat": itemvat,
                        //   "price": double.parse(sprice.text)
                        // });

                        List<InvoiceItem> invoiceitems = <InvoiceItem>[];

                        List itemlist = jsonDecode(sale['itemList']);
                        print(itemlist);

                        for (int i = 0; i < itemlist.length; i++) {
                          invoiceitems.add(InvoiceItem(
                              no: i + 1,
                              description: itemlist[i]['name'],
                              descriptionA: itemlist[i]['arabicname'],
                              quantity: itemlist[i]['quantity'],
                              vat: itemlist[i]['vat'],
                              unit: itemlist[i]['unit'] ?? " ",
                              unitprice: itemlist[i]['price']));
                        }

                        InvoicePrice price = InvoicePrice(
                            totalamt: sale['totalAmount'],
                            discount: sale['discount'],
                            vat: sale['vat'],
                            netamt: sale['netAmount'],
                            aft: sale['aftDiscount']);

                        final invoice = Invoice(
                          customer: customerSupplierModel,
                          items: invoiceitems,
                          price: price,
                          id: sale["saleId"],
                          date: sale['tdate'],
                          time: sale['ttime'],
                        );

                        final pdfFile = await PdfInvoice.generate(invoice);
                        print(pdfFile);
                        PdfMain.openFile(pdfFile);
                      },
                      backgroundColor:
                          const Color.fromRGBO(181, 75, 61, 0.1803921568627451),
                      foregroundColor: const Color.fromRGBO(181, 75, 61, 1.0),
                      icon: Icons.picture_as_pdf_outlined,
                      label: 'PDF',
                    ),
                    SlidableAction(
                      autoClose: true,
                      onPressed: (s) async {
                        List<InvoiceItem> invoiceitems = <InvoiceItem>[];

                        List itemlist = jsonDecode(sale['itemList']);

                        for (int i = 0; i < itemlist.length; i++) {
                          invoiceitems.add(InvoiceItem(
                              no: i + 1,
                              description: itemlist[i]['name'],
                              descriptionA: itemlist[i]['arabicname'],
                              quantity: itemlist[i]['quantity'],
                              vat: itemlist[i]['vat'],
                              unit: itemlist[i]['unit'] ?? " ",
                              unitprice: itemlist[i]['price']));
                        }

                        InvoicePrice price = InvoicePrice(
                            totalamt: sale['totalAmount'],
                            discount: sale['discount'],
                            vat: sale['vat'],
                            netamt: sale['netAmount'],
                            aft: sale['aftDiscount']);

                        final invoice = Invoice(
                          customer: customerSupplierModel,
                          items: invoiceitems,
                          price: price,
                          id: sale["saleId"],
                          date: sale['tdate'],
                          time: sale['ttime'],
                        );

                        await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return ThermalPrinterPopup(invoice: invoice);
                            });
                      },
                      backgroundColor:
                          const Color.fromRGBO(181, 95, 61, 0.1803921568627451),
                      foregroundColor: const Color.fromRGBO(181, 95, 61, 1.0),
                      icon: Icons.print,
                      label: 'Thermal',
                    ),
                  ],
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      // Container(
                      //   width: 60,
                      //   height: 60,
                      //   margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      //   decoration: BoxDecoration(
                      //     color: Colors.indigo,
                      //     borderRadius: BorderRadius.circular(30),
                      //     image: DecorationImage(
                      //         image: AssetImage('images/cprofile.png'), fit: BoxFit.fill),
                      //   ),
                      // ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 10),
                            child: Text(
                              'Invoice ${sale['saleId']}',
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                  color: Color.fromRGBO(0, 0, 0, 1),
                                  fontFamily: 'Roboto',
                                  fontSize: 15,
                                  letterSpacing: 0,
                                  fontWeight: FontWeight.bold,
                                  height: 1),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              '${_customersDisplay[i].name}',
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                  color: Color.fromRGBO(0, 0, 0, 1),
                                  fontFamily: 'Roboto',
                                  fontSize: 15,
                                  letterSpacing: 0,
                                  fontWeight: FontWeight.normal,
                                  height: 1),
                            ),
                          ),
                          Text(
                            '${sale['customerId']}',
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                                color:
                                    Color.fromRGBO(0, 0, 0, 0.6200000047683716),
                                fontFamily: 'Roboto',
                                fontSize: 12,
                                letterSpacing: 0,
                                fontWeight: FontWeight.normal,
                                height: 1),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                              padding: const EdgeInsets.only(
                                  top: 20, bottom: 10, right: 20),
                              child: Text(
                                '${sale["recievedAmount"]} Cr',
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                    color: Colors.green,
                                    fontFamily: 'Roboto',
                                    fontSize: 15,
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.normal,
                                    height: 1),
                              )),
                          // Padding(
                          //   padding: const EdgeInsets.only(bottom: 10),
                          //   child: Text(
                          //     '${sale["balance"]}',
                          //     textAlign: TextAlign.left,
                          //     style: TextStyle(
                          //         color: Color.fromRGBO(0, 0, 0, 0.6200000047683716),
                          //         fontFamily: 'Roboto',
                          //         fontSize: 12,
                          //         letterSpacing: 0,
                          //         fontWeight: FontWeight.normal,
                          //         height: 1),
                          //   ),
                          // ),
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: Text(
                              '${sale["totalBalance"]} Dr',
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                  color: Colors.red,
                                  fontFamily: 'Roboto',
                                  fontSize: 12,
                                  letterSpacing: 0,
                                  fontWeight: FontWeight.normal,
                                  height: 1),
                            ),
                          ),
                        ],
                      ),
                    ]),
              ),
            ),
          );
          i = _customersDisplay.length;
        }
      }
    }

    setState(() {
      salesData = listItems;
    });
  }

  @override
  void initState() {
    _isLoading = true;
    _isError = false;
    fetchSales();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
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
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
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
                          "SALES",
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.indigo,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  InkWell(
                    onTap: () async {
                      await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return SaleAddPopup(
                              isReport: false,
                            );
                          });
                      fetchSales();
                    },
                    child: Container(
                      width: 160,
                      margin: const EdgeInsets.only(right: 20),
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.indigo.withOpacity(0.5),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20.0))),
                      child: const Text(
                        "New Sale",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.indigo,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SmartRefresher(
                  enablePullDown: true,
                  header: WaterDropMaterialHeader(
                    backgroundColor: Colors.indigo.shade300,
                  ),
                  controller: _refreshController,
                  onRefresh: _onRefresh,
                  onLoading: _onLoading,
                  child: _isLoading
                      ? ListView.builder(
                          itemBuilder: (context, index) =>
                              const SalesPurchaseListSkelton(),
                          itemCount: 6)
                      : _isError
                          ? Container(
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text("Can't connect to Database"),
                                  Text("Try Refreshing")
                                ],
                              ),
                            )
                          : (salesData.isNotEmpty
                              ? ListView.builder(
                                  itemCount: salesData.length,
                                  itemBuilder: (BuildContext context, index) {
                                    return salesData[index];
                                  },
                                )
                              : Container(
                                  alignment: Alignment.center,
                                  child: InkWell(
                                    onTap: () async {
                                      await showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return SaleAddPopup(
                                              isReport: false,
                                            );
                                          });
                                      fetchSales();
                                    },
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Text("Oop's No Sales Found"),
                                        BlinkingAddButton(),
                                        Text("Add New Sale")
                                      ],
                                    ),
                                  ),
                                ))),
            )
          ],
        ),
      ),
    );
  }
}
