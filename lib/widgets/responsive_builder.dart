import 'package:flutter/widgets.dart';

class ResponsiveLayoutBuilder extends StatelessWidget {
  final Widget Function(BuildContext, bool) builder;
  final double breakpoint;

  const ResponsiveLayoutBuilder({
    Key? key,
    required this.builder,
    this.breakpoint = 768, // Default breakpoint for mobile/desktop
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return builder(
          context,
          constraints.maxWidth < breakpoint,
        );
      },
    );
  }
}
