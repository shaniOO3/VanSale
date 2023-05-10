import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:vansales/api/api.dart';
import 'package:vansales/screen/profile_setup_screen.dart';
import 'package:vansales/utils.dart';
import 'package:vansales/widgets/NotificationBody.dart';
import 'package:vansales/widgets/responsive_text_field.dart';

import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late FirebaseAuth _auth;
  bool includingvat = false;
  bool vibration = false;

  late User? _user;
  late String? phoneno;

  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
    _user = _auth.currentUser;
    if (_user != null) {
      phoneno = _user!.phoneNumber;
    }
    includingvat = Preferences.getIncludingVat();
    vibration = Preferences.getVibrationState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.only(left: 32, right: 32, top: 15, bottom: 15),
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width - 40,
                  height: 50,
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    "SETTINGS",
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.indigo,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Container(
                    width: MediaQuery.of(context).size.width,
                    //alignment: Alignment.center,
                    padding: const EdgeInsets.only(
                        top: 15, left: 20, bottom: 15, right: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'PROFILE',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 18),
                        ),
                        const Divider(),
                        const SizedBox(
                          height: 8,
                        ),
                        InkWell(
                          onTap: () async {
                            bool isUpdated = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ProfileSetupScreen(
                                          isUpdate: true,
                                        )));
                            if (isUpdated) {
                              InAppNotification.show(
                                  child:
                                      NotificationBody(title: 'Data Updated'),
                                  context: context,
                                  duration: const Duration(seconds: 2),
                                  curve: Curves.decelerate);
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Update Info',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 18),
                              ),
                              Row(
                                children: const [
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 15,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(
                                    width: 18,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  //alignment: Alignment.center,
                  padding: const EdgeInsets.only(
                      top: 15, left: 20, bottom: 15, right: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'BILLING OPTION',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 18),
                      ),
                      const Divider(),
                      // const SizedBox(
                      //   height: 8,
                      // ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Including Vat',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                                fontSize: 18),
                          ),
                          Transform.scale(
                            scale: 1.5,
                            child: Checkbox(
                              value: includingvat,
                              shape: const CircleBorder(),
                              onChanged: (i) async {
                                setState(() {
                                  includingvat = i!;
                                });
                                await Preferences.setIncludingvat(includingvat);
                              },
                            ),
                          ),
                        ],
                      ),
                      const Divider(
                        thickness: 0.15,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      InkWell(
                        onTap: () async {
                          bool isUploaded = await showDialog(
                              context: context,
                              builder: (context) => const VatAddPopup());
                          if (isUploaded) {
                            InAppNotification.show(
                                child: NotificationBody(title: 'New VAT Added'),
                                context: context,
                                duration: const Duration(seconds: 2),
                                curve: Curves.decelerate);
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'New Vat',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 18),
                            ),
                            Row(
                              children: const [
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 15,
                                  color: Colors.grey,
                                ),
                                SizedBox(
                                  width: 18,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  //alignment: Alignment.center,
                  padding: const EdgeInsets.only(
                      top: 15, left: 20, bottom: 15, right: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'ACCOUNT SETTINGS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 18),
                      ),
                      const Divider(),
                      const SizedBox(
                        height: 8,
                      ),
                      InkWell(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return CupertinoAlertDialog(
                                  insetAnimationCurve: Curves.easeInOutCubic,
                                  title: const Text(
                                    '⚠️ Clear DB',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  content: Column(
                                    children: const [
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        'Are you sure?',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        "All data from the database will be deleted. Except the user's info.",
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    CupertinoDialogAction(
                                      child: const Text('Cancel'),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    CupertinoDialogAction(
                                      child: const Text(
                                        'Clear',
                                        style: TextStyle(
                                            color: Colors.red, fontSize: 20),
                                      ),
                                      onPressed: () async {
                                        final endPointUri = Uri.parse(
                                            apiRootAddress +
                                                "companies/delete/all/data/${Preferences.getUserId()}");

                                        try {
                                          final response =
                                              await get(endPointUri);
                                          print(response.statusCode);
                                          if (response.statusCode >= 200 &&
                                              response.statusCode < 300) {
                                            InAppNotification.show(
                                              child: NotificationBody(
                                                title: 'DB Cleared',
                                                body:
                                                    "DataBase cleared successfully.",
                                              ),
                                              context: context,
                                              duration:
                                                  const Duration(seconds: 3),
                                              curve: Curves.decelerate,
                                            );
                                          } else {
                                            InAppNotification.show(
                                                child: NotificationBody(
                                                  title: 'Failed',
                                                  body: "Failed to clear DB",
                                                  isError: true,
                                                ),
                                                context: context,
                                                duration:
                                                    const Duration(seconds: 3),
                                                curve: Curves.decelerate);
                                          }
                                        } on HttpException catch (e) {
                                          print(e);
                                          InAppNotification.show(
                                              child: NotificationBody(
                                                title: 'Failed',
                                                body: "Unable to clear DB",
                                                isError: true,
                                              ),
                                              context: context,
                                              duration:
                                                  const Duration(seconds: 3),
                                              curve: Curves.decelerate);
                                        }
                                      },
                                    )
                                  ],
                                );
                              });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Clear DataBase',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 18),
                            ),
                            Row(
                              children: const [
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 15,
                                  color: Colors.grey,
                                ),
                                SizedBox(
                                  width: 18,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Container(
                    width: MediaQuery.of(context).size.width,
                    //alignment: Alignment.center,
                    padding: const EdgeInsets.only(
                        top: 15, left: 20, bottom: 15, right: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'ALERT',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 18),
                        ),
                        const Divider(),
                        const SizedBox(
                          height: 8,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Vibration',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 18),
                            ),
                            CupertinoSwitch(
                              value: vibration,
                              onChanged: (i) async {
                                setState(() {
                                  vibration = i;
                                });
                                await Preferences.setVibrationState(vibration);
                              },
                            ),
                          ],
                        ),
                      ],
                    )),
                const SizedBox(
                  height: 30,
                ),
                InkWell(
                  onTap: () {
                    // if (vibration) {
                    //   HapticFeedback.heavyImpact();
                    // }
                    // showSheet(
                    //   context,
                    //   child: Container(
                    //     height: 150,
                    //     color: Colors.white,
                    //     child: Column(
                    //       children: const [
                    //         Text(
                    //           'Log out',
                    //           style: TextStyle(
                    //             color: Colors.black,
                    //             fontSize: 20
                    //           ),
                    //         ),
                    //         Text(
                    //           'Are you sure you want to Logout?',
                    //           style: TextStyle(
                    //               color: Colors.black,
                    //               fontSize: 14
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    //   onClicked: () async{
                    //     await _auth.signOut();
                    //     await Preferences.setPData(false);
                    //     await Preferences.setVibrationState(false);
                    //     Navigator.pushReplacement(
                    //         context,
                    //         MaterialPageRoute(
                    //             builder: (context) => const LoginScreen()));
                    //   },
                    // );

                    showDialog(
                        context: context,
                        builder: (context) {
                          return CupertinoAlertDialog(
                            insetAnimationCurve: Curves.easeInOutCubic,
                            title: const Text(
                              'Log out',
                              style: TextStyle(fontSize: 20),
                            ),
                            content: Column(
                              children: const [
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  'Are you sure want to Logout?',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            actions: [
                              CupertinoDialogAction(
                                child: const Text('Close'),
                                onPressed: () => Navigator.pop(context),
                              ),
                              CupertinoDialogAction(
                                child: const Text(
                                  'Logout',
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 20),
                                ),
                                onPressed: () async {
                                  await _auth.signOut();
                                  await Preferences.setUserId(0);
                                  await Preferences.setPData(false);
                                  await Preferences.setVibrationState(false);
                                  int count = 0;
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginScreen()),
                                      (_) => count++ >= 2);
                                },
                              )
                            ],
                          );
                        });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'LOGOUT',
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
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

class VatAddPopup extends StatefulWidget {
  const VatAddPopup({Key? key}) : super(key: key);

  @override
  _VatAddPopupState createState() => _VatAddPopupState();
}

class _VatAddPopupState extends State<VatAddPopup> {
  TextEditingController vat = TextEditingController();

  final vataddUri = Uri.parse(apiRootAddress + "/vatmaster/add");

  late bool _isPressed;

  void postData() async {
    double newvat = double.parse(vat.text) / 100;

    try {
      var body = jsonEncode({'vat': '$newvat'});

      final response = await post(vataddUri,
              headers: {
                "Accept": "application/json",
                "content-type": "application/json"
              },
              body: body)
          .timeout(const Duration(seconds: 5));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        Navigator.pop(context, true);
      } else if (response.statusCode == 409) {
        InAppNotification.show(
            child: NotificationBody(
              title: 'Failed',
              body: 'Vat already exist',
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
      }
    } on Exception catch (e) {
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
  }

  @override
  void initState() {
    _isPressed = false;
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
        height: 190,
        width: 190,
        padding:
            const EdgeInsets.only(left: 30, right: 30, top: 25, bottom: 10),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 5),
              child: const Text(
                "New VAT",
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
              controller: vat,
              label: "Vat",
              suffixText: '%',
              type: const TextInputType.numberWithOptions(decimal: true),
              action: TextInputAction.done,
            ),
            const SizedBox(
              height: 15,
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
                        if (vat.text.isNotEmpty) {
                          setState(() {
                            _isPressed = true;
                          });
                          postData();
                        } else {
                          InAppNotification.show(
                              child: NotificationBody(
                                title: 'Failed',
                                body: 'Please fill the field',
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
                        : const Text("Add")),
              ],
            )
          ],
        ),
      );
}
