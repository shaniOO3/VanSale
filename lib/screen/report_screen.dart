import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:intl/intl.dart';
import 'package:vansales/api/api.dart';
import 'package:vansales/pdf/pdf_main.dart';
import 'package:vansales/popups/sale_add_popup.dart';
import 'package:vansales/widgets/NotificationBody.dart';

import '../utils.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  DateTime dateTime = DateTime.now();

  static void showSnackBar(BuildContext context, String text) {
    final snackBar = SnackBar(
      content: Text(text, style: const TextStyle(fontSize: 24)),
    );

    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static void showSheet(
    BuildContext context, {
    required Widget child,
    required VoidCallback onClicked,
    String? button,
  }) =>
      showCupertinoModalPopup(
        context: context,
        builder: (context) => CupertinoActionSheet(
          actions: [
            child,
          ],
          cancelButton: CupertinoActionSheetAction(
            child: Text(button ?? 'Done'),
            onPressed: onClicked,
          ),
        ),
      );

  Widget buildDatePicker() => Container(
        height: 180,
        color: Colors.white,
        child: CupertinoDatePicker(
          minimumYear: 2015,
          maximumYear: DateTime.now().year,
          maximumDate: DateTime.now(),
          initialDateTime: dateTime,
          mode: CupertinoDatePickerMode.date,
          onDateTimeChanged: (dateTime) =>
              setState(() => this.dateTime = dateTime),
        ),
      );

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
                    "REPORTS",
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.indigo,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                // InkWell(
                //   onTap: () => showSheet(
                //     context,
                //     child: buildDatePicker(),
                //     onClicked: () async {
                //       final value = DateFormat('yyyy-MM-dd').format(dateTime);

                //       final endPointUri = Uri.parse(apiRootAddress +
                //           "/pdf/generate/pdf/sales/$value/${Preferences.getUserId()}");

                //       try {
                //         final response = await get(endPointUri);
                //         print(response.statusCode);
                //         if (response.statusCode >= 200 &&
                //             response.statusCode < 300) {
                //           final pdfFile = await PdfMain.saveDocument(
                //               name: 'sale' + value, byties: response.bodyBytes);
                //           PdfMain.openFile(pdfFile);
                //         } else {
                //           InAppNotification.show(
                //               child: NotificationBody(
                //                 title: 'Failed',
                //                 body: "No sale found on $value",
                //                 isError: true,
                //               ),
                //               context: context,
                //               duration: const Duration(seconds: 3),
                //               curve: Curves.decelerate);
                //         }
                //       } on HttpException catch (e) {
                //         print(e);
                //       }

                //       //showSnackBar(context, 'Selected "$value"');

                //       Navigator.pop(context);
                //     },
                //   ),
                //   child: Container(
                //     width: MediaQuery.of(context).size.width,
                //     alignment: Alignment.center,
                //     padding: const EdgeInsets.all(20),
                //     decoration: BoxDecoration(
                //         color: Colors.white,
                //         borderRadius: BorderRadius.circular(12),
                //         boxShadow: [
                //           BoxShadow(
                //               color: Colors.indigo.withOpacity(0.2),
                //               blurRadius: 10.0),
                //         ]),
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //       children: const [
                //         Text(
                //           'Sales Summery',
                //           style: TextStyle(
                //               fontWeight: FontWeight.bold, fontSize: 18),
                //         ),
                //         Icon(Icons.picture_as_pdf_outlined),
                //       ],
                //     ),
                //   ),
                // ),
                // const SizedBox(
                //   height: 15,
                // ),
                InkWell(
                  onTap: () => showSheet(
                    context,
                    child: buildDatePicker(),
                    button: 'Next',
                    onClicked: () async {
                      final date1 = DateFormat('yyyy-MM-dd').format(dateTime);

                      Navigator.pop(context);

                      showSheet(
                        context,
                        child: buildDatePicker(),
                        onClicked: () async {
                          final date2 =
                              DateFormat('yyyy-MM-dd').format(dateTime);

                          // final endPointUri = Uri.parse(apiRootAddress +
                          //     "/pdf/generate/periodsale/$date1/$date2/${Preferences.getUserId()}");
                          final endPointUri = Uri.parse(apiRootAddress +
                              "/pdf/generate/new/periodsale/$date1/$date2/${Preferences.getUserId()}");

                          try {
                            final response = await get(endPointUri);
                            print(response.statusCode);
                            print(response.body);
                            if (response.statusCode >= 200 &&
                                response.statusCode < 300) {
                              final pdfFile = await PdfMain.saveDocument(
                                  name: 'sale' + date1 + date2,
                                  byties: response.bodyBytes);
                              PdfMain.openFile(pdfFile);
                            } else {
                              InAppNotification.show(
                                  child: NotificationBody(
                                    title: 'Failed',
                                    body: "No sale from $date1 to $date2",
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
                        },
                      );
                    },
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.indigo.withOpacity(0.2),
                              blurRadius: 10.0),
                        ]),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Sales Summery',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Icon(Icons.picture_as_pdf_outlined),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                InkWell(
                  onTap: () => showSheet(
                    context,
                    child: buildDatePicker(),
                    button: 'Next',
                    onClicked: () async {
                      final date1 = DateFormat('yyyy-MM-dd').format(dateTime);

                      Navigator.pop(context);

                      showSheet(
                        context,
                        child: buildDatePicker(),
                        onClicked: () async {
                          final date2 =
                              DateFormat('yyyy-MM-dd').format(dateTime);

                          final endPointUri = Uri.parse(apiRootAddress +
                              "/pdf/generate/new/periodpurchase/$date1 00:00:00/$date2 12:00:00/${Preferences.getUserId()}");

                          try {
                            final response = await get(endPointUri);
                            print(endPointUri);
                            print(response.statusCode);
                            print(response.body);
                            if (response.statusCode >= 200 &&
                                response.statusCode < 300) {
                              final pdfFile = await PdfMain.saveDocument(
                                  name: 'purc' + date1 + date2,
                                  byties: response.bodyBytes);
                              PdfMain.openFile(pdfFile);
                            } else {
                              InAppNotification.show(
                                  child: NotificationBody(
                                    title: 'Failed',
                                    body: "No Purchase from $date1 to $date2",
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
                        },
                      );
                    },
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.indigo.withOpacity(0.2),
                              blurRadius: 10.0),
                        ]),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Purchase Summery',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Icon(Icons.picture_as_pdf_outlined),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                InkWell(
                  onTap: () async {
                    return showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const SaleAddPopup(
                            isReport: true,
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
                        boxShadow: [
                          BoxShadow(
                              color: Colors.indigo.withOpacity(0.2),
                              blurRadius: 10.0),
                        ]),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Customer Balance',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Icon(Icons.picture_as_pdf_outlined),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                InkWell(
                  onTap: () async {
                    final endPointUri = Uri.parse(apiRootAddress +
                        "/pdf/generate/new/balance/${Preferences.getUserId()}");

                    try {
                      final response = await get(endPointUri);
                      print(response.statusCode);
                      if (response.statusCode >= 200 &&
                          response.statusCode < 300) {
                        final pdfFile = await PdfMain.saveDocument(
                            name: 'bal report', byties: response.bodyBytes);
                        PdfMain.openFile(pdfFile);
                      } else {
                        InAppNotification.show(
                            child: NotificationBody(
                              title: 'Failed',
                              body: "No report found",
                              isError: true,
                            ),
                            context: context,
                            duration: const Duration(seconds: 3),
                            curve: Curves.decelerate);
                      }
                    } on HttpException catch (e) {
                      print(e);
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.indigo.withOpacity(0.2),
                              blurRadius: 10.0),
                        ]),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Balance Report',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Icon(Icons.picture_as_pdf_outlined),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                // InkWell(
                //   onTap: () => showSheet(
                //     context,
                //     child: buildDatePicker(),
                //     onClicked: () async {
                //       final value = DateFormat('yyyy-MM-dd').format(dateTime);

                //       final endPointUri = Uri.parse(apiRootAddress +
                //           "/pdf/generate/stocklist/$value/${Preferences.getUserId()}");

                //       try {
                //         final response = await get(endPointUri);
                //         print(response.statusCode);
                //         if (response.statusCode >= 200 &&
                //             response.statusCode < 300) {
                //           final pdfFile = await PdfMain.saveDocument(
                //               name: 'stock' + value, byties: response.bodyBytes);
                //           PdfMain.openFile(pdfFile);
                //         } else {
                //           InAppNotification.show(
                //               child: NotificationBody(
                //                 title: 'Failed',
                //                 body: "No report found on $value",
                //                 isError: true,
                //               ),
                //               context: context,
                //               duration: const Duration(seconds: 3),
                //               curve: Curves.decelerate);
                //         }
                //       } on HttpException catch (e) {
                //         print(e);
                //         InAppNotification.show(
                //             child: NotificationBody(
                //               title: 'Error',
                //               body: "can't connect to database",
                //               isError: true,
                //             ),
                //             context: context,
                //             duration: const Duration(seconds: 3),
                //             curve: Curves.decelerate);
                //       }

                //       //showSnackBar(context, 'Selected "$value"');

                //       Navigator.pop(context);
                //     },
                //   ),
                //   child: Container(
                //     width: MediaQuery.of(context).size.width,
                //     alignment: Alignment.center,
                //     padding: const EdgeInsets.all(20),
                //     decoration: BoxDecoration(
                //         color: Colors.white,
                //         borderRadius: BorderRadius.circular(12),
                //         boxShadow: [
                //           BoxShadow(
                //               color: Colors.indigo.withOpacity(0.2),
                //               blurRadius: 10.0),
                //         ]),
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //       children: const [
                //         Text(
                //           'Sold Item',
                //           style: TextStyle(
                //               fontWeight: FontWeight.bold, fontSize: 18),
                //         ),
                //         Icon(Icons.picture_as_pdf_outlined),
                //       ],
                //     ),
                //   ),
                // ),
                // const SizedBox(
                //   height: 15,
                // ),
                InkWell(
                  onTap: () async {
                    final endPointUri = Uri.parse(apiRootAddress +
                        "/pdf/generate/new/stocklist/${Preferences.getUserId()}");

                    try {
                      final response = await get(endPointUri);
                      print(response.statusCode);
                      if (response.statusCode >= 200 &&
                          response.statusCode < 300) {
                        final pdfFile = await PdfMain.saveDocument(
                            name: 'sold report', byties: response.bodyBytes);
                        PdfMain.openFile(pdfFile);
                      } else {
                        InAppNotification.show(
                            child: NotificationBody(
                              title: 'Failed',
                              body: "No report found",
                              isError: true,
                            ),
                            context: context,
                            duration: const Duration(seconds: 3),
                            curve: Curves.decelerate);
                      }
                    } on HttpException catch (e) {
                      print(e);
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.indigo.withOpacity(0.2),
                              blurRadius: 10.0),
                        ]),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Sold Stock Report',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Icon(Icons.picture_as_pdf_outlined),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                InkWell(
                  onTap: () async {
                    final endPointUri = Uri.parse(apiRootAddress +
                        "/pdf/generate/new/instocklist/${Preferences.getUserId()}");

                    try {
                      final response = await get(endPointUri);
                      print(response.statusCode);
                      if (response.statusCode >= 200 &&
                          response.statusCode < 300) {
                        final pdfFile = await PdfMain.saveDocument(
                            name: 'stock report', byties: response.bodyBytes);
                        PdfMain.openFile(pdfFile);
                      } else {
                        InAppNotification.show(
                            child: NotificationBody(
                              title: 'Failed',
                              body: "No report found",
                              isError: true,
                            ),
                            context: context,
                            duration: const Duration(seconds: 3),
                            curve: Curves.decelerate);
                      }
                    } on HttpException catch (e) {
                      print(e);
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.indigo.withOpacity(0.2),
                              blurRadius: 10.0),
                        ]),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Stock Report',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Icon(Icons.picture_as_pdf_outlined),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),

                // InkWell(
                //   onTap: () async {
                //     final endPointUri = Uri.parse(apiRootAddress +
                //         "/pdf/generate/vatreport/${Preferences.getUserId()}");

                //     try {
                //       final response = await get(endPointUri);
                //       print(response.statusCode);
                //       if (response.statusCode >= 200 &&
                //           response.statusCode < 300) {
                //         final pdfFile = await PdfMain.saveDocument(
                //             name: 'vat report', byties: response.bodyBytes);
                //         PdfMain.openFile(pdfFile);
                //       } else {
                //         InAppNotification.show(
                //             child: NotificationBody(
                //               title: 'Failed',
                //               body: "No report found",
                //               isError: true,
                //             ),
                //             context: context,
                //             duration: const Duration(seconds: 3),
                //             curve: Curves.decelerate);
                //       }
                //     } on HttpException catch (e) {
                //       print(e);
                //     }
                //   },
                //   child: Container(
                //     width: MediaQuery.of(context).size.width,
                //     alignment: Alignment.center,
                //     padding: const EdgeInsets.all(20),
                //     decoration: BoxDecoration(
                //         color: Colors.white,
                //         borderRadius: BorderRadius.circular(12),
                //         boxShadow: [
                //           BoxShadow(
                //               color: Colors.indigo.withOpacity(0.2),
                //               blurRadius: 10.0),
                //         ]),
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //       children: const [
                //         Text(
                //           'Vat Report',
                //           style: TextStyle(
                //               fontWeight: FontWeight.bold, fontSize: 18),
                //         ),
                //         Icon(Icons.picture_as_pdf_outlined),
                //       ],
                //     ),
                //   ),
                // ),
                // const SizedBox(
                //   height: 15,
                // ),
                InkWell(
                  onTap: () => showSheet(
                    context,
                    child: buildDatePicker(),
                    button: 'Next',
                    onClicked: () async {
                      final date1 = DateFormat('yyyy-MM-dd').format(dateTime);

                      Navigator.pop(context);

                      showSheet(
                        context,
                        child: buildDatePicker(),
                        onClicked: () async {
                          final date2 =
                              DateFormat('yyyy-MM-dd').format(dateTime);

                          final endPointUri = Uri.parse(apiRootAddress +
                              "/pdf/generate/periodvat/$date1/$date2/${Preferences.getUserId()}");

                          try {
                            final response = await get(endPointUri);
                            print(response.statusCode);
                            print(response.body);
                            if (response.statusCode >= 200 &&
                                response.statusCode < 300) {
                              final pdfFile = await PdfMain.saveDocument(
                                  name: 'vat' + date1 + date2,
                                  byties: response.bodyBytes);
                              PdfMain.openFile(pdfFile);
                            } else {
                              InAppNotification.show(
                                  child: NotificationBody(
                                    title: 'Failed',
                                    body: "No vat report from $date1 to $date2",
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
                        },
                      );
                    },
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.indigo.withOpacity(0.2),
                              blurRadius: 10.0),
                        ]),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Vat Report',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Icon(Icons.picture_as_pdf_outlined),
                      ],
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
