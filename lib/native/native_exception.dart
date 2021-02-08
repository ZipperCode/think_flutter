class NativeException {
  int code;

  String message;

  dynamic data;

  NativeException({this.code = 0, this.message = '未知错误', this.data});
}
