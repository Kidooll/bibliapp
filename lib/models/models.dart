import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';


class Devotional {
  final String id;
  final String title;
  final String text;
  final String date;

  Devotional({required this.id, required this.title, required this.text, required this.date});

  factory Devotional.fromMap(String id, Map data) {
    return Devotional(
      id: id,
      title: data['title'],
      text: data['text'],
      date: data['date'],
    );
  }
}
