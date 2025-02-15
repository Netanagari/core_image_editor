import 'package:core_image_editor/models/template_types.dart';
import 'package:flutter/material.dart';

class LeaderThumbnail extends StatefulWidget {
  final TemplateElement leader;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const LeaderThumbnail({
    super.key,
    required this.leader,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<LeaderThumbnail> createState() => _LeaderThumbnailState();
}

class _LeaderThumbnailState extends State<LeaderThumbnail> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 8),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  widget.leader.style.imageShape == 'circle' ? 999 : 8,
                ),
                child: Image.network(
                  widget.leader.content['url'],
                  fit: BoxFit.cover,
                ),
              ),
            ),
            if (isHovered)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(
                      widget.leader.style.imageShape == 'circle' ? 999 : 8,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: widget.onEdit,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white),
                        onPressed: widget.onDelete,
                      ),
                    ],
                  ),
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.drag_handle,
                  color: Colors.white.withOpacity(0.7),
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
