import 'package:flutter/material.dart';

class roleInfo {
  final IconData icon;
  final int billing;

  roleInfo({required this.icon, this.billing = 0});
}


final Map<String, roleInfo> roleIcons = {
  'actor': roleInfo(icon: Icons.theater_comedy_outlined, billing: 5),
  'producer': roleInfo(icon: Icons.shop_outlined, billing: 4),
  'director': roleInfo(icon: Icons.movie_creation_sharp, billing: 1),
  'co-director': roleInfo(icon: Icons.movie_creation_outlined, billing: 2),

  'writer': roleInfo(icon: Icons.draw, billing: 3),
  'original-writer': roleInfo(icon: Icons.edit_document, billing: 6),
  'story': roleInfo(icon: Icons.menu_book_rounded, billing: 7),

  'casting': roleInfo(icon: Icons.people_alt, billing: 8),
  'editor': roleInfo(icon: Icons.local_movies, billing: 9),
  'cinematography': roleInfo(icon: Icons.yard_rounded, billing: 10),
  'assistant-director': roleInfo(icon: Icons.support_agent, billing: 11),
  'additional-directing': roleInfo(icon: Icons.camera_outdoor, billing: 12),
  'executive-producer': roleInfo(icon: Icons.shop_2_outlined, billing: 13),
  'lighting': roleInfo(icon: Icons.photo_camera_front, billing: 14),
  'camera-operator': roleInfo(icon: Icons.videocam_rounded, billing: 15),
  'additional-photography': roleInfo(icon: Icons.videocam_sharp, billing: 16),


  'production-design': roleInfo(icon: Icons.design_services_rounded, billing: 17),
  'art-direction': roleInfo(icon: Icons.queue_music_rounded, billing: 18),
  'set-decoration': roleInfo(icon: Icons.chair_alt_rounded, billing: 19),
  'visual-effects': roleInfo(icon: Icons.volume_up_rounded, billing: 20),
  'title-design': roleInfo(icon: Icons.subtitles_outlined, billing: 21),

  'choreography': roleInfo(icon: Icons.directions_run_rounded, billing: 22),
  'stunts': roleInfo(icon: Icons.face_retouching_natural_outlined, billing: 23),

  'composer': roleInfo(icon: Icons.light_mode_outlined, billing: 24),
  'songs': roleInfo(icon: Icons.music_note_sharp, billing: 25),
  'special-effects': roleInfo(icon: Icons.auto_awesome_sharp, billing: 26),
  'sound': roleInfo(icon: Icons.palette, billing: 27),

  'costume-design': roleInfo(icon: Icons.motorcycle_sharp, billing: 28),
  'makeup': roleInfo(icon: Icons.display_settings, billing: 29),
  'hairstyling': roleInfo(icon: Icons.sports_gymnastics_rounded, billing: 30)

};

// Sorting icons map - removing const to match roleIcons pattern

final Map<String, roleInfo> sortingIcons = {
  "Popularity": roleInfo(icon: Icons.stars),
  "Alphabetical": roleInfo(icon: Icons.sort_by_alpha),
  "Rating": roleInfo(icon: Icons.thumbs_up_down_sharp),
  "Release Year": roleInfo(icon: Icons.date_range),
};