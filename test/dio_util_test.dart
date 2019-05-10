import 'package:flutter_test/flutter_test.dart';
import 'package:dio_util/dio_util.dart';

void main() {
  test('util test', () async  {
    await DioUtil().request(get, '', BaseProcessor(false));
  });
}
