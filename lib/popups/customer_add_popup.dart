import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:vansales/api/api.dart';
import 'package:vansales/utils.dart';
import 'package:vansales/widgets/NotificationBody.dart';
import 'package:vansales/widgets/responsive_text_field.dart';

class CustomerAddPopup extends StatefulWidget {
  final bool isUpdate;
  final int customerid;

  const CustomerAddPopup({
    Key? key,
    required this.isUpdate,
    required this.customerid,
  }) : super(key: key);

  @override
  _CustomerAddPopupState createState() =>
      _CustomerAddPopupState(isUpdate, customerid);
}

class _CustomerAddPopupState extends State<CustomerAddPopup> {
  _CustomerAddPopupState(this._isUpdate, this.customerid);

  final bool _isUpdate;
  int customerid;

  int lastid = 3000;

  late bool _isPressed;
  int currentStep = 0;
  double height = 370;
  TextEditingController id = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController aname = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController aaddress = TextEditingController();
  TextEditingController vat = TextEditingController();

  void fetchCustomers() async {
    final customerUri = Uri.parse(
        apiRootAddress + "/customer/get/all/userId/${Preferences.getUserId()}");

    try {
      final response = await get(customerUri);
      final jsonCData = jsonDecode(response.body) as List;
      if (jsonCData.isNotEmpty) {
        setState(() {
          lastid = jsonCData[jsonCData.length - 1]['csId'];
        });
      }
    } catch (err) {
      print(err);
      InAppNotification.show(
          child: NotificationBody(
            title: 'Error',
            body: "Can't get the id",
            isError: true,
          ),
          context: context,
          duration: const Duration(seconds: 3),
          curve: Curves.decelerate);
    }
  }

  void fetchCustomer() async {
    final customerUri =
        Uri.parse(apiRootAddress + "/customer/get/byId/$customerid");

    try {
      final response = await get(customerUri);
      final jsonCuData = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonCuData.isNotEmpty) {
        setState(() {
          id.text = jsonCuData['csId'].toString();
          name.text = jsonCuData['name'];
          address.text = jsonCuData['address'];
          vat.text = jsonCuData['vatNo'];
        });
      }
    } catch (err) {
      print(err);
      InAppNotification.show(
          child: NotificationBody(
            title: 'Error',
            body: "Can't get the customer details",
            isError: true,
          ),
          context: context,
          duration: const Duration(seconds: 3),
          curve: Curves.decelerate);
    }
  }

  void postData() async {
    //var connectivityResult = await (Connectivity().checkConnectivity());

    //if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {

    final endPointUri = Uri.parse(apiRootAddress + "/customer/Add");

    try {
      var body = jsonEncode([
        {
          "csId": id.text,
          "name": name.text,
          //"arabicname": "${aname.text}",
          "address": address.text,
          //"arabicaddress": "${aaddress.text}",
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
              body: body)
          .timeout(const Duration(seconds: 5));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        Navigator.pop(context, true);
        // ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(content: Text("New customer ${name.text} added successfully"))
        // );
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
    //var connectivityResult = await (Connectivity().checkConnectivity());

    //if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {

    final endPointUri = Uri.parse(apiRootAddress + "/customer/update/all");

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

      if (response.statusCode >= 200 && response.statusCode < 300) {
        Navigator.pop(context, true);
        // ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(content: Text("New customer ${name.text} added successfully"))
        // );
      } else {
        print(response.body);
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
    _isUpdate ? fetchCustomer() : fetchCustomers();
    _isPressed = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int newid = int.parse(lastid.toString().substring(3));
    newid = newid + 1;
    id.text = _isUpdate ? id.text : '300$newid';
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 5),
                child: Text(
                  _isUpdate ? "Update Customer" : "New Customer",
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
                  type: TextInputType.number,
                  isEnabled: _isUpdate ? false : true,
                  action: TextInputAction.next),
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
              //ResponsiveTextField(controller: aname, label: "Name In Arabic", action: TextInputAction.next, textDirection: TextDirection.rtl,),
              // SizedBox(
              //   height: 12,
              // ),
              ResponsiveTextField(
                  controller: address,
                  label: "Address",
                  action: TextInputAction.next),
              const SizedBox(
                height: 12,
              ),
              //ResponsiveTextField(controller: aaddress, label: "Address In Arabic", action: TextInputAction.next, textDirection: TextDirection.rtl,),
              // SizedBox(
              //   height: 12,
              // ),
              ResponsiveTextField(
                  controller: vat,
                  label: "Vat No",
                  action: TextInputAction.done),
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
                            _isUpdate ? updateData() : postData();
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
                      clipBehavior: Clip.hardEdge,
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
                          : Text(_isUpdate ? "Update" : "Add")),
                ],
              )
            ],
          ),
        ),
      );
}
