import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await StorageService.init();
  await DeviceInfoHelper.init();
  LoggerService.init();
  await NetworkConnectivity.init();
  
  BankUtils.init(paystackSecretKey: 'your_test_key');
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Utils Example',
      home: ExampleScreen(),
    );
  }
}

class ExampleScreen extends StatelessWidget {
  const ExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Your Company Utils')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // String Extension Example
          Text('hello world'.toTitleCase), // "Hello World"
          
          // Number Formatting Example
          Text(1500000.toCurrency()), // "₦1,500,000.00"
          
          // Network Status
          StreamBuilder<NetworkStatus>(
            stream: NetworkConnectivity.onConnectivityChanged,
            builder: (context, snapshot) {
              final status = snapshot.data;
              return Text(
                status?.isConnected == true 
                  ? '✓ Connected' 
                  : '✗ No Connection'
              );
            },
          ),
        ],
      ),
    );
  }
}