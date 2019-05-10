import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';

class MyInterceptor extends Interceptor {
  bool isDebug;

  MyInterceptor(this.isDebug);

  @override
  onRequest(RequestOptions options) {
    return options;
  }

  @override
  onResponse(Response response) {
    return response;
  }

  Map<String, dynamic> _decodeData(Response response) {
    if (response == null ||
        response.data == null ||
        response.data.toString().isEmpty) {
      return new Map();
    }
    return json.decode(response.data.toString());
  }

  @override
  onError(DioError err) {
    try {
      String message = err.message;
      switch (err.response.statusCode) {
        case HttpStatus.badRequest: // 400
          err.response.data = _decodeData(err.response);
          message = err.response.data['msg'] ?? '请求失败，请联系我们';
          break;
        case HttpStatus.unauthorized: // 401
          err.response.data = _decodeData(err.response);
          message = err.response.data['msg'] ?? '未授权，请登录';
          break;
        case HttpStatus.forbidden: // 403
          message = '拒绝访问';
          break;
        case HttpStatus.notFound: // 404
          message = '请求地址出错';
          break;
        case HttpStatus.requestTimeout: // 408
          message = '请求超时';
          break;
        case HttpStatus.internalServerError: // 500
          message = '服务器内部错误';
          break;
        case HttpStatus.notImplemented: // 501
          message = '服务未实现';
          break;
        case HttpStatus.badGateway: // 502
          message = '网关错误';
          break;
        case HttpStatus.serviceUnavailable: // 503
          message = '服务不可用';
          break;
        case HttpStatus.gatewayTimeout: // 504
          message = '网关超时';
          break;
      }
      err.message = message;
      return err;
    } on TypeError {
      err.message = '信息转换错误';
      return err;
    } catch (e) {
      err.message = '未知错误';
      return err;
    }
  }
}
