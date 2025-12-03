import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:xcore_mobile/config.dart';
import 'package:xcore_mobile/models/forum_entry.dart';
import 'package:xcore_mobile/models/post_entry.dart';
import 'forum_service.dart';

class ForumPage extends StatefulWidget {
  final String matchId;

  const ForumPage({super.key, required this.matchId});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  ForumEntry? _forum;
  List<PostEntry> _posts = [];
  bool _isLoading = true;
  String _error = '';
  final TextEditingController _postController = TextEditingController();
  final Map<String, TextEditingController> _editControllers = {};

  // Variabel untuk current user yang sedang login
  int? _currentUserId;
  bool? _isAdmin;

  @override
  void initState() {
    super.initState();
    _loadForumData();
  }

  Future<void> _loadForumData() async {
    try {
      final forum = await ForumService.fetchForumByMatch(widget.matchId);

      // fetchPosts sekarang mengembalikan Map dengan posts dan user info
      final response = await ForumService.fetchPosts(forum.id, context);

      setState(() {
        _forum = forum;
        _posts = response['posts']; // Ambil posts dari response
        _currentUserId = response['user_id']; // Simpan user ID
        _isAdmin = response['user_is_admin']; // Simpan status admin
        _isLoading = false;
      });

      // Debug
      print('Current User ID: $_currentUserId');
      print('Is Admin: $_isAdmin');

    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }


  Future<void> _addPost() async {
    final message = _postController.text.trim();
    if (message.isEmpty || _forum == null) {
      _showSnackBar('Message cannot be empty!');
      return;
    };

    try {
      await ForumService.addPost(_forum!.id, message, context);
      _postController.clear();
      await _loadForumData(); // Refresh posts
      _showSnackBar('Post added successfully!');
    } catch (e) {
      _showSnackBar('Failed to add post: ${e.toString()}');
    }
  }

  Future<void> _editPost(String postId, String newMessage) async {
    final request = context.watch<CookieRequest>();

    if (newMessage.isEmpty || _forum == null) {
      _showSnackBar('Message cannot be empty!');
      return;
    }

    try {
      await ForumService.editPost(_forum!.id, postId, newMessage, context);
      await _loadForumData(); // Refresh posts

      _editControllers.remove(postId);

      _showSnackBar('Post message updated successfully!');

    } catch (e) {
      _showSnackBar('Failed to update post: ${e.toString()}');
    }
  }

  Future<void> _deletePost(String postId) async {
    if (_forum == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ForumService.deletePost(_forum!.id, postId, context);
        await _loadForumData(); // Refresh posts
        _showSnackBar('Post deleted successfully!');
      } catch (e) {
        _showSnackBar('Failed to delete post: ${e.toString()}');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[600],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _startEditPost(PostEntry post) {
    _editControllers[post.id] = TextEditingController(text: post.message);
    setState(() {});
  }

  void _cancelEdit(String postId) {
    _editControllers.remove(postId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          _forum?.nama ?? 'Forum',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.green[700],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _error.isNotEmpty
          ? _buildErrorState()
          : _buildContent(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green[700]!),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading Forum...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
            const SizedBox(height: 16),
            const Text(
              'Failed to Load Forum',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadForumData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Match Info Header
        if (_forum?.matchHome != null && _forum?.matchAway != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.green[700]!, Colors.green[500]!],
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 4),
                Text(
                  'Welcome to the Discussion Forum. Please keep conversations respectful and relevant. Start a new topic or explore existing discussions.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

        // Posts List
        Expanded(
          child: _posts.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _posts.length,
            itemBuilder: (context, index) {
              final post = _posts[index];
              final isEditing = _editControllers.containsKey(post.id);

              return _buildPostCard(post, isEditing);
            },
          ),
        ),

        // Add Post Input
        _buildPostInput(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.forum_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No Posts Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Be the first to start the discussion!',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(PostEntry post, bool isEditing) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with user info
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(
                    post.authorPicture != null
                        ? '${Config.baseUrl}${post.authorPicture}'
                        : 'https://via.placeholder.com/40',
                  ),
                  onBackgroundImageError: (_, __) {},
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _formatPostTime(post),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // Popup menu button
                if (post.authorId == _currentUserId || _isAdmin == true)
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                    onSelected: (value) {
                      if (value == 'edit' && post.authorId == _currentUserId) {
                        _startEditPost(post);
                      } else if (value == 'delete') {
                        _deletePost(post.id);
                      }
                    },
                    itemBuilder: (context) {
                      final menuItems = <PopupMenuEntry<String>>[];

                      // Hanya tampilkan edit untuk pemilik post
                      if (post.authorId == _currentUserId) {
                        menuItems.add(
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 18),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                        );
                      }

                      // Tampilkan delete untuk pemilik post dan admin
                      menuItems.add(
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      );

                      return menuItems;
                    },
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Post Content
            if (!isEditing)
              Text(
                post.message,
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),

            // Edit Mode
            if (isEditing)
              Column(
                children: [
                  TextField(
                    controller: _editControllers[post.id],
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => _cancelEdit(post.id),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          final newMessage = _editControllers[post.id]!.text.trim();

                          if (newMessage == post.message){
                            _showSnackBar('Message cannot be the same!');
                            _cancelEdit(post.id);
                            return;
                          }

                          if (newMessage.isNotEmpty) {
                            _editPost(post.id, newMessage);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _postController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Write your post...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[400]!),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _addPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Send Post',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPostTime(PostEntry post) {
    final time = post.isEdited ? post.editedAt : post.createdAt;

    // Handle null case untuk editedAt
    if (time == null) return 'Unknown time';

    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';

    return '${time.day}/${time.month}/${time.year}';
  }

  @override
  void dispose() {
    _postController.dispose();
    for (final controller in _editControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
