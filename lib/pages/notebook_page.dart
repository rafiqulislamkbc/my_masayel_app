import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    final String cleanTitle = title.isEmpty ? 'শিরোনামহীন নোট' : title;
    final String cleanCategory = category ?? 'মাসআলা নোট';
    final int timestamp = DateTime.now().millisecondsSinceEpoch;
    final String localId = 'note_$timestamp';

    final Map<String, dynamic> newNote = {
      'id': localId,
      'title': cleanTitle,
      'content': content,
      'category': cleanCategory,
      'color': 'teal',
      'createdAt': timestamp,
      'updatedAt': timestamp,
    };

    // ১. লোকাল স্টোরেজে স্থায়ী সংরক্ষণ (অফলাইন ও অনলাইনে আজীবন সংরক্ষিত থাকবে)
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> rawList = prefs.getStringList('local_user_notes') ?? [];
      rawList.insert(0, jsonEncode(newNote));
      await prefs.setStringList('local_user_notes', rawList);
    } catch (e) {
      debugPrint('Local save error: $e');
    }

    // ২. ফায়ারবেস ক্লাউডে সিঙ্ক (যদি ইউজার লগইন থাকে বা অনলাইন থাকে)
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('notes').add({
          'userId': user.uid,
          'localId': localId,
          'title': cleanTitle,
          'content': content,
          'category': cleanCategory,
          'color': 'teal',
          'isDeleted': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('Cloud sync error (safely handled): $e');
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '"$cleanTitle" সফলভাবে নোটবইতে সংরক্ষিত হয়েছে!',
            style: const TextStyle(fontFamily: 'SolaimanLipi'),
          ),
          backgroundColor: Colors.teal,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  State<NotebookPage> createState() => _NotebookPageState();
}

class _NotebookPageState extends State<NotebookPage> {
  List<Map<String, dynamic>> _notes = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  // নোটগুলো লোড করার মেথড
  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    List<String> rawList = prefs.getStringList('local_user_notes') ?? [];

    List<Map<String, dynamic>> loaded = [];
    for (String item in rawList) {
      try {
        loaded.add(Map<String, dynamic>.from(jsonDecode(item)));
      } catch (_) {}
    }

