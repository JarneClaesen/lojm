import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> sendOneSignalNotification(String title, String messageContent, String senderPlayerId) async {
  const String apiUrl = 'https://onesignal.com/api/v1/notifications';
  const String appId = 'c060575a-62b7-4692-a983-517f9ef27627'; // Replace with your OneSignal App ID
  const String apiKey = 'NjFkMmMyZmQtODY1Ni00NDkwLWIxMTItOWY4YzczNDQzYmEw'; // Replace with your OneSignal REST API Key
  const String oneSignalEndpoint = "https://onesignal.com/api/v1/players?app_id=$appId";

  // Fetch all player IDs from your database
  List<String> allPlayerIds = await fetchAllPlayerIdsFromOneSignal();

  // Remove the sender's player ID from the list
  allPlayerIds.remove(senderPlayerId);

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Basic $apiKey',
      },
      body: json.encode({
        'app_id': appId,
        'include_player_ids': allPlayerIds,  // Use the filtered list
        'headings': {'en': title},
        'contents': {'en': messageContent},
      }),
    );

    if (response.statusCode != 200) {
      print('Failed to send notification: ${response.body}');
    }
  } catch (e) {
    print('Error sending OneSignal notification: $e');
  }
}

Future<List<String>> fetchAllPlayerIdsFromOneSignal() async {
  const String appId = 'c060575a-62b7-4692-a983-517f9ef27627';
  const String apiKey = 'NjFkMmMyZmQtODY1Ni00NDkwLWIxMTItOWY4YzczNDQzYmEw';
  const String oneSignalEndpoint = "https://onesignal.com/api/v1/players?app_id=$appId";
  List<String> playerIds = [];

  int offset = 0;
  int limit = 300; // You can adjust this value as needed

  while (true) {
    final response = await http.get(
      Uri.parse("$oneSignalEndpoint&limit=$limit&offset=$offset"),
      headers: {
        "Authorization": "Basic $apiKey",
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (responseBody['players'] != null) {
        for (var player in responseBody['players']) {
          playerIds.add(player['id']);
        }

        if (responseBody['players'].length < limit) {
          break; // End the loop if we've fetched all players
        } else {
          offset += limit; // Increase the offset for the next batch
        }
      } else {
        break; // End the loop if there are no players
      }
    } else {
      throw Exception("Failed to fetch players from OneSignal: ${response.body}");
    }
  }

  return playerIds;
}