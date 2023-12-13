import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DioUtils {
  /// global dio object
  static Dio? dio;

  static String? token;

  /// http request methods
  static const String getMethod = 'get';
  static const String postMethod = 'post';

  static Dio createInstance() {
    if (dio == null) {
      var options = BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          responseType: ResponseType.json,
          validateStatus: (status) {
            // 不使用http状态码判断状态，使用AdapterInterceptor来处理（适用于标准REST风格）
            return true;
          },
          baseUrl: dotenv.env['SERVER_DOMAIN_DEV'] ?? '',
          headers: httpHeaders);

      dio = Dio(options);
    }

    return dio!;
  }

  static reset(String? newToken) {
    token = newToken;
    dio = null;
  }

  ///Get请求
  static void getHttp<T>(
    String url, {
    Map<String, dynamic>? parameters,
    Function(T)? onSuccess,
    Function(String error)? onError,
  }) async {
    parameters = parameters ?? {};
    parameters.forEach((key, value) {
      if (url.contains(key)) {
        url = url.replaceAll(':$key', value.toString());
      }
    });

    try {
      Response response;
      Dio dio = createInstance();
      response = await dio.get(url, queryParameters: parameters);
      var responseData = response.data;
      if (responseData['code'] == 0) {
        if (onSuccess != null) {
          onSuccess(responseData['resp']);
        }
      } else {
        throw Exception('erroMsg:${responseData['message']}');
      }
    } catch (e) {
      if (onError != null) {
        onError(e.toString());
      }
    }
  }

  static void postHttp<T>(
    String url, {
    Map<String, dynamic>? parameters,
    Object? data,
    Function(T)? onSuccess,
    Function(String error)? onError,
  }) async {
    parameters = parameters ?? {};
    parameters.forEach((key, value) {
      if (url.contains(key)) {
        url = url.replaceAll(':$key', value.toString());
      }
    });

    try {
      Response response;
      Dio dio = createInstance();
      response = await dio.post(url, queryParameters: parameters, data: data);
      var responseData = response.data;
      if (responseData['code'] == 0) {
        if (onSuccess != null) {
          onSuccess(responseData['resp']);
        }
      } else {
        throw Exception('erroMsg:${responseData['message']}');
      }
    } catch (e) {
      if (onError != null) {
        onError(e.toString());
      }
    }
  }

  static void requestHttp<T>(String url,
      {Map<String, dynamic>? parameters,
      Object? data,
      method,
      Function(dynamic)? onSuccess,
      Function(String error)? onError}) async {
    parameters = parameters ?? {};
    method = method ?? 'GET';

    if (method == DioUtils.getMethod) {
      getHttp(
        url,
        parameters: parameters,
        onSuccess: (data) {
          if (onSuccess != null) {
            onSuccess(data);
          }
        },
        onError: (error) {
          if (onError != null) {
            onError(error);
          }
        },
      );
    } else if (method == DioUtils.postMethod) {
      postHttp(
        url,
        parameters: parameters,
        data: data,
        onSuccess: (data) {
          if (onSuccess != null) {
            onSuccess(data);
          }
        },
        onError: (error) {
          if (onError != null) {
            onError(error);
          }
        },
      );
    }
  }

  /// 自定义Header
  static Map<String, dynamic> httpHeaders = {
    'Accept': 'application/json,*/*',
    'Content-Type': 'application/json',
    'token': token,
  };
}
