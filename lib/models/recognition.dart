import 'package:Hasssan_Hallak_live_object/models/screen_params.dart';
import 'package:flutter/cupertino.dart';

/// Represents the recognition output from the model
class Recognition {
  /// Index of the result
  final int _id;

  /// Label of the result
  final String _label;

  /// Confidence [0.0, 1.0]
  final double _score;

  /// Location of bounding box rect
  final Rect _location;

  /// Guidance message (e.g., "Move closer", "Move farther", "Object in position")
  final String _guidanceMessage;

  Recognition(this._id, this._label, this._score, this._location, this._guidanceMessage);

  int get id => _id;
  String get label => _label;
  double get score => _score;
  Rect get location => _location;
  String get guidanceMessage => _guidanceMessage;

  /// Returns bounding box rectangle corresponding to the displayed image on screen
  Rect get renderLocation {
    final double scaleX = ScreenParams.screenPreviewSize.width / 300;
    final double scaleY = ScreenParams.screenPreviewSize.height / 300;
    return Rect.fromLTWH(
      location.left * scaleX,
      location.top * scaleY,
      location.width * scaleX,
      location.height * scaleY,
    );
  }

  @override
  String toString() {
    return 'Recognition(id: $id, label: $label, score: $score, location: $location, guidanceMessage: $guidanceMessage)';
  }
}