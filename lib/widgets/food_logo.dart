import 'package:flutter/material.dart';

class FoodLogo extends StatelessWidget {
  final double fontSize;
  
  const FoodLogo({
    Key? key,
    this.fontSize = 48,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double largeDotSize = fontSize * 0.7;
    final double smallDotSize = fontSize * 0.5;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'F',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Container(
          width: largeDotSize,
          height: largeDotSize,
          margin: EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: Colors.orange,
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: smallDotSize,
          height: smallDotSize,
          margin: EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: Colors.orange,
            shape: BoxShape.circle,
          ),
        ),
        Text(
          'd',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}