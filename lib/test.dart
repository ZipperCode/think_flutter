import 'dart:math';

void main() {
  Random random = Random();
  // print(random.nextDouble());
  // print(random.nextDouble() * 100);
  var i = 0;
  while (i < 100) {
    print(random.nextDouble() * -10);
  }
}

void listenWithPause() {
  int count = 0;
  int t = 0;
  // ignore: cancel_subscriptions
  var counterStream = Stream.periodic(const Duration(minutes: 1)).listen((event) {
    print(count++);
  });
  // ignore: cancel_subscriptions
  var time = Stream.periodic(const Duration(seconds: 1)).listen((event) {
    print("time = ${t++}");
  });

  Future.delayed(Duration(seconds: 45)).then((value) {
    print("pause");
    counterStream.pause();
  });

  Future.delayed(Duration(seconds: 50)).then((value) {
    print("resume");
    counterStream.resume();
  });
}
