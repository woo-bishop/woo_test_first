import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebasetestapp/firebase_options.dart';
import 'package:firebasetestapp/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: //const HomeScreen(),
          const NotificationScrren(),
    );
  }
}

class NotificationScrren extends StatefulWidget {
  const NotificationScrren({super.key});

  @override
  State<NotificationScrren> createState() => _NotificationScrrenState();
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print(
      'background title : ${message.notification?.title}, message : ${message.notification?.body}');
}

class _NotificationScrrenState extends State<NotificationScrren> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final int _counter = 0;
  final int _tartgetNumger = 10;

  @override
  void initState() {
    super.initState();

    _firebaseMessaging.requestPermission();

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        print(
            'foreground title : ${message.notification?.title}, message : ${message.notification?.body}');
      },
    );

    FirebaseMessaging.instance.getToken().then(
      (value) {
        print('token : $value');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FCM Example'),
      ),
      body: const Center(
        child: Text('Listen for Notifications'),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _counter = 0;
  int _targetNumber = 10;
  Timer? _timer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _requestNotificationPermissions();
  }

  void _requestNotificationPermissions() async {
    final status = await NotificationService().requestNotificationPermissions();
    if (status.isDenied && context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('알림 권한 거부'),
          content: const Text('앱 설정에서 권한 허용'),
          actions: [
            TextButton(
              onPressed: () {
                openAppSettings();
              },
              child: const Text('설정'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('취소'),
            ),
          ],
        ),
      );
    } //final status = await Notifi
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('쭈미로운 생활 푸시 알림 예제')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('타이머: $_counter'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('알림 시간 입력(초) : '),
                SizedBox(
                  width: 60,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _targetNumber = int.parse(value);
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _resetCounter,
                  child: const Text('초기화'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _toggleTimer,
                  child: Text(_timer?.isActive == true ? '정지' : '시작'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _resetCounter() {
    setState(() {
      _counter = 0; // _counter 변수를 0으로 초기화
    });
  }

  void _toggleTimer() {
    // 타이머 시작/정지 기능
    if (_timer?.isActive == true) {
      _stopTimer();
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    //타이머 시작
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _counter++;
        if (_counter == _targetNumber) {
          NotificationService().showNotification(_targetNumber);
          _stopTimer();
        }
      });
    });
  }

  void _stopTimer() {
    //타이머 정지
    _timer?.cancel();
  }
}
