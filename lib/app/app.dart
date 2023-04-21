import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import 'pages/index.dart';

class DuplicatesDetectorApp extends StatelessWidget {
  const DuplicatesDetectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: yaruLubuntuDark,
      darkTheme: ThemeData.dark(),
      // themeMode: ThemeMode.dark,
      home: const HomePage(),
    );
  }
}
