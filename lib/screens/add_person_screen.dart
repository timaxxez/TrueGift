import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import '../models/person.dart';
import '../data/local_database.dart';

class HolidayFieldController {
  final TextEditingController nameCtrl;
  final TextEditingController giftCtrl;
  DateTime? date;

  HolidayFieldController({String name = '', String gift = '', this.date})
      : nameCtrl = TextEditingController(text: name),
        giftCtrl = TextEditingController(text: gift);

  void dispose() {
    nameCtrl.dispose();
    giftCtrl.dispose();
  }
}

class AddPersonScreen extends StatefulWidget {
  final Person? person;
  const AddPersonScreen({super.key, this.person});

  @override
  State<AddPersonScreen> createState() => _AddPersonScreenState();
}

class _AddPersonScreenState extends State<AddPersonScreen> {
  final _formKey = GlobalKey<FormState>();
  final LocalDatabase _db = LocalDatabase();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _shoeController;
  late final TextEditingController _ringController; 
  late final TextEditingController _clothesController;
  late final TextEditingController _allergiesController; 
  late final TextEditingController _generalIdeasController;
  
  final List<HolidayFieldController> _holidayControllers = [];

  static const List<String> _categories = ['Семья', 'Коллеги', 'Родственники', 'Друзья', 'Одногруппники'];
  
  late String _selectedCategory;
  late Color _avatarColor;
  late String _favoriteColorStr; 

  @override
  void initState() {
    super.initState();
    final p = widget.person;
    _nameController = TextEditingController(text: p?.name ?? '');
    _phoneController = TextEditingController(text: p?.phoneNumber ?? ''); 
    _shoeController = TextEditingController(text: p?.shoeSize ?? '');
    _ringController = TextEditingController(text: p?.ringSize ?? ''); 
    _clothesController = TextEditingController(text: p?.clothingSize ?? '');
    _allergiesController = TextEditingController(text: p?.allergies ?? ''); 
    _generalIdeasController = TextEditingController(text: p?.generalGiftIdeas.join(', ') ?? '');
    
    _selectedCategory = p?.category ?? _categories.first;
    _avatarColor = p?.avatarColor ?? _getRandomColor();
    _favoriteColorStr = p?.favoriteColor ?? '#FF0000'; 

    if (p != null && p.holidays.isNotEmpty) {
      for (var holiday in p.holidays) {
        _holidayControllers.add(HolidayFieldController(
          name: holiday.name, 
          gift: holiday.giftIdea ?? '',
          date: holiday.date
        ));
      }
    }
  }

  Color _getRandomColor() {
    final colors = [const Color(0xFFEF4444), const Color(0xFF3B82F6), const Color(0xFF10B981), const Color(0xFFF59E0B), const Color(0xFF8B5CF6), const Color(0xFF14B8A6)];
    return colors[Random().nextInt(colors.length)];
  }

