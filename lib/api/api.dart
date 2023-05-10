import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:vansales/api/customer_supplier_model.dart';
import 'package:vansales/api/item_model.dart';
import 'package:vansales/api/vat_mater_model.dart';

import '../utils.dart';

//ToDo : Add backend server address Here 👇
const apiRootAddress = 'BACKEND SERVER ADDRESS';

//Customer
List<CustomerSupplierModel> parseCustomersSuppliers(String responseBody) {
  var list = json.decode(responseBody) as List<dynamic>;
  var customersSuppliers =
      list.map((model) => CustomerSupplierModel.fromJson(model)).toList();
  return customersSuppliers;
}

Future<List<CustomerSupplierModel>> fetchCustomers(bool active) async {
  final response = active
      ? await get(Uri.parse(
          '$apiRootAddress/customer/get/all/active/${Preferences.getUserId()}'))
      : await get(Uri.parse(
          '$apiRootAddress/customer/get/all/userId/${Preferences.getUserId()}'));
  if (response.statusCode == 200) {
    return compute(parseCustomersSuppliers, utf8.decode(response.bodyBytes));
  } else {
    throw Exception("Request API Error");
  }
}

CustomerSupplierModel parseCustomerSupplier(String responseBody) {
  var dlt = json.decode(responseBody);
  var customerSuppleir =
      dlt.map((model) => CustomerSupplierModel.fromJson(model));
  return customerSuppleir;
}

Future<CustomerSupplierModel> fetchCustomer(id) async {
  final response =
      await get(Uri.parse('$apiRootAddress/customer/get/byId/$id'));
  if (response.statusCode == 200) {
    return compute(parseCustomerSupplier, response.body);
  } else {
    throw Exception("Request API Error");
  }
}

//Supplier
Future<List<CustomerSupplierModel>> fetchSupplier(bool active) async {
  final response = active
      ? await get(Uri.parse(
          '$apiRootAddress/supplier/get/all/active/${Preferences.getUserId()}'))
      : await get(Uri.parse(
          '$apiRootAddress/supplier/get/all/userId/${Preferences.getUserId()}'));
  if (response.statusCode == 200) {
    return compute(parseCustomersSuppliers, response.body);
  } else {
    throw Exception("Request API Error");
  }
}

//item
List<ItemModel> parseItem(String responseBody) {
  var list = json.decode(responseBody) as List<dynamic>;
  var items = list.map((model) => ItemModel.fromJson(model)).toList();
  return items;
}

Future<List<ItemModel>> fetchItem() async {
  final response = await get(Uri.parse(
      '$apiRootAddress/item/get/all/userId/${Preferences.getUserId()}'));
  if (response.statusCode == 200) {
    return compute(parseItem, utf8.decode(response.bodyBytes));
  } else {
    throw Exception("Request API Error");
  }
}

class ItemApi {
  static Future<List<ItemModel>> getItemSuggestions(String query) async {
    final url = Uri.parse(
        '$apiRootAddress/item/get/all/userId/${Preferences.getUserId()}');
    final response = await get(url);

    if (response.statusCode == 200) {
      final List items = json.decode(utf8.decode(response.bodyBytes));

      return items.map((json) => ItemModel.fromJson(json)).where((item) {
        final nameLower = item.name!.toLowerCase();
        final queryLower = query.toLowerCase();

        return nameLower.contains(queryLower);
      }).toList();
    } else {
      throw Exception();
    }
  }
}

class VatMasterApi {
  static Future<List<VatMasterModel>> getVatSuggestions(String query) async {
    final url = Uri.parse('$apiRootAddress/item/get/all');
    final response = await get(url);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final List vats = json.decode(response.body);

      return vats.map((json) => VatMasterModel.fromJson(json)).where((vat) {
        final fvat = '${vat.vat! * 100}%';
        final queryLower = query.toLowerCase();
        return fvat.contains(queryLower);
      }).toList();
    } else {
      throw Exception();
    }
  }
}
