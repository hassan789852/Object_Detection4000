import 'package:flutter/material.dart';

import '../../../models/recognition.dart';

class BoxWidget extends StatelessWidget {
  final Recognition result;
  final String selectedObject;

  const BoxWidget({super.key, required this.result,required this.selectedObject});

  @override
  Widget build(BuildContext context) {

    if (result.label != selectedObject) {

      return const SizedBox.shrink();
    }

    Color color = Colors.primaries[
    (result.label.length + result.label.codeUnitAt(0) + result.id) %
        Colors.primaries.length];

    return Positioned(
      left: result.renderLocation.left,
      top: result.renderLocation.top,
      width: result.renderLocation.width,
      height: result.renderLocation.height,
      child: Container(
        width: result.renderLocation.width,
        height: result.renderLocation.height,
        decoration: BoxDecoration(
            border: Border.all(color: color, width: 3),
            borderRadius: const BorderRadius.all(Radius.circular(2))),
        child: Align(
          alignment: Alignment.topLeft,
          child: FittedBox(
            child: Container(
              color: color,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(result.label),
                  Text(" ${result.score.toStringAsFixed(2)}"),
                  Text(" - ${result.guidanceMessage}"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}