import 'package:dio/dio.dart';

class ApiProvider{
late Dio _dio;

String a_token = "";

final BaseOptions options = BaseOptions(
  baseUrl: 'https://5ff0-102-219-208-154.ngrok-free.app',
  connectTimeout: Duration(milliseconds: 15000),
  receiveTimeout: Duration(milliseconds: 13000),
);
static final ApiProvider _instance = ApiProvider._internal();

factory ApiProvider() => _instance;

ApiProvider._internal() {
  _dio = Dio(options);
  _dio.interceptors.add(InterceptorsWrapper(

  ));
}


}