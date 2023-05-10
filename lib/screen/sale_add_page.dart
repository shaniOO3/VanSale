import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:intl/intl.dart';
import 'package:vansales/api/api.dart';
import 'package:vansales/api/customer_supplier_model.dart';
import 'package:vansales/api/item_model.dart';
import 'package:vansales/screen/sale_save_page.dart';
import 'package:vansales/widgets/NotificationBody.dart';
import 'package:vansales/widgets/responsive_text_field.dart';

class SaleAddPage extends StatefulWidget {
  CustomerSupplierModel customer;

  SaleAddPage({Key? key, required this.customer}) : super(key: key);

  @override
  _SaleAddPageState createState() => _SaleAddPageState(customer);
}

class _SaleAddPageState extends State<SaleAddPage> {
  _SaleAddPageState(CustomerSupplierModel _customer) {
    customer = _customer;
  }
  late CustomerSupplierModel customer;

  TextEditingController item = TextEditingController();
  TextEditingController quantity = TextEditingController();
  TextEditingController stock = TextEditingController();
  TextEditingController sprice = TextEditingController();

  final List<ItemModel>? _items = <ItemModel>[];
  //List<ItemModel>? _itemsDisplay = [];

  var itemId;
  var itemArabicName;
  var unit;
  late var date;
  late double itemvat;
  List<Widget> itemData = [];
  var itemlist = [];

  DateTime dateTime = DateTime.now();

  @override
  void initState() {
    fetchItem().then((value) {
      setState(() {
        _items?.addAll(value);
      });
    });
    super.initState();
  }

  static void showSheet(
    BuildContext context, {
    required Widget child,
    required VoidCallback onClicked,
    String? button,
  }) =>
      showCupertinoModalPopup(
        context: context,
        builder: (context) => CupertinoActionSheet(
          actions: [
            child,
          ],
          cancelButton: CupertinoActionSheetAction(
            child: Text(button ?? 'Select'),
            onPressed: onClicked,
          ),
        ),
      );

  Widget buildDatePicker() => Container(
        height: 180,
        color: Colors.white,
        child: CupertinoDatePicker(
          minimumYear: 2015,
          maximumYear: DateTime.now().year,
          maximumDate: DateTime.now(),
          initialDateTime: dateTime,
          mode: CupertinoDatePickerMode.date,
          onDateTimeChanged: (dateTime) =>
              setState(() => this.dateTime = dateTime),
        ),
      );

