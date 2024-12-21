import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextLogo extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final Color borderColor; // Border color
  final double borderWidth; // Border width

  const TextLogo({
    super.key,
    this.text = 'Julie',
    this.fontSize = 24.0,
    this.color = const Color.fromARGB(255, 235, 227, 248),
    this.borderColor = const Color(0xFF624E88), 
    this.borderWidth = 2.0, 
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Border effect
        Text(
          text,
          style: GoogleFonts.lora(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = borderWidth
              ..color = borderColor,
          ),
        ),
        // Main text on top
        Text(
          text,
          style: GoogleFonts.lora(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
