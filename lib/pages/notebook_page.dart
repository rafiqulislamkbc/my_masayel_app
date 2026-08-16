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

    // ১. লোকাল স্টোরেজে স্থায়ী সংরক্ষণ (অফলাইনেও আজীবন থাকবে)
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> rawList = prefs.getStringList('local_user_notes') ?? [];
      rawList.insert(0, jsonEncode(newNote));
      await prefs.setStringList('local_user_notes', rawList);
    } catch (e) {
      debugPrint('Local save error: $e');
    }

    // ২. ফায়ারবেসে ইউজারের আন্ডারে notes সাব-কালেকশনে জমা হবে
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('notes')
            .doc(localId)
            .set({
          'userId': user.uid,
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
      debugPrint('Cloud save error: $e');
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '"$cleanTitle" সফলভাবে নোটবইতে সংরক্ষিত হয়েছে!',
                  style: const TextStyle(fontFamily: 'SolaimanLipi', fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.teal.shade800,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

    // ক্লাউড থেকে সিঙ্ক
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final snap = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('notes')
            .where('isDeleted', isEqualTo: false)
            .get();

        for (var doc in snap.docs) {
          final data = doc.data();
          final id = doc.id;
          if (!loaded.any((n) => n['id'] == id)) {
            loaded.add({
              'id': id,
              'title': data['title'] ?? '',
              'content': data['content'] ?? '',
              'category': data['category'] ?? '',
              'color': data['color'] ?? 'teal',
            });
          }
        }
      } catch (e) {
        debugPrint('Cloud fetch error: $e');
      }
    }

    setState(() {
      _notes = loaded;
      _isLoading = false;
    });
  }

  Future<void> _saveNoteToList({
    String? id,
    required String title,
    required String content,
    String? category,
    String? color,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    final noteId = id ?? 'note_$now';

    if (id == null) {
      final item = {
        'id': noteId,
        'title': title.isEmpty ? 'শিরোনামহীন নোট' : title,
        'content': content,
        'category': category ?? 'কাস্টম নোট',
        'color': color ?? 'teal',
        'createdAt': now,
        'updatedAt': now,
      };
      _notes.insert(0, item);
    } else {
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

    // ফায়ারবেসে আপডেট
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('notes')
            .doc(noteId)
            .set({
          'userId': user.uid,
          'title': title.isEmpty ? 'শিরোনামহীন নোট' : title,
          'content': content,
          'category': category ?? 'কাস্টম নোট',
          'color': color ?? 'teal',
          'isDeleted': false,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Cloud sync error: $e');
      }
    }
  }

  Future<void> _deleteNote(String id) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notes.removeWhere((n) => n['id'] == id);
    });
    final rawList = _notes.map((n) => jsonEncode(n)).toList();
    await prefs.setStringList('local_user_notes', rawList);

    // ফায়ারবেসে সফট ডিলিট
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('notes')
            .doc(id)
            .delete();
      } catch (_) {}
    }

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

  // থিম অনুয়ায়ী কার্ডের ব্যাকগ্রাউন্ড কালার নির্ধারণ
  Color _getCardColor(String? colorKey, bool isDark) {
    if (isDark) {
      switch (colorKey) {
        case 'amber':
          return const Color(0xFF2E2412);
        case 'emerald':
          return const Color(0xFF132F23);
        case 'teal':
          return const Color(0xFF113230);
        case 'purple':
          return const Color(0xFF26163B);
        case 'rose':
          return const Color(0xFF33161C);
        default:
          return const Color(0xFF1E293B);
      }
    } else {
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
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'নোটবই ও সংরক্ষিত তথ্য',
          style: TextStyle(
            fontFamily: 'SolaimanLipi',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF004D40) : Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
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
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              style: TextStyle(
                fontFamily: 'SolaimanLipi',
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: 'সংরক্ষিত নোট বা মাসআলা খুঁজুন...',
                hintStyle: TextStyle(
                  fontFamily: 'SolaimanLipi',
                  fontSize: 14,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: 20,
                  color: isDark ? Colors.tealAccent : Colors.teal,
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white12 : Colors.grey.shade300,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white12 : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.teal))
                : filteredNotes.isEmpty
                    ? Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.bookmark_border,
                                size: 64,
                                color: isDark ? Colors.grey.shade600 : Colors.grey,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'কোনো সংরক্ষিত নোট নেই',
                                style: TextStyle(
                                  fontFamily: 'SolaimanLipi',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.grey.shade400 : Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'যেকোনো মাসআলার বুকমার্ক আইকনে ক্লিক করে অথবা নিচের (+) বাটন দিয়ে আপনার ব্যক্তিগত নোট লিখে রাখুন।',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'SolaimanLipi',
                                  fontSize: 14,
                                  color: isDark ? Colors.grey.shade500 : Colors.grey,
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
                          return _buildNoteCard(note, isDark);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: isDark ? Colors.tealAccent.shade700 : Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _openNoteEditor(context),
      ),
    );
  }

  Widget _buildNoteCard(Map<String, dynamic> note, bool isDark) {
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
          color: _getCardColor(note['color'], isDark),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black38 : Colors.black12,
              blurRadius: 4,
              offset: const Offset(0, 2),
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
                      color: isDark ? const Color(0x332DD4BF) : const Color(0x1F009688),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      category.toString(),
                      style: TextStyle(
                        fontFamily: 'SolaimanLipi',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.tealAccent : Colors.teal,
                      ),
                    ),
                  ),
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.more_vert,
                    size: 18,
                    color: isDark ? Colors.grey.shade400 : Colors.grey,
                  ),
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
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
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit,
                            size: 18,
                            color: isDark ? Colors.tealAccent : Colors.teal,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'সম্পাদনা',
                            style: TextStyle(
                              fontFamily: 'SolaimanLipi',
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'copy',
                      child: Row(
                        children: [
                          Icon(
                            Icons.copy,
                            size: 18,
                            color: isDark ? Colors.grey.shade300 : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'কপি করুন',
                            style: TextStyle(
                              fontFamily: 'SolaimanLipi',
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            'মুছে ফেলুন',
                            style: TextStyle(
                              fontFamily: 'SolaimanLipi',
                              color: Colors.red,
                            ),
                          ),
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
              style: TextStyle(
                fontFamily: 'SolaimanLipi',
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
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
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
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

  void _openNoteDetailModal(Map<String, dynamic> note) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgModal = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF334155);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: bgModal,
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
                      style: TextStyle(
                        fontFamily: 'SolaimanLipi',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: isDark ? Colors.tealAccent : Colors.teal,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: isDark ? Colors.grey.shade300 : Colors.black54,
                    ),
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
                      color: isDark ? const Color(0x332DD4BF) : const Color(0x1F009688),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      note['category'],
                      style: TextStyle(
                        fontFamily: 'SolaimanLipi',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.tealAccent : Colors.teal,
                      ),
                    ),
                  ),
                ),
              ],
              Divider(
                height: 24,
                color: isDark ? Colors.white12 : Colors.grey.shade300,
              ),
              SelectableText(
                note['content'] ?? '',
                style: TextStyle(
                  fontFamily: 'SolaimanLipi',
                  fontSize: 16,
                  height: 1.5,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.copy, size: 18),
                      label: const Text(
                        'কপি',
                        style: TextStyle(fontFamily: 'SolaimanLipi'),
                      ),
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: '${note['title']}\n\n${note['content']}'),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('কপি করা হয়েছে!')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.teal : Colors.teal,
                      ),
                      icon: const Icon(Icons.edit, size: 18, color: Colors.white),
                      label: const Text(
                        'সম্পাদনা',
                        style: TextStyle(
                          fontFamily: 'SolaimanLipi',
                          color: Colors.white,
                        ),
                      ),
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

  void _openNoteEditor(BuildContext context, {Map<String, dynamic>? note}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = note != null;
    final titleCtrl = TextEditingController(text: isEditing ? note['title'] : '');
    final contentCtrl = TextEditingController(text: isEditing ? note['content'] : '');
    final bgModal = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final inputFill = isDark ? const Color(0xFF0F172A) : Colors.grey.shade50;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: bgModal,
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
              style: TextStyle(
                fontFamily: 'SolaimanLipi',
                fontWeight: FontWeight.bold,
                fontSize: 19,
                color: isDark ? Colors.tealAccent : Colors.teal,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: titleCtrl,
              style: TextStyle(
                fontFamily: 'SolaimanLipi',
                color: textColor,
              ),
              decoration: InputDecoration(
                hintText: 'শিরোনাম...',
                hintStyle: TextStyle(
                  fontFamily: 'SolaimanLipi',
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                filled: true,
                fillColor: inputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white12 : Colors.grey.shade300,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white12 : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: contentCtrl,
              maxLines: 5,
              style: TextStyle(
                fontFamily: 'SolaimanLipi',
                color: textColor,
              ),
              decoration: InputDecoration(
                hintText: 'বিস্তারিত নোট লিখুন...',
                hintStyle: TextStyle(
                  fontFamily: 'SolaimanLipi',
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                filled: true,
                fillColor: inputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white12 : Colors.grey.shade300,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white12 : Colors.grey.shade300,
                  ),
                ),
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