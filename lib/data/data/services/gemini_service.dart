import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  // TODO: Replace with your actual Gemini API Key from https://aistudio.google.com/
  static const String apiKey = 'YOUR_API_KEY_HERE';
  
  static Future<Map<String, String>> generateNoticeFromPrompt(String prompt) async {
    if (apiKey == 'YOUR_API_KEY_HERE') {
      throw Exception('Please insert your Gemini API Key inside lib/data/services/gemini_service.dart');
    }
    
    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
    
    final fullPrompt = '''
You are an expert HR and administrative assistant. 
Based on the following rough prompt, write a professional Notice Board entry.
Provide the output strictly in this exact format:
TITLE: [The Title]
BODY: [The professional notice description]

User Prompt: "$prompt"
''';

    final response = await model.generateContent([Content.text(fullPrompt)]);
    final text = response.text ?? '';
    
    String title = "Generated Notice";
    String body = text;
    
    if (text.contains('TITLE:') && text.contains('BODY:')) {
      final parts = text.split('BODY:');
      title = parts[0].replaceAll('TITLE:', '').trim();
      body = parts[1].trim();
    }
    
    return {
      'title': title,
      'body': body,
    };
  }
}
