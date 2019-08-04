// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generate_api.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

class _RestClient implements RestClient {
  _RestClient([this._dio]) {
    ArgumentError.checkNotNull(_dio, '_dio');
    _dio.options.baseUrl = 'https://shreyasbaliga.github.io/HelloBootstrap/';
  }

  final Dio _dio;

  @override
  profile({map2}) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(map2 ?? {});
    return _dio.request('/manifest.json',
        queryParameters: queryParameters,
        options: RequestOptions(method: 'GET', headers: {}, extra: _extra),
        data: _data);
  }
}
