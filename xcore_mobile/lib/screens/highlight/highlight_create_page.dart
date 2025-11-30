import 'package:flutter/material.dart';
import 'highlight_service.dart';

class HighlightCreatePage extends StatefulWidget {
  final String matchId;

  const HighlightCreatePage({super.key, required this.matchId});

  @override
  State<HighlightCreatePage> createState() => _HighlightCreatePageState();
}

class _HighlightCreatePageState extends State<HighlightCreatePage> {
  final TextEditingController _videoController = TextEditingController();
  bool loading = false;

  void _submit() async {
    if (_videoController.text.isEmpty) {
      _showError("Video URL cannot be empty");
      return;
    }

    setState(() => loading = true);

    final success = await HighlightService.createHighlight(
      widget.matchId,
      _videoController.text.trim(),
    );

    setState(() => loading = false);

    if (success) {
      Navigator.pop(context, true); // return to previous screen
    } else {
      _showError("Failed to create highlight.");
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
        title: const Text("Create Highlight"),
        backgroundColor: const Color(0xFF1e423b),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Insert YouTube Embed Link",
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
                    : const Text("Create Highlight"),
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
