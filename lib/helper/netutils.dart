import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:lifecostapp/components/global.dart';

class NetUtils {
  static String? token;

  /// http request methods
  static const String getMethod = 'get';
  static const String postMethod = 'post';

  static reset(String? newToken) {
    token = newToken;
  }

  static Uri getUri(String url, Map<String, dynamic>? parameters) {
    String baseUrl = Global.devMode
        ? dotenv.env['SERVER_DOMAIN_DEV']!
        : dotenv.env['SERVER_DOMAIN']!;
    return baseUrl.startsWith('https://')
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
    Function(int code, String msg, T resp)? onResult,
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
        if (resp['code'] < 100) {
          if (onSuccess != null && resp['code'] == 0) {
            onSuccess(resp['resp']);
          } else {
            throw Exception('erroMsg:${resp['message']}');
          }

          if (onResult != null) {
            onResult(resp['code'], resp['message'] as String, resp['resp']);
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
    Function(int code, String msg, T resp)? onResult,
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
        if (resp['code'] < 100) {
          if (onSuccess != null && resp['code'] == 0) {
            onSuccess(resp['resp']);
          } else {
            throw Exception('${resp['message']}');
          }

          if (onResult != null) {
            onResult(resp['code'], resp['message'] as String, resp['resp']);
          }
        } else {
          throw Exception('${resp['message']}');
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
      Function(int code, String msg, dynamic resp)? onResult,
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
        onResult: (code, msg, data) {
          if (onResult != null) {
            onResult(code, msg, data);
          }
        },
        onError: (error) {
          if (onError != null) {
            if (error.startsWith('Exception:')) {
              error = error.substring('Exception:'.length);
            }
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
        onResult: (code, msg, data) {
          if (onResult != null) {
            onResult(code, msg, data);
          }
        },
        onError: (error) {
          if (onError != null) {
            if (error.startsWith('Exception:')) {
              error = error.substring('Exception:'.length);
            }
            onError(error);
          }
        },
      );
    }
  }
}
