import 'package:flutter/material.dart';

const purple = Color(0xFFB397DC);
const blue = Color(0xFF95D0E8);

class PageBackground extends StatelessWidget {
  final Widget child;
  final bool login;
  const PageBackground({super.key, required this.child, this.login = false});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      children: [
        Positioned.fill(child: CustomPaint(painter: _Waves(login))),
        SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: SizedBox(width: double.infinity, child: child),
            ),
          ),
        ),
      ],
    ),
  );
}

class _Waves extends CustomPainter {
  final bool login;
  _Waves(this.login);

  @override
  void paint(Canvas canvas, Size size) {
    final top = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, login ? size.height * .24 : size.height * .08)
      ..cubicTo(
        size.width * .65,
        size.height * .16,
        size.width * .2,
        size.height * .36,
        0,
        size.height * .24,
      )
      ..close();
    canvas.drawPath(
      top,
      Paint()..color = login ? purple : const Color(0xFFE8D9FF),
    );
    final bottom = Path()
      ..moveTo(0, size.height * .88)
      ..cubicTo(
        size.width * .32,
        size.height * .98,
        size.width * .65,
        size.height * .77,
        size.width,
        size.height * .87,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(bottom, Paint()..color = blue);
  }

  @override
  bool shouldRepaint(covariant _Waves oldDelegate) =>
      oldDelegate.login != login;
}

class Brand extends StatelessWidget {
  final double size;
  const Brand({super.key, this.size = 105});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFE3F5FF),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF2599E5), width: 3),
        ),
        child: Icon(
          Icons.pets,
          color: const Color(0xFF2599E5),
          size: size * .62,
        ),
      ),
      const SizedBox(height: 8),
      const Text(
        'FisioPet',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: Color(0xFF007BCD),
        ),
      ),
    ],
  );
}

class ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;
  const ActionButton({
    super.key,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 48,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
