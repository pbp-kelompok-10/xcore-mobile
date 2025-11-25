import 'package:flutter/material.dart';

class StatistikRow extends StatelessWidget {
  final String title;
  final dynamic homeValue;
  final dynamic awayValue;
  final bool isPercentage;
  final IconData? icon;

  const StatistikRow({
    super.key,
    required this.title,
    required this.homeValue,
    required this.awayValue,
    this.isPercentage = false,
    this.icon,
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
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Colors.white, Colors.grey[50]!],
        ),
      ),
      child: Row(
        children: [
          // Home value dengan background
          Container(
            width: 60,
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[100]!),
            ),
            child: Text(
              _formatValue(homeValue),
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 6),
                ],
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14, 
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
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
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[100]!),
            ),
            child: Text(
              _formatValue(awayValue),
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold,
                color: Colors.red[800],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}