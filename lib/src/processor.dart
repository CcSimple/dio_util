import 'dart:convert';
import 'package:dio/dio.dart';

/// 对象生成方法
typedef ObjGenerateFun<T> = T Function(Map<String, dynamic>);

/// 数据处理器
abstract class Processor<T> {
  Processor(this.isList, {this.objGenerateFun});
  bool isList;
  ObjGenerateFun<T> objGenerateFun;
  // 成功数据处理
  success(Response response) => response;
  // 失败数据处理
  failed(DioError err) => err;
}

/// 定义 普通数据格式
class BaseResp<T> {
  int status;
  int code;
  String msg;
  T data;
  BaseResp(this.status, this.code, this.msg, this.data);

  String toString() {
    StringBuffer sb = new StringBuffer('{');
    sb.write("\"status\":\"$status\"");
    sb.write(",\"code\":$code");
    sb.write(",\"msg\":\"$msg\"");
    sb.write(",\"data\":\"$data\"");
    sb.write('}');
    return sb.toString();
  }
}

/// 定义 List数据格式
class BaseRespList<T> {
  int status;
  int code;
  String msg;
  List<T> data;
  BaseRespList(this.status, this.code, this.msg, this.data);

  @override
  String toString() {
    StringBuffer sb = new StringBuffer('{');
    sb.write("\"status\":\"$status\"");
    sb.write(",\"code\":$code");
    sb.write(",\"msg\":\"$msg\"");
    sb.write(",\"data\":\"$data\"");
    sb.write('}');
    return sb.toString();
  }
}

/// 实现默认处理器
class BaseProcessor<T> extends Processor<T> {
  BaseProcessor(bool isList, {ObjGenerateFun<T> fun})
      : super(isList, objGenerateFun: fun);

  @override
  ObjGenerateFun<T> get objGenerateFun => super.objGenerateFun;

  // 转换json
  Map<String, dynamic> decodeData(Response response) {
    if (response == null ||
        response.data == null ||
        response.data.toString().isEmpty) {
      return new Map();
    }
    return json.decode(response.data.toString());
  }

  @override
  success(Response response) {
    int _status = response.statusCode;
    int _code;
    String _msg;
    // List数据处理 [{...},{...}]
    if (isList) {
      List<T> _data = new List<T>();
      if (response.data is Map) {
        _code = response.data['code'];
        _msg = response.data['msg'];
        if (T.toString() == 'dynamic') {
          _data = response.data['data'];
        } else {
          if (response.data['data'] != null) {
            _data = (response.data['data'] as List)
                .map<T>((v) => objGenerateFun(v))
                .toList();
          }
        }
      } else {
        Map<String, dynamic> _dataMap = decodeData(response);
        _code = _dataMap['code'];
        _msg = _dataMap['msg'];
        if (T.toString() == 'dynamic') {
          _data = _dataMap['data'];
        } else {
          if (objGenerateFun == null) {
            throw Exception('you need add ObjGenerateFun or remove T');
          }
          if (_dataMap['data'] != null) {
            _data = (_dataMap['data'] as List)
                .map<T>((v) => objGenerateFun(v))
                .toList();
          }
        }
      }
      return BaseRespList(_status, _code, _msg, _data);
    } else {
      // 普通数据处理 {...}
      T _data;
      if (response.data is Map) {
        _code = response.data['code'];
        _msg = response.data['msg'];
        if (T.toString() == 'dynamic') {
          _data = response.data['data'];
        } else {
          _data = objGenerateFun(response.data['data']);
        }
      } else {
        Map<String, dynamic> _dataMap = decodeData(response);
        _code = _dataMap['code'];
        _msg = _dataMap['msg'];
        if (T.toString() == 'dynamic') {
          _data = _dataMap['data'];
        } else {
          _data = objGenerateFun(_dataMap['data']);
        }
      }
      return BaseResp(_status, _code, _msg, _data);
    }
  }

  @override
  failed(DioError err) {
    int _status = err.response.statusCode;
    String _msg = err.message;
    if (isList) {
      return BaseRespList(_status, -1, _msg, <T>[]);
    }
    return BaseResp(_status, -1, _msg, null);
  }
}
