import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'stream.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stream - Ersa',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const StreamHomePage(),
    );
  }
}

class StreamHomePage extends StatefulWidget {
  const StreamHomePage({super.key});

  @override
  State<StreamHomePage> createState() => _StreamHomePageState();
}

class _StreamHomePageState extends State<StreamHomePage> {
  int lastNumber = 0;
  late StreamController numberStreamController;
  late NumberStream numberStream;
  late StreamSubscription subscription;
  late StreamSubscription subscription2;
  String values = '';

  @override
  void initState() {
    super.initState();

    numberStream = NumberStream();
    numberStreamController = numberStream.controller;

    // Menggunakan asBroadcastStream agar bisa memiliki lebih dari satu listener
    Stream stream = numberStreamController.stream.asBroadcastStream();

    // Mendengarkan stream untuk subscription pertama
    subscription = stream.listen((event) {
      setState(() {
        lastNumber = event; // Menampilkan angka terbaru
      });
    });

    // Mendengarkan stream untuk subscription kedua
    subscription2 = stream.listen((event) {
      setState(() {
        values += '$event - '; // Menampilkan hasil yang bertambah
      });
    });

    subscription.onError((error) {
      setState(() {
        lastNumber = -1;
      });
    });

    subscription.onDone(() {
      print('OnDone was called');
    });
  }

  @override
  void dispose() {
    subscription.cancel();
    subscription2.cancel();
    super.dispose();
  }

  void stopStream() {
    numberStreamController.close(); // Menutup stream
  }

  void addRandomNumber() {
    Random random = Random();
    int myNum = random.nextInt(10);
    if (!numberStreamController.isClosed) {
      numberStream.addNumberToSink(myNum);
    } else {
      setState(() {
        lastNumber = -1; // Jika stream ditutup, tampilkan -1
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stream')),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Menampilkan angka terbaru yang diterima oleh stream
            Text(
              lastNumber.toString(),
              style: const TextStyle(fontSize: 48),
            ),
            // Menampilkan rangkaian angka yang diterima oleh listener kedua
            Text(
              values,
              style: const TextStyle(fontSize: 24),
            ),
            ElevatedButton(
              onPressed: () => addRandomNumber(),
              child: const Text('New Random Number'),
            ),
            ElevatedButton(
              onPressed: () => stopStream(),
              child: const Text('Stop Subscription'),
            ),
          ],
        ),
      ),
    );
  }
}
