import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vansales/loadingskeleton/skeleton.dart';

class CustoSupplListSkeleton extends StatelessWidget {

  bool? item = false;

  CustoSupplListSkeleton({
    Key? key,
    this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade400,
      highlightColor: Colors.grey.shade900,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        padding:
        const EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 15),
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            boxShadow: [
              BoxShadow(
                  color: Colors.indigo.withOpacity(0.05), blurRadius: 10.0),
            ]),
        child: Row(
          children: [
            Icon(
              item == true ? Icons.archive : Icons.account_circle,
              size: 75,
              color: Colors.black.withOpacity(0.04),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Expanded(child: Skeleton()),
                      Expanded(child: SizedBox())
                    ],
                  ),
                  Row(
                    children: const [
                      Expanded(child: Skeleton()),
                      Expanded(child: SizedBox()),
                      Expanded(child: Skeleton())
                    ],
                  ),
                  Row(
                    children: const [
                      Expanded(child: Skeleton()),
                      Expanded(flex: 2,child: SizedBox()),
                    ],
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