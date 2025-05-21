import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../ana_sayfa.dart';
import '../../../kullanici_girisi.dart';
import '../../../widgets/barkod_okuyucu.dart';
import '../../cubit/ambar_sayim_cubit/ambar_sayim_sorgu_cubit.dart';
import '../../cubit/kullanici_giris_cubit/kullanici_giris_cubit.dart';
import 'ambar_geri_al.dart';
import 'ambar_sayim.dart';

class Ambarsayimsorgu extends StatefulWidget {
  const Ambarsayimsorgu({super.key});

  @override
  State<Ambarsayimsorgu> createState() => _AmbarsayimsorguState();
}

class _AmbarsayimsorguState extends State<Ambarsayimsorgu> {
  var rafNoController = TextEditingController();
  var gozNoController = TextEditingController();
  var barkodNoController = TextEditingController();
  late final KullaniciGirisCubit _kullaniciGirisCubit;
  bool barkodOkumaAktif = false;
  bool isProcessing = false;
  List<Map<String, String>> sonucListesi = [];
  String? hataMesaji;

  @override
  void initState() {
    super.initState();
    _kullaniciGirisCubit = context.read<KullaniciGirisCubit>();
    _kullaniciGirisCubit.startInactivityTimer();
  }

  @override
  void dispose() {
    _kullaniciGirisCubit.stopInactivityTimer();
    rafNoController.dispose();
    gozNoController.dispose();
    barkodNoController.dispose();
    super.dispose();
  }
  void _barkodOku() async {
    if (isProcessing) return;
    _kullaniciGirisCubit.resetInactivityTimer();
    setState(() {
      barkodOkumaAktif = true;
      isProcessing = true;
    });

    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BarkodOkuyucu(
            onBarkodDetected: (barcode) {
              if (mounted) {
                setState(() {
                  barkodNoController.text = barcode;
                });
              }
              _kullaniciGirisCubit.resetInactivityTimer();
            },
          ),
        ),
      );

      if (!mounted) return;
      if (result != null && result is String) {
        setState(() {
          barkodNoController.text = result;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Barkod okuma hatası: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          barkodOkumaAktif = false;
          isProcessing = false;
        });
      }
      _kullaniciGirisCubit.resetInactivityTimer();
    }
  }


  Future<void> _sorgula() async {
    if (rafNoController.text.isEmpty || gozNoController.text.isEmpty || barkodNoController.text.isEmpty) {
      setState(() {
        hataMesaji = "Tüm alanları doldurunuz!";
      });
      return;
    }

    setState(() {
      isProcessing = true;
      sonucListesi = [];
      hataMesaji = null;
    });

    try {
      final cubit = context.read<AmbarSayimSorguCubit>();
      await cubit.kaydetAmbarSayimSorgu(
        rafNoController.text.trim(),
        gozNoController.text.trim(),
        barkodNoController.text.trim(),
      );
      setState(() {
        sonucListesi = cubit.state.data;
        hataMesaji = cubit.state.error;
        if (sonucListesi.isEmpty && hataMesaji == null) {
          hataMesaji = "Bu Raf No (${rafNoController.text}), Göz No (${gozNoController.text}) ve Barkod No (${barkodNoController.text}) ile kayıt bulunamadı.";
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
        print('KullaniciGirisCubit durumu: $state');
        if ((state == 'loggedOut' || state == 'logoutError') && mounted) {
          if (!barkodOkumaAktif) {
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
          } else {
            print('Barkod okuma sırasında logout engellendi.');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: InkWell(
            onTap: () {
              _kullaniciGirisCubit.resetInactivityTimer();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => Anasayfa()),
                    (route) => false,
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
                  _kullaniciGirisCubit.resetInactivityTimer();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Çıkış yapılıyor...')),
                  );
                  await _kullaniciGirisCubit.cikisYap();
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
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: isProcessing
                            ? null
                            : () {
                          _kullaniciGirisCubit.resetInactivityTimer();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const Ambarsayim()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                          disabledBackgroundColor: Colors.grey,

                        ),
                        child: const Text(
                          "Sayım",
                          style: TextStyle(color: Colors.white, fontSize: 16,),

                        ),
                      ),
                      ElevatedButton(
                        onPressed: isProcessing
                            ? null
                            : () {
                          _kullaniciGirisCubit.resetInactivityTimer();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const Ambargerial()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                          disabledBackgroundColor: Colors.grey,
                        ),
                        child:  Text(
                          "Geri Al",
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
                      "Sayım Sorgu",
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
                      "Raf No",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: rafNoController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(10),
                      ),
                      onChanged: (value) {
                        _kullaniciGirisCubit.resetInactivityTimer();
                      },
                      enabled: !isProcessing,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Göz No",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: gozNoController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(10),
                      ),
                      onChanged: (value) {
                        _kullaniciGirisCubit.resetInactivityTimer();
                      },
                      enabled: !isProcessing,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Barkod No",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: barkodNoController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.all(10),
                            ),
                            onChanged: (value) {
                              _kullaniciGirisCubit.resetInactivityTimer();
                            },
                            enabled: !isProcessing,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.qr_code_scanner, size: 30, color: Colors.black54),
                          onPressed: isProcessing ? null : _barkodOku,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 15),
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
      ),
    );
  }
}

