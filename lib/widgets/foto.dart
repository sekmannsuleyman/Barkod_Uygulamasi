import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Foto extends StatefulWidget {
  const Foto({super.key});

  @override
  State<Foto> createState() => _FotoState();
}

class _FotoState extends State<Foto> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  Center(
        child: Opacity(
          opacity: 0.6,
          child: Image.asset(
            'resimler/bien.png',
            width: 200,
            height: 200,
          ),
        ),),
    );
  }
}
