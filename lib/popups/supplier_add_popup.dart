import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:vansales/api/api.dart';
import 'package:vansales/widgets/NotificationBody.dart';
import 'package:vansales/widgets/responsive_text_field.dart';
import 'package:http/http.dart';

import '../utils.dart';

class SupplierAddPopup extends StatefulWidget {
  final bool isUpdate;
  final int supplierid;

  const SupplierAddPopup({
    Key? key,
    required this.isUpdate,
    required this.supplierid,
  }) : super(key: key);

  @override
  _SupplierAddPopupState createState() =>
      _SupplierAddPopupState(isUpdate, supplierid);
}

class _SupplierAddPopupState extends State<SupplierAddPopup> {
  int lastid = 4000;
  late bool _isPressed;
  int currentStep = 0;
  double height = 370;
  TextEditingController id = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController vat = TextEditingController();

  _SupplierAddPopupState(this.isUpdate, this.supplierid);

  bool isUpdate;
  int supplierid;

  void fetchSuppliers() async {
    final endPointUri = Uri.parse(
        apiRootAddress + "/supplier/get/all/userId/${Preferences.getUserId()}");

    try {
      final response = await get(endPointUri);
      final jsonData = jsonDecode(response.body) as List;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (jsonData.isNotEmpty) {
          setState(() {
            lastid = jsonData[jsonData.length - 1]['csId'];
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
          duration: const Duration(seconds: 3),
          curve: Curves.decelerate);
    }
  }

  void fetchSupplier() async {
    print(supplierid);

    final endPointUri =
        Uri.parse(apiRootAddress + "/supplier/get/byId/$supplierid");

    try {
      final response = await get(endPointUri);
      print(response.statusCode);
      print(response.body);
      final jsonData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        setState(() {
          id.text = jsonData['csId'].toString();
          name.text = jsonData['name'];
          address.text = jsonData['address'];
          vat.text = jsonData['vatNo'];
        });
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
    }
  }

  void postData() async {
    final endPointUri = Uri.parse(apiRootAddress + "/supplier/Add");

    try {
      var body = jsonEncode([
        {
          "csId": id.text,
          "name": name.text,
          "address": address.text,
          "vatNo": vat.text,
          "userId": '${Preferences.getUserId()}',
          "isactive": '1'
        }
      ]);

      final response = await post(endPointUri,
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body: body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        Navigator.pop(context, true);
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
        setState(() {
          _isPressed = false;
        });
      } else {
        print(response.statusCode);
        InAppNotification.show(
            child: NotificationBody(
              title: 'Failed',
              isError: true,
            ),
            context: context,
            duration: const Duration(seconds: 3),
            curve: Curves.decelerate);
        setState(() {
          _isPressed = false;
        });
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
      setState(() {
        _isPressed = false;
      });
    }
    // }else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text("No Network Connection"))
    //   );
    // }
  }

  void updateData() async {
    final endPointUri = Uri.parse(apiRootAddress + "/supplier/update/all");

    try {
      var body = jsonEncode({
        "csId": id.text,
        "name": name.text,
        "address": address.text,
        "vatNo": vat.text,
        "userId": '${Preferences.getUserId()}',
        "isactive": '1'
      });

      final response = await post(endPointUri,
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body: body);

      print(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        Navigator.pop(context, true);
      } else {
        print(response.statusCode);
        InAppNotification.show(
            child: NotificationBody(
              title: 'Failed',
              isError: true,
            ),
            context: context,
            duration: const Duration(seconds: 3),
            curve: Curves.decelerate);
        setState(() {
          _isPressed = false;
        });
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
      setState(() {
        _isPressed = false;
      });
    }
    // }else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text("No Network Connection"))
    //   );
    // }
  }

  @override
  void initState() {
    _isPressed = false;
    isUpdate ? fetchSupplier() : fetchSuppliers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int newid = int.parse(lastid.toString().substring(3));
    newid = newid + 1;
    id.text = isUpdate ? id.text : '400$newid';
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildChild(context),
    );
  }

  _buildChild(BuildContext context) => Container(
        height: height,
        width: 400,
        padding:
            const EdgeInsets.only(left: 30, right: 30, top: 25, bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.indigo.withOpacity(0.3), blurRadius: 20.0),
          ],
        ),
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 5),
              child: Text(
                isUpdate ? "Update Supplier" : "New Supplier",
                style: const TextStyle(
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
              controller: name,
              label: "Name",
              action: TextInputAction.next,
            ),
            const SizedBox(
              height: 12,
            ),
            ResponsiveTextField(
                controller: address,
                label: "Address",
                action: TextInputAction.next),
            const SizedBox(
              height: 12,
            ),
            ResponsiveTextField(
                controller: vat, label: "Vat No", action: TextInputAction.done),
            const SizedBox(
              height: 12,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _isPressed
                    ? TextButton(
                        onPressed: () {},
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: Colors.grey.shade400),
                        ))
                    : TextButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        child: const Text("Cancel")),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                    onPressed: () {
                      if (_isPressed == false) {
                        if (id.text.isNotEmpty &&
                            name.text.isNotEmpty &&
                            address.text.isNotEmpty) {
                          setState(() {
                            _isPressed = true;
                          });
                          isUpdate ? updateData() : postData();
                        } else {
                          InAppNotification.show(
                              child: NotificationBody(
                                title: 'Failed',
                                body: 'Please fill all the fields',
                                isError: true,
                              ),
                              context: context,
                              duration: const Duration(seconds: 2),
                              curve: Curves.decelerate);
                        }
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
                        : Text(isUpdate ? "Update" : "Add")),
              ],
            )
          ],
        ),
      );
}
