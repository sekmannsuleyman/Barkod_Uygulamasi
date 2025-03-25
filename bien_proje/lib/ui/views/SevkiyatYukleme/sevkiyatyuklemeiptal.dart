import 'package:bien_proje/anaSayfa.dart';
import 'package:bien_proje/kullanicigiris.dart';
import 'package:bien_proje/ui/cubit/SevkiyatYuklemeCubit/sevkiyat_yukleme_iptal_c%C4%B1bit.dart';
import 'package:bien_proje/ui/views/SevkiyatYukleme/sevkiyatsorgu.dart';
import 'package:bien_proje/ui/views/SevkiyatYukleme/sevkiyatyukleme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Sevkiyatyuklemeiptal extends StatefulWidget {
  const Sevkiyatyuklemeiptal({super.key});

  @override
  State<Sevkiyatyuklemeiptal> createState() => _SevkiyatyuklemeiptalState();
}

class _SevkiyatyuklemeiptalState extends State<Sevkiyatyuklemeiptal> {
  var emirNoController = TextEditingController();
  var barkodNoController = TextEditingController();
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

      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            const SizedBox(height: 1),
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
                        builder: (context) => SevkiyatYukleme(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.red, // İptal butonu için kırmızı renk
                    padding: const EdgeInsets.symmetric(
                      horizontal: 65,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    "Yükleme",
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
                    backgroundColor: Colors.blue, // Sorgu butonu için mavi renk
                    padding: const EdgeInsets.symmetric(
                      horizontal: 65,
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
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text(
                  "Sevkiyat Yükleme İptal",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Emir No",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: emirNoController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: const EdgeInsets.all(10),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Barkod No",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: barkodNoController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: const EdgeInsets.all(10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  context
                      .read<SevkiyatYuklemeIptalCubit>()
                      .kaydetSevkiyatYuklemeIptalCubit(
                        emirNoController.text,
                        barkodNoController.text,
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
    );
  }
}
