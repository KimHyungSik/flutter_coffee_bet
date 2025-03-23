import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesManager {
  static const String PARTICIPANTS_LISTS_KEY = 'participants_lists';

  // Get all saved participant lists
  static Future<Map<String, List<String>>> getParticipantsLists() async {
    final prefs = await SharedPreferences.getInstance();
    final String? listsJson = prefs.getString(PARTICIPANTS_LISTS_KEY);

    if (listsJson == null) {
      return {};
    }

    Map<String, dynamic> jsonData = json.decode(listsJson);
    Map<String, List<String>> result = {};

    jsonData.forEach((key, value) {
      result[key] = List<String>.from(value);
    });

    return result;
  }

  // Save a participant list with a name
  static Future<bool> saveParticipantsList(String name, List<String> participants) async {
    if (name.isEmpty || participants.isEmpty) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    Map<String, List<String>> lists = await getParticipantsLists();

    lists[name] = participants;

    return await prefs.setString(PARTICIPANTS_LISTS_KEY, json.encode(lists));
  }

  // Delete a participant list by name
  static Future<bool> deleteParticipantsList(String name) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, List<String>> lists = await getParticipantsLists();

    if (lists.containsKey(name)) {
      lists.remove(name);
      return await prefs.setString(PARTICIPANTS_LISTS_KEY, json.encode(lists));
    }

    return false;
  }
}