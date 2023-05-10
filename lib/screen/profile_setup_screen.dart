import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:vansales/api/api.dart';
import 'package:vansales/utils.dart';
import 'package:vansales/widgets/NotificationBody.dart';
import 'package:vansales/widgets/responsive_text_field.dart';

import 'main_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  final bool isUpdate;

  const ProfileSetupScreen({Key? key, required this.isUpdate})
      : super(key: key);

  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState(isUpdate);
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final name = TextEditingController();
  final phone = TextEditingController();
  final companyName = TextEditingController();
  final companyNameA = TextEditingController();
  final address = TextEditingController();
  final addressA = TextEditingController();
  final vatNo = TextEditingController();

  _ProfileSetupScreenState(this.isUpdate);

  final bool isUpdate;
  late bool _isPressed;
  late FirebaseAuth _auth;
  late String? phoneno;

  final addUri = Uri.parse(apiRootAddress + "/user/add/user");
  late Uri getUri = Uri.parse(apiRootAddress + "/user/get/byPhone/" + phoneno!);
  final updateUri = Uri.parse(apiRootAddress + "/user/update");

  void fetchData() async {
    try {
      final response = await get(getUri);
      final jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        setState(() {
          name.text = jsonData['name'];
          companyName.text = jsonData['companyName'];
          companyNameA.text = jsonData['companyNameInArabic'] ?? " ";
          address.text = jsonData['address'];
          addressA.text = jsonData['addressInArabic'] ?? " ";
          vatNo.text = jsonData['vatNo'];
        });
      } else {}
    } on HttpException catch (e) {
      InAppNotification.show(
          child: NotificationBody(
            title: 'Error',
            body: e.message,
            isError: true,
          ),
          context: context,
          duration: const Duration(seconds: 3),
          curve: Curves.decelerate);
    }
  }

  void postData() async {
    try {
      var body = jsonEncode({
        "name": name.text,
        "phone": phone.text,
        "companyName": companyName.text,
        "companyNameInArabic": companyNameA.text,
        "address": address.text,
        "addressInArabic": addressA.text,
        "vatNo": vatNo.text
      });

      final response = await post(updateUri,
          headers: {
            "Accept": "application/json",
            "content-type": "application/json"
          },
          body: body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await Preferences.setPData(true);
        isUpdate
            ? Navigator.pop(context, true)
            : Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const MainScreen()));
        // ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(content: Text("New customer ${name.text} added successfully"))
        // );
      } else {
        InAppNotification.show(
            child: NotificationBody(
              title: 'Failed',
              isError: true,
            ),
            context: context,
            duration: const Duration(seconds: 4),
            curve: Curves.decelerate);
        setState(() {
          _isPressed = false;
        });
        // ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(content: Text("Failed! try again later"))
        // );
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
          duration: const Duration(seconds: 4),
          curve: Curves.decelerate);
      setState(() {
        _isPressed = false;
      });
    }
  }

  @override
  void initState() {
    _isPressed = false;
    _auth = FirebaseAuth.instance;
    phoneno = _auth.currentUser!.phoneNumber;
    phone.text = phoneno!;
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xfff7f6fb),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            //padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            padding:
                const EdgeInsets.only(left: 32, right: 32, top: 15, bottom: 24),
            child: Column(
              children: [
                isUpdate
                    ? Align(
                        alignment: Alignment.topLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context, false),
                          child: const Icon(
                            Icons.arrow_back,
                            size: 32,
                            color: Colors.black54,
                          ),
                        ),
                      )
                    : const SizedBox(
                        height: 42,
                      ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    //color: Colors.indigo.shade50,
                    color: Colors.indigoAccent.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/images/user.png',
                    fit: BoxFit.fitWidth,
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                const Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  isUpdate
                      ? 'Make the changes you need'
                      : "Complete your profile to continue",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black38,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 28,
                ),
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      ResponsiveTextField(
                        label: 'Name',
                        controller: name,
                        action: TextInputAction.next,
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      ResponsiveTextField(
                        label: 'Phone',
                        controller: phone,
                        action: TextInputAction.next,
                        isEnabled: false,
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      ResponsiveTextField(
                        label: 'Company Name',
                        controller: companyName,
                        action: TextInputAction.next,
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      ResponsiveTextField(
                        label: 'Company Name Arabic',
                        controller: companyNameA,
                        fontFamily: 'Almarai',
                        action: TextInputAction.next,
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      ResponsiveTextField(
                        label: 'Address',
                        controller: address,
                        fontFamily: 'Almarai',
                        action: TextInputAction.next,
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      ResponsiveTextField(
                        label: 'Address Arabic',
                        controller: addressA,
                        fontFamily: 'Almarai',
                        action: TextInputAction.next,
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      ResponsiveTextField(
                          label: 'Vat No',
                          controller: vatNo,
                          action: TextInputAction.done),
                      const SizedBox(
                        height: 22,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (name.text.isNotEmpty &&
                                companyName.text.isNotEmpty &&
                                address.text.isNotEmpty &&
                                vatNo.text.isNotEmpty) {
                              setState(() {
                                _isPressed = true;
                              });
                              postData();
                            } else {
                              InAppNotification.show(
                                  child: NotificationBody(
                                    title: 'Failed',
                                    body: "Please fill all the fields",
                                    isError: true,
                                  ),
                                  context: context,
                                  duration: const Duration(seconds: 3),
                                  curve: Curves.decelerate);
                            }
                          },
                          style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                _isPressed
                                    ? Colors.grey.shade400
                                    : Colors.indigoAccent),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24.0),
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: _isPressed
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator())
                                : Text(
                                    isUpdate ? 'Update' : 'Save',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
