import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:vansales/api/api.dart';
import 'package:vansales/api/customer_supplier_model.dart';
import 'package:vansales/pdf/pdf_main.dart';
import 'package:vansales/screen/sale_add_page.dart';
import 'package:vansales/widgets/NotificationBody.dart';

import '../utils.dart';
import 'customer_add_popup.dart';

class SaleAddPopup extends StatefulWidget {
  final bool isReport;
  const SaleAddPopup({Key? key, required this.isReport}) : super(key: key);

  @override
  _SaleAddPopupState createState() => _SaleAddPopupState(isReport);
}

class _SaleAddPopupState extends State<SaleAddPopup> {
  _SaleAddPopupState(this._isReport);

  final bool _isReport;
  double height = 450;
  bool _isloading = true;

  final List<CustomerSupplierModel> _customers = <CustomerSupplierModel>[];
  List<CustomerSupplierModel> _customersDisplay = <CustomerSupplierModel>[];

  Future<void> reportprint(int cusid) async {
    final value = cusid;

    final endPointUri = Uri.parse(apiRootAddress +
        "/pdf/generate/pdf/customer/$value/${Preferences.getUserId()}");

    try {
      final response = await get(endPointUri);
      print(response.statusCode);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final pdfFile = await PdfMain.saveDocument(
            name: 'bal $value', byties: response.bodyBytes);
        PdfMain.openFile(pdfFile);
      } else {
        InAppNotification.show(
            child: NotificationBody(
              title: 'Failed',
              body: "No sale found on $value",
              isError: true,
            ),
            context: context,
            duration: const Duration(seconds: 3),
            curve: Curves.decelerate);
      }
    } on HttpException catch (e) {
      print(e);
    }

    //showSnackBar(context, 'Selected "$value"');

    Navigator.pop(context);
  }

  @override
  void initState() {
    fetchCustomers(true).then((value) {
      setState(() {
        _customers.addAll(value);
        _customersDisplay = _customers;
      });
    }).whenComplete(() => _isloading = false);
    super.initState();
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
              //alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Select Customer",
                    style: TextStyle(
                        color: Colors.indigo,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
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
                        initState();
                      }
                    },
                    child: Container(
                      width: 60,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.indigo.withOpacity(0.5),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(15))),
                      child: const Text(
                        "New",
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
            const SizedBox(
              height: 12,
            ),
            Expanded(
              child: _customers.isNotEmpty
                  ? ListView.builder(
                      itemBuilder: (context, index) {
                        return index == 0 ? _searchBar() : _listItem(index - 1);
                      },
                      itemCount: _customersDisplay.length + 1,
                    )
                  : Center(
                      child: _isloading
                          ? const CircularProgressIndicator()
                          : const Text('No active customer found'),
                    ),
            ),
          ],
        ),
      );

  _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextField(
        decoration: InputDecoration(
          labelText: 'Customer Name',
          labelStyle: TextStyle(color: Colors.grey.shade400),
          floatingLabelStyle: const TextStyle(color: Colors.indigo),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(32.0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade700, width: 1.0),
            borderRadius: const BorderRadius.all(Radius.circular(12.0)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.indigo, width: 2.0),
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),
        ),
        onChanged: (text) {
          text = text.toLowerCase();
          setState(() {
            _customersDisplay = _customers.where((customer) {
              var customerName = customer.name!.toLowerCase();
              return customerName.contains(text);
            }).toList();
          });
        },
      ),
    );
  }

  _listItem(index) {
    return GestureDetector(
      onTap: () {
        if (_isReport) {
          reportprint(_customersDisplay[index].csId!);
        } else {
          //Navigator.pop(context);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SaleAddPage(
                        customer: _customersDisplay[index],
                      )));
        }
      },
      child: Container(
        height: 70,
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.indigo.withOpacity(0.2), blurRadius: 10.0),
            ]),
        child: Row(children: <Widget>[
          Container(
            width: 30,
            height: 30,
            margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
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
                  padding: const EdgeInsets.only(top: 20, bottom: 7),
                  child: Text(
                    '${_customersDisplay[index].csId}',
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                        color: Color.fromRGBO(0, 0, 0, 0.6200000047683716),
                        fontFamily: 'Roboto',
                        fontSize: 12,
                        letterSpacing: 0,
                        fontWeight: FontWeight.normal,
                        height: 1),
                  )),
              Text(
                '${_customersDisplay[index].name}',
                textAlign: TextAlign.left,
                style: const TextStyle(
                    color: Color.fromRGBO(0, 0, 0, 1),
                    fontFamily: 'Roboto',
                    fontSize: 15,
                    letterSpacing: 0,
                    fontWeight: FontWeight.normal,
                    height: 1),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
