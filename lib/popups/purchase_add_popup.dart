import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:vansales/api/api.dart';
import 'package:vansales/api/customer_supplier_model.dart';
import 'package:vansales/screen/purchase_add_page.dart';
import 'package:vansales/widgets/NotificationBody.dart';

class PurchaseAddPopup extends StatefulWidget {
  const PurchaseAddPopup({
    Key? key,
  }) : super(key: key);

  @override
  _PurchaseAddPopupState createState() => _PurchaseAddPopupState();
}

class _PurchaseAddPopupState extends State<PurchaseAddPopup> {
  double height = 450;
  bool _isloading = true;

  final List<CustomerSupplierModel> _suppliers = <CustomerSupplierModel>[];
  List<CustomerSupplierModel> _suppliersDisplay = <CustomerSupplierModel>[];

  @override
  void initState() {
    fetchSupplier(true).then((value) {
      setState(() {
        _suppliers.addAll(value);
        _suppliersDisplay = _suppliers;
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
              child: const Text(
                "Select Supplier",
                style: TextStyle(
                    color: Colors.indigo,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            Expanded(
              child: _suppliers.isNotEmpty
                  ? ListView.builder(
                      itemBuilder: (context, index) {
                        return index == 0 ? _searchBar() : _listItem(index - 1);
                      },
                      itemCount: _suppliersDisplay.length + 1,
                    )
                  : Center(
                      child: _isloading
                          ? const CircularProgressIndicator()
                          : const Text('No active Supplier found'),
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
          labelText: 'Supplier',
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
            _suppliersDisplay = _suppliers.where((customer) {
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
        //Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    PurchaseAddPage(supplier: _suppliersDisplay[index])));
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
                    '${_suppliersDisplay[index].csId}',
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
                '${_suppliersDisplay[index].name}',
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
