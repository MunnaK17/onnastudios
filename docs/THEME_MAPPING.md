

---

# THEME_MAPPING.md

```md
# Flutter Theme Mapping

This document maps DESIGN.md into Flutter theme implementation.

## Theme Strategy
Use a centralized theme system inside:

/lib/core/theme/
  app_colors.dart
  app_typography.dart
  app_spacing.dart
  app_radius.dart
  app_shadows.dart
  app_theme.dart

---

## Color Mapping

### Background
- background = surface / off-white
- card background = surface-container-lowest
- secondary surface = surface-container

### Text
- primary text = on-surface
- secondary text = on-surface-variant
- inverse text = inverse-on-surface

### Actions
- primary CTA = terracotta / tertiary-container
- premium accent = gold / secondary
- destructive action = error

---

## Typography Mapping

### Headings
Use Epilogue for:
- splash title
- screen title
- section title
- class name
- package name

### Body
Use Manrope for:
- paragraph
- form input
- metadata
- navigation label

---

## Radius Mapping

- button radius = 16
- input radius = 16
- card radius = 24
- image radius = 24
- chip radius = 999

---

## Shadow Mapping

Use soft ambient shadow only:
- opacity: 0.04 - 0.08
- blur: high
- offset: subtle

Avoid harsh Material default elevation.