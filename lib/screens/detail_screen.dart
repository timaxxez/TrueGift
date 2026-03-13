import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/person.dart';
import '../data/local_database.dart';
import '../data/gemini_service.dart';
import 'add_person_screen.dart';

class DetailScreen extends StatefulWidget {
  final Person person;
  const DetailScreen({super.key, required this.person});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Person currentPerson;
  final db = LocalDatabase();
  final aiService = GeminiService();

  @override
  void initState() {
    super.initState();
    currentPerson = widget.person;
  }

  void _editPerson() async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddPersonScreen(person: currentPerson)));
    if (result == true) {
      setState(() {
        currentPerson =
            db.getAllPersons().firstWhere((p) => p.id == currentPerson.id);
      });
    }
  }

  void _generateAiIdeas() async {
    // Показываем диалог загрузки
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.indigo),
            SizedBox(height: 16),
            Text("ИИ думает над подарками...", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("Обычно это занимает 2-3 секунды"),
          ],
        ),
      ),
    );

    // Делаем запрос к Gemini
    final ideas = await aiService.generateGiftIdeas(currentPerson);

    // Убираем диалог загрузки
    if (mounted) Navigator.pop(context);

    // Показываем диалог с результатами (ИСПРАВЛЕНО ПЕРЕПОЛНЕНИЕ ТЕКСТА)
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.amber),
              const SizedBox(width: 8),
              // Expanded не даст длинному имени вылезти за края экрана!
              Expanded(
                child: Text(
                  'Идеи от ИИ для ${currentPerson.name}',
                  softWrap: true,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Text(
              ideas, 
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Понятно'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : Colors.black87),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).colorScheme.surface;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 280.0,
            pinned: true,
            backgroundColor: currentPerson.avatarColor,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.auto_awesome_outlined,
                    color: Colors.white, size: 28),
                tooltip: 'Сгенерировать идеи подарков',
                onPressed: _generateAiIdeas,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 24.0),
                child: IconButton(
                    icon: const Icon(Icons.edit_rounded,
                        color: Colors.white, size: 28),
                    onPressed: _editPerson),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'avatar_${currentPerson.id}',
                child: Container(
                  color: currentPerson.avatarColor,
                  child: Center(
                    child: Text(
                      currentPerson.name.isNotEmpty
                          ? currentPerson.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                          fontSize: 100,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -30),
              child: Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40)),
                ),
                padding: const EdgeInsets.only(
                    left: 45.0, right: 30.0, top: 120.0, bottom: 40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentPerson.name,
                      style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: textColor),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currentPerson.category,
                      style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontWeight: FontWeight.bold),
                    ),
                    if (currentPerson.phoneNumber != null &&
                        currentPerson.phoneNumber!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.phone,
                              size: 18,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(currentPerson.phoneNumber!,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600])),
                        ],
                      ),
                    ],
                    const SizedBox(height: 50),

                    if (currentPerson.generalGiftIdeas.isNotEmpty) ...[
                      _buildSectionTitle('Что любит, что нравится', isDark),
                      ...currentPerson.generalGiftIdeas.map((idea) => Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.favorite_rounded,
                                    color: Colors.pinkAccent, size: 24),
                                const SizedBox(width: 18),
                                Expanded(
                                  child: Text(idea,
                                      style: TextStyle(
                                          fontSize: 18,
                                          height: 1.5,
                                          color: textColor)),
                                ),
                              ],
                            ),
                          )),
                      const SizedBox(height: 30),
                    ],

                    if (currentPerson.allergies != null &&
                        currentPerson.allergies!.isNotEmpty) ...[
                      _buildSectionTitle('Аллергии / Что не дарить', isDark),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.block,
                              color: Colors.redAccent, size: 24),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Text(currentPerson.allergies!,
                                style: TextStyle(
                                    fontSize: 18,
                                    height: 1.5,
                                    color: textColor)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 50),
                    ],

                    if ((currentPerson.shoeSize?.isNotEmpty ?? false) ||
                        (currentPerson.clothingSize?.isNotEmpty ?? false) ||
                        (currentPerson.ringSize?.isNotEmpty ?? false)) ...[
                      _buildSectionTitle('Размеры', isDark),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: isDark
                              ? []
                              : [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 10)
                                ],
                        ),
                        child: Column(
                          children: [
                            if (currentPerson.shoeSize?.isNotEmpty ?? false)
                              _buildSizeRow(Icons.directions_walk, 'Обувь',
                                  currentPerson.shoeSize!, isDark),
                            if (currentPerson.clothingSize?.isNotEmpty ?? false)
                              _buildSizeRow(Icons.checkroom, 'Одежда',
                                  currentPerson.clothingSize!, isDark),
                            if (currentPerson.ringSize?.isNotEmpty ?? false)
                              _buildSizeRow(Icons.radio_button_unchecked,
                                  'Кольцо', currentPerson.ringSize!, isDark,
                                  isLast: true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],

                    if (currentPerson.holidays.isNotEmpty) ...[
                      _buildSectionTitle('Праздники', isDark),
                      ...currentPerson.holidays.map((holiday) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: isDark
                                ? []
                                : [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 10)
                                  ],
                            border: Border.all(
                                color: currentPerson.avatarColor.withOpacity(0.3),
                                width: 1.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    holiday.name,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: textColor),
                                  ),
                                  if (holiday.date != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: currentPerson.avatarColor
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        DateFormat('dd.MM.yyyy')
                                            .format(holiday.date!),
                                        style: TextStyle(
                                            color: currentPerson.avatarColor,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                ],
                              ),
                              if (holiday.giftIdea != null &&
                                  holiday.giftIdea!.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(Icons.card_giftcard,
                                        color: currentPerson.avatarColor,
                                        size: 20),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        holiday.giftIdea!,
                                        style: TextStyle(
                                            fontSize: 16, color: textColor),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeRow(IconData icon, String label, String value, bool isDark,
      {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[500], size: 24),
          const SizedBox(width: 16),
          Text(label,
              style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.grey[400] : Colors.grey[600])),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87)),
        ],
      ),
    );
  }
}