import 'package:flutter/material.dart';

import '../../shared/widgets/layout/app_scaffold.dart';
import 'placeholder_content.dart';

class FoundationPlaceholderScreen extends StatelessWidget {
  const FoundationPlaceholderScreen({
    required this.title,
    required this.subtitle,
    super.key,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: PlaceholderContent(title: title, subtitle: subtitle),
    );
  }
}
