import 'package:flutter/material.dart';

final Map<String, IconData> roleIcons = {
  'actor': Icons.theater_comedy_outlined,
  'director': Icons.movie_creation_sharp,
  'writer': Icons.draw,
  'producer': Icons.shop_outlined,
  'editor': Icons.local_movies,
  'cinematography': Icons.yard_rounded,
  'camera-operator': Icons.photo_camera_front,
  'production-design': Icons.design_services_rounded,
  'composer': Icons.queue_music_rounded,
  'sound': Icons.volume_up_rounded,
  'makeup': Icons.face_retouching_natural_outlined,
  'lighting': Icons.light_mode_outlined,
  'special-effects': Icons.auto_awesome_sharp,
  'art-direction': Icons.palette,
  'stunts': Icons.motorcycle_sharp,
  'executive-producer': Icons.shop_2_outlined,
  'visual-effects': Icons.display_settings,
  'casting': Icons.people_alt,
  'choreography': Icons.sports_gymnastics_rounded,
  'songs': Icons.music_note_sharp,
  'title-design': Icons.subtitles_outlined,
};

// Sorting icons map - removing const to match roleIcons pattern
final Map<String, IconData> sortingIcons = {
  "Popularity": Icons.stars,
  "Alphabetical": Icons.sort_by_alpha,
  "Release Year": Icons.date_range,
};