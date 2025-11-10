// Lokasi File: lib/services/unsplash_service.dart

import 'package:dio/dio.dart';
import 'package:project_akhir/config.dart';
import 'package:project_akhir/models/photo_model.dart';

class UnsplashService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.unsplash.com/',
      headers: {
        'Authorization': 'Client-ID ${Config.unsplashAccessKey}',
      },
    ),
  );

  // --- Fungsi Get New Photos (Beranda & Ide) ---
  Future<List<Photo>> getNewPhotos(int page) async {
    try {
      final response = await _dio.get(
        '/photos',
        queryParameters: {
          'page': page,
          'per_page': 20,
          'order_by': 'latest',
        },
      );
      List<Photo> photos = (response.data as List)
          .map((item) => Photo.fromJson(item))
          .toList();
      return photos;
    } on DioException catch (e) {
      print('Error fetching photos: $e');
      throw Exception('Failed to load photos');
    }
  }

  // --- Fungsi Search Photos ---
  Future<List<Photo>> searchPhotos(String query, int page) async {
    try {
      final response = await _dio.get(
        '/search/photos',
        queryParameters: {
          'query': query,
          'page': page,
          'per_page': 20,
        },
      );
      List<Photo> photos = (response.data['results'] as List)
          .map((item) => Photo.fromJson(item))
          .toList();
      return photos;
    } on DioException catch (e) {
      print('Error searching photos: $e');
      throw Exception('Failed to search photos');
    }
  }

  // --- Fungsi Get Popular Photos (Carousel) ---
  Future<List<Photo>> getPopularPhotos() async {
    try {
      final response = await _dio.get(
        '/photos',
        queryParameters: {
          'page': 1,
          'per_page': 5,
          'order_by': 'popular',
        },
      );
      List<Photo> photos = (response.data as List)
          .map((item) => Photo.fromJson(item))
          .toList();
      return photos;
    } on DioException catch (e) {
      print('Error fetching popular photos: $e');
      throw Exception('Failed to load popular photos');
    }
  }
  // Fungsi untuk mengambil foto serupa/terkait
  Future<List<Photo>> getRelatedPhotos(String photoId) async {
    try {
      // Panggil endpoint /photos/:id/related
      final response = await _dio.get('/photos/$photoId/related');

      // Endpoint ini mengembalikan data di dalam key 'results'
      List<Photo> photos = (response.data['results'] as List)
          .map((item) => Photo.fromJson(item))
          .toList();
      return photos;
    } on DioException catch (e) {
      print('Error fetching related photos: $e');
      throw Exception('Failed to load related photos');
    }
  }
}