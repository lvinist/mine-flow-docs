import 'dart:math';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

double relativeLuminance(Color color) {
  double transform(double channel) {
    return channel <= 0.03928
        ? channel / 12.92
        : pow((channel + 0.055) / 1.055, 2.4).toDouble();
  }

  final r = transform(color.r);
  final g = transform(color.g);
  final b = transform(color.b);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

double contrastRatio(Color fg, Color bg) {
  final l1 = relativeLuminance(fg);
  final l2 = relativeLuminance(bg);
  final lighter = max(l1, l2);
  final darker = min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

String hex(Color c) {
  return "#${c.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}";
}

void auditTheme(String name, FThemeData theme) {
  print("=========================================");
  print("THEME AUDIT: $name");
  print("=========================================");
  final colors = theme.colors;

  final pairs = [
    {"label": "foreground on background", "fg": colors.foreground, "bg": colors.background, "normalReq": 4.5, "largeReq": 3.0},
    {"label": "foreground on card", "fg": colors.foreground, "bg": colors.card, "normalReq": 4.5, "largeReq": 3.0},
    {"label": "mutedForeground on background", "fg": colors.mutedForeground, "bg": colors.background, "normalReq": 4.5, "largeReq": 3.0},
    {"label": "mutedForeground on card", "fg": colors.mutedForeground, "bg": colors.card, "normalReq": 4.5, "largeReq": 3.0},
    {"label": "primaryForeground on primary", "fg": colors.primaryForeground, "bg": colors.primary, "normalReq": 4.5, "largeReq": 3.0},
    {"label": "primary on background", "fg": colors.primary, "bg": colors.background, "normalReq": 4.5, "largeReq": 3.0},
    {"label": "primary on card", "fg": colors.primary, "bg": colors.card, "normalReq": 4.5, "largeReq": 3.0},
    {"label": "border on background", "fg": colors.border, "bg": colors.background, "normalReq": 3.0, "largeReq": 3.0},
    {"label": "border on card", "fg": colors.border, "bg": colors.card, "normalReq": 3.0, "largeReq": 3.0},
    {"label": "destructiveForeground on destructive", "fg": colors.destructiveForeground, "bg": colors.destructive, "normalReq": 4.5, "largeReq": 3.0},
    {"label": "destructive on background", "fg": colors.destructive, "bg": colors.background, "normalReq": 4.5, "largeReq": 3.0},
  ];

  for (final p in pairs) {
    final fg = p["fg"] as Color;
    final bg = p["bg"] as Color;
    final ratio = contrastRatio(fg, bg);
    final normalReq = p["normalReq"] as double;
    final largeReq = p["largeReq"] as double;
    final passNormal = ratio >= normalReq;
    final passLarge = ratio >= largeReq;

    print("${p["label"]}: ${fg.toARGB32().toRadixString(16)} on ${bg.toARGB32().toRadixString(16)}");
    print("  Ratio: ${ratio.toStringAsFixed(2)}:1 | Normal AA (>=${normalReq}): ${passNormal ? "PASS" : "FAIL"} | Large/UI AA (>=${largeReq}): ${passLarge ? "PASS" : "FAIL"}");
  }
}

void main() {
  auditTheme("Neutral Light", FTheme.neutral.light.touch);
  auditTheme("Neutral Dark", FTheme.neutral.dark.touch);
}
