import 'package:flutter/material.dart';


class Devotional {
  final String id;
  final String title;
  final String text;
  final String date;

  Devotional({required this.id, required this.title, required this.text, required this.date});

  factory Devotional.fromMap(Map<String, dynamic> data) {
    return Devotional(
      id: data['id'].toString(),
      title: data['title'] ?? '',
      text: data['text'] ?? '',
      date: data['date'] ?? '',
    );
  }
}
