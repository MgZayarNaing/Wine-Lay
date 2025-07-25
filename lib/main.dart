import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      home: WebViewPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WebViewPage extends StatefulWidget {
  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;
  bool isLoading = true;
  bool hasConnection = true;
  int _currentIndex = 0;

  final List<String> _urls = [
    'https://www.malikhacourierexpress.com/',
    'https://www.malikhacourierexpress.com/track/',
    'https://www.malikhacourierexpress.com/spinwheel/',
    'https://www.malikhacourierexpress.com/service/',
    'https://www.malikhacourierexpress.com/dashboard/',
  ];

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => isLoading = true),
          onPageFinished: (_) => setState(() => isLoading = false),
        ),
      );
    _checkConnectionAndLoad();

    // ✅ Version 5.x compatibility
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      _checkConnectionAndLoad();
    });
  }

  Future<void> _checkConnectionAndLoad() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    bool connected = connectivityResult != ConnectivityResult.none;
    setState(() {
      hasConnection = connected;
      isLoading = connected;
    });
    if (connected) {
      _controller.loadRequest(Uri.parse(_urls[_currentIndex]));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: hasConnection
          ? Stack(
              children: [
                SafeArea(child: WebViewWidget(controller: _controller)),
                if (isLoading)
                  Center(child: CircularProgressIndicator(color: Colors.red)),
              ],
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    'No Internet Connection',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: _checkConnectionAndLoad,
                    child: Text("Retry"),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color.fromARGB(255, 255, 0, 0),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (hasConnection) {
            _controller.loadRequest(Uri.parse(_urls[index]));
          } else {
            _checkConnectionAndLoad();
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Tracking',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.casino), label: 'Spin'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Services',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
}
