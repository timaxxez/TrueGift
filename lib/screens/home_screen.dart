import 'package:flutter/material.dart';
import '../data/local_database.dart';
import '../models/person.dart';
import 'detail_screen.dart';
import 'add_person_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocalDatabase _db = LocalDatabase();
  final TextEditingController _searchController = TextEditingController();
  
  List<Person> _allPersons = [];
  List<Person> _filteredPersons = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    setState(() {
      _allPersons = _db.getAllPersons();
      _allPersons.sort((a, b) => a.name.compareTo(b.name));
      _onSearchChanged();
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredPersons = List.from(_allPersons);
      } else {
        _filteredPersons = _allPersons
            .where((p) => p.name.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  Future<void> _navigateToAddOrEdit([Person? person]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddPersonScreen(person: person)),
    );
    if (result == true) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Проверяем текущую тему
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddOrEdit,
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Добавить',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar.large(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            title: const Text('True Gift', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5)),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Поиск друзей...',
                  prefixIcon: const Icon(Icons.search, color: Colors.indigo),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                ),
              ),
            ),
          ),
          if (_filteredPersons.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_search, size: 64, color: isDark ? Colors.grey[700] : Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      _allPersons.isEmpty ? 'Список пуст' : 'Ничего не найдено',
                      style: TextStyle(fontSize: 18, color: Colors.grey[500], fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100, top: 12),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return _buildPersonCard(_filteredPersons[index], isDark);
                  },
                  childCount: _filteredPersons.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPersonCard(Person person, bool isDark) {
    int totalIdeas = person.generalGiftIdeas.length +
        person.holidays.where((h) => h.giftIdea != null && h.giftIdea!.isNotEmpty).length;

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailScreen(person: person)),
        );
        _loadData();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          // Цвет карточки автоматически меняется (Тёмный/Светлый)
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: isDark ? [] : [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 8)),
          ],
        ),
        child: Row(
          children: [
            Hero(
              tag: 'avatar_${person.id}',
              child: CircleAvatar(
                radius: 30,
                backgroundColor: person.avatarColor.withOpacity(0.15),
                child: Text(
                  person.name.isNotEmpty ? person.name[0].toUpperCase() : '?',
                  style: TextStyle(color: person.avatarColor, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    person.name, 
                    // Текст становится белым в тёмной теме
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87)
                  ),
                  const SizedBox(height: 6),
                  Text(
                    person.category,
                    style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(Icons.card_giftcard, size: 18, color: Colors.amber[600]),
                const SizedBox(height: 4),
                Text(
                  '$totalIdeas записей',
                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}