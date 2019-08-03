import 'package:retrofit/http.dart';
import 'package:dio/dio.dart';

part 'generate_api.g.dart';

@RestApi(baseUrl: "https://shreyasbaliga.github.io/HelloBootstrap/")
abstract class RestClient {
  factory RestClient([Dio dio]) = _RestClient;

  @GET("/manifest.json")
  Future<Response<String>> profile({@Body() Map<String, dynamic> map2});
}
