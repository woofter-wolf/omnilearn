import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:omnilearn/tools/ai_prompts.dart';


class AI{
  late String _provider;
  late String _baseUrl;
  late String _apiKey;
  late String _modelName;
  static const int _maxTokens = 16384;
  static const Map<String, String> _urlList = {
    'openrouter': "https://openrouter.ai/api/v1/chat/completions"
  };

  final _aiPrompts = AIPrompts();

  /// Set API key
  void setApiKey(String apiKey) => this._apiKey = apiKey;
  /// Set name of the used model
  void setModelName(String modelName) => this._modelName = modelName;
  /// Set AI provider (for now it's only OpenRouter)
  void setProvider(String provider) {
    this._provider = provider;
    switch(provider) {
      case 'openrouter':
        this._baseUrl = _urlList['openrouter']!;
        break;
      default:
        this._baseUrl = _urlList['openrouter']!;
        break;
    }
  }

  /// Returns image (MIME) type
  /// - `path`: image path
  String _getMimeType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      default:
        return 'image/jpeg';
    }
  }

  /// Returns header
  Map<String, String> _getHeaders() => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_apiKey'
  };

  /// Returns the request body
  String _getRequestBody(String content) => jsonEncode({
    'model': _modelName,
    'max_tokens': _maxTokens,
    'messages': [
      {
        'role': 'system',
        'content': _aiPrompts.getSystemPrompt()
      },
      {
        'role': 'user',
        'content': content
      }
    ]
  });

  /// Returns the request body with included images
  Future<String> _getRequestBodyImage(String textContent, List<XFile> images) async {
    final List<Map<String, dynamic>> userContent = [
      {
        'type': 'text',
        'text': textContent
      }
    ];

    for(final image in images) {
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);
      final mimeType = image.mimeType ?? _getMimeType(image.path);

      userContent.add({
        'type': 'image_url',
        'image_url': {
          'url': 'data:$mimeType;base64,$base64Image',
        }
      });
    }

    return jsonEncode({
      'model': _modelName,
      'max_tokens': _maxTokens,
      'messages': [
        {
          'role': 'system',
          'content': _aiPrompts.getSystemPrompt()
        },
        {
          'role': 'user',
          'content': userContent
        }
      ]
    });
  }

  /// Returns the request body for Task Scanner module
  Future<String> _getRequestBodyTaskScanner(Map chatHistory) async {
    var _aiPrompts = AIPrompts();
    List chatHistoryMessages = [];
    List visionImages = [];
    int imageCounter = 0;

    // Move through all messages
    for(final e in chatHistory['messages']) {
      if(e['type'] == 'initial_images') {
        List chatHistoryMessageContent = [];
        for(final content in e['content']) {
          // Replaces images URL with Base64 format of image content for API
          if(content['type'] == 'image') {
            final String imagePath = content['image_url'].toString();
            final bytes = await File(imagePath).readAsBytes();
            final base64Image = base64Encode(bytes);
            final mimeType = _getMimeType(imagePath);
            final String imageId = 'image$imageCounter.jpg';
            imageCounter++;
            visionImages.add(
              {
                'type': 'image_url',
                'image_url': {
                  'url': 'data:$mimeType;base64,$base64Image',
                }
              }
            );
            chatHistoryMessageContent.add(
              {
                'type': 'image',
                'image_url': imageId
              }
            );
          }
        }
        chatHistoryMessages.add(
          {
            'role': 'user',
            'creation_date': e['creation_date'],
            'type': 'initial_images',
            'content': chatHistoryMessageContent
          }
        );
      }
      else if(e['type'] == 'message' && e['role'] == 'user') {
        List chatHistoryMessageContent = [];
        for(final content in e['content']) {
          // Replaces images URL with Base64 format of image content for API
          if(content['type'] == 'image') {
            final String imagePath = content['image_url'].toString();
            final bytes = await File(imagePath).readAsBytes();
            final base64Image = base64Encode(bytes);
            final mimeType = _getMimeType(imagePath);
            final String imageId = 'image$imageCounter.jpg';
            imageCounter++;
            visionImages.add(
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': 'data:$mimeType;base64,$base64Image',
                  }
                }
            );
            chatHistoryMessageContent.add(
                {
                  'type': 'image',
                  'image_url': imageId
                }
            );
          }
          else {
            chatHistoryMessageContent.add(content);
          }
        }
        chatHistoryMessages.add({
          'role': 'user',
          'creation_date': e['creation_date'],
          'type': 'message',
          'content': chatHistoryMessageContent
        });
      }
      else {
        chatHistoryMessages.add(e);
      }
    }

    // Converted chat history
    Map chatHistoryConverted = {
      'last_message_date_time': chatHistory['last_message_date_time'],
      'messages': chatHistoryMessages
    };

    // Add module prompt
    final List userContent = [
      {
        'type': 'text',
        'text': _aiPrompts.taskScannerPrompt(jsonEncode(chatHistoryConverted))
      },
      ...visionImages
    ];

    return jsonEncode({
      'model': _modelName,
      'max_tokens': _maxTokens,
      'messages': [
        {
          'role': 'system',
          'content': _aiPrompts.getSystemPrompt()
        },
        {
          'role': 'user',
          'content': userContent
        }
      ]
    });
  }

  /// Send message to selected AI model
  ///
  /// Arguments:
  /// - `context`: widget build context
  /// - `content`: message content
  /// Returns:
  /// String with response, throws [Exception] if error occurs
  Future<String> sendMessage(BuildContext context, String content) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _getHeaders(),
        body: _getRequestBody(content)
      );

      if(response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to get response: ${response.statusCode}")));
        throw Exception("Failed to get response: ${response.statusCode}");
      }
    }
    catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("API error: $e")));
      throw Exception("API error: $e");
    }
  }

  /// Generate flashcards from images by using selected AI model
  ///
  /// Arguments:
  /// - `context`: widget build context
  /// - `images`: images list
  /// Returns:
  /// String with JSON of flashcards structure or null if error occurred
  Future<String?> generateFlashcards(BuildContext context, List<XFile> images) async {
    try {
      final response = await http.post(
          Uri.parse(_baseUrl),
          headers: _getHeaders(),
          body: await _getRequestBodyImage(_aiPrompts.flashcardsPrompt(), images)
      );

      if(response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if(data['error'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("API error: ${data['error']['message']}")));
          debugPrint("API error: ${data['error']['message']}");
          return null;
        }
        return data['choices'][0]['message']?['content'];
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to get response: ${response.statusCode}, body: ${response.body}")));
        debugPrint("Failed to get response: ${response.statusCode}, body: ${response.body}");
        return null;
      }
    }
    catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("API error: $e")));
      debugPrint("API error: $e");
      return null;
    }
  }

  /// Generate quiz from flashcards by using selected AI model
  ///
  /// Arguments:
  /// - `context`: widget build context
  /// - `images`: images list
  /// - `flashcards`: flashcards list
  /// Returns:
  /// String with JSON of quiz structure or null if error occurred
  Future<String?> generateQuiz(BuildContext context, List<XFile> images, List flashcards) async {
    try {
      final response = await http.post(
          Uri.parse(_baseUrl),
          headers: _getHeaders(),
          body: await _getRequestBodyImage(_aiPrompts.quizzesPrompt(flashcards: flashcards.length == 0 ? "NO FLASHCARDS" : flashcards.toString()), images)
      );

      if(response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if(data['error'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("API error: ${data['error']['message']}")));
          debugPrint("API error: ${data['error']['message']}");
          return null;
        }

        return data['choices'][0]['message']?['content'];
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to get response: ${response.statusCode}, body: ${response.body}")));
        debugPrint("Failed to get response: ${response.statusCode}, body: ${response.body}");
        return null;
      }
    }
    catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("API error: $e")));
      debugPrint("API error: $e");
      return null;
    }
  }

  /// Generate message for Task Scanner module by using selected AI model
  ///
  /// Arguments:
  /// - `context`: widget build context
  /// - `chatHistory`: chat history
  /// Returns:
  /// String with list of JSON of message quiz or open question structure or null if error occurred
  Future<String?> generateTaskScannerMessage(BuildContext context, Map chatHistory) async {
    try {
      final response = await http.post(
          Uri.parse(_baseUrl),
          headers: _getHeaders(),
          body: await _getRequestBodyTaskScanner(chatHistory)
      );

      if(response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if(data['error'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("API error: ${data['error']['message']}")));
          debugPrint("API error: ${data['error']['message']}");
          return null;
        }

        return data['choices'][0]['message']?['content'];
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to get response: ${response.statusCode}, body: ${response.body}")));
        debugPrint("Failed to get response: ${response.statusCode}, body: ${response.body}");
        return null;
      }
    }
    catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("API error: $e")));
      debugPrint("API error: $e");
      return null;
    }
  }
}