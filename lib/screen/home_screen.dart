import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:vansales/assets.dart';

import 'cards/customer_screen.dart';
import 'cards/items_screen.dart';
import 'cards/purchase_screen.dart';
import 'cards/sales_screen.dart';
import 'cards/supplier_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: double.maxFinite,
      // color: Colors.indigo,
      child: SafeArea(
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                width: double.maxFinite,
                height: 390,
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(bgImg),
                    ),
                  ),
                  child: NeumorphicText(
                    "VANSALE",
                    style: NeumorphicStyle(
                      lightSource: LightSource.topRight,
                      depth: 2,
                      intensity: 1,
                      color: Colors.white,
                      shadowDarkColor: Colors.indigo.withOpacity(0.8),
                    ),
                    textStyle: NeumorphicTextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      //fontFamily: 'Baumans'
                    ),
                  ),
                ),
              ),
            ),
            // Positioned(
            //   top: 330,
            //   child: Container(
            //     width: MediaQuery.of(context).size.width,
            //     height: 500,
            //     decoration: BoxDecoration(
            //         //color: Color.fromARGB(255, 9, 84, 179),
            //         color: AppColors.mainColor,
            //         borderRadius: BorderRadius.only(
            //             topLeft: Radius.circular(60),
            //             topRight: Radius.circular(60))),
            //   ),
            // ),
            Positioned(
              top: 270,
              right: 20,
              left: 20,
              bottom: 30,
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            hoverColor: Colors.indigo.withOpacity(0.2),
                            highlightColor: Colors.indigo.withOpacity(0.2),
                            focusColor: Colors.indigo.withOpacity(0.2),
                            splashColor: Colors.indigo.withOpacity(0.2),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const SalesPage()));
                            },
                            child: Neumorphic(
                              style: NeumorphicStyle(
                                  shape: NeumorphicShape.concave,
                                  boxShape: NeumorphicBoxShape.roundRect(
                                      BorderRadius.circular(18)),
                                  depth: 8,
                                  lightSource: LightSource.topLeft,
                                  shadowLightColor:
                                      Colors.indigo.withOpacity(0.8),
                                  shadowDarkColor:
                                      Colors.indigo.withOpacity(0.8),
                                  color: Colors.white.withOpacity(0.98)),
                              child: Container(
                                padding: const EdgeInsets.only(bottom: 10),
                                alignment: Alignment.bottomCenter,
                                //height: 170,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height,
                                        decoration: const BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage(salesImg),
                                            alignment: Alignment.topCenter,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Text(
                                      "Sales",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.indigo),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: InkWell(
                            hoverColor: Colors.indigo.withOpacity(0.2),
                            highlightColor: Colors.indigo.withOpacity(0.2),
                            focusColor: Colors.indigo.withOpacity(0.2),
                            splashColor: Colors.indigo.withOpacity(0.2),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const PurchaseScreen()));
                            },
                            child: Neumorphic(
                              style: NeumorphicStyle(
                                  shape: NeumorphicShape.concave,
                                  boxShape: NeumorphicBoxShape.roundRect(
                                      BorderRadius.circular(18)),
                                  depth: 8,
                                  lightSource: LightSource.topLeft,
                                  shadowLightColor:
                                      Colors.indigo.withOpacity(0.8),
                                  shadowDarkColor:
                                      Colors.indigo.withOpacity(0.8),
                                  color: Colors.white.withOpacity(0.98)),
                              child: Container(
                                padding: const EdgeInsets.only(bottom: 10),
                                alignment: Alignment.bottomCenter,
                                //height: 170,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height,
                                        decoration: const BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage(purchaseImg),
                                            alignment: Alignment.topCenter,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Text(
                                      "Purchase",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.indigo),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            hoverColor: Colors.indigo.withOpacity(0.2),
                            highlightColor: Colors.indigo.withOpacity(0.2),
                            focusColor: Colors.indigo.withOpacity(0.2),
                            splashColor: Colors.indigo.withOpacity(0.2),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const CustomerScreen()));
                            },
                            child: Neumorphic(
                              style: NeumorphicStyle(
                                  shape: NeumorphicShape.concave,
                                  boxShape: NeumorphicBoxShape.roundRect(
                                      BorderRadius.circular(18)),
                                  depth: 8,
                                  lightSource: LightSource.topLeft,
                                  shadowLightColor:
                                      Colors.indigo.withOpacity(0.8),
                                  shadowDarkColor:
                                      Colors.indigo.withOpacity(0.8),
                                  color: Colors.white.withOpacity(0.98)),
                              child: Container(
                                padding: const EdgeInsets.only(bottom: 10),
                                alignment: Alignment.bottomCenter,
                                //height: 170,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height,
                                        decoration: const BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage(customerImg),
                                            alignment: Alignment.topCenter,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Text(
                                      "Customer",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.indigo),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: InkWell(
                            hoverColor: Colors.indigo.withOpacity(0.2),
                            highlightColor: Colors.indigo.withOpacity(0.2),
                            focusColor: Colors.indigo.withOpacity(0.2),
                            splashColor: Colors.indigo.withOpacity(0.2),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const SupplierPage()));
                            },
                            child: Neumorphic(
                              style: NeumorphicStyle(
                                  shape: NeumorphicShape.concave,
                                  boxShape: NeumorphicBoxShape.roundRect(
                                      BorderRadius.circular(18)),
                                  depth: 8,
                                  lightSource: LightSource.topLeft,
                                  shadowLightColor:
                                      Colors.indigo.withOpacity(0.8),
                                  shadowDarkColor:
                                      Colors.indigo.withOpacity(0.8),
                                  color: Colors.white.withOpacity(0.98)),
                              child: Container(
                                padding: const EdgeInsets.only(bottom: 10),
                                //alignment: Alignment.bottomCenter,
                                //height: 170,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height,
                                        decoration: const BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage(supplierImg),
                                            alignment: Alignment.topCenter,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Text(
                                      "Supplier",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.indigo),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            hoverColor: Colors.indigo.withOpacity(0.2),
                            highlightColor: Colors.indigo.withOpacity(0.2),
                            focusColor: Colors.indigo.withOpacity(0.2),
                            splashColor: Colors.indigo.withOpacity(0.2),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ItemsScreen()));
                            },
                            child: Neumorphic(
                              style: NeumorphicStyle(
                                  shape: NeumorphicShape.concave,
                                  boxShape: NeumorphicBoxShape.roundRect(
                                      BorderRadius.circular(18)),
                                  depth: 8,
                                  lightSource: LightSource.topLeft,
                                  shadowLightColor:
                                      Colors.indigo.withOpacity(0.8),
                                  shadowDarkColor:
                                      Colors.indigo.withOpacity(0.8),
                                  color: Colors.white.withOpacity(0.98)),
                              child: Container(
                                padding: const EdgeInsets.only(bottom: 10),
                                alignment: Alignment.bottomCenter,
                                //height: 170,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height,
                                        decoration: const BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage(itemsImg),
                                            alignment: Alignment.topCenter,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Text(
                                      "Items",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.indigo),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        // SizedBox(
                        //   width: 10,
                        // ),
                        // Expanded(
                        //   child: Neumorphic(
                        //     style: NeumorphicStyle(
                        //         shape: NeumorphicShape.concave,
                        //         boxShape: NeumorphicBoxShape.roundRect(
                        //             BorderRadius.circular(12)),
                        //         depth: 8,
                        //         lightSource: LightSource.topLeft,
                        //         color: Colors.white.withOpacity(0.9)),
                        //     child: Container(
                        //       padding: const EdgeInsets.only(bottom: 10),
                        //       alignment: Alignment.bottomCenter,
                        //       height: 170,
                        //       child: Column(
                        //         mainAxisAlignment: MainAxisAlignment.center,
                        //         children: [
                        //           Expanded(
                        //             child: Container(
                        //               height:
                        //                   MediaQuery.of(context).size.height,
                        //               decoration: BoxDecoration(
                        //                 image: DecorationImage(
                        //                   image:
                        //                       AssetImage("images/price.png"),
                        //                   alignment: Alignment.topCenter,
                        //                 ),
                        //               ),
                        //             ),
                        //           ),
                        //           Text(
                        //             "Price",
                        //             style: TextStyle(
                        //                 fontSize: 20,
                        //                 fontWeight: FontWeight.bold,
                        //                 color: Colors.indigoAccent),
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
