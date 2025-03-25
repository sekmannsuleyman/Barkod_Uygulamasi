import 'package:flutter/material.dart';

import '../../../anaSayfa.dart';
import '../../../kullanicigiris.dart';
import 'SarfaCikis.dart';

class Sarfasorgu extends StatefulWidget {
  const Sarfasorgu({super.key});

  @override
  State<Sarfasorgu> createState() => _SarfasorguState();
}

class _SarfasorguState extends State<Sarfasorgu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Anasayfa()),
            );
          },
          child: const Text(
            "Anasayfa",
            style: TextStyle(
              color: Colors.white,
              decoration:
                  TextDecoration
                      .underline, // Kullanıcıya tıklanabilir olduğunu göstermek için
            ),
          ),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Kullanicigiris(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text("Çıkış"),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 60.0, top: 20),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SarfaCikis()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Sorgu butonu için mavi renk
                padding: const EdgeInsets.symmetric(
                  horizontal: 100,
                  vertical: 12,
                ),
              ),
              child: const Text(
                "Safra Çıkış",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
