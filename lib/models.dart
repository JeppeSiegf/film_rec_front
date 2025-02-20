import 'package:flutter/material.dart';

class Film {
  final String pageRef;
  final String imageRef;
  final  String title;
  final int releaseYear;
  final List<String> directors;
  
  

  Film({required this.title, 
        required this.releaseYear, 
        required this.imageRef,
        required this.pageRef,
        required this.directors,});

  @override
  String toString() {
    return '$title ($releaseYear)';
  }

 

  factory Film.fromJson(Map<String, dynamic> json) {
    return Film(
      pageRef: json['page_ref'] as String,
      imageRef: json['image_ref'] as String,
      title: json['title'] as String,
      releaseYear: json['release_year'] as int,
      directors: List<String>.from(json['directors']),
    );
}
}