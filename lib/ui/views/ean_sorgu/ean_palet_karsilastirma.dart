import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../ana_sayfa.dart';
import '../../../kullanici_girisi.dart';
import '../../cubit/ean_sorgu_cubit/ean_palet_karsilastirma_cubit.dart';
import '../../cubit/kullanici_giris_cubit/kullanici_giris_cubit.dart';
import 'ean_sorgu.dart';

class Eanpaletkarsilastirma extends StatefulWidget {
  const Eanpaletkarsilastirma({super.key});

  @override
  State<Eanpaletkarsilastirma> createState() => _EanpaletkarsilastirmaState();
}

class _EanpaletkarsilastirmaState extends State<Eanpaletkarsilastirma> {
  final paletIdController = TextEditingController();
  final eanNoController = TextEditingController();
  late final KullaniciGirisCubit kullaniciGirisCubit;

  @override
  void initState() {
    super.initState();
    context.read<EanPaletKarsilastirmaCubit>().temizle();
    kullaniciGirisCubit = context.read<KullaniciGirisCubit>();
    kullaniciGirisCubit.startInactivityTimer();
  }

  @override
  void dispose() {
    kullaniciGirisCubit.stopInactivityTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Anasayfa()),
            );
          },
          child: const Text(
            "Anasayfa",
            style: TextStyle(
              color: Colors.white,

            ),
          ),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: ElevatedButton(
              onPressed: () async {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Çıkış yapılıyor...')),
                );
                await kullaniciGirisCubit.cikisYap();
                if (kullaniciGirisCubit.state == 'loggedOut') {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const Kullanicigiris()),
                        (route) => false,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Çıkış işlemi başarısız oldu')),
                  );
                }
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
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Eansorgu(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      "Ean Sorgu",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
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
                  "Ean-Palet Karşılaştırma",
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
                  "Palet ID",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: paletIdController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(10),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Ean No",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: eanNoController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(10),
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
                  context.read<EanPaletKarsilastirmaCubit>().karsilastir(
                    paletIdController.text.trim(),
                    eanNoController.text.trim(),
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
            const SizedBox(height: 20),
            BlocBuilder<EanPaletKarsilastirmaCubit, EanPaletKarsilastirmaState?>(
              builder: (context, state) {
                if (state == null) return const SizedBox.shrink();
                return Text(
                  state.mesaj,
                  style: TextStyle(
                    color: state.hata ? Colors.red : Colors.green,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
