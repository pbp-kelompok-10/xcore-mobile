import 'package:flutter/material.dart';
import 'highlight_service.dart';

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

  @override
  void initState() {
    super.initState();
    _videoController = TextEditingController(text: widget.currentVideo);
  }

  void _submit() async {
    if (_videoController.text.isEmpty) {
      _showError("Video URL cannot be empty");
      return;
    }

    setState(() => loading = true);

    final success = await HighlightService.updateHighlight(
      widget.matchId,
      _videoController.text.trim(),
    );

    setState(() => loading = false);

    if (success) {
      Navigator.pop(context, true); // return to previous screen
    } else {
      _showError("Failed to update highlight.");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(msg),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Highlight"),
        backgroundColor: const Color(0xFF1e423b),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Update YouTube Embed Link",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1e423b),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _videoController,
              decoration: InputDecoration(
                labelText: "YouTube Embed URL",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save Changes"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1e423b),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: loading ? null : _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