  Future<void> _selectDate(HolidayFieldController hc) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: hc.date ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => hc.date = picked);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _shoeController.dispose();
    _ringController.dispose();
    _clothesController.dispose();
    _allergiesController.dispose();
    _generalIdeasController.dispose();
    for (var hc in _holidayControllers) { hc.dispose(); }
    super.dispose();
  }

  Future<void> _savePerson() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final generalIdeas = _generalIdeasController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        
    final holidaysList = _holidayControllers.where((hc) => hc.nameCtrl.text.trim().isNotEmpty).map((hc) => HolidayItem(
      name: hc.nameCtrl.text.trim(),
      giftIdea: hc.giftCtrl.text.trim().isNotEmpty ? hc.giftCtrl.text.trim() : null,
      date: hc.date,
    )).toList();

    final savedPerson = Person(
      id: widget.person?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      colorValue: _avatarColor.value,
      category: _selectedCategory,
      phoneNumber: _phoneController.text.trim(),
      shoeSize: _shoeController.text.trim(),
      ringSize: _ringController.text.trim(),
      clothingSize: _clothesController.text.trim(),
      allergies: _allergiesController.text.trim(),
      generalGiftIdeas: generalIdeas,
      holidays: holidaysList,
      favoriteColor: _favoriteColorStr,
    );

    await _db.savePerson(savedPerson);
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _deletePerson() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить профиль?'),
        content: const Text('Вы уверены, что хотите удалить этого человека? Это действие нельзя отменить.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Удалить', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (shouldDelete == true && widget.person != null && mounted) {
      await _db.deletePerson(widget.person!.id);
      Navigator.pop(context, true); // Закрываем экран редактирования
      Navigator.pop(context, true); // Закрываем экран деталей (DetailScreen)
    }
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    // Проверяем, какая сейчас тема, чтобы правильно красить текст
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface, // Автоматически меняется в тёмной теме
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title, 
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87 // Белый текст для тёмной темы
              )
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.person != null;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Автоматически подтягивает фон из темы
      appBar: AppBar(
        title: Text(isEditing ? 'Редактирование' : 'Новая карточка', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(onPressed: _savePerson, child: const Text('Готово', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildSectionCard(
                title: 'Основная информация',
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Имя и Фамилия', prefixIcon: Icon(Icons.badge_outlined)),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Введите имя' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Телефон', prefixIcon: Icon(Icons.phone_outlined))),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: const InputDecoration(labelText: 'Категория', prefixIcon: Icon(Icons.folder_outlined)),
                      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) { if (val != null) setState(() => _selectedCategory = val); },
                    ),
                  ],
                ),
              ),
              _buildSectionCard(
                title: 'Размеры (Необязательно)',
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: TextFormField(controller: _shoeController, decoration: const InputDecoration(labelText: 'Обувь', prefixIcon: Icon(Icons.directions_walk)))),
                        const SizedBox(width: 12),
                        Expanded(child: TextFormField(controller: _clothesController, decoration: const InputDecoration(labelText: 'Одежда', prefixIcon: Icon(Icons.checkroom)))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(controller: _ringController, decoration: const InputDecoration(labelText: 'Размер кольца', prefixIcon: Icon(Icons.radio_button_unchecked))),
                  ],
                ),
              ),
              _buildSectionCard(
                title: 'Детали профиля',
                child: Column(
                  children: [
                    TextFormField(
                      controller: _generalIdeasController,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Что любит, что нравится (через запятую)', prefixIcon: Padding(padding: EdgeInsets.only(bottom: 24), child: Icon(Icons.favorite_border))),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(controller: _allergiesController, decoration: const InputDecoration(labelText: 'Аллергии / Что не дарить', prefixIcon: Icon(Icons.block, color: Colors.redAccent))),
                  ],
                ),
              ),
              _buildSectionCard(
                title: 'Праздники',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_holidayControllers.isEmpty) Text('Пока нет праздников', style: TextStyle(color: Colors.grey[500])),
                    ..._holidayControllers.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final hc = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor, // Поля праздников тоже адаптируются
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.withOpacity(0.2)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(child: TextFormField(controller: hc.nameCtrl, decoration: const InputDecoration(labelText: 'Название (напр. Новый год)'))),
                                IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: () => setState(() { _holidayControllers[idx].dispose(); _holidayControllers.removeAt(idx); })),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.calendar_month, color: Colors.indigo),
                              title: Text(hc.date == null ? 'Выбрать дату' : DateFormat('dd.MM.yyyy').format(hc.date!), style: const TextStyle(fontWeight: FontWeight.bold)),
                              trailing: const Icon(Icons.edit, size: 16),
                              onTap: () => _selectDate(hc),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(controller: hc.giftCtrl, decoration: const InputDecoration(labelText: 'Что подарить?', prefixIcon: Icon(Icons.card_giftcard))),
                          ],
                        ),
                      );
                    }),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Center(
                        child: TextButton.icon(
                          onPressed: () => setState(() => _holidayControllers.add(HolidayFieldController())),
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('Добавить праздник'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // ЯВНАЯ КНОПКА УДАЛЕНИЯ В САМОМ НИЗУ (появляется только при редактировании)
              if (isEditing)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 10, bottom: 40),
                  child: ElevatedButton.icon(
                    onPressed: _deletePerson,
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    label: const Text('УДАЛИТЬ КАРТОЧКУ', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              
              if (!isEditing) const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}