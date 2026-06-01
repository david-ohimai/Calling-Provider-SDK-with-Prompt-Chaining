import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

// Load environment variables from a .env file.
Future<Map<String, String>> loadEnv() async {
  final envFile = File('.env');
  if (!await envFile.exists()) {
    throw Exception('.env file not found');
  }
  final lines = await envFile.readAsLines();
  final env = <String, String>{};
  for (final line in lines) {
    if (line.trim().isEmpty || line.startsWith('#')) continue;
    final parts = line.split('=');
    if (parts.length == 2) {
      env[parts[0].trim()] = parts[1].trim();
    }
  }
  return env;
}

// Load a prompt file and substitute placeholders with provided values.
String loadPrompt(String filename, Map<String, String> values) {
  final file = File('prompts/$filename');
  String content = file.readAsStringSync();
  values.forEach((key, value) {
    content = content.replaceAll('{$key}', value);
  });
  return content;
}

// Call the OpenRouter API with the given prompt.
Future<String> callApi(String prompt, String apiKey, String modelName) async {
  final env = await loadEnv();
  final apiUrl = Platform.environment['API_URL'] ?? env['API_URL'];
  final url = Uri.parse('$apiUrl/chat/completions');
  final headers = {
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
  };
  final body = jsonEncode({
    'model': modelName,
    'messages': [
      {'role': 'user', 'content': prompt},
    ],
  });

  final response = await http.post(url, headers: headers, body: body);

  final contentType = response.headers['content-type'] ?? '';
  if (!contentType.contains('application/json')) {
    throw Exception(
      'Expected JSON but got $contentType. Body: ${response.body.substring(0, 200)}',
    );
  }

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['choices'][0]['message']['content'];
  } else {
    throw Exception(
      'API request failed: ${response.statusCode} ${response.body}',
    );
  }
}

void printStep(int step, String label, String response) {
  print('\n${'=' * 60}');
  print('STEP $step: $label');
  print('-' * 60);
  print(response);
  print('=' * 60);
}

Future<void> runPromptChain(
    String query, String apiKey, String modelName) async {
  print('\nCustomer query: "$query"');

  // Step 1: Interpret the customer intent.
  final prompt1 = loadPrompt('prompt_1_intent.md', {'query': query});
  final intent = await callApi(prompt1, apiKey, modelName);
  printStep(1, 'Customer Intent', intent);

  // Step 2: Map to possible categories.
  final prompt2 = loadPrompt('prompt_2_categories.md', {
    'query': query,
    'intent': intent,
  });
  final possibleCategories = await callApi(prompt2, apiKey, modelName);
  printStep(2, 'Possible Categories', possibleCategories);

  // Step 3: Choose the single best category.
  final prompt3 = loadPrompt('prompt_3_best_category.md', {
    'query': query,
    'intent': intent,
    'possible_categories': possibleCategories,
  });
  final bestCategory = await callApi(prompt3, apiKey, modelName);
  printStep(3, 'Best Category', bestCategory);

  // Step 4: Extract additional details.
  final prompt4 = loadPrompt('prompt_4_details.md', {
    'query': query,
    'category': bestCategory,
  });
  final details = await callApi(prompt4, apiKey, modelName);
  printStep(4, 'Extracted Details', details);

  // Step 5: Generate the final customer response.
  final prompt5 = loadPrompt('prompt_5_response.md', {
    'query': query,
    'intent': intent,
    'category': bestCategory,
    'details': details,
  });
  final finalResponse = await callApi(prompt5, apiKey, modelName);
  printStep(5, 'Final Response to Customer', finalResponse);

  print('FINAL RESPONSE:');
  print('${'*' * 60}');
  print(finalResponse);
}

void main(List<String> args) async {
  final env = await loadEnv();

  final apiKey = env['OPENROUTER_API_KEY'];
  final modelName = env['MODEL_NAME'];

  if (apiKey == null || apiKey.isEmpty) {
    print('Error: OPENROUTER_API_KEY is not set in your .env file.');
    exit(1);
  }

  if (modelName == null || modelName.isEmpty) {
    print('Error: MODEL_NAME is not set in your .env file.');
    exit(1);
  }

  print('\nWelcome to Bank Customer Support.');
  print('Type "exit" or "quit" at any time to end the session.\n');

  // Use the first CLI argument as the opening query if provided.
  String? initialQuery = args.isNotEmpty ? args.join(' ') : null;

  while (true) {
    String query;

    if (initialQuery != null) {
      query = initialQuery;
      initialQuery = null;
    } else {
      stdout.write('Enter your query: ');
      final input = stdin.readLineSync();

      if (input == null || input.trim().isEmpty) {
        print('No query entered. Please type a query or "exit" to quit.\n');
        continue;
      }

      final trimmed = input.trim().toLowerCase();
      if (trimmed == 'exit' || trimmed == 'quit') {
        print('\nThank you for contacting Bank Customer Support. Goodbye!\n');
        exit(0);
      }

      query = input.trim();
    }

    await runPromptChain(query, apiKey, modelName);

    print('\n' + ('*' * 60) + '\n');
    print('Is there anything else I can help you with?');
    print(
        'Type your next query, or type "exit" / "quit" to end the session.\n');
  }
}
