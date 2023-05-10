import 'dart:convert';
import 'package:http/http.dart';
import 'package:vansales/api/api.dart';

import '../utils.dart';

class Supplier {
  final String name;
  final int? id;

  const Supplier({
    required this.name,
    this.id
  });

  static Supplier fromJson(Map<String, dynamic> json) => Supplier(
    name: json['name'],
    id: json['id']
  );
}

class SupplierApi {
  static Future<List<Supplier>> getSupplierSuggestions(String query) async {
    final url = Uri.parse(apiRootAddress+'/supplier/get/all/active/${Preferences.getUserId()}');
    final response = await get(url);

    if (response.statusCode == 200) {
      final List suppliers = json.decode(response.body);

      return suppliers.map((json) => Supplier.fromJson(json)).where((supplier) {
        final nameLower = supplier.name.toLowerCase();
        final queryLower = query.toLowerCase();

        return nameLower.contains(queryLower);
      }).toList();
    } else {
      throw Exception();
    }
  }
}