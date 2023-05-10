import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:vansales/api/api.dart';
import 'package:vansales/loadingskeleton/custo_suppl_list_skeleton.dart';
import 'package:vansales/popups/customer_add_popup.dart';
import 'package:vansales/utils.dart';
import 'package:vansales/widgets/NotificationBody.dart';
import 'package:vansales/widgets/blinking_add_button.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({Key? key}) : super(key: key);

  @override
  _CustomerScreenState createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  int lastid = 3000;
  late bool _isLoading;
  late bool _isError;
  List<Widget> customersData = [];

  var _postsJson = [];

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    fetchCustomers();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()

    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  void fetchCustomers() async {
    final endPointUri = Uri.parse(
        apiRootAddress + "/customer/get/all/userId/${Preferences.getUserId()}");
    try {
      final response = await get(endPointUri);
      final jsonData = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      setState(() {
        _postsJson = jsonData;
      });
      if (_postsJson.isNotEmpty) {
        lastid = _postsJson[_postsJson.length - 1]['id'];
      }
      if (response.statusCode >= 200 && response.statusCode < 300) {
        setState(() {
          _isLoading = false;
        });
        getCustomerData();
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
          duration: const Duration(seconds: 3),
          curve: Curves.decelerate);
      setState(() {
        _isLoading = false;
        _isError = true;
      });
    }
  }

  void deleteCustomer(url) async {
    try {
      final response = await post(url);
      print(response.statusCode);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        fetchCustomers();
      } else {
        InAppNotification.show(
            child: NotificationBody(
              title: 'Failed',
              isError: true,
            ),
            context: context,
            duration: const Duration(seconds: 3),
            curve: Curves.decelerate);
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

  void getCustomerData() {
    List<dynamic> responseList = _postsJson;
    List<Widget> listItems = [];
    for (var customer in responseList) {
      listItems.add(
        Container(
          height: 100,
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.indigo.withOpacity(0.2), blurRadius: 10.0),
              ]),
          child: Slidable(
            key: const ValueKey(0),
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  autoClose: true,
                  onPressed: (c) {
                    final getbyidurl = Uri.parse(apiRootAddress +
                        "/customer/deleteBy/${customer['csId']}/${customer['userId']}");
                    deleteCustomer(getbyidurl);
                  },
                  backgroundColor:
                      const Color.fromRGBO(164, 38, 38, 0.1803921568627451),
                  foregroundColor: const Color.fromRGBO(164, 38, 38, 1.0),
                  icon: Icons.delete_outline,
                  label: 'Delete',
                ),
                SlidableAction(
                  autoClose: true,
                  onPressed: (c) async {
                    bool isUploaded = await showDialog(
                        context: context,
                        // barrierDismissible: false,
                        builder: (context) => CustomerAddPopup(
                              isUpdate: true,
                              customerid: customer['id'],
                            ));
                    if (isUploaded) {
                      InAppNotification.show(
                          child: NotificationBody(title: 'Customer Updated'),
                          context: context,
                          duration: const Duration(seconds: 2),
                          curve: Curves.decelerate);
                      fetchCustomers();
                    }
                  },
                  backgroundColor:
                      const Color.fromRGBO(181, 103, 61, 0.1803921568627451),
                  foregroundColor: const Color.fromRGBO(181, 103, 61, 1.0),
                  icon: Icons.edit,
                  label: 'Edit',
                ),
              ],
            ),
            child: Row(children: <Widget>[
              Container(
                width: 60,
                height: 60,
                margin:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.indigo,
                  borderRadius: BorderRadius.circular(30),
                  image: const DecorationImage(
                      image: AssetImage('assets/images/cprofile.png'),
                      fit: BoxFit.fill),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 10),
                      child: Text(
                        '${customer["name"]}',
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                            color: Color.fromRGBO(0, 0, 0, 1),
                            fontFamily: 'Roboto',
                            fontSize: 15,
                            letterSpacing: 0,
                            fontWeight: FontWeight.normal,
                            height: 1),
                      )),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      '${customer["address"]}',
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                          color: Color.fromRGBO(0, 0, 0, 0.6200000047683716),
                          fontFamily: 'Roboto',
                          fontSize: 12,
                          letterSpacing: 0,
                          fontWeight: FontWeight.normal,
                          height: 1),
                    ),
                  ),
                  Text(
                    '${customer["csId"]}',
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                        color: Color.fromRGBO(0, 0, 0, 0.6200000047683716),
                        fontFamily: 'Roboto',
                        fontSize: 12,
                        letterSpacing: 0,
                        fontWeight: FontWeight.normal,
                        height: 1),
                  ),
                ],
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.centerRight,
                  margin: const EdgeInsets.only(right: 20),
                  child: SizedBox(
                    width: 68,
                    height: 16.808080673217773,
                    child: customer['isactive'] == 1
                        ? Stack(children: <Widget>[
                            Positioned(
                              top: 0,
                              left: 0,
                              child: Container(
                                width: 68,
                                height: 16.808080673217773,
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(30),
                                    bottomLeft: Radius.circular(30),
                                    bottomRight: Radius.circular(30),
                                  ),
                                  color: Color.fromRGBO(
                                      56, 164, 38, 0.18000000715255737),
                                ),
                              ),
                            ),
                            const Positioned(
                                top: 3.151510000228882,
                                left: 21,
                                child: Text(
                                  'Active',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: Color.fromRGBO(56, 164, 38, 1),
                                      fontFamily: 'Roboto',
                                      fontSize: 10,
                                      letterSpacing: 0,
                                      fontWeight: FontWeight.normal,
                                      height: 1),
                                )),
                            Positioned(
                                top: 4.202014923095703,
                                left: 11,
                                child: Container(
                                    width: 7,
                                    height: 7.353535175323486,
                                    decoration: const BoxDecoration(
                                      color: Color.fromRGBO(64, 226, 50, 1),
                                      borderRadius: BorderRadius.all(
                                          Radius.elliptical(
                                              7, 7.353535175323486)),
                                    ))),
                          ])
                        : Stack(children: <Widget>[
                            Positioned(
                              top: 0,
                              left: 0,
                              child: Container(
                                width: 68,
                                height: 16.808080673217773,
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(30),
                                    bottomLeft: Radius.circular(30),
                                    bottomRight: Radius.circular(30),
                                  ),
                                  color: Color.fromRGBO(
                                      164, 38, 38, 0.1803921568627451),
                                ),
                              ),
                            ),
                            const Positioned(
                                top: 3.151510000228882,
                                left: 21,
                                child: Text(
                                  'Inactive',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: Color.fromRGBO(164, 38, 38, 1.0),
                                      fontFamily: 'Roboto',
                                      fontSize: 10,
                                      letterSpacing: 0,
                                      fontWeight: FontWeight.normal,
                                      height: 1),
                                )),
                            Positioned(
                                top: 4.202014923095703,
                                left: 11,
                                child: Container(
                                    width: 7,
                                    height: 7.353535175323486,
                                    decoration: const BoxDecoration(
                                      color: Color.fromRGBO(226, 50, 50, 1.0),
                                      borderRadius: BorderRadius.all(
                                          Radius.elliptical(
                                              7, 7.353535175323486)),
                                    ))),
                          ]),
                  ),
                ),
              ),
            ]),
          ),
        ),
      );
    }

    setState(() {
      customersData = listItems;
    });
  }

  @override
  void initState() {
    _isLoading = true;
    _isError = false;
    fetchCustomers();
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
                          "CUSTOMERS",
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
                      bool isUploaded = await showDialog(
                          context: context,
                          builder: (context) => const CustomerAddPopup(
                                customerid: 0,
                                isUpdate: false,
                              ));
                      if (isUploaded) {
                        InAppNotification.show(
                            child: NotificationBody(title: 'Customer Added'),
                            context: context,
                            duration: const Duration(seconds: 2),
                            curve: Curves.decelerate);
                        fetchCustomers();
                      }
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
                        "New Customer",
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
                            CustoSupplListSkeleton(),
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
                        : (customersData.isNotEmpty
                            ? ListView.builder(
                                itemCount: customersData.length,
                                itemBuilder: (BuildContext context, index) {
                                  return customersData[index];
                                },
                              )
                            : Container(
                                alignment: Alignment.center,
                                child: GestureDetector(
                                  onTap: () async {
                                    bool isUploaded = await showDialog(
                                        context: context,
                                        builder: (context) =>
                                            const CustomerAddPopup(
                                              customerid: 0,
                                              isUpdate: false,
                                            ));
                                    if (isUploaded) {
                                      InAppNotification.show(
                                          child: NotificationBody(
                                              title: 'Customer Added'),
                                          context: context,
                                          duration: const Duration(seconds: 2),
                                          curve: Curves.decelerate);
                                      fetchCustomers();
                                    }
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Text("Oop's No Customer Found"),
                                      BlinkingAddButton(),
                                      Text("Add New Customer")
                                    ],
                                  ),
                                ),
                              )),
              ),
            )
          ],
        ),
      ),
    );
  }
}
