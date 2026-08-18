import 'package:flutter/material.dart';

class IconHelper {
  static IconData getDynamicIcon(String? iconKey) {
    switch (iconKey?.toLowerCase().trim()) {
      // ১. ইবাদত, কুরআন ও সালাত
      case 'quran':
      case 'book':
      case 'menu_book':
        return Icons.menu_book_rounded;
      case 'mosque':
      case 'prayer':
        return Icons.mosque_rounded;
      case 'dua':
      case 'hands':
        return Icons.pan_tool_alt_rounded;
      case 'tasbih':
      case 'zikr':
        return Icons.fingerprint_rounded;
      case 'kaaba':
      case 'qibla':
        return Icons.location_city_rounded;

      // ২. দিন, সময় ও বর্ষপঞ্জি
      case 'moon':
      case 'crescent':
      case 'night':
        return Icons.nightlight_round;
      case 'sun':
      case 'day':
        return Icons.wb_sunny_rounded;
      case 'alarm':
      case 'timer':
      case 'clock':
        return Icons.alarm_rounded;
      case 'calendar':
      case 'friday':
      case 'event':
        return Icons.calendar_month_rounded;
      case 'water':
      case 'wudu':
        return Icons.water_drop_rounded;

      // ৩. সদকা ও আত্মশুদ্ধি
      case 'charity':
      case 'gift':
      case 'sadakah':
        return Icons.volunteer_activism_rounded;
      case 'heart':
      case 'love':
      case 'favorite':
        return Icons.favorite_rounded;
      case 'shield':
      case 'protect':
        return Icons.shield_rounded;
      case 'family':
      case 'people':
        return Icons.people_alt_rounded;

      // ৪. অনুপ্রেরণা, নসিহত ও নোটিশ
      case 'lightbulb':
      case 'tips':
      case 'idea':
        return Icons.lightbulb_outline_rounded;
      case 'star':
      case 'grade':
        return Icons.star_rounded;
      case 'trophy':
      case 'award':
        return Icons.emoji_events_rounded;
      case 'campaign':
      case 'notice':
      case 'announcement':
        return Icons.campaign_rounded;
      case 'check':
      case 'verified':
        return Icons.verified_rounded;
      case 'bookmark':
      case 'flag':
        return Icons.bookmark_added_rounded;

      case 'sparkles':
      case 'auto_awesome':
      default:
        return Icons.auto_awesome;
    }
  }
}