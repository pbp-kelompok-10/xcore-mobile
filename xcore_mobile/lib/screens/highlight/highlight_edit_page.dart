import 'package:flutter/material.dart';
import '../../services/highlight_service.dart';

class HighlightEditPage extends StatefulWidget {
  final String matchId;
  final String currentVideo;

  const HighlightEditPage({
    super.key,
    required this.matchId,
    required this.currentVideo,
  });

  @override
  State<HighlightEditPage> createState() => _HighlightEditPageState();
}

class _HighlightEditPageState extends State<HighlightEditPage> {
  late TextEditingController _videoController;
  bool loading = false;

  // Warna konsisten dengan MatchStatisticsPage dan ForumPage
  static const Color primaryColor = Color(0xFF4AA69B);
  static const Color scaffoldBgColor = Color(0xFFE8F6F4);
  static const Color darkTextColor = Color(0xFF2C5F5A);
  static const Color mutedTextColor = Color(0xFF6B8E8A);
  static const Color accentColor = Color(0xFF34C6B8);
  static const Color lightBgColor = Color(0xFFD1F0EB);
  static const Color whiteColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _videoController = TextEditingController(text: widget.currentVideo);
  }

  void _submit() async {
    if (_videoController.text.isEmpty) {
      _showSnackBar("⚠️ Video URL cannot be empty", isError: true);
      return;
    }

    if (_videoController.text.trim() == widget.currentVideo) {
      _showSnackBar("⚠️ No changes detected", isError: true);
      return;
    }

    setState(() => loading = true);

    final success = await HighlightService.updateHighlight(
      widget.matchId,
      _videoController.text.trim(),
    );

    setState(() => loading = false);

    if (success) {
      _showSnackBar("✅ Highlight updated successfully!", isError: false);
      Navigator.pop(context, true); // return to previous screen
    } else {
      _showSnackBar("❌ Failed to update highlight", isError: true);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red[600] : primaryColor,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        title: Text(
          "Edit Highlight",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: whiteColor,
            fontSize: 18,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: whiteColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info Card
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryColor.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.edit,
                          size: 24,
                          color: accentColor,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Update Match Highlight",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: darkTextColor,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Modify the YouTube embed link below",
                              style: TextStyle(
                                fontSize: 13,
                                color: mutedTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Form Card
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryColor.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.link, size: 18, color: primaryColor),
                      SizedBox(width: 8),
                      Text(
                        "Video URL",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: darkTextColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),

                  TextField(
                    controller: _videoController,
                    maxLines: 3,
                    style: TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      labelText: "YouTube Embed URL",
                      hintText: "https://www.youtube.com/embed/...",
                      hintStyle: TextStyle(
                        color: mutedTextColor.withOpacity(0.6),
                        fontSize: 13,
                      ),
                      labelStyle: TextStyle(color: mutedTextColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: mutedTextColor.withOpacity(0.3)),
                      ),
                      contentPadding: EdgeInsets.all(16),
                      fillColor: scaffoldBgColor,
                      filled: true,
                    ),
                  ),

                  SizedBox(height: 16),

                  // Helper text
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: primaryColor.withOpacity(0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, size: 16, color: primaryColor),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Paste the YouTube embed URL (not the regular watch URL). Example: https://www.youtube.com/embed/VIDEO_ID",
                            style: TextStyle(
                              fontSize: 12,
                              color: mutedTextColor,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: loading
                    ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: whiteColor,
                    strokeWidth: 2,
                  ),
                )
                    : Icon(Icons.save, size: 20),
                label: Text(
                  loading ? "Updating..." : "Save Changes",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: whiteColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: mutedTextColor,
                ),
                onPressed: loading ? null : _submit,
              ),
            ),

            SizedBox(height: 12),

            // Cancel Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: loading ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: mutedTextColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: mutedTextColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }
}