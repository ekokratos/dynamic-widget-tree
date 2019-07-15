import 'package:retrofit/http.dart';
import 'package:dio/dio.dart';

part 'retro_api.g.dart';

@RestApi(baseUrl: "https://jsonplaceholder.typicode.com/")
abstract class RestClient {
  factory RestClient([Dio dio]) = _RestClient;

  @GET("/posts")
  Future<Response<String>> ip(@Query('userId') String query);

  @GET("/profile/{id}")
  Future<Response<String>> profile(@Path("id") String id,
      {@Query("role") String role = "user",
      @Queries() Map<String, dynamic> map = const {},
      @Body() Map<String, dynamic> map2});
}
