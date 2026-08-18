import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _showAboutAppDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('অ্যাপ সম্পর্কে'),
        content: const Text(
          'এটি একটি ইসলামিক মাসআলা ভিত্তিক মোবাইল অ্যাপ্লিকেশন। এখানে দৈনন্দিন জীবনের বিভিন্ন গুরুত্বপূর্ণ মাসআলা ও সমাধান খুব সহজে খুঁজে পাওয়া যাবে। অ্যাপ সংস্করণ: ১.০.০',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ঠিক আছে'),
          ),
        ],
      ),
    );
  }

  void _showNaseehaItDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('নাসিহাহ আইটি'),
        content: const Text(
          'নাসিহাহ আইটি হলো একটি প্রযুক্তিভিত্তিক প্রতিষ্ঠান, যা ইসলামিক ও জনকল্যাণমূলক সফটওয়্যার এবং মোবাইল অ্যাপ তৈরি করে থাকে। আমাদের লক্ষ্য প্রযুক্তির ছোঁয়া পৌঁছে দেওয়া।',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ধন্যবাদ'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('গোপনীয়তা নীতিমালা'),
        content: const Text(
          'আপনার গোপনীয়তা আমাদের কাছে অত্যন্ত গুরুত্বপূর্ণ। এই অ্যাপটি ব্যবহারকারীর কোনো ব্যক্তিগত তথ্য সংগ্রহ বা অপব্যবহার করে না।',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('বন্ধ করুন'),
          ),
        ],
      ),
    );
  }

  void _showDeveloperDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Center(
          child: Text(
            'ডেভেলপার পরিচিতি',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 42,
              backgroundColor: Colors.teal,
              child: CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage('assets/developer.jpg'),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'রফিকুল ইসলাম',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'আমি রফিকুল ইসলাম। ২০২৬ইং সনে কওমী মাদরাসা থেকে দাওরায়ে হাদিস সম্পন্ন করেছি। পড়াশোনার পাশাপাশি লেখালেখি, ডিজাইন এবং আধুনিক টেকনোলজির প্রতি আগ্রহ রয়েছে। পড়াশোনাকে মূল রেখে অবসর সময়গুলোতে শখের বশে বিভিন্ন ওয়েবসাইট, মোবাইল অ্যাপ তৈরি করেছি। এই অ্যাপটির প্রয়োজনীয়তা অনুভব করে কষ্ট হওয়া সত্ত্বেও এ কাজ হাতে নিয়েছিলাম। আশা করি কিছুটা হলেও সফল হয়েছি। আল্লাহ তায়ালা এ মেহনতকে কবুল করুন এবং সাদাকায়ে জারিয়ার অন্তর্ভূক্ত করুন। আমীন। সবার নিকট আবেদন থাকবে, অ্যাপটি শেয়ার করে অন্যদেরকে গুরুত্বপূর্ণ এ মাসাআলাগুলো জানার ব্যবস্থা করে দিবেন ইনশাআল্লাহ। অ্যাপটির আপডেট চলমান থাকবে; নতুন আপডেট আসলেই অ্যাপে নোটিশ চলে আসবে। আল্লাহ তায়ালা সকলের কল্যাণ করুন।',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey.shade300 : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'যোগাযোগ: ০১৮৩৩-০৭০৩২০',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.tealAccent : Colors.teal.shade800,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('বন্ধ করুন'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            width: double.infinity,
            color: isDarkMode ? const Color(0xFF004D40) : Colors.teal,
            padding: const EdgeInsets.only(top: 48, bottom: 16, left: 16, right: 16),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 34,
                    backgroundImage: ResizeImage(
                      AssetImage('assets/app_icon.png'),
                      width: 140,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'আপনি যা জানতে চেয়েছেন',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'মাসিক আলকাউছার-এর\nআপনি যা জানতে চেয়েছেন বিভাগ',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.teal),
            title: const Text('অ্যাপ সম্পর্কে'),
            subtitle: const Text('অ্যাপের পরিচিতি ও বিবরণ'),
            onTap: () {
              Navigator.pop(context);
              _showAboutAppDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.business, color: Colors.teal),
            title: const Text('নাসিহাহ আইটি'),
            subtitle: const Text('ডেভলপকারী প্রতিষ্ঠানের পরিচিতি'),
            onTap: () {
              Navigator.pop(context);
              _showNaseehaItDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.teal),
            title: const Text('ডেভেলপার পরিচিতি'),
            subtitle: const Text('বিস্তারিত জানতে ক্লিক করুন'),
            onTap: () {
              Navigator.pop(context);
              _showDeveloperDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.phone, color: Colors.teal),
            title: const Text('যোগাযোগ'),
            subtitle: const Text('০১৮৩৩-০৭০৩২০'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined, color: Colors.teal),
            title: const Text('প্রাইভেসি পলিসি'),
            subtitle: const Text('আমাদের নীতিমালা'),
            onTap: () {
              Navigator.pop(context);
              _showPrivacyPolicyDialog(context);
            },
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.info_outline, color: Colors.teal),
            title: Text('অ্যাপ ভার্সন'),
            subtitle: Text('১.০'),
          ),
        ],
      ),
    );
  }
}