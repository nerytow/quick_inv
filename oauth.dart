// my code for the authentication


// might also include the update thing here
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';


import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:http/http.dart' as http;

import 'package:pocketbase/pocketbase.dart'; 
/* imported necessary packages */


// defining important variables (static)
final TURSO_DATABASE_URL="libsql://quick-inv-horisofine.turso.io";

final TURSO_AUTH_TOKEN="eyJhbGciOiJFZERTQSIsInR5cCI6IkpXVCJ9.eyJhIjoicnciLCJpYXQiOjE3MDkxNTY1NzQsImlkIjoiZjQ4MDNjZGQtZDVkOS0xMWVlLWE5ZmMtZmFjNjg0YWUwMTkyIn0.oBb904uk643He_3BiHhRl91BHdcZiTFJpXl9sQmlfR0FqUhOEmqPdCB1q-Lq1oqBL5p3m-nqk4pm7FvU5wvHBg";

final pb = PocketBase('http://127.0.0.1:8090');

final userData = await pb.collection('users').authWithPassword('admin@admin.com', 'admin12345!');


final authorizationEndpoint =
    Uri.parse('https://discord.com/oauth2/authorize');
final tokenEndpoint = Uri.parse('https://discord.com/api/oauth2/token	');


final identifier = 'quickinv'+randomHexString(5);
Random _random = Random();

String randomHexString(int length) {
  StringBuffer sb = StringBuffer();
  for (var i = 0; i < length; i++) {
    sb.write(_random.nextInt(16).toRadixString(16));
  }
  return sb.toString();
}
//generate random passw
//hash func
String hash(String orig){

}

final secret = randomHexString(32); 

final redirectUrl = Uri.parse('https://bdquickinv.happyfir.com/');
try { // if the file doesnt exist
final credentialsFile = File('~/.myapp/credentials.json');}
catch (error) {
    print('Error: $error');
}
// access the user Roles w parameters accessToken and guildID it will always be '751662000093921291'
Future<void> getUserRoles(String accessToken, String guildId) async { 
  final response = await http.get(
    Uri.parse('https://discord.com/api/guilds/$guildId/members/@me'),
    headers: {
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode == 200) {
    // If the server returns a 200 OK response parse the JSON
    Map<String, dynamic> data = jsonDecode(response.body); 
    List<dynamic> roles = data['roles'];
    print('User roles: $roles'); // print all the roles then we can look for Execs: 751662317569179791 lab supervisor : 1044742711162449920
  } else {
    // If the server did not return a 200 OK response throw an exception
    throw Exception('Failed to load user roles');
  }
}

Future<oauth2.Client> createClient() async {
  var exists = await credentialsFile.exists(); // checks if the credential files exists

   if (exists) { // it exsists already
    var credentials = 
        oauth2.Credentials.fromJson(await credentialsFile.readAsString());// make the credentials a string stored into credentials
    return oauth2.Client(credentials, identifier: identifier, secret: secret); // create client in format : credentials, identifier, secret
  }

  var grant = oauth2.AuthorizationCodeGrant(
      identifier, authorizationEndpoint, tokenEndpoint,
      secret: secret);  
      
      var authorizationUrl = grant.getAuthorizationUrl(redirectUrl);
      await redirect(authorizationUrl);
  var responseUrl = await listen(redirectUrl);
   return await grant.handleAuthorizationResponse(responseUrl.queryParameters);
}

void main() async {
  var client = await createClient();
  try {
        var rolesResponse = await client.get(Uri.parse('https://discord.com/api/guilds/$guildId/members/@me'),
                headers: {'Authorization': 'Bearer ${client.credentials.accessToken}'});
        print('User roles in guild $guildId: $rolesResponse'); // guilds ID os 751662000093921291
  print(await client.read('http://bdquickinv.happyfir.com/protected-resources.txt'));}
  catch (error) {print('Error: $error');}

  

 await credentialsFile.writeAsString(client.credentials.toJson());
}

