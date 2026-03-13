import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/person.dart';

class GeminiService {
  // --- НЕ ЗАБУДЬ СНОВА ВСТАВИТЬ СВОЙ КЛЮЧ СЮДА ---
  static const String _apiKey = 'AIzaSyA1H7HgJWrN_4r2MNflntcGq2YSzWGcqks';

  final GenerativeModel _model;

  GeminiService()
      : _model = GenerativeModel(
          // ИСПОЛЬЗУЕМ НОВУЮ, АКТУАЛЬНУЮ МОДЕЛЬ:
          model: 'gemini-2.5-flash', 
          apiKey: _apiKey,
        );

  Future<String> generateGiftIdeas(Person person) async {
    final interests = person.generalGiftIdeas.join(', ');
    
    final prompt = [
      Content.text(
        'Ты эксперт по подбору подарков. Твоя задача — предложить 5 креативных, оригинальных и продуманных идей подарка для человека по имени ${person.name}.'
        'Этот человек относится к категории "${person.category}".'
        'Его интересы и то, что он любит: $interests.'
        'Если указаны аллергии или то, что нельзя дарить ("${person.allergies ?? 'нет'}"), обязательно учти это и НЕ предлагай такие вещи.'
        'Ответ должен быть строго на русском языке. Ответ должен быть кратким, в виде маркированного списка, без лишних вступлений.'
      ),
    ];

    try {
      final response = await _model.generateContent(prompt);
      return response.text ?? 'К сожалению, не удалось сгенерировать идеи.';
    } catch (e) {
      return 'Ошибка при обращении к ИИ: $e';
    }
  }
}