import 'package:flutter/material.dart';

class FlagWidget extends StatelessWidget {
  final String teamCode;
  final bool isHome;
  final double width;
  final double height;

  const FlagWidget({
    super.key,
    required this.teamCode,
    required this.isHome,
    this.width = 60,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    String effectiveCode = teamCode.toLowerCase();
    if (effectiveCode.isEmpty || effectiveCode.length != 2) {
      effectiveCode = isHome ? 'id' : 'sg';
    }

    final flagUrl = "https://flagcdn.com/w80/$effectiveCode.png";
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          flagUrl,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: isHome ? Color(0xFF4AA69B) : Color(0xFF34C6B8),
              child: Center(
                child: Text(
                  effectiveCode.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Color(0xFFE8F6F4),
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / 
                        loadingProgress.expectedTotalBytes!
                      : null,
                  strokeWidth: 2,
                  color: Color(0xFF4AA69B),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}