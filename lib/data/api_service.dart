import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '/data/models.dart'; 


class ApiService {
  
  final String? apiUrl;

  ApiService() : apiUrl = dotenv.env['API_URL'];

 
  // This method connects to the Flask search endpoint
  Future<List<Film>> searchFilms(String query) async {
   
    
    final url = Uri.parse('$apiUrl/api/films?search_query=$query'); 

    final response = await http.get(url);

    if (response.statusCode == 200) {
      
      List data = jsonDecode(response.body);
      
      return data.map((filmData) => Film.fromJson(filmData)).toList();
    } else if (response.statusCode == 404) {
     
      throw Exception('No matching films found');
    } else {
      throw Exception('Failed to search films');
    }
  }

  Future<List<Film>> getFilmography(String directorRef) async {
  final url = Uri.parse('$apiUrl/api/films/dir?director_ref=$directorRef'); 

  
  final response = await http.get(url);

  if (response.statusCode == 200) {
    
    List data = jsonDecode(response.body);
    
    
    return data.map((filmData) => Film.fromJson(filmData)).toList();
  } else if (response.statusCode == 404) {
 
    throw Exception('No matching films found');
  } else {
   
    throw Exception('Failed to search films');
  }
}

  
  Future<List<Film>> reccomendFilms(String page_ref) async {
   
    final url = Uri.parse('$apiUrl/api/recommendation?page_ref=$page_ref'); 

    final response = await http.get(url);

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((filmData) => Film.fromJson(filmData)).toList();
    } else if (response.statusCode == 404) {
      throw Exception('No matching films found');
    } else {
      throw Exception('Failed to search films');
    }
  }
}
