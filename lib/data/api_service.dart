import 'dart:convert';

import 'package:http/http.dart' as http;
import '/data/models.dart'; 


class ApiService {
  
  final String apiUrl;

   ApiService()
      : apiUrl = const String.fromEnvironment('API_BASE_URL'); 

  // This method connects to the Flask search endpoint
  Future<List<SearchResult>> searchFilms(String query) async {
   
   
    final url = Uri.parse('$apiUrl/api/films?search_query=$query'); 
    
    final response = await http.get(url);

    if (response.statusCode == 200) {
      
      List data = jsonDecode(response.body);
      
      return data.map((seachData) => SearchResult.fromJson(seachData)).toList();
    } else if (response.statusCode == 404) {
     
      throw Exception('No matching films found');
    } else {
      throw Exception('Failed to search films');
    }
  }

  Future<Film> getFilm(String pageRef) async {
    try {
   
      final response = await http.get(Uri.parse('$apiUrl/api/films/$pageRef'));

      
      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (responseBody.isNotEmpty) {
        return Film.fromJson(responseBody); 
      } else {
        throw Exception('Film not found');
      }
    } catch (error) {
      throw Exception('Failed to load film');
    }
  }




  Future<List<Film>> getFilmography(String crewRef) async {
   if (crewRef.isEmpty) {
    throw Exception("page_ref cannot be empty");
  }

  final url = Uri.parse('$apiUrl/api/films/by?crew_ref=$crewRef');

  
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

Future<List<Film>> getFilmSeries(int series_id) async {
   if (series_id.isNaN) {
    throw Exception("series_id not valied");
  }

  final url = Uri.parse('$apiUrl/api/films/in?series_id=$series_id');

  
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

Future<List<Film>> reccomendFilms(String pageRef) async {
  if (pageRef.isEmpty) {
    throw Exception("page_ref cannot be empty");
  }

  final url = Uri.parse('$apiUrl/api/recommendation?page_ref=$pageRef'); 

  final response = await http.get(url);

  if (response.statusCode == 200) {
    List data = jsonDecode(response.body);
    return data.map((filmData) => Film.fromJson(filmData)).toList();
  } else if (response.statusCode == 404) {
    throw Exception('No matching films found');
  } else {
    throw Exception('Failed to fetch recommendations');
  }
}
}