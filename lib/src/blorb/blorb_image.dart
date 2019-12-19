import 'dart:math';

import '../../zvm.dart';

/// This class represents a rational number.
class Ratio {
  int _numerator;
  int _denominator;

  Ratio(int numerator, int denominator) {
    _numerator = numerator;
    _denominator = denominator;
  }

  /// Returns the numerator.
  int getNumerator() {
    return _numerator;
  }

  /// Returns the denominator.
  int getDenominator() {
    return _denominator;
  }

  /// Returns the calculated value as a float value.
  double getValue() {
    return _numerator / _denominator;
  }

  /// Determines whether this value specifies valid value.
  bool isDefined() {
    return !(_numerator == 0 && _denominator == 0);
  }

  @override
  String toString() {
    return "${_numerator}/${_denominator}";
  }
}

/// This class represents resolution information.
class ResolutionInfo {
  Resolution _standard;
  Resolution _minimum;
  Resolution _maximum;

  ResolutionInfo(Resolution std, Resolution min, Resolution max) {
    _standard = std;
    _minimum = min;
    _maximum = max;
  }

  /// Returns the standard resolution.
  Resolution getStandard() {
    return _standard;
  }

  /// Returns the minimum resolution.
  Resolution getMinimum() {
    return _minimum;
  }

  /// Returns the maximum resolution.
  Resolution getMaximum() {
    return _maximum;
  }

  /// Calculates the ERF ("Elbow Room Factor").
  double computeERF(int screenwidth, int screenheight) {
    return min(screenwidth / _standard.getWidth(),
        screenheight / _standard.getHeight());
  }

  @override
  String toString() {
    return "Std: " +
        _standard.toString() +
        " Min: " +
        _minimum.toString() +
        " Max: " +
        _maximum.toString();
  }
}

/// Representation of scaling information.
class ScaleInfo {
  ResolutionInfo _resolutionInfo;
  Ratio _standard;
  Ratio _minimum;
  Ratio _maximum;

  ScaleInfo(ResolutionInfo resinfo, Ratio std, Ratio min, Ratio max) {
    _resolutionInfo = resinfo;
    _standard = std;
    _minimum = min;
    _maximum = max;
  }

  /// Returns the resolution information.
  ResolutionInfo getResolutionInfo() {
    return _resolutionInfo;
  }

  /// Returns the standard aspect ratio.
  Ratio getStdRatio() {
    return _standard;
  }

  /// Returns the minimum aspect ratio.
  Ratio getMinRatio() {
    return _minimum;
  }

  /// Returns the maximum aspect ratio.
  Ratio getMaxRatio() {
    return _maximum;
  }

  /// Computes the scaling ratio depending on the specified screen dimensions.
  double computeScaleRatio(int screenwidth, int screenheight) {
    double value = _resolutionInfo.computeERF(screenwidth, screenheight) *
        _standard.getValue();

    if (_minimum.isDefined() && value < _minimum.getValue()) {
      value = _minimum.getValue();
    }
    if (_maximum.isDefined() && value > _maximum.getValue()) {
      value = _maximum.getValue();
    }
    return value;
  }

  @override
  String toString() {
    return "std: ${_standard.toString()}, min: ${_minimum.toString()}, max: ${_maximum.toString()}\n";
  }
}

/// This class contains informations related to Blorb images and their
/// scaling. Scaling information is optional and probably only relevant
/// to V6 games. BlorbImage also calculates the correct image size,
/// according to the specification made in the Blorb standard specification.
class BlorbImage implements ZmppImage {
  NativeImage _image;
  Resolution _resolution;
  ScaleInfo _scaleinfo;

  BlorbImage(NativeImage image) {
    this._image = image;
  }

  BlorbImage.resolution(int width, int height) {
    _resolution = Resolution(width, height);
  }

  /// Returns the wrapped NativeImage.
  NativeImage getImage() {
    return _image;
  }

  /// Returns the scaling information.
  ScaleInfo getScaleInfo() {
    return _scaleinfo;
  }

  /// Returns the size of the image, scaled to the specified screen dimensions
  Resolution getSize(int screenwidth, int screenheight) {
    if (_scaleinfo != null) {
      double ratio = _scaleinfo.computeScaleRatio(screenwidth, screenheight);
      if (_image != null) {
        return Resolution((_image.getWidth() * ratio).truncate(),
            (_image.getHeight() * ratio).truncate());
      } else {
        return Resolution((_resolution.getWidth() * ratio).truncate(),
            (_resolution.getHeight() * ratio).truncate());
      }
    } else {
      if (_image != null) {
        return Resolution(_image.getWidth(), _image.getHeight());
      } else {
        return Resolution(_resolution.getWidth(), _resolution.getHeight());
      }
    }
  }

  /// Sets the ScaleInfo.
  void setScaleInfo(ScaleInfo aScaleinfo) {
    this._scaleinfo = aScaleinfo;
  }
}
