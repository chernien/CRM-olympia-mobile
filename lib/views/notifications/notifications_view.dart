import 'package:flutter/material.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: const SafeArea(
        child: Center(
          child: Text('Aucune notification pour le moment'),
        ),
      ),
    );
  }
}
