import 'package:bien_proje/ui/cubit/SevkiyatYuklemeCubit/sevkiyat_yukleme_cubit.dart';
import 'package:bien_proje/ui/views/SevkiyatYukleme/sevkiyatsorgu.dart';
import 'package:bien_proje/ui/views/SevkiyatYukleme/sevkiyatyuklemeiptal.dart';
import 'package:flutter/material.dart';
import 'package:bien_proje/anaSayfa.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../kullanicigiris.dart';

class SevkiyatYukleme extends StatefulWidget {
  const SevkiyatYukleme({super.key});

  @override
  State<SevkiyatYukleme> createState() => _SevkiyatYuklemeState();
}

class _SevkiyatYuklemeState extends State<SevkiyatYukleme> {
  var sicilNoController = TextEditingController();
  var emirNoController = TextEditingController();
  var barkodNoController = TextEditingController();
  var agirlikController = TextEditingController();

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

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceEvenly, // Butonları eşit aralıklarla yay
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Sevkiyatyuklemeiptal(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.red, // İptal butonu için kırmızı renk
                      padding: const EdgeInsets.symmetric(
                        horizontal: 70,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      "İptal",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Sevkiyatsorgu(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.blue, // Sorgu butonu için mavi renk
                      padding: const EdgeInsets.symmetric(
                        horizontal: 70,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      "Sorgu",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),

              // Sicil No Alanı (Değiştirilemez)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: const Text(
                  "Sicil No",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 250.0),
                child: TextField(
                  controller: sicilNoController,
                  decoration: InputDecoration(border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(height: 10),

              // Emir No Alanı
              const Text(
                "Emir No",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: emirNoController,
                decoration: InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),

              // Barkod No Alanı
              const Text(
                "Barkod No",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: barkodNoController,
                decoration: InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),

              // Ağırlık Alanı
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: agirlikController,
                      decoration: InputDecoration(border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                    ),
                    child: const Text(
                      "Ağırlık",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Okut Butonu
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    context
                        .read<SevkiyatYuklemeCubit>()
                        .kaydetSevkiyatYuklemeCubit(
                          emirNoController.text,
                          barkodNoController.text,
                          agirlikController.text,
                        );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: const Text(
                    "Okut",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
