import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BlinkingAddButton extends StatefulWidget {
  const BlinkingAddButton({Key? key}) : super(key: key);

  @override
  _BlinkingAddButtonState createState() => _BlinkingAddButtonState();
}

class _BlinkingAddButtonState extends State<BlinkingAddButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animationController.repeat(reverse: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animationController,
      child: const Icon(
        Icons.add,
        size: 40,
        color: Colors.indigo,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
