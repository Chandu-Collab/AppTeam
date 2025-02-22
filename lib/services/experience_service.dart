import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:taurusai/models/experience.dart';

class ExperienceService {
  final String baseUrl;

  ExperienceService({required this.baseUrl});

  Future<List<Experience>> getExperiences() async {
    final response = await http.get(Uri.parse('$baseUrl/experiences'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Experience.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load experiences');
    }
  }

  Future<Experience> getExperienceById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/experiences/$id'));

    if (response.statusCode == 200) {
      return Experience.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load experience');
    }
  }

  Future<void> createExperience(Experience experience) async {
    final response = await http.post(
      Uri.parse('$baseUrl/experiences'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(experience.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create experience');
    }
  }

  Future<void> updateExperience(String id, Experience experience) async {
    final response = await http.put(
      Uri.parse('$baseUrl/experiences/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(experience.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update experience');
    }
  }

  Future<void> deleteExperience(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/experiences/$id'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete experience');
    }
  }
}