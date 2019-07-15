// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'retro_api.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

class _RestClient implements RestClient {
  _RestClient([this._dio]) {
    ArgumentError.checkNotNull(_dio, '_dio');
    _dio.options.baseUrl = 'https://jsonplaceholder.typicode.com/';
  }

  final Dio _dio;

  @override
  ip(query) async {
    ArgumentError.checkNotNull(query, 'query');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{'userId': query};
    const _data = null;
    return _dio.request('/posts',
        queryParameters: queryParameters,
        options: RequestOptions(method: 'GET', headers: {}, extra: _extra),
        data: _data);
  }

  @override
  profile(id, {role = "user", map = const {}, map2}) async {
    ArgumentError.checkNotNull(id, 'id');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{'role': role};
    queryParameters.addAll(map ?? {});
    final _data = <String, dynamic>{};
    _data.addAll(map2 ?? {});
    return _dio.request('/profile/$id',
        queryParameters: queryParameters,
        options: RequestOptions(method: 'GET', headers: {}, extra: _extra),
        data: _data);
  }
}
