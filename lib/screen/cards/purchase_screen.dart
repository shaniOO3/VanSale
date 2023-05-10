import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:vansales/api/api.dart';
import 'package:vansales/api/customer_supplier_model.dart';
import 'package:vansales/loadingskeleton/sales_purchase_list_skeleton.dart';
import 'package:vansales/popups/purchase_add_popup.dart';
import 'package:vansales/utils.dart';
import 'package:vansales/widgets/NotificationBody.dart';
import 'package:vansales/widgets/blinking_add_button.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({Key? key}) : super(key: key);

  @override
  _PurchaseScreenState createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  late bool _isLoading;
  late bool _isError;
  List<Widget> purchaseData = [];

  var _postsJson = [];

  final List<CustomerSupplierModel> _suppliers = <CustomerSupplierModel>[];
  List<CustomerSupplierModel> _suppliersDisplay = <CustomerSupplierModel>[];

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    fetchPurchases();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()

    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  void fetchPurchases() async {
    final endPointUri = Uri.parse(
        apiRootAddress + "/purchase/get/all/userId/${Preferences.getUserId()}");

    try {
      await fetchSupplier(false).then((value) {
        setState(() {
          _suppliers.addAll(value);
          _suppliersDisplay = _suppliers;
        });
      });
      final response = await get(endPointUri);
      final jsonData = jsonDecode(response.body) as List;
      setState(() {
        _postsJson = jsonData;
      });
      if (response.statusCode >= 200 && response.statusCode < 300) {
        setState(() {
          _isLoading = false;
        });
        getPurchaseData();
      }
    } catch (err) {
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

  void getPurchaseData() {
    List<dynamic> responseList = _postsJson;
    List<Widget> listItems = [];
    for (var purchase in responseList) {
      int i;
      for (i = 0; i < _suppliersDisplay.length; i++) {
        if (purchase['supplierId'] == _suppliersDisplay[i].csId) {
          listItems.add(
            Container(
              height: 100,
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              padding: const EdgeInsets.only(left: 20, right: 20),
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.indigo.withOpacity(0.2),
                        blurRadius: 10.0),
                  ]),
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
                            'Invoice ${purchase['purchaseId']}',
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
                            '${_suppliersDisplay[i].name}',
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
                          '${purchase['supplierId']}',
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
                            padding: const EdgeInsets.only(top: 20, bottom: 10),
                            child: Text(
                              '${purchase["paidAmount"]} Cr',
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
                        Text(
                          '${purchase["totalBalance"]} Dr',
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                              color: Colors.red,
                              fontFamily: 'Roboto',
                              fontSize: 12,
                              letterSpacing: 0,
                              fontWeight: FontWeight.normal,
                              height: 1),
                        ),
                      ],
                    ),
                  ]),
            ),
          );
          i = _suppliersDisplay.length;
        }
      }
    }

    setState(() {
      purchaseData = listItems;
    });
  }

  @override
  void initState() {
    _isLoading = true;
    _isError = false;
    fetchPurchases();
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
                          "PURCHASES",
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
                  GestureDetector(
                    onTap: () async {
                      await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const PurchaseAddPopup();
                          });
                      print('njan poyii');
                      fetchPurchases();
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
                        "New Purchase",
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
                        : purchaseData.isNotEmpty
                            ? ListView.builder(
                                itemCount: purchaseData.length,
                                itemBuilder: (BuildContext context, index) {
                                  return purchaseData[index];
                                },
                              )
                            : Container(
                                alignment: Alignment.center,
                                child: InkWell(
                                  onTap: () async {
                                    return showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return const PurchaseAddPopup();
                                        });
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Text("Oop's No Purchase Found"),
                                      BlinkingAddButton(),
                                      Text("Add New Purchase")
                                    ],
                                  ),
                                ),
                              ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
