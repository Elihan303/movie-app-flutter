import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final Dio _dio = Dio();

  ApiService() {
    dotenv.load(fileName: ".env");
    _dio.options.baseUrl = 'https://api.themoviedb.org/3/movie/';
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 3);

    // Agrega un interceptor para incluir la API key en todas las solicitudes
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Agrega la API key como parámetro de consulta
        options.queryParameters['language'] = 'es-ES';
        options.queryParameters['api_key'] = dotenv.env['API_KEY'];
        return handler.next(options); // Continúa con la solicitud
      },
      onResponse: (response, handler) {
        // Maneja la respuesta
        return handler.next(response); // Continúa con la respuesta
      },
      onError: (DioException e, handler) {
        // Maneja los errores
        return handler.next(e); // Continúa con el error
      },
    ));
  }

  // Ejemplo de método GET
  Future<Response> getMovies(String endpoint,
      {Map<String, dynamic>? params}) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: params);
      return response;
    } on DioException {
      // Maneja el error
      rethrow;
    }
  }
}
