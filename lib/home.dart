import 'package:demoapp/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:styled_widget/styled_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return vstack([
      buton("GithubSearch")(() => {context.push('/github')}).padding(top: 100),
      spacer(),
      buton("Counter")(() => {context.push('/counter')})
    ])()
        .backgroundColor(Colors.white);
  }
}