  @override
  Widget build(BuildContext context) {
    date = DateFormat('yyyy-MM-dd').format(dateTime);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        color: Colors.white,
        child: SafeArea(
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
                                "SALE",
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
              Container(
                color: Colors.indigo.withOpacity(0.05),
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.only(
                    left: 30, right: 20, top: 20, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${customer.name}',
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 25,
                                letterSpacing: 1),
                          ),
                        ),
                        Text(
                          '${customer.vatNo}',
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.fade,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    Text(
                      '${customer.csId}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Current Balance'),
                        Text('${customer.cbalance?.toStringAsFixed(2)}'),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 13, 25, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text("Invoice Date : "),
                        Text(date),
                      ],
                    ),
                    InkWell(
                      onTap: () => showSheet(context, child: buildDatePicker(),
                          onClicked: () {
                        date = DateFormat('yyyy-MM-dd').format(dateTime);
                        Navigator.pop(context);
                      }),
                      child: const Text(
                        "Change date",
                        style: TextStyle(
                            color: Colors.indigo, fontWeight: FontWeight.w600),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
                child: InkWell(
                  hoverColor: Colors.indigo.withOpacity(0.2),
                  highlightColor: Colors.indigo.withOpacity(0.2),
                  focusColor: Colors.indigo.withOpacity(0.2),
                  splashColor: Colors.indigo.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) => _ItemSelectPopup()),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 12),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [Text('Select Item'), Icon(Icons.add)],
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(left: 38, right: 38, bottom: 10),
                child: Row(
                  children: const [
                    Expanded(
                        child: Text(
                      'Name',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                    Expanded(
                        child: Text(
                      'Quantity',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                    Expanded(
                        child: Text(
                      'price',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                    Icon(
                      Icons.close_sharp,
                      color: Colors.transparent,
                    )
                  ],
                ),
              ),
              Expanded(
                child: Container(
                    width: double.maxFinite,
                    margin:
                        const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                    alignment: Alignment.center,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey)),
                    child: itemData.length > 0
                        ? ListView.builder(
                            itemCount: itemData.length,
                            itemBuilder: (BuildContext context, index) {
                              return itemData[index];
                            })
                        : const Text("Add Item")),
              ),
              Container(
                height: 50,
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.only(left: 20, right: 20, bottom: 30),
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    if (itemlist.isNotEmpty) {
                      bool _isRepeat = false;
                      int j = 1;
                      for (int i = 0; i < itemlist.length; i++) {
                        j = i + 1;
                        for (j; j < itemlist.length; j++) {
                          if (itemlist[i]['id'] == itemlist[j]['id']) {
                            setState(() {
                              _isRepeat = true;
                            });
                            break;
                          } else {
                            setState(() {
                              _isRepeat = false;
                            });
                          }
                        }
                        if (_isRepeat == true) {
                          break;
                        }
                      }
                      if (_isRepeat) {
                        InAppNotification.show(
                            child: NotificationBody(
                              title: 'Same item added twice',
                              isError: true,
                            ),
                            context: context,
                            duration: const Duration(seconds: 3),
                            curve: Curves.decelerate);
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SaleSavePage(
                                      itemlist: itemlist,
                                      customer: customer,
                                      date: date,
                                    )));
                      }
                    } else {
                      InAppNotification.show(
                          child: NotificationBody(
                            title: 'No Item Selected',
                            isError: true,
                          ),
                          context: context,
                          duration: const Duration(seconds: 3),
                          curve: Curves.decelerate);
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: itemlist.isEmpty
                        ? MaterialStateProperty.all(Colors.grey)
                        : MaterialStateProperty.all(Colors.indigo),
                  ),
                  child: const Text('BILL'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _ItemSelectPopup() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
          height: 330,
          padding:
              const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 5),
                child: const Text(
                  "Select Item",
                  style: TextStyle(
                      color: Colors.indigo,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              TypeAheadField<ItemModel>(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: item,
                  decoration: InputDecoration(
                    labelText: "Item",
                    labelStyle: TextStyle(color: Colors.grey.shade400),
                    floatingLabelStyle: const TextStyle(color: Colors.indigo),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 20.0),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.grey.shade700, width: 1.0),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(12.0)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.indigo, width: 2.0),
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    ),
                  ),
                ),
                noItemsFoundBuilder: (context) {
                  return Container(
                    height: 50,
                    child: const Center(
                      child: Text("No Item found"),
                    ),
                  );
                },
                suggestionsBoxDecoration: SuggestionsBoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    shadowColor: Colors.indigo),
                suggestionsCallback: ItemApi.getItemSuggestions,
                onSuggestionSelected: (ItemModel suggestion) {
                  final items = suggestion;
                  item.text = items.name!;
                  itemId = items.itemId!;
                  itemArabicName = items.arabicname;
                  unit = items.unit;

                  stock.text = '${items.stock}';
                  var supplier = jsonDecode(items.suppliers!);
                  itemvat = items.vat!;
                  sprice.text = supplier[0]['sprice'];
                },
                itemBuilder: (context, ItemModel suggestion) {
                  final items = suggestion;
                  return ListTile(
                    title: Text('${items.name}'),
                  );
                },
              ),
              const SizedBox(
                height: 12,
              ),
              Row(
                children: [
                  Expanded(
                    child: ResponsiveTextField(
                      label: 'Quantity',
                      controller: quantity,
                      type: TextInputType.number,
                      action: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: TextField(
                      controller: stock,
                      readOnly: true,
                      onChanged: (value) {
                        //Do something with the user input.
                      },
                      decoration: InputDecoration(
                        labelText: "Stock",
                        labelStyle: TextStyle(color: Colors.grey.shade400),
                        floatingLabelStyle:
                            const TextStyle(color: Colors.indigo),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.grey.shade700, width: 1.0),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12.0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.grey.shade700, width: 1.0),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12.0)),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              ResponsiveTextField(
                label: 'Selling Price',
                controller: sprice,
                type: const TextInputType.numberWithOptions(decimal: true),
                action: TextInputAction.done,
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () {
                          item.text = "";
                          quantity.text = "";
                          stock.text = "";
                          sprice.text = "";
                          Navigator.of(context).pop();
                        },
                        child: const Text("CLOSE")),
                    const SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                        onPressed: () {
                          if (item.text.isNotEmpty &&
                              quantity.text.isNotEmpty &&
                              stock.text.isNotEmpty &&
                              sprice.text.isNotEmpty) {
                            // if (int.parse(quantity.text) <= int.parse(stock.text)) {
                            itemlist.add({
                              "id": itemId,
                              "name": item.text,
                              "arabicname": itemArabicName,
                              "quantity": int.parse(quantity.text),
                              "vat": itemvat,
                              "unit": unit,
                              "price": double.parse(sprice.text)
                            });

                            selecteditemlist();
                            item.text = "";
                            quantity.text = "";
                            stock.text = "";
                            sprice.text = "";
                            // } else {
                            //   InAppNotification.show(
                            //       child: NotificationBody(
                            //         title: 'Failed',
                            //         body: 'Not much stock available',
                            //         isError: true,
                            //       ),
                            //       context: context,
                            //       duration: const Duration(seconds: 3),
                            //       curve: Curves.decelerate);
                            // }
                          } else {
                            InAppNotification.show(
                                child: NotificationBody(
                                  title: 'Failed',
                                  body: 'Please fill all fields',
                                  isError: true,
                                ),
                                context: context,
                                duration: const Duration(seconds: 3),
                                curve: Curves.decelerate);

                            // ScaffoldMessenger.of(context).showSnackBar(
                            //     SnackBar(content: Text("Please fill all fields"))
                            // );
                          }
                        },
                        child: const Text("ADD")),
                  ],
                ),
              )
            ],
          )),
    );
  }

  void selecteditemlist() {
    List<dynamic> responselist = itemlist;
    List<Widget> listitems = [];
    for (var item in responselist) {
      listitems.add(
        Container(
          height: 65,
          margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.indigo.withOpacity(0.2), blurRadius: 10.0),
              ]),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${item['name']}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Text(
                  '${item['quantity']}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              Expanded(
                child: Text(
                  '${item['price']}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              InkWell(
                onTap: () {
                  itemlist.remove(item);
                  selecteditemlist();
                },
                child: const Icon(
                  Icons.remove_circle,
                  color: Colors.red,
                ),
              )
            ],
          ),
        ),
      );
    }
    setState(() {
      itemData = listitems;
    });
  }
}