    setState(() {
      _notes = loaded;
      _isLoading = false;
    });
  }

  // নোট সেভ বা আপডেট
  Future<void> _saveNoteToList({
    String? id,
    required String title,
    required String content,
    String? category,
    String? color,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;

    if (id == null) {
      // নতুন নোট
      final newId = 'note_$now';
      final item = {
        'id': newId,
        'title': title.isEmpty ? 'শিরোনামহীন নোট' : title,
        'content': content,
        'category': category ?? 'কাস্টম নোট',
        'color': color ?? 'teal',
        'createdAt': now,
        'updatedAt': now,
      };
      _notes.insert(0, item);
    } else {
      // এডিট/আপডেট
      final index = _notes.indexWhere((n) => n['id'] == id);
      if (index != -1) {
        _notes[index]['title'] = title;
        _notes[index]['content'] = content;
        _notes[index]['updatedAt'] = now;
      }
    }

    final rawList = _notes.map((n) => jsonEncode(n)).toList();
    await prefs.setStringList('local_user_notes', rawList);
    setState(() {});
  }

  // নোট ডিলিট
  Future<void> _deleteNote(String id) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notes.removeWhere((n) => n['id'] == id);
    });
    final rawList = _notes.map((n) => jsonEncode(n)).toList();
    await prefs.setStringList('local_user_notes', rawList);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'নোটটি মুছে ফেলা হয়েছে',
            style: TextStyle(fontFamily: 'SolaimanLipi'),
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

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
    var filteredNotes = _notes;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filteredNotes = _notes.where((n) {
        final title = (n['title'] ?? '').toString().toLowerCase();
        final content = (n['content'] ?? '').toString().toLowerCase();
        return title.contains(q) || content.contains(q);
      }).toList();
    }

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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'রিফ্রেশ',
            onPressed: _loadNotes,
          ),
        ],
      ),
      body: Column(
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
                prefixIcon: const Icon(Icons.search, size: 20, color: Colors.teal),
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

          // নোট লিস্ট
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.teal))
                : filteredNotes.isEmpty
                    ? Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.bookmark_border,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'কোনো সংরক্ষিত নোট নেই',
                                style: TextStyle(
                                  fontFamily: 'SolaimanLipi',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'যেকোনো মাসআলার বুকমার্ক আইকনে ক্লিক করে অথবা নিচের (+) বাটন দিয়ে আপনার ব্যক্তিগত নোট লিখে রাখুন।',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'SolaimanLipi',
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: filteredNotes.length,
                        itemBuilder: (context, index) {
                          final note = filteredNotes[index];
                          return _buildNoteCard(note);
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

  Widget _buildNoteCard(Map<String, dynamic> note) {
    final id = note['id'] ?? '';
    final title = note['title'] ?? 'শিরোনামহীন নোট';
    final content = note['content'] ?? '';
    final category = note['category'] ?? '';

    return InkWell(
      onTap: () => _openNoteDetailModal(note),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _getCardColor(note['color']),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (category.toString().isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0x1F009688),
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
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
                  onSelected: (val) {
                    if (val == 'edit') {
                      _openNoteEditor(context, note: note);
                    } else if (val == 'delete') {
                      _deleteNote(id);
                    } else if (val == 'copy') {
                      Clipboard.setData(ClipboardData(text: '$title\n\n$content'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'নোটটি কপি করা হয়েছে',
                            style: TextStyle(fontFamily: 'SolaimanLipi'),
                          ),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18, color: Colors.teal),
                          SizedBox(width: 8),
                          Text('সম্পাদনা', style: TextStyle(fontFamily: 'SolaimanLipi')),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'copy',
                      child: Row(
                        children: [
                          Icon(Icons.copy, size: 18, color: Colors.grey),
                          SizedBox(width: 8),
                          Text('কপি করুন', style: TextStyle(fontFamily: 'SolaimanLipi')),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('মুছে ফেলুন', style: TextStyle(fontFamily: 'SolaimanLipi', color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
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
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // নোটে ক্লিক করলে বিস্তারিত পড়ার পপআপ
  void _openNoteDetailModal(Map<String, dynamic> note) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: scrollController,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      note['title'] ?? '',
                      style: const TextStyle(
                        fontFamily: 'SolaimanLipi',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              if ((note['category'] ?? '').isNotEmpty) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0x1F009688),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      note['category'],
                      style: const TextStyle(
                        fontFamily: 'SolaimanLipi',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                ),
              ],
              const Divider(height: 24),
              SelectableText(
                note['content'] ?? '',
                style: const TextStyle(
                  fontFamily: 'SolaimanLipi',
                  fontSize: 16,
                  height: 1.5,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text('কপি', style: TextStyle(fontFamily: 'SolaimanLipi')),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: '${note['title']}\n\n${note['content']}'));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('কপি করা হয়েছে!')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                      icon: const Icon(Icons.edit, size: 18, color: Colors.white),
                      label: const Text('সম্পাদনা', style: TextStyle(fontFamily: 'SolaimanLipi', color: Colors.white)),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _openNoteEditor(context, note: note);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // নোট তৈরি বা এডিট করার ফর্ম
  void _openNoteEditor(BuildContext context, {Map<String, dynamic>? note}) {
    final isEditing = note != null;
    final titleCtrl = TextEditingController(text: isEditing ? note['title'] : '');
    final contentCtrl = TextEditingController(text: isEditing ? note['content'] : '');

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
            Text(
              isEditing ? 'নোট সম্পাদনা করুন' : 'নতুন নোট লিখুন',
              style: const TextStyle(
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
              maxLines: 5,
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
                onPressed: () async {
                  if (titleCtrl.text.isNotEmpty || contentCtrl.text.isNotEmpty) {
                    Navigator.pop(ctx);
                    await _saveNoteToList(
                      id: isEditing ? note['id'] : null,
                      title: titleCtrl.text.isEmpty ? 'নতুন নোট' : titleCtrl.text,
                      content: contentCtrl.text,
                    );
                  }
                },
                child: Text(
                  isEditing ? 'আপডেট করুন' : 'সংরক্ষণ করুন',
                  style: const TextStyle(
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