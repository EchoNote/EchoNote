import 'dart:math';

import 'package:echo_note/Pages/canvas_page/canvaspage.dart';
import 'package:echo_note/Pages/ui/scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Pages/canvas_page/pen_canvas.dart';
import 'Pages/note_page/notepage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 设置状态栏和导航栏透明沉浸
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // 状态栏透明
      systemNavigationBarColor: Colors.transparent, // 导航栏透明
      systemNavigationBarIconBrightness: Brightness.dark, // 根据背景调整图标颜色
      statusBarIconBrightness: Brightness.dark, // 状态栏图标颜色
      systemNavigationBarContrastEnforced: false,
    ),
  );
  // 保留状态栏与导航栏，但允许沉浸
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge, // 沉浸式效果但不隐藏
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      scrollBehavior: EchoScrollBehavior(),

      // 浅色设置
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue, // 主题色（主色调）
        primaryColor: Colors.blue, // 主题色（主色调）
        scaffoldBackgroundColor: Colors.grey.shade200,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue.shade100, // AppBar 背景颜色
          foregroundColor: Colors.black, // AppBar 文字颜色
          elevation: 4, // AppBar 阴影高度
        ),
      ),

      // 深色设置
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primarySwatch: Colors.indigo, // 🌑 深色模式主色调
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.grey.shade900,
        appBarTheme: AppBarTheme(
          backgroundColor: const Color.fromARGB(255, 26, 53, 93), // AppBar 背景颜色
          foregroundColor: Colors.white,
          elevation: 4,
        ),
      ),
      themeMode: ThemeMode.system, // 跟随系统
      // home: NotePage(),
      home: const CanvasPage(), // 画布页面
    );
  }
}

double randomInRange(double min, double max) {
  final random = Random();
  return min + (max - min) * random.nextDouble();
}
