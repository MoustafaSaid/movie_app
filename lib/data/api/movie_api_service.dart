import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/movie_response_model.dart';

part 'movie_api_service.g.dart';

@RestApi()
abstract class MovieApiService {
  factory MovieApiService(Dio dio, {String baseUrl}) = _MovieApiService;

  @GET('/movie/top_rated')
  Future<MovieResponseModel> getTopRatedMovies(@Query('page') int page);
}
