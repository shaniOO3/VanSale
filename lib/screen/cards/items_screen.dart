import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:vansales/api/api.dart';
import 'package:vansales/loadingskeleton/custo_suppl_list_skeleton.dart';
import 'package:vansales/popups/item_add_popup.dart';
import 'package:vansales/utils.dart';
import 'package:vansales/widgets/NotificationBody.dart';
import 'package:vansales/widgets/blinking_add_button.dart';
import 'package:http/http.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({Key? key}) : super(key: key);

  @override
  _ItemsScreenState createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  late bool _isLoading;
  late bool _isError;
  List<Widget> itemsData = [];

  final endPointUri = Uri.parse(
      apiRootAddress + "/item/get/all/userId/${Preferences.getUserId()}");
  var _postsJson = [];

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    fetchItems();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()

    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  void fetchItems() async {
    try {
      final response = await get(endPointUri);
      final jsonData = jsonDecode(utf8.decode(response.bodyBytes)) as List;
      print(jsonData);
      setState(() {
        _postsJson = jsonData;
      });
      if (response.statusCode >= 200 && response.statusCode < 300) {
        setState(() {
          _isLoading = false;
        });
        getItemData();
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
      setState(() {
        _isLoading = false;
        _isError = true;
      });
    }
  }

  void deleteItem(url) async {
    try {
      final response = await post(url);
      print(response.statusCode);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        fetchItems();
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

  void getItemData() {
    List<dynamic> responseList = _postsJson;
    List<Widget> listItems = [];
    for (var items in responseList) {
      listItems.add(
        Container(
          height: 100,
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
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
                        "/item/deleteBy/${items['userId']}/${items['itemId']}");
                    deleteItem(getbyidurl);
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
                        builder: (context) => ItemAddPopup(
                              isUpdate: true,
                              itemid: items['id'],
                            ));
                    if (isUploaded) {
                      InAppNotification.show(
                          child: NotificationBody(title: 'Item Updated'),
                          context: context,
                          duration: const Duration(seconds: 2),
                          curve: Curves.decelerate);
                      fetchItems();
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
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.indigo,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/iprofile.png'),
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 10),
                    child: Text(
                      '${items["name"]}',
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
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      '${items["itemId"]}',
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
                    '${items["stock"]} ${items["unit"]}',
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
                    width: 90,
                    height: 17,
                    child: items['stock'] > 0
                        ? Stack(children: <Widget>[
                            Positioned(
                              top: 0,
                              left: 0,
                              child: Container(
                                width: 90,
                                height: 17,
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
                              top: 3,
                              left: 26,
                              child: Text(
                                'Available',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: Color.fromRGBO(56, 164, 38, 1),
                                    fontFamily: 'Roboto',
                                    fontSize: 10,
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.normal,
                                    height: 1),
                              ),
                            ),
                            Positioned(
                                top: 4,
                                left: 16,
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
                                width: 90,
                                height: 17,
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
                              top: 3,
                              left: 21,
                              child: Text(
                                'Out of stock',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: Color.fromRGBO(164, 38, 38, 1.0),
                                    fontFamily: 'Roboto',
                                    fontSize: 10,
                                    letterSpacing: 0,
                                    fontWeight: FontWeight.normal,
                                    height: 1),
                              ),
                            ),
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
      itemsData = listItems;
    });
  }

  @override
  void initState() {
    _isLoading = true;
    _isError = false;
    fetchItems();
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
                          "ITEMS",
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
                          builder: (context) => const ItemAddPopup(
                                isUpdate: false,
                                itemid: 0,
                              ));
                      fetchItems();
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
                        "New Item",
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
                        itemBuilder: (context, index) => CustoSupplListSkeleton(
                              item: true,
                            ),
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
                        : itemsData.isNotEmpty
                            ? ListView.builder(
                                itemCount: itemsData.length,
                                itemBuilder: (BuildContext context, index) {
                                  return itemsData[index];
                                },
                              )
                            : Container(
                                alignment: Alignment.center,
                                child: GestureDetector(
                                  onTap: () async {
                                    await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return const ItemAddPopup(
                                            isUpdate: false,
                                            itemid: 0,
                                          );
                                        });
                                    fetchItems();
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Text("Oop's No Item Found"),
                                      BlinkingAddButton(),
                                      Text("Add New Item")
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
