import 'package:flutter/material.dart';

class HolidayItem {
  final String name;
  final String? giftIdea;
  final DateTime? date; // ВЕРНУЛИ ДАТУ ДЛЯ КАЛЕНДАРЯ!

  HolidayItem({required this.name, this.giftIdea, this.date});

  factory HolidayItem.fromJson(Map<dynamic, dynamic> json) {
    return HolidayItem(
      name: json['name'] as String? ?? '',
      giftIdea: json['giftIdea'] as String?,
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'giftIdea': giftIdea,
        'date': date?.toIso8601String(),
      };
}

class Person {
  final String id;
  final String name;
  final int colorValue;
  final String category;
  final String? phoneNumber;
  final String? shoeSize;
  final String? ringSize;       
  final String? clothingSize;
  final String? allergies;
  final List<String> generalGiftIdeas; 
  final List<HolidayItem> holidays;
  final String favoriteColor;   

  Person({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.category,
    this.phoneNumber,
    this.shoeSize,
    this.ringSize,
    this.clothingSize,
    this.allergies,
    this.generalGiftIdeas = const [],
    this.holidays = const [],
    this.favoriteColor = '#FF0000',
  });

  Color get avatarColor => Color(colorValue);

  factory Person.fromJson(Map<dynamic, dynamic> json) {
    return Person(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Неизвестно',
      colorValue: json['colorValue'] as int? ?? Colors.grey.value,
      category: json['category'] as String? ?? 'Друзья',
      phoneNumber: json['phoneNumber'] as String?,
      shoeSize: json['shoeSize'] as String?,
      ringSize: json['ringSize'] as String?,
      clothingSize: json['clothingSize'] as String?,
      allergies: json['allergies'] as String?,
      generalGiftIdeas: (json['generalGiftIdeas'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      holidays: (json['holidays'] as List<dynamic>?)
              ?.map((e) => HolidayItem.fromJson(e as Map<dynamic, dynamic>))
              .toList() ??
          const [],
      favoriteColor: json['favoriteColor'] as String? ?? '#FF0000',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'colorValue': colorValue,
        'category': category,
        'phoneNumber': phoneNumber,
        'shoeSize': shoeSize,
        'ringSize': ringSize,
        'clothingSize': clothingSize,
        'allergies': allergies,
        'generalGiftIdeas': generalGiftIdeas,
        'holidays': holidays.map((h) => h.toJson()).toList(),
        'favoriteColor': favoriteColor,
      };
}