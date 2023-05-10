import 'dart:convert';

import 'package:dropdown_button2/custom_dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:multi_wizard/multi_wizard.dart';
import 'package:vansales/api/api.dart';
import 'package:vansales/api/supplier_api.dart';
import 'package:vansales/widgets/NotificationBody.dart';
import 'package:vansales/widgets/responsive_text_field.dart';

import '../utils.dart';

class ItemAddPopup extends StatefulWidget {
  final bool isUpdate;
  final int itemid;

  const ItemAddPopup({
    Key? key,
    required this.isUpdate,
    required this.itemid,
  }) : super(key: key);

  @override
  _ItemAddPopupState createState() => _ItemAddPopupState(isUpdate, itemid);
}

class _ItemAddPopupState extends State<ItemAddPopup> {
  _ItemAddPopupState(this.isUpdate, this.itemid);

  bool isUpdate;
  int itemid;

  //List<Widget> supplierData = [];
  //var supplierlist = [];
  //late int itemindex;
  //int currentStep = 0;

  int lastid = 5000;
  double height = 400;
  TextEditingController id = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController arabicName = TextEditingController();
  TextEditingController cartoon = TextEditingController();
  TextEditingController vat = TextEditingController();
  TextEditingController supplier = TextEditingController();
  TextEditingController sPrice = TextEditingController();
  TextEditingController bPrice = TextEditingController();
  FocusNode buyprice = FocusNode();

  late int supplierId = 0;
  var supplierUri;
  var suppliers;

  String? selectedValue;
  String? currentValue;

  String? selectedUnit;
  String currentUnit = "Quantity";

  late List<String> vatmater = [];

  final units = ["Pcs", "Box", "Carton", "Dozen"];

  void fetchItems() async {
    final endPointUri = Uri.parse(
        apiRootAddress + "/item/get/all/userId/${Preferences.getUserId()}");

    try {
      final response = await get(endPointUri);
      final jsonData = jsonDecode(response.body) as List;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (jsonData.isNotEmpty) {
          setState(() {
            lastid = jsonData[jsonData.length - 1]['itemId'];
          });
        }
        print(lastid);
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

  void fetchItem() async {
    final endPointUri = Uri.parse(apiRootAddress + "/item/get/byId/$itemid");
    try {
      final response = await get(endPointUri);
      final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      print(jsonData);
      final supplierdata = jsonDecode(jsonData['suppliers']);
      print(supplierdata[0]['supplier']);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (jsonData.isNotEmpty) {
          setState(() {
            id.text = jsonData['itemId'].toString();
            name.text = jsonData['name'];
            arabicName.text = jsonData['arabicname'];
            cartoon.text = jsonData['stock'].toString();
            currentValue = (jsonData['vat'] * 100).toString() + "%";
            currentUnit = jsonData['unit'];
            supplier.text = supplierdata[0]['supplier']['name'];
            supplierId = supplierdata[0]['supplier']['id'];
            bPrice.text = supplierdata[0]['bprice'];
            sPrice.text = supplierdata[0]['sprice'];
          });
          print(currentUnit);
        }
      }
    } catch (err) {
      print(err);
      InAppNotification.show(
          child: NotificationBody(
            title: 'Error',
            body: "Can't connect to the Databasessss",
            isError: true,
          ),
          context: context,
          duration: const Duration(seconds: 3),
          curve: Curves.decelerate);
    }
  }

  void fetchVatMaster() async {
    final vatUri = Uri.parse(apiRootAddress + "/vatmaster/get/all");
    try {
      final response = await get(vatUri);
      final jsonData = jsonDecode(response.body) as List;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        for (int i = 0; i < jsonData.length; i++) {
          setState(() {
            vatmater.add("${jsonData[i]['vat'] * 100}%");
          });

          print(vatmater);
        }
      } else {
        print(response.statusCode);
      }
    } on Exception catch (e) {
      print(e);
    }
  }

  void fetchSupplier() async {
    try {
      final response = await get(supplierUri);
      print(response.body);
      final jsonData = jsonDecode(response.body);

      var jsupplier = {};
      jsupplier["supplier"] = jsonData;
      jsupplier["bprice"] = bPrice.text;
      jsupplier["sprice"] = sPrice.text;
      suppliers = json.encode([jsupplier]);
      isUpdate ? updateData() : postData();
    } catch (err) {
      print(err);
    }
  }

  void postData() async {
    //var connectivityResult = await (Connectivity().checkConnectivity());
    //if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {

    List<String> splitvalue = selectedValue!.split('');
    splitvalue.removeLast();
    double nvat = double.parse(splitvalue.join());
    double newvat = nvat / 100;
    print(newvat);

    final endPointUri = Uri.parse(apiRootAddress + "/item/Add");

    try {
      var body = jsonEncode([
        {
          "itemId": id.text,
          "name": name.text,
          "arabicname": arabicName.text,
          "stock": cartoon.text,
          "suppliers": "$suppliers",
          "vat": "$newvat",
          "unit": selectedUnit,
          "userId": '${Preferences.getUserId()}',
          "isactive": "1",
        }
      ]);

      final response = await post(endPointUri,
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body: body);

      print(response.statusCode);
      print(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        InAppNotification.show(
            child: NotificationBody(
              title: 'Data added successfully',
            ),
            context: context,
            duration: const Duration(seconds: 2),
            curve: Curves.decelerate);
        // ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(content: Text("New item ${name.text} added successfully"))
        // );
        Navigator.of(context).pop();
      } else if (response.statusCode == 409) {
        InAppNotification.show(
            child: NotificationBody(
              title: 'Failed',
              body: 'Data with same id exist please change the id',
              isError: true,
            ),
            context: context,
            duration: const Duration(seconds: 3),
            curve: Curves.decelerate);
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
        //     const SnackBar(content: Text("Failed! try again later"))
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
    // }else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text("No Network Connection"))
    //   );
    // }
  }

  void updateData() async {
    List<String> splitvalue = selectedValue == null
        ? currentValue!.split('')
        : selectedValue!.split('');
    splitvalue.removeLast();
    double nvat = double.parse(splitvalue.join());
    double newvat = nvat / 100;
    print(newvat);

    final endPointUri = Uri.parse(apiRootAddress + "/item/update/All");

    try {
      var body = jsonEncode({
        "itemId": id.text,
        "name": name.text,
        "arabicname": arabicName.text,
        "stock": cartoon.text,
        "vat": "$newvat",
        "unit": selectedUnit ?? currentUnit,
        "suppliers": "$suppliers",
        "userId": '${Preferences.getUserId()}',
        "isactive": "1",
      });

      final response = await post(endPointUri,
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body: body);

      print(body);
      print(response.statusCode);
      print(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        InAppNotification.show(
            child: NotificationBody(
              title: 'Data updated successfully',
            ),
            context: context,
            duration: const Duration(seconds: 2),
            curve: Curves.decelerate);
        // ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(content: Text("New item ${name.text} added successfully"))
        // );
        Navigator.pop(context, true);
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
        //     const SnackBar(content: Text("Failed! try again later"))
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
    // }else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text("No Network Connection"))
    //   );
    // }
  }

  // void getSupplierData() {
  //   List<dynamic> responselist = supplierlist;
  //   List<Widget> listitems = [];
  //   responselist.forEach((supplier) {
  //     listitems.add(
  //       Container(
  //         height: 65,
  //         margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
  //         padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
  //         clipBehavior: Clip.hardEdge,
  //         decoration: BoxDecoration(
  //             borderRadius: BorderRadius.all(Radius.circular(10.0)),
  //             color: Colors.white,
  //             boxShadow: [
  //               BoxShadow(
  //                   color: Colors.indigo.withOpacity(0.2), blurRadius: 10.0),
  //             ]),
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                     '${supplier['name']}',
  //                   style: TextStyle(
  //                     fontSize: 14,
  //                     fontWeight: FontWeight.bold
  //                   ),
  //                 ),
  //                     Text(
  //                       'selling price - ${supplier['sprice']}',
  //                       style: TextStyle(
  //                           fontSize: 12
  //                       ),
  //                     ),
  //                     Text(
  //                       'buying price - ${supplier['bprice']}',
  //                       style: TextStyle(
  //                           fontSize: 12
  //                       ),
  //                     ),
  //               ],
  //             ),
  //             GestureDetector(
  //               onTap: (){
  //                 supplierlist.removeAt(itemindex);
  //                 getSupplierData();
  //               },
  //               child: Icon(
  //                 Icons.person_remove_outlined,
  //                 color: Colors.red,
  //               ),
  //             )
  //           ],
  //         ),
  //       ),
  //     );
  //   });
  //   setState(() {
  //     supplierData = listitems;
  //   });
  // }

  @override
  void initState() {
    fetchVatMaster();
    isUpdate ? fetchItem() : fetchItems();
    super.initState();
    // getSupplierData();
  }

  @override
  Widget build(BuildContext context) {
    int newid = int.parse(lastid.toString().substring(3));
    newid = newid + 1;
    id.text = isUpdate ? id.text : '500$newid';
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildChild(context),
    );
  }

  _buildChild(BuildContext context) => Container(
      height: height,
      padding: const EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.indigo.withOpacity(0.3), blurRadius: 20.0),
        ],
      ),
      child: MultiWizard(
        finishFunction: () {
          if (id.text.isNotEmpty &&
              name.text.isNotEmpty &&
              cartoon.text.isNotEmpty &&
              (selectedValue != null || currentValue != null) &&
              (selectedUnit != null || currentUnit != null)) {
            if (sPrice.text.isNotEmpty && bPrice.text.isNotEmpty) {
              if (supplierId != 0) {
                setState(() {
                  supplierUri = Uri.parse(
                      apiRootAddress + "/supplier/get/byId/$supplierId");
                });
                fetchSupplier();
              } else {
                InAppNotification.show(
                    child: NotificationBody(
                      title: 'Failed',
                      body: "Not a valid supplier",
                      isError: true,
                    ),
                    context: context,
                    duration: const Duration(seconds: 3),
                    curve: Curves.decelerate);
              }
            } else {
              InAppNotification.show(
                  child: NotificationBody(
                    title: 'Failed',
                    body: "No supplier found",
                    isError: true,
                  ),
                  context: context,
                  duration: const Duration(seconds: 3),
                  curve: Curves.decelerate);
            }
          } else {
            InAppNotification.show(
                child: NotificationBody(
                  title: 'Failed',
                  body: "Item details missing",
                  isError: true,
                ),
                context: context,
                duration: const Duration(seconds: 3),
                curve: Curves.decelerate);
          }
        },
        steps: [
          WizardStep(
            showPrevious: false,
            nextFunction: () {
              setState(() {
                height = 250;
              });
            },
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 5),
                  child: const Text(
                    "Item Details",
                    style: TextStyle(
                        color: Colors.indigo,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                ResponsiveTextField(
                  controller: id,
                  label: "Id",
                  isEnabled: isUpdate ? false : true,
                  type: TextInputType.number,
                  action: TextInputAction.next,
                ),
                const SizedBox(
                  height: 12,
                ),
                ResponsiveTextField(
                  label: "Name",
                  controller: name,
                  action: TextInputAction.next,
                ),
                const SizedBox(
                  height: 12,
                ),
                ResponsiveTextField(
                  label: "Arabic Name",
                  controller: arabicName,
                  action: TextInputAction.next,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(
                  height: 12,
                ),
                CustomDropdownButton2(
                  hint: isUpdate ? currentUnit : 'Unit',
                  icon: const Icon(Icons.arrow_drop_down),
                  iconSize: 20,
                  buttonHeight: 49,
                  buttonWidth: double.maxFinite,
                  dropdownItems: units,
                  value: selectedUnit,
                  onChanged: (value) {
                    setState(() {
                      selectedUnit = value;
                    });
                  },
                  buttonDecoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade700),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                Row(
                  children: [
                    Expanded(
                        child: ResponsiveTextField(
                      label: isUpdate
                          ? currentUnit
                          : selectedUnit != null
                              ? selectedUnit!
                              : "Quantity",
                      controller: cartoon,
                      type: TextInputType.number,
                      action: TextInputAction.done,
                    )),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: CustomDropdownButton2(
                        hint: isUpdate ? currentValue ?? 'Vat' : 'Vat',
                        icon: const Icon(Icons.arrow_drop_down),
                        iconSize: 20,
                        buttonHeight: 49,
                        dropdownItems: vatmater,
                        value: selectedValue,
                        onChanged: (value) {
                          setState(() {
                            selectedValue = value;
                          });
                        },
                        buttonDecoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade700),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          WizardStep(
            previousFunction: () {
              setState(() {
                height = 400;
              });
            },
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 5),
                  child: const Text(
                    "Supplier Details",
                    style: TextStyle(
                        color: Colors.indigo,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                TypeAheadField<Supplier>(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: supplier,
                    decoration: InputDecoration(
                      labelText: "supplier",
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
                        borderSide:
                            BorderSide(color: Colors.indigo, width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      ),
                    ),
                  ),
                  noItemsFoundBuilder: (context) {
                    return const SizedBox(
                      height: 50,
                      child: Center(
                        child: Text("No supplier found"),
                      ),
                    );
                  },
                  suggestionsBoxDecoration: SuggestionsBoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      shadowColor: Colors.indigo),
                  suggestionsCallback: SupplierApi.getSupplierSuggestions,
                  onSuggestionSelected: (Supplier suggestion) {
                    final suppliers = suggestion;
                    supplier.text = suppliers.name;
                    supplierId = suppliers.id!;
                    FocusScope.of(context).requestFocus(buyprice);
                  },
                  itemBuilder: (context, Supplier suggestion) {
                    final suppliers = suggestion;
                    return ListTile(
                      title: Text(suppliers.name),
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
                      label: "Buying Price",
                      type:
                          const TextInputType.numberWithOptions(decimal: true),
                      controller: bPrice,
                      action: TextInputAction.next,
                      focusNode: buyprice,
                    )),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                        child: ResponsiveTextField(
                      label: "Selling Price",
                      type:
                          const TextInputType.numberWithOptions(decimal: true),
                      controller: sPrice,
                      action: TextInputAction.done,
                    )),
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                // Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Text(
                //         "Supplier List",
                //         style: TextStyle(
                //             color: AppColors.mainColor,
                //             fontSize: 18,
                //             fontWeight: FontWeight.bold
                //         ),
                //       ),
                //       GestureDetector(
                //         onTap: () {
                //           if (supplier.text.isNotEmpty && sPrice.text.isNotEmpty && bPrice.text.isNotEmpty) {
                //             supplierUri = Uri.parse("http://192.168.18.5:8080/supplier/get/byId/${supplierId}");
                //             fetchSupplier();
                //             supplierlist.add(
                //               {
                //                 "name": "${supplier.text}",
                //                 "sprice": "${sPrice.text}",
                //                 "bprice": "${bPrice.text}"
                //               }
                //             );
                //           }
                //           // getSupplierData();
                //           FocusScope.of(context).unfocus();
                //           if(supplierData.length > 2) {
                //             height = 460;
                //           }
                //         },
                //         child: Container(
                //           width: 80,
                //           height: 25,
                //           alignment: Alignment.center,
                //           decoration: BoxDecoration(
                //               color: Colors.indigo,
                //               borderRadius:
                //               BorderRadius.circular(8)),
                //           child: Text(
                //             "Add",
                //             style: TextStyle(
                //                 fontSize: 18,
                //                 color: Colors.white,
                //                 fontWeight: FontWeight.bold),
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // Expanded(
                //   child: Container(
                //     width: double.maxFinite,
                //     margin: const EdgeInsets.only(top: 12, bottom: 45),
                //     alignment: Alignment.center,
                //     clipBehavior: Clip.hardEdge,
                //     decoration: BoxDecoration(
                //       color: Colors.white,
                //       borderRadius: BorderRadius.circular(12),
                //       border: Border.all(
                //         color: AppColors.mainColor
                //       )
                //     ),
                //     child: supplierData.length > 0
                //         ? ListView.builder(
                //             itemCount: supplierData.length,
                //             itemBuilder: (BuildContext context, index) {
                //               itemindex = index;
                //               return supplierData[index];
                //             }
                //     )
                //         : Text("Add Supplier"),
                //     ),
                // ),
              ],
            ),
          )
        ],
      ));
}
