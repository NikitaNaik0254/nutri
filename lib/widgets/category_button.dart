import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const CategoryButton({
    Key? key,
    required this.icon,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.deepOrange),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12),
        ),
      ],
    );
  }
}