import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

// https://github.com/flutterchina/dio/blob/master/README-ZH.md#%E8%BD%AC%E6%8D%A2%E5%99%A8
class MyTransformer extends DefaultTransformer {
  MyTransformer() : super(jsonDecodeCallback: _parseJson);
}

_parseAndDecode(String response) {
  return jsonDecode(response);
}

_parseJson(String text) {
  return compute(_parseAndDecode, text);
}
