import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../api_controller/user_controller.dart';

// Generate speech from text using the Google Cloud Text-to-Speech API
Future<Uint8List> generateSpeech(String text, String languageCode, String voiceName) async {
  final url = "https://texttospeech.googleapis.com/v1/text:synthesize?key=${allSettings.value.googleApikey}";
  
  final headers = {"Content-Type": "application/json"};
  
  final body = jsonEncode({
    "input": {"text": text},
    "voice": {"languageCode": languageCode, "name": voiceName},
    "audioConfig": {"audioEncoding": Platform.isIOS ? 'LINEAR16' : "MP3"}
  });
  
  final response = await http.post(Uri.parse(url), headers: headers, body: body);
   print(response);
  final res = base64.decode(jsonDecode(response.body)["audioContent"]);
  return res;
}

Future<void> saveUint8ListAsText(Uint8List bytes,String txt) async {
  // String text = utf8.decode(bytes);
  final directory = await getTemporaryDirectory();
  final file = File('${directory.path}/$txt.mp3');
    if (await file.exists()) {
    // Read the existing file content
    final existingContent = await file.readAsBytes();
    // Compare the existing content with the new content
    if ( listEquals(existingContent, bytes)) {
      return;
    }
    await file.delete(); // delete previous file
  }
  // Save the file
  await file.writeAsBytes(bytes);
}


/// Naive [List] equality implementation.
bool listEquals<E>(List<E> list1, List<E> list2) {
  if (identical(list1, list2)) {
    return true;
  }

  if (list1.length != list2.length) {
    return false;
  }

  for (var i = 0; i < list1.length; i += 1) {
    if (list1[i] != list2[i]) {
      return false;
    }
  }

  return true;
}

// Play the generated audio using a media player
// Uint8List playAudio(http.Response response) {
//   // Decode the audio data from the response body
//   final audioData = base64.decode(jsonDecode(response.body)["audioContent"]);
//   // playLocal(audioData);
//   //  final audioBase64 = base64Encode(audioData);
//   return audioData;
//   // Play the audio using a media player
//   // ...
// }


// Usage example
