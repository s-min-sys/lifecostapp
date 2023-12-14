import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class NetUtils {
  static String baseUrl = dotenv.env['SERVER_DOMAIN_DEV']!;

  static String? token;

  /// http request methods
  static const String getMethod = 'get';
  static const String postMethod = 'post';

  static reset(String? newToken) {
    token = newToken;
  }

  static Uri getUri(String url, Map<String, dynamic>? parameters) {
    return baseUrl.endsWith('https://')
        ? Uri.https(
            baseUrl.substring(baseUrl.indexOf("://") + 3), url, parameters)
        : Uri.http(
            baseUrl.substring(baseUrl.indexOf("://") + 3), url, parameters);
  }

  ///Get请求
  static void getHttp<T>(
    String url, {
    Map<String, dynamic>? parameters,
    Function(T)? onSuccess,
    Function(String error)? onError,
  }) async {
    try {
      final response = await http.get(
        getUri(url, parameters),
        headers: {
          'Accept': 'application/json,*/*',
          'Content-Type': 'application/json',
          'token': token ?? "",
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> resp =
            json.decode(utf8.decode(response.bodyBytes));
        if (resp['code'] == 0) {
          if (onSuccess != null) {
            onSuccess(resp['resp']);
          }
        } else {
          throw Exception('erroMsg:${resp['message']}');
        }
      } else {
        if (onError != null) {
          onError('${response.statusCode}');
        }
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
    try {
      final response = await http.post(getUri(url, parameters),
          headers: {
            'Accept': 'application/json,*/*',
            'Content-Type': 'application/json',
            'token': token ?? "",
          },
          body: jsonEncode(data));

      if (response.statusCode == 200) {
        Map<String, dynamic> resp =
            json.decode(utf8.decode(response.bodyBytes));
        if (resp['code'] == 0) {
          if (onSuccess != null) {
            onSuccess(resp['resp']);
          }
        } else {
          throw Exception('erroMsg:${resp['message']}');
        }
      } else {
        if (onError != null) {
          onError('${response.statusCode}');
        }
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

    if (method == NetUtils.getMethod) {
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
    } else if (method == NetUtils.postMethod) {
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
}
