import 'dart:convert';
import 'dart:math';
import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';

// Initialize PocketBase
final pb = PocketBase('http://127.0.0.1:8090');
const guildId = '751662000093921291';

// Function to get user roles and determine their role
Future<String> getUserRoles(String accessToken, String guildId) async {
  try {
    final response = await http.get(
      Uri.parse('https://discord.com/api/guilds/$guildId/members/@me'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      List<dynamic> roles = data['roles'];
      print('User roles: $roles'); // Print roles for verification

      if (roles.contains('751662317569179791')) {
        return 'Exec';
      } else if (roles.contains('1044742711162449920')) {
        return 'LabSupervisor';
      } else {
        return 'Guest';
      }
    } else {
      print('Failed to load user roles, status code: ${response.statusCode}');
      print('Response: ${response.body}');
      return 'Error';
    }
  } catch (e) {
    print('Error fetching user roles: $e');
    return 'Error';
  }
}

// Function to authenticate with PocketBase using OAuth2
Future<String> authenticateWithPocketBase() async {
  try {
    final authData = await pb.collection('users').authWithOAuth2('discord', (url) async {
      if (await canLaunch(url.toString())) {
        await launch(url.toString());
      } else {
        throw 'Could not launch $url';
      }
    });

    if (pb.authStore.isValid) {
      print('Authentication successful');
      print('Token: ${pb.authStore.token}'); // these to debug
      print('User ID: ${pb.authStore.model.id}');

      await pb.collection('users').update(pb.authStore.model.id, body: {
        "oauth_token": pb.authStore.token,
      });

      return await getUserRoles(pb.authStore.token, guildId);
    } else {
      print('Authentication failed');
      return 'Error';
    }
  } catch (e) {
    print('Error during authentication: $e');
    return 'Error';
  }
}

void main() async {
  dotenv.load();
  final tursoDatabaseUrl = dotenv.env['TURSO_DATABASE_URL'];
  final tursoAuthToken = dotenv.env['TURSO_AUTH_TOKEN'];


  if (tursoDatabaseUrl == null || tursoAuthToken == null) {
    print('Turso database URL, auth token, client ID or client secret is not set in the .env file.');
    return;
  }

  pb.baseUrl = tursoDatabaseUrl;
  pb.authStore.save(tursoAuthToken, 'admin'); 

  try {
    String result = await authenticateWithPocketBase();
    if (result == 'Exec') {
      print('User is an Exec.');
    } else if (result == 'LabSupervisor') {
      print('User is a Lab Supervisor.');
    } else if (result == 'Guest') {
      print('User is a Guest.');
    } else {
      print('Error user role.');
    }
  } catch (error) {
    print('Error: $error');
  }
}
