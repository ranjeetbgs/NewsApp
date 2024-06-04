import 'dart:async';

class MyStream {
  final StreamController<String> _controller = StreamController<String>();

  Stream<String> get myStream => _controller.stream;

  void startFetchingData() {
    Timer.periodic(const Duration(minutes: 10), (_) {
      _fetchData();
    });
  }

  void _fetchData() {
    // Perform your API call here
    // For example:
    // API.fetchData().then((data) {
    //   _controller.add(data);
    // });
    // Replace the above code with your actual API call

    // For demonstration purposes, let's simulate a response after 2 seconds
    Future.delayed(Duration(seconds: 2), () {
      _controller.add("New data at ${DateTime.now()}");
    });
  }

  void dispose() {
    _controller.close();
  }
}
