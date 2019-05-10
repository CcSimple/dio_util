import 'package:flutter_test/flutter_test.dart';
import 'package:dio_util/dio_util.dart';

class TestEntity {
  String first;
  String second;

  TestEntity({this.first, this.second});

  TestEntity.fromJson(Map<String, dynamic> json) {
    first = json['first'];
    second = json['second'];
  }
  /// 手动实现  或者 使用 FlutterJsonBeanFactory 插件生成 EntityFactory
  /// 见下方
  static T generateOBJ<T>(json) {
    return TestEntity.fromJson(json) as T;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['first'] = this.first;
    data['second'] = this.second;
    return data;
  }
}

class Test2Entity {
  String third;
  String fourth;

  Test2Entity({this.third, this.fourth});

  Test2Entity.fromJson(Map<String, dynamic> json) {
    third = json['third'];
    fourth = json['fourth'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['third'] = this.third;
    data['fourth'] = this.fourth;
    return data;
  }
}
// 使用 FlutterJsonBeanFactory 插件生成
// https://github.com/zhangruiyu/FlutterJsonBeanFactory
class EntityFactory {
  static T generateOBJ<T>(json) {
    if (1 == 0) {
      return null;
    } else if (T.toString() == "TestEntity") {
      return TestEntity.fromJson(json) as T;
    } else if (T.toString() == "Test2Entity") {
      return Test2Entity.fromJson(json) as T;
    } else {
      return null;
    }
  }
}

void main() {
  /// 手动实现 类似 generateOBJ 方法
  test('util test(简单测试)', () async {
    BaseResp<TestEntity> res = await DioUtil().request<TestEntity>(
        get,
        'https://raw.githubusercontent.com/CcSimple/dio_util/master/json/base.json',
        BaseProcessor(false,fun: TestEntity.generateOBJ));
    print('----------------------------------');
    print('status: ${res.status}');
    print('code: ${res.code}');
    print('msg: ${res.msg}');
    print('data: ${res.data}');
    print('first: ${res.data.first}');
    print('second: ${res.data.second}');
    print('----------------------------------');
  });
  /// EntityFactory 自动处理
  test('util test EntityFactory(测试对象生成方法)', () async {
    BaseResp<Test2Entity> res = await DioUtil().request<Test2Entity>(
        get,
        'https://raw.githubusercontent.com/CcSimple/dio_util/master/json/base2.json',
        BaseProcessor(false,fun: EntityFactory.generateOBJ));
    print('----------------------------------');
    print('status: ${res.status}');
    print('code: ${res.code}');
    print('msg: ${res.msg}');
    print('data: ${res.data}');
    print('third: ${res.data.third}');
    print('fourth: ${res.data.fourth}');
    print('----------------------------------');
  });
  /// EntityFactory 自动处理
  test('util test list EntityFactory(测试List对象生成方法)', () async {
    BaseRespList<TestEntity> res = await DioUtil().request<TestEntity>(
        get,
        'https://raw.githubusercontent.com/CcSimple/dio_util/master/json/list.json',
        BaseProcessor(true, fun: EntityFactory.generateOBJ));
    print('----------------------------------');
    print('status: ${res.status}');
    print('code: ${res.code}');
    print('msg: ${res.msg}');
    print('data: ${res.data}');
    print('first: ${res.data.elementAt(0).first}');
    print('second: ${res.data.elementAt(0).second}');
    print('----------------------------------');
  });
}
