import 'package:flutter/material.dart';

class SplahScrenn extends StatelessWidget {
  const SplahScrenn({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat App"),
      ),
      body: const Center(
        child: Text("Waiting ..."),
      ),
    );
  }
}
