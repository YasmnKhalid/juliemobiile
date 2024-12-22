import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../utils/helpers.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  _ForumPageState createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  File? _selectedImage;
  final TextEditingController _contentController = TextEditingController();
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Set page background color
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Forum',
          style: TextStyle(
            color: Color(0xFF624E88),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            color: Color(0xFF624E88),
            onPressed: () => _showCreatePostDialog(context),
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('forum_posts')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(child: Text('Error loading posts'));
              }

              final posts = snapshot.data?.docs ?? [];

              return ListView.separated(
                itemCount: posts.length,
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider(color: Color(0xFF624E88));
                },
                itemBuilder: (BuildContext context, int index) {
                  final post = posts[index];
                  final data = post.data() as Map<String, dynamic>;

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _AvatarImage(data['userAvatar']),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment
                                    .center, // Align vertically at the center
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween, // Spread items horizontally
                                children: [
                                  Expanded(
                                    child: RichText(
                                      overflow: TextOverflow.ellipsis,
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text:
                                                data['userName'] ?? 'Anonymous',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Color(
                                                  0xFF624E88), // Text color
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                ' · ${_formatTimestamp(data['timestamp'])}',
                                            style: const TextStyle(
                                              color: Color.fromARGB(
                                                  179, 114, 112, 112),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_horiz,
                                        color: Color(0xFF624E88)),
                                    onSelected: (value) async {
                                      if (value == 'delete') {
                                        // Check if the current user owns the post
                                        if (data['userId'] ==
                                            FirebaseAuth
                                                .instance.currentUser?.uid) {
                                          try {
                                            await FirebaseFirestore.instance
                                                .collection('forum_posts')
                                                .doc(post.id)
                                                .delete();
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      'Post deleted successfully.')),
                                            );
                                          } catch (e) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Error deleting post: $e')),
                                            );
                                          }
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'You can only delete your own posts.')),
                                          );
                                        }
                                      }
                                    },
                                    itemBuilder: (BuildContext context) => [
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Delete'),
                                      ),
                                      const PopupMenuItem(
                                        value: 'hide',
                                        child: Text('Hide'),
                                      ),
                                      const PopupMenuItem(
                                        value: 'report',
                                        child: Text('Report'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (data['content'] != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    data['content'],
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ),
                              if (data['imageUrl'] != null)
                                Container(
                                  height: 200,
                                  margin: const EdgeInsets.only(top: 8.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.0),
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(data['imageUrl']),
                                    ),
                                  ),
                                ),
                              _ActionsRow(postId: post.id, data: data),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showCreatePostDialog(BuildContext context) async {
    setState(() {
      _selectedImage = null;
      _contentController.clear();
    });

    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 16,
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Write something...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              if (_selectedImage != null)
                Image.file(
                  _selectedImage!,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file),
                    onPressed: _selectImage,
                  ),
                  ElevatedButton(
                    onPressed: _isUploading ? null : _createPost,
                    child: _isUploading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text('Post'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _createPost() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to post.')),
      );
      return;
    }

    final String content = _contentController.text.trim();
    if (content.isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post cannot be empty.')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    String? imageUrl;
    if (_selectedImage != null) {
      final String fileName =
          '${user.uid}_${DateTime.now().millisecondsSinceEpoch}';
      final Reference storageRef =
          FirebaseStorage.instance.ref().child('forum_images/$fileName');

      try {
        await storageRef.putFile(_selectedImage!);
        imageUrl = await storageRef.getDownloadURL();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $e')),
        );
      }
    }

    try {
      await FirebaseFirestore.instance.collection('forum_posts').add({
        'content': content,
        'imageUrl': imageUrl,
        'userId': user.uid,
        'userName': user.displayName ?? 'Anonymous',
        'userAvatar': user.photoURL,
        'timestamp': FieldValue.serverTimestamp(),
        'likes': 0, // Initialize likes
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post created successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating post: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Just now';
    final dateTime = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }
}

class _AvatarImage extends StatelessWidget {
  final String? url;
  const _AvatarImage(this.url);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: url != null ? DecorationImage(image: NetworkImage(url!)) : null,
        color: url == null ? Colors.grey : null,
      ),
      child: url == null ? const Icon(Icons.person, color: Colors.white) : null,
    );
  }
}

class _ActionsRow extends StatelessWidget {
  final String postId;
  final Map<String, dynamic> data;

  const _ActionsRow({
    required this.postId,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final int likes = data['likes'] ?? 0;

    return Theme(
      data: Theme.of(context).copyWith(
        iconTheme: const IconThemeData(color: Color(0xFF624E88), size: 18),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.all(Color(0xFF624E88)),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: () => _likePost(postId, likes),
            icon: const Icon(Icons.favorite_border),
            label: Text('$likes'),
          ),
          TextButton.icon(
            onPressed: () => _showComments(context, postId),
            icon: const Icon(Icons.mode_comment_outlined),
            label: const Text('Comment'),
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.share_up),
            onPressed: () => _sharePost(context, data),
          ),
        ],
      ),
    );
  }

  Future<void> _likePost(String postId, int currentLikes) async {
    try {
      await FirebaseFirestore.instance
          .collection('forum_posts')
          .doc(postId)
          .update({
        'likes': currentLikes + 1,
      });
    } catch (e) {
      debugPrint('Error liking post: $e');
    }
  }

  Future<void> _showComments(BuildContext context, String postId) async {
    final TextEditingController commentController = TextEditingController();

    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        final double screenHeight = MediaQuery.of(context).size.height;
        return SizedBox(
          height: screenHeight * 0.7, // Set the height to 70% of the screen
          child: Padding(
            padding: EdgeInsets.only(
              top: 16,
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom +
                  10, // Add extra padding
            ),
            child: Column(
              children: [
                const Text(
                  'Comments',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF624E88),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('forum_posts')
                        .doc(postId)
                        .collection('comments')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return const Center(
                            child: Text('Error loading comments.'));
                      }

                      final comments = snapshot.data?.docs ?? [];

                      if (comments.isEmpty) {
                        return const Center(
                          child:
                              Text('No comments yet. Be the first to comment!'),
                        );
                      }

                      return ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment =
                              comments[index].data() as Map<String, dynamic>;

                          return ListTile(
                            leading: _AvatarImage(comment['userAvatar']),
                            title: Text(
                              comment['userName'] ?? 'Anonymous',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF624E88),
                              ),
                            ),
                            subtitle: Text(
                              comment['content'] ?? '',
                              style: const TextStyle(color: Colors.black),
                            ),
                            trailing: Text(
                              formatTimestamp(
                                  comment['timestamp'] as Timestamp?),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: 10.0), // Add margin below input
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentController,
                          decoration: const InputDecoration(
                            hintText: 'Add a comment...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Color(0xFF624E88)),
                        onPressed: () async {
                          final String comment = commentController.text.trim();
                          if (comment.isNotEmpty) {
                            await _addComment(context, postId, comment);
                            commentController.clear();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _sharePost(BuildContext context, Map<String, dynamic> data) {
    final content = data['content'] ?? '';
    final imageUrl = data['imageUrl'] ?? '';
    final shareText =
        imageUrl.isNotEmpty ? '$content\n\nCheck this out: $imageUrl' : content;

    Share.share(shareText);
  } //share post

  Future<void> _addComment(
      BuildContext context, String postId, String content) async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to comment.')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('forum_posts')
          .doc(postId)
          .collection('comments')
          .add({
        'content': content,
        'userId': user.uid,
        'userName': user.displayName ?? 'Anonymous',
        'userAvatar': user.photoURL,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment added successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding comment: $e')),
      );
    }
  }
}//class
