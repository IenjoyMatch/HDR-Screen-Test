// Copyright 2026, flutter_miuix contributors
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/widgets.dart';

part 'miuix_extended_icons_1.g.dart';
part 'miuix_extended_icons_2.g.dart';
part 'miuix_extended_icons_3.g.dart';
part 'miuix_extended_icons_4.g.dart';

/// The five optical weights shipped by the original MIUIX icon package.
enum MiuixIconWeight { light, normal, regular, medium, demibold }

/// One MIUIX icon exposed through the package's five compatible weight names.
@immutable
class MiuixExtendedIconData {
  /// Creates a complete, immutable icon weight family.
  const MiuixExtendedIconData({
    required this.name,
    required this.light,
    required this.normal,
    required this.regular,
    required this.medium,
    required this.demibold,
  });

  /// Original English glyph name used by Compose MIUIX.
  final String name;

  /// Light optical weight.
  final IconData light;

  /// Normal optical weight.
  final IconData normal;

  /// Regular optical weight.
  final IconData regular;

  /// Medium optical weight.
  final IconData medium;

  /// Demibold optical weight.
  final IconData demibold;

  /// Resolves a glyph without callers having to switch on the weight.
  IconData resolve(MiuixIconWeight weight) => switch (weight) {
    MiuixIconWeight.light => light,
    MiuixIconWeight.normal => normal,
    MiuixIconWeight.regular => regular,
    MiuixIconWeight.medium => medium,
    MiuixIconWeight.demibold => demibold,
  };
}

/// Complete current MIUIX extended icon catalogue in source-name order.
abstract final class MiuixExtendedIconCatalog {
  /// All 156 extended icons from the authoritative current catalogue.
  static const all = <MiuixExtendedIconData>[
    ..._miuixExtendedIcons1,
    ..._miuixExtendedIcons2,
    ..._miuixExtendedIcons3,
    ..._miuixExtendedIcons4,
  ];

  /// Finds a glyph family by its exact original name.
  static MiuixExtendedIconData? find(String name) {
    for (final icon in all) {
      if (icon.name == name) return icon;
    }
    return null;
  }
}
