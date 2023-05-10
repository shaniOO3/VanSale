import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:in_app_notification/in_app_notification.dart';

import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:vansales/api/api.dart';

import 'package:vansales/pdf/invoice_model.dart';
import 'package:vansales/pdf/thermal_printer.dart';
import 'package:vansales/widgets/NotificationBody.dart';

class ThermalPrinterPopup extends StatefulWidget {
  final Invoice invoice;
  const ThermalPrinterPopup({Key? key, required this.invoice})
      : super(key: key);

  @override
  _ThermalPrinterPopupState createState() => _ThermalPrinterPopupState(invoice);
}

class _ThermalPrinterPopupState extends State<ThermalPrinterPopup> {
  _ThermalPrinterPopupState(this.invoice);

  Invoice invoice;
  bool isBtEnabled = false;
  bool isDAvailable = false;
  bool connected = false;
  List<BluetoothInfo> items = [];

  String name = '';
  String companyName = '';
  String companyNameA = '';
  String addressA = '';
  String vatNo = '';
  String phone = '';

  void fetchData() async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    String? phoneno = _auth.currentUser!.phoneNumber;
    phone = phoneno!;
    late Uri getUri =
        Uri.parse(apiRootAddress + "/user/get/byPhone/" + phoneno);

    try {
      final response = await get(getUri);
      final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        name = jsonData['name'];
        companyName = jsonData['companyName'];
        companyNameA = jsonData['companyNameInArabic'];
        //address = jsonData['address'];
        addressA = jsonData['addressInArabic'];
        vatNo = jsonData['vatNo'];
        print(name);
      } else {
        print('ooopppp');
      }
    } on HttpException catch (e) {
      print(e);
    }
  }

  Future<void> initPlatformState() async {
    //if (!mounted) return;

    final bool result = await PrintBluetoothThermal.bluetoothEnabled;
    print("bluetooth enabled: $result");
    if (result) {
      setState(() {
        isBtEnabled = result;
      });
      getBluetooths();
    } else {
      setState(() {
        isBtEnabled = result;
      });
    }
  }

  Future<void> getBluetooths() async {
    final List<BluetoothInfo> listResult =
        await PrintBluetoothThermal.pairedBluetooths;

    /*await Future.forEach(listResult, (BluetoothInfo bluetooth) {
      String name = bluetooth.name;
      String mac = bluetooth.macAdress;
    });*/

    if (listResult.isEmpty) {
      setState(() {
        isDAvailable = false;
      });
    } else {
      setState(() {
        isDAvailable = true;
      });
    }

    setState(() {
      items = listResult;
    });
  }

  Future<void> connect(String mac) async {
    setState(() {});
    print(mac);
    final bool result =
        await PrintBluetoothThermal.connect(macPrinterAddress: mac);
    print("state conected $result");
    if (result) {
      connected = true;
      InAppNotification.show(
          child: NotificationBody(
            title: 'ALERT',
            body: 'Do not close this screen before the print finish',
            isError: true,
          ),
          context: context,
          duration: const Duration(seconds: 3),
          curve: Curves.decelerate);
      printTest();
    } else {
      InAppNotification.show(
          child: NotificationBody(
            title: 'Failed',
            body: "Can't connect to the printer",
            isError: true,
          ),
          context: context,
          duration: const Duration(seconds: 3),
          curve: Curves.decelerate);
    }
    setState(() {});
  }

  Future<void> printTest() async {
    bool connectionStatus = await PrintBluetoothThermal.connectionStatus;
    if (connectionStatus) {
      List<int> ticket = await ThermalPrinter().testTicket(
          invoice, name, companyName, companyNameA, addressA, vatNo, phone);
      final result = await PrintBluetoothThermal.writeBytes(ticket);
      print("impresion $result");
    } else {
      //no conectado, reconecte
    }
  }

  Future<void> disconnect() async {
    final bool status = await PrintBluetoothThermal.disconnect;
    setState(() {
      connected = false;
    });
    print("status disconnect $status");
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
    fetchData();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildChild(context),
    );
  }

  _buildChild(BuildContext context) => Container(
        height: 400,
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
                child: const Text(
                  "Bluetooth Devices",
                  style: TextStyle(
                      color: Colors.indigo,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              Container(
                height: 300,
                clipBehavior: Clip.hardEdge,
                padding: const EdgeInsets.only(top: 3, bottom: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  // border: Border.all(
                  //     color: Colors.grey
                  // )
                ),
                child: isBtEnabled
                    ? isDAvailable
                        ? ListView.builder(
                            itemCount: items.isNotEmpty ? items.length : 0,
                            itemBuilder: (context, index) {
                              return Container(
                                height: 65,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 3, vertical: 3),
                                //padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10.0)),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.indigo.withOpacity(0.2),
                                          blurRadius: 10.0),
                                    ]),
                                child: ListTile(
                                  onTap: () {
                                    InAppNotification.show(
                                        child: NotificationBody(
                                          title: 'ALERT',
                                          body:
                                              'Please wait connecting to the printer',
                                          isError: true,
                                        ),
                                        context: context,
                                        duration: const Duration(seconds: 3),
                                        curve: Curves.decelerate);

                                    String mac = items[index].macAdress;
                                    connected ? printTest() : connect(mac);
                                  },
                                  title: Text(items[index].name),
                                  subtitle: Text(items[index].macAdress),
                                ),
                              );
                            },
                          )
                        : const Center(
                            child: Text(
                                'There are no bluetooth linked, go to settings and link the printer'),
                          )
                    : const Center(
                        child: Text('Bluetooth not enabled'),
                      ),
              ),
            ],
          ),
        ),
      );
}
