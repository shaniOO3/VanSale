import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils.dart';

class NotificationBody extends StatelessWidget {
  final String title;
  final String? body;
  bool? isError = false;

  NotificationBody({
    Key? key,
    required this.title, this.body, this.isError,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(Preferences.getVibrationState()) HapticFeedback.heavyImpact();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 12,
              blurRadius: 16,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: isError == true ? Colors.red.withOpacity(0.2) : Colors.indigo.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16.0),
                // border: Border.all(
                //   width: 1.4,
                //   color: Colors.indigo.withOpacity(0.2),
                // ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        title,
                        style: Theme.of(context)
                            .textTheme
                            .headline6!
                            .copyWith(color: Colors.white),
                      ),
                      if(body != null) Text(
                          '$body',
                        style: const TextStyle(
                          color: Colors.white70
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}