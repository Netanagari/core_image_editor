import 'dart:ui';

import 'package:core_image_editor/models/template_types.dart';
import 'package:core_image_editor/widgets/leader_thumnail.dart';
import 'package:flutter/material.dart';

class ReorderableLeaderStrip extends StatelessWidget {
  final List<TemplateElement> leaders;
  final Function(int oldIndex, int newIndex) onReorder;
  final Function(int index) onDelete;
  final Function(TemplateElement leader) onEdit;

  const ReorderableLeaderStrip({
    super.key,
    required this.leaders,
    required this.onReorder,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ReorderableListView(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          padding: const EdgeInsets.all(8),
          proxyDecorator: (child, index, animation) {
            return AnimatedBuilder(
              animation: animation,
              builder: (BuildContext context, Widget? child) {
                final double animValue =
                    Curves.easeInOut.transform(animation.value);
                return Material(
                  elevation: lerpDouble(0, 6, animValue)!,
                  color: Colors.transparent,
                  child: child,
                );
              },
              child: child,
            );
          },
          onReorder: onReorder,
          children: [
            for (int index = 0; index < leaders.length; index++)
              LeaderThumbnail(
                key: ValueKey(leaders[index].content['url']),
                leader: leaders[index],
                onDelete: () => onDelete(index),
                onEdit: () => onEdit(leaders[index]),
              ),
          ],
        ));
  }
}
