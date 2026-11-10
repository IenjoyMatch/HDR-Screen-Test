import 'dart:io' show Platform;

/// Uses the real process host rather than a test theme platform override.
bool get miuixHostIsAndroid => Platform.isAndroid;
