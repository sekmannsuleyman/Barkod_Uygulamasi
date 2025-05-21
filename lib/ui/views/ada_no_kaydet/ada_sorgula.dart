import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../ana_sayfa.dart';
import '../../../kullanici_girisi.dart';
import '../../cubit/ada_no_kaydet_cubit/ada_sorgula_cubit.dart';
import '../../cubit/kullanici_giris_cubit/kullanici_giris_cubit.dart';
import 'ada_no_kaydet.dart';

class Adasorgula extends StatefulWidget {
  const Adasorgula({super.key});

  @override
  State<Adasorgula> createState() => _AdasorgulaState();
}

class _AdasorgulaState extends State<Adasorgula> {
  var adaNoController = TextEditingController();
  var siraNoController = TextEditingController();
  late final KullaniciGirisCubit kullaniciGirisCubit;
  bool isProcessing = false;
  List<Map<String, String>> sonucListesi = [];
  String? hataMesaji;

  @override
  void initState() {
    super.initState();
    kullaniciGirisCubit = context.read<KullaniciGirisCubit>();
    kullaniciGirisCubit.startInactivityTimer();
  }

  @override
  void dispose() {
    kullaniciGirisCubit.stopInactivityTimer();
    adaNoController.dispose();
    siraNoController.dispose();
    super.dispose();
  }

  Future<void> _sorgula() async {
    if (adaNoController.text.isEmpty) {
      setState(() {
        hataMesaji = "Ada No boş olamaz!";
      });
      return;
    }

    setState(() {
      isProcessing = true;
      sonucListesi = [];
      hataMesaji = null;
    });

    try {
      await context.read<AdaSorgulaCubit>().kaydetAdaSorgula(
        adaNoController.text.trim(),
        siraNoController.text.trim(),
      );
      setState(() {
        sonucListesi = context.read<AdaSorgulaCubit>().state.data;
        hataMesaji = context.read<AdaSorgulaCubit>().state.error;
        if (sonucListesi.isEmpty && hataMesaji == null) {
          hataMesaji = "Bu Ada No (${adaNoController.text}) ve Sıra No (${siraNoController.text}) ile kayıt bulunamadı.";
        }
      });
    } catch (e) {
      setState(() {
        hataMesaji = "Sorgu başarısız: ${e.toString()}";
      });
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<KullaniciGirisCubit, String>(
      listener: (context, state) {
        if ((state == 'loggedOut' || state == 'logoutError') && mounted) {
          print('Çıkış yapıldı, giriş ekranına yönlendiriliyor');
          Future.microtask(() {
            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const Kullanicigiris()),
                    (route) => false,
              );
            }
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: InkWell(
            onTap: () {
              kullaniciGirisCubit.resetInactivityTimer();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Anasayfa()),
              );
            },
            child: const Text(
              "Anasayfa",
              style: TextStyle(color: Colors.white),
            ),
          ),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: ElevatedButton(
                onPressed: isProcessing
                    ? null
                    : () async {
                  kullaniciGirisCubit.resetInactivityTimer();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Çıkış yapılıyor...')),
                  );
                  await kullaniciGirisCubit.cikisYap();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey,
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
                padding: const EdgeInsets.only(top: 1.0, right: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: isProcessing
                          ? null
                          : () {
                        kullaniciGirisCubit.resetInactivityTimer();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Adanokaydet()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                        disabledBackgroundColor: Colors.grey,
                      ),
                      child: const Text(
                        "Ada No Kaydet",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text(
                    "Ada Sorgu",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Ada No",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    controller: adaNoController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(10),
                    ),
                    maxLength: 8,
                    enabled: !isProcessing,
                    onChanged: (value) {
                      kullaniciGirisCubit.resetInactivityTimer();
                    },
                  ),
                  const SizedBox(height: 1),
                  const Text(
                    "Sıra No",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    controller: siraNoController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(10),
                    ),
                    maxLength: 8,
                    enabled: !isProcessing,
                    onChanged: (value) {
                      kullaniciGirisCubit.resetInactivityTimer();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isProcessing ? null : _sorgula,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Okut",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (hataMesaji != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    hataMesaji!,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              if (sonucListesi.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: sonucListesi.length,
                    itemBuilder: (context, index) {
                      final row = sonucListesi[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: row.entries
                                .map((e) => Text("${e.key}: ${e.value}", style: const TextStyle(fontSize: 14)))
                                .toList(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}