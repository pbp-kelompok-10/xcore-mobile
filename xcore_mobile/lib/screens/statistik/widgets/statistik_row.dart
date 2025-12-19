import 'package:flutter/material.dart';

class StatistikRow extends StatelessWidget {
  final String title;
  final dynamic homeValue;
  final dynamic awayValue;
  final bool isPercentage;
  final IconData? icon;
  final Color primaryColor;
  final Color accentColor;
  final Color textColor;
  final Color mutedColor;

  const StatistikRow({
    super.key,
    required this.title,
    required this.homeValue,
    required this.awayValue,
    this.isPercentage = false,
    this.icon,
    this.primaryColor = const Color(0xFF4AA69B),
    this.accentColor = const Color(0xFF34C6B8),
    this.textColor = const Color(0xFF2C5F5A),
    this.mutedColor = const Color(0xFF6B8E8A),
  });

  String _formatValue(dynamic value) {
    if (isPercentage) {
      if (value is double) {
        return '${value.toStringAsFixed(1)}%';
      } else if (value is int) {
        return '$value%';
      }
      return '$value%';
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: primaryColor.withOpacity(0.1))),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Colors.white, primaryColor.withOpacity(0.05)],
        ),
      ),
      child: Row(
        children: [
          // Home value dengan background
          Container(
            width: 60,
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: primaryColor.withOpacity(0.3)),
            ),
            child: Text(
              _formatValue(homeValue),
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: primaryColor),
                  SizedBox(width: 6),
                ],
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14, 
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          // Away value dengan background
          Container(
            width: 60,
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: accentColor.withOpacity(0.3)),
            ),
            child: Text(
              _formatValue(awayValue),
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}