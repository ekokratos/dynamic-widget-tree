import 'package:retrofit/http.dart';
import 'package:dio/dio.dart';

part 'dynamic_page_demo.g.dart';

@RestApi(baseUrl: "https://shreyasbaliga.github.io/HelloBootstrap/")
abstract class RestClient {
  factory RestClient([Dio dio]) = _RestClient;

//  @GET("/posts")
//  Future<Response<String>> ip(@Query('type') String query);

  @GET("/manifest.json")
  Future<Response<String>> profile({@Body() Map<String, dynamic> map2});
}
