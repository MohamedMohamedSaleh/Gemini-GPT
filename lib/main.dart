import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gemini_gpt/feature/themes.dart';
import 'package:gemini_gpt/views/home_page.dart';

void main()async {
  //  TODO: use dotenv package and make file with key api 
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gemini GPT',
      theme: MyThemes.lightTheme,
      // darkTheme: MyThemes.darkTheme,
      home: const HomePageView(),
    );
  }
}
