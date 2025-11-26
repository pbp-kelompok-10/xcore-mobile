import 'package:flutter/material.dart';

class NavigationCards extends StatelessWidget {
  final Function() onForumTap;
  final Function() onHighlightTap;
  final Function() onPredictionTap;
  final Function() onLineupTap;

  const NavigationCards({
    super.key,
    required this.onForumTap,
    required this.onHighlightTap,
    required this.onPredictionTap,
    required this.onLineupTap,
  });

  Widget _buildNavigationCard(String title, IconData icon, Function() onTap) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.green[700]!, Colors.green[600]!],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: Colors.white),
                SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildNavigationCard('Forum', Icons.forum, onForumTap),
          SizedBox(width: 8),
          _buildNavigationCard('Highlight', Icons.video_library, onHighlightTap),
          SizedBox(width: 8),
          _buildNavigationCard('Prediction', Icons.analytics, onPredictionTap),
          SizedBox(width: 8),
          _buildNavigationCard('Lineup', Icons.people, onLineupTap),
        ],
      ),
    );
  }
}