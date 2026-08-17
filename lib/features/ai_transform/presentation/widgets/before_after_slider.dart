import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';

/// Interactive before/after comparison of two network images.
///
/// The "before" image is clipped to the left of the drag handle; "after" fills
/// the rest. Drag (or tap) anywhere to move the divider.
class BeforeAfterSlider extends StatefulWidget {
  const BeforeAfterSlider({
    super.key,
    required this.beforeImageUrl,
    required this.afterImageUrl,
  });

  final String beforeImageUrl;
  final String afterImageUrl;

  @override
  State<BeforeAfterSlider> createState() => _BeforeAfterSliderState();
}

class _BeforeAfterSliderState extends State<BeforeAfterSlider> {
  double _position = 0.5;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double width = constraints.maxWidth;
          return SizedBox(
            height: 420,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Image.network(widget.afterImageUrl, fit: BoxFit.cover),
                ClipRect(
                  clipper: _HalfClipper(_position),
                  child: Image.network(widget.beforeImageUrl, fit: BoxFit.cover),
                ),
                Positioned(
                  left: width * _position - 1.5,
                  top: 0,
                  bottom: 0,
                  child: Container(width: 3, color: Colors.white),
                ),
                Positioned(
                  left: width * _position - 18,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.code,
                        size: 20,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: _Label(text: l10n.beforeLabel),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: _Label(text: l10n.afterLabel),
                ),
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragUpdate: (DragUpdateDetails details) {
                      setState(() {
                        _position =
                            (_position + details.delta.dx / width).clamp(0.0, 1.0);
                      });
                    },
                    onTapDown: (TapDownDetails details) {
                      setState(() {
                        _position =
                            (details.localPosition.dx / width).clamp(0.0, 1.0);
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }
}

class _HalfClipper extends CustomClipper<Rect> {
  _HalfClipper(this.position);

  final double position;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, 0, size.width * position, size.height);

  @override
  bool shouldReclip(_HalfClipper oldClipper) =>
      oldClipper.position != position;
}
