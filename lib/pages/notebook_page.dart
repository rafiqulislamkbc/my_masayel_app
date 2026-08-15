import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotebookPage extends StatefulWidget {
  const NotebookPage({super.key});

  // যেকোনো স্ক্রিন বা মাসআলা পেজ থেকে তথ্য সরাসরি নোটবইতে সেভ করার ফাংশন
  static Future<void> saveQuickNote({
    required BuildContext context,
    required String title,
    required String content,
    String? category,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'নোট সংরক্ষণ করতে সাইন-ইন প্রয়োজন',
            style: TextStyle(fontFamily: 'SolaimanLipi'),
          ),
        ),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('notes').add({
      'userId': user.uid,
      'title': title,
      'content': content,
      'category': category ?? 'মাসআলা নোট',
      'color': 'teal',
      'isPinned': false,
      'isFavorite': false,
      'isDeleted': false,
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '"$title" সফলভাবে নোটবইতে সংরক্ষিত হয়েছে!',
            style: const TextStyle(fontFamily: 'SolaimanLipi'),
          ),
          backgroundColor: Colors.teal,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  State<NotebookPage> createState() => _NotebookPageState();
}

class _NotebookPageState extends State<NotebookPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String _searchQuery = '';

  Color _getCardColor(String? colorKey) {
    switch (colorKey) {
      case 'amber':
        return const Color(0xFFFEF3C7);
      case 'emerald':
        return const Color(0xFFD1FAE5);
      case 'teal':
        return const Color(0xFFE0F2F1);
      case 'purple':
        return const Color(0xFFF3E8FF);
      case 'rose':
        return const Color(0xFFFFE4E6);
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'নোটবই ও সংরক্ষিত তথ্য',
          style: TextStyle(
            fontFamily: 'SolaimanLipi',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: user == null
          ? const Center(
              child: Text(
                'আপনার সংরক্ষিত নোটগুলো দেখতে সাইন-ইন করুন',
                style: TextStyle(
                  fontFamily: 'SolaimanLipi',
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            )
          : Column(
              children: [
                // সার্চ বার
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: const TextStyle(fontFamily: 'SolaimanLipi'),
                    decoration: InputDecoration(
                      hintText: 'সংরক্ষিত নোট বা মাসআলা খুঁজুন...',
                      hintStyle: const TextStyle(
                        fontFamily: 'SolaimanLipi',
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 20,
                        color: Colors.teal,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ),

                // নোট লিস্ট গ্রিড
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _db
                        .collection('notes')
                        .where('userId', isEqualTo: user.uid)
                        .where('isDeleted', isEqualTo: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.teal),
                        );
                      }

                      var docs = snapshot.data?.docs ?? [];

                      if (_searchQuery.isNotEmpty) {
                        docs = docs.where((d) {
                          final data = d.data() as Map<String, dynamic>;
                          final title = (data['title'] ?? '')
                              .toString()
                              .toLowerCase();
                          final content = (data['content'] ?? '')
                              .toString()
                              .toLowerCase();
                          final q = _searchQuery.toLowerCase();
                          return title.contains(q) || content.contains(q);
                        }).toList();
                      }

                      if (docs.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.bookmark_border,
                                size: 54,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'কোনো সংরক্ষিত নোট নেই',
                                style: TextStyle(
                                  fontFamily: 'SolaimanLipi',
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'যেকোনো মাসআলা পেজ থেকে তথ্য এখানে সংরক্ষণ করতে পারবেন',
                                style: TextStyle(
                                  fontFamily: 'SolaimanLipi',
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.88,
                        ),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final data = doc.data() as Map<String, dynamic>;
                          return _buildNoteCard(doc.id, data);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _openNoteEditor(context),
      ),
    );
  }

  Widget _buildNoteCard(String id, Map<String, dynamic> data) {
    final title = data['title'] ?? 'শিরোনামহীন নোট';
    final content = data['content'] ?? '';
    final category = data['category'] ?? '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getCardColor(data['color']),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (category.toString().isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: const Color(0x1F009688), // Colors.teal 12% opacity
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                category.toString(),
                style: const TextStyle(
                  fontFamily: 'SolaimanLipi',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
            ),
          Text(
            title.toString(),
            style: const TextStyle(
              fontFamily: 'SolaimanLipi',
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xFF1E293B),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (content.toString().isNotEmpty) ...[
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                content.toString(),
                style: TextStyle(
                  fontFamily: 'SolaimanLipi',
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  height: 1.3,
                ),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openNoteEditor(BuildContext context) {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'নতুন নোট লিখুন',
              style: TextStyle(
                fontFamily: 'SolaimanLipi',
                fontWeight: FontWeight.bold,
                fontSize: 19,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: titleCtrl,
              style: const TextStyle(fontFamily: 'SolaimanLipi'),
              decoration: const InputDecoration(
                hintText: 'শিরোনাম...',
                hintStyle: TextStyle(fontFamily: 'SolaimanLipi'),
              ),
            ),
            TextField(
              controller: contentCtrl,
              maxLines: 4,
              style: const TextStyle(fontFamily: 'SolaimanLipi'),
              decoration: const InputDecoration(
                hintText: 'বিস্তারিত নোট লিখুন...',
                hintStyle: TextStyle(fontFamily: 'SolaimanLipi'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  if (titleCtrl.text.isNotEmpty || contentCtrl.text.isNotEmpty) {
                    NotebookPage.saveQuickNote(
                      context: context,
                      title: titleCtrl.text.isEmpty ? 'নতুন নোট' : titleCtrl.text,
                      content: contentCtrl.text,
                    );
                    Navigator.pop(ctx);
                  }
                },
                child: const Text(
                  'সংরক্ষণ করুন',
                  style: TextStyle(
                    fontFamily: 'SolaimanLipi',
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}