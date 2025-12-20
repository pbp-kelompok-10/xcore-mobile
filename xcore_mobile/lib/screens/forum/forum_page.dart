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
  final TextEditingController _searchController = TextEditingController();
  final Map<String, TextEditingController> _editControllers = {};

  // Variabel untuk current user yang sedang login
  int? _currentUserId;
  bool? _isAdmin;

  // Filter dan Sort variables
  String _selectedAuthorFilter = 'all';
  String _selectedSort = 'newest';
  bool _isFilterExpanded = false;

  // Warna konsisten dengan MatchStatisticsPage
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
    _loadForumData();
  }

  Future<void> _loadForumData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final forum = await ForumService.fetchForumByMatch(widget.matchId);

      // fetchPosts sekarang mengembalikan Map dengan posts dan user info
      final response = await ForumService.fetchPosts(
        forum.id,
        context,
        searchQuery: _searchController.text.trim(),
        authorFilter: _selectedAuthorFilter,
        sortBy: _selectedSort,
      );

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

  void _applyFilters() {
    _loadForumData();
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedAuthorFilter = 'all';
      _selectedSort = 'newest';
    });
    _loadForumData();
  }

  Future<void> _addPost() async {
    final message = _postController.text.trim();

    // Cek apakah user sudah login
    final request = Provider.of<CookieRequest>(context, listen: false);
    if (!request.loggedIn) {
      _showWarningSnackBar('Silakan login terlebih dahulu');
      _postController.clear();
      return;
    }

    if (message.isEmpty || _forum == null) {
      _showSnackBar('Message cannot be empty!');
      return;
    }

    try {
      await ForumService.addPost(_forum!.id, message, context);
      _postController.clear();
      await _loadForumData(); // Refresh posts
      _showSnackBar('✅ Post added successfully!');
    } catch (e) {
      _showSnackBar('❌ Failed to add post: ${e.toString()}');
    }
  }

  Future<void> _editPost(String postId, String newMessage) async {
    if (newMessage.isEmpty || _forum == null) {
      _showSnackBar('Message cannot be empty!');
      return;
    }

    try {
      await ForumService.editPost(_forum!.id, postId, newMessage, context);
      await _loadForumData(); // Refresh posts

      _editControllers.remove(postId);

      _showSnackBar('✅ Post updated successfully!');
    } catch (e) {
      _showSnackBar('❌ Failed to update post: ${e.toString()}');
    }
  }

  Future<void> _deletePost(String postId) async {
    if (_forum == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: whiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          'Delete Post',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: darkTextColor,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this post?',
          style: TextStyle(
            color: mutedTextColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: mutedTextColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ForumService.deletePost(_forum!.id, postId, context);
        await _loadForumData(); // Refresh posts
        _showSnackBar('✅ Post deleted successfully!');
      } catch (e) {
        _showSnackBar('❌ Failed to delete post: ${e.toString()}');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: primaryColor,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }

  void _showWarningSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange.shade700,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
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
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        title: Text(
          _forum?.nama ?? 'Forum',
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
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: whiteColor),
          onPressed: () => Navigator.pop(context),
        ),
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
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            strokeWidth: 2,
          ),
          SizedBox(height: 16),
          Text(
            'Loading Forum...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: mutedTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.error_outline, size: 40, color: Colors.red),
              ),
              SizedBox(height: 20),
              Text(
                'Failed to Load Forum',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 8),
              Text(
                _error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: mutedTextColor,
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadForumData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: whiteColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Try Again'),
              ),
            ],
          ),
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
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: whiteColor,
              border: Border(
                bottom: BorderSide(color: primaryColor.withOpacity(0.2)),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: primaryColor),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Welcome to the Discussion Forum. Please keep conversations respectful and relevant.',
                        style: TextStyle(
                          fontSize: 12,
                          color: mutedTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

        // Search, Filter, Sort Controls
        _buildFilterSection(),

        // Posts List
        Expanded(
          child: _posts.isEmpty ? _buildEmptyState() : _buildPostsList(),
        ),

        // Add Post Input
        _buildPostInput(),
      ],
    );
  }

  Widget _buildFilterSection() {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(12),
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
          // Search Bar
          Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '🔍 Search by message or author...',
                hintStyle: TextStyle(color: mutedTextColor, fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
                contentPadding:
                EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                fillColor: scaffoldBgColor,
                filled: true,
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear, color: mutedTextColor),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                    });
                    _applyFilters();
                  },
                )
                    : null,
              ),
              onSubmitted: (_) => _applyFilters(),
            ),
          ),

          // Divider
          Divider(height: 1, color: primaryColor.withOpacity(0.1)),

          // Filter Toggle Button
          InkWell(
            onTap: () {
              setState(() {
                _isFilterExpanded = !_isFilterExpanded;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tune, size: 18, color: primaryColor),
                      SizedBox(width: 8),
                      Text(
                        'Filter & Sort',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: darkTextColor,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    _isFilterExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: mutedTextColor,
                  ),
                ],
              ),
            ),
          ),

          // Expandable Filter Options
          if (_isFilterExpanded) ...[
            Divider(height: 1, color: primaryColor.withOpacity(0.1)),
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author Filter
                  Text(
                    '👤 FILTER POSTS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: scaffoldBgColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: primaryColor.withOpacity(0.2), width: 1.5),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedAuthorFilter,
                      isExpanded: true,
                      underline: SizedBox(),
                      style: TextStyle(
                        fontSize: 14,
                        color: darkTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                      dropdownColor: whiteColor,
                      icon: Icon(Icons.arrow_drop_down, color: primaryColor),
                      items: [
                        DropdownMenuItem(
                          value: 'all',
                          child: Text('All Posts'),
                        ),
                        if (_currentUserId != null)
                          DropdownMenuItem(
                            value: 'my_posts',
                            child: Text('My Posts'),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedAuthorFilter = value!;
                        });
                      },
                    ),
                  ),

                  SizedBox(height: 16),

                  // Sort Options
                  Text(
                    '🔄 SORT BY',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: scaffoldBgColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: primaryColor.withOpacity(0.2), width: 1.5),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedSort,
                      isExpanded: true,
                      underline: SizedBox(),
                      style: TextStyle(
                        fontSize: 14,
                        color: darkTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                      dropdownColor: whiteColor,
                      icon: Icon(Icons.arrow_drop_down, color: primaryColor),
                      items: [
                        DropdownMenuItem(
                          value: 'newest',
                          child: Text('Newest First'),
                        ),
                        DropdownMenuItem(
                          value: 'oldest',
                          child: Text('Oldest First'),
                        ),
                        DropdownMenuItem(
                          value: 'edited',
                          child: Text('Recently Edited'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedSort = value!;
                        });
                      },
                    ),
                  ),

                  SizedBox(height: 16),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _applyFilters,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: whiteColor,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Apply',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _resetFilters,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: mutedTextColor,
                            side: BorderSide(color: mutedTextColor, width: 1.5),
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Reset',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          // Results Info
          if (_searchController.text.isNotEmpty ||
              _selectedAuthorFilter != 'all' ||
              _selectedSort != 'newest')
            Container(
              margin: EdgeInsets.fromLTRB(12, 0, 12, 12),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: lightBgColor,
                borderRadius: BorderRadius.circular(8),
                border: Border(
                  left: BorderSide(color: primaryColor, width: 3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: primaryColor),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '📊 ${_posts.length} post(s) found',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: darkTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPostsList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final post = _posts[index];
        final isEditing = _editControllers.containsKey(post.id);

        return _buildPostCard(post, isEditing);
      },
    );
  }

  Widget _buildEmptyState() {
    String emptyMessage = 'No posts yet. Be the first to post!';
    if (_selectedAuthorFilter == 'my_posts') {
      emptyMessage = 'You haven\'t posted anything yet.';
    } else if (_searchController.text.isNotEmpty) {
      emptyMessage =
      'No posts found matching your criteria. Try adjusting your filters.';
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Container(
          padding: EdgeInsets.all(32),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child:
                Icon(Icons.forum_outlined, size: 40, color: primaryColor),
              ),
              SizedBox(height: 20),
              Text(
                'No Posts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: darkTextColor,
                ),
              ),
              SizedBox(height: 8),
              Text(
                emptyMessage,
                style: TextStyle(
                  fontSize: 14,
                  color: mutedTextColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostCard(PostEntry post, bool isEditing) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with user info and edited badge
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: lightBgColor,
                  backgroundImage: NetworkImage(
                    post.authorPicture != null
                        ? '${Config.baseUrl}${post.authorPicture}'
                        : 'https://via.placeholder.com/40',
                  ),
                  onBackgroundImageError: (_, __) {},
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: darkTextColor,
                        ),
                      ),
                      Text(
                        _formatPostTime(post),
                        style: TextStyle(
                          fontSize: 12,
                          color: mutedTextColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Edited Badge (before menu button)
                if (post.isEdited && !isEditing)
                  Container(
                    margin: EdgeInsets.only(right: 8),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: mutedTextColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 11,
                          color: mutedTextColor,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Edited',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: mutedTextColor,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Popup menu button
                if (post.authorId == _currentUserId || _isAdmin == true)
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: mutedTextColor, size: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 18, color: primaryColor),
                                SizedBox(width: 8),
                                Text(
                                  'Edit',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      // Tampilkan delete untuk pemilik post dan admin
                      menuItems.add(
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );

                      return menuItems;
                    },
                  ),
              ],
            ),

            SizedBox(height: 12),

            // Post Content (tanpa background box)
            if (!isEditing)
              Padding(
                padding: EdgeInsets.only(left: 0),
                child: Text(
                  post.message,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: darkTextColor,
                  ),
                ),
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
                        borderSide: BorderSide(color: primaryColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                      contentPadding: EdgeInsets.all(12),
                      fillColor: scaffoldBgColor,
                      filled: true,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => _cancelEdit(post.id),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: mutedTextColor,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          final newMessage =
                          _editControllers[post.id]!.text.trim();

                          if (newMessage == post.message) {
                            _showSnackBar('Message cannot be the same!');
                            _cancelEdit(post.id);
                            return;
                          }

                          if (newMessage.isNotEmpty) {
                            _editPost(post.id, newMessage);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: whiteColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Save',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whiteColor,
        border: Border(
          top: BorderSide(color: primaryColor.withOpacity(0.2)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _postController,
              decoration: InputDecoration(
                hintText: 'Write your post...',
                hintStyle: TextStyle(
                  color: mutedTextColor,
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                fillColor: scaffoldBgColor,
                filled: true,
              ),
              maxLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _addPost(),
            ),
          ),
          SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: _addPost,
              icon: Icon(Icons.send_rounded, color: whiteColor, size: 20),
              padding: EdgeInsets.all(12),
              constraints: BoxConstraints(),
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
    _searchController.dispose();
    for (final controller in _editControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}