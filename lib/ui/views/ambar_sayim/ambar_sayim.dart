import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../ana_sayfa.dart';
import '../../../kullanici_girisi.dart';
import '../../../widgets/barkod_okuyucu.dart';
import '../../cubit/ambar_sayim_cubit/ambar_sayim_cubit.dart';
import '../../cubit/kullanici_giris_cubit/kullanici_giris_cubit.dart';
import 'ambar_geri_al.dart';
import 'ambar_sayim_sorgu.dart';

class Ambarsayim extends StatefulWidget {
  const Ambarsayim({super.key});

  @override
  State<Ambarsayim> createState() => _AmbarsayimState();
}

class _AmbarsayimState extends State<Ambarsayim> {
  var rafNoController = TextEditingController();
  var gozNoController = TextEditingController();
  var barkodNoController = TextEditingController();
  var adetController = TextEditingController();
  var sicilNoController = TextEditingController();
  var sayimNoController = TextEditingController();
  late final KullaniciGirisCubit _kullaniciGirisCubit;
  bool barkodOkumaAktif = false;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    _kullaniciGirisCubit = context.read<KullaniciGirisCubit>();
    _kullaniciGirisCubit.startInactivityTimer();
    _loadSicilNo();
  }

  @override
  void dispose() {
    _kullaniciGirisCubit.stopInactivityTimer();
    rafNoController.dispose();
    gozNoController.dispose();
    barkodNoController.dispose();
    adetController.dispose();
    sicilNoController.dispose();
    sayimNoController.dispose();
    super.dispose();
  }

  Future<void> _loadSicilNo() async {
    final prefs = await SharedPreferences.getInstance();
    final sicilNo = prefs.getString('kullanici_id') ?? '';
    setState(() {
      sicilNoController.text = sicilNo;
    });
  }

  void _barkodOku() async {
    if (isProcessing) return;

    print('Barkod okuyucu açılıyor...');
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
              print('Barkod tespit edildi: $barcode');
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
        print('Barkod değeri set edildi: ${barkodNoController.text}');
      }
    } catch (e) {
      print('Barkod okuma hatası: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Barkod okuma hatası: $e')));
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<KullaniciGirisCubit, String>(
      listener: (context, state) {
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
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const Ambarsayimsorgu()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 12),
                          disabledBackgroundColor: Colors.grey,
                        ),
                        child: const Text(
                          "Sorgu",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: isProcessing
                            ? null
                            : () {
                          _kullaniciGirisCubit.resetInactivityTimer();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const Ambargerial()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 12),
                          disabledBackgroundColor: Colors.grey,
                        ),
                        child: const Text(
                          "Geri Al",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 1.0),
                  child: const SizedBox(height: 10),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Text(
                    "Sayım",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Raf No / Göz No",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: rafNoController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        ),
                        onChanged: (value) {
                          _kullaniciGirisCubit.resetInactivityTimer();
                        },
                        enabled: !isProcessing,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: gozNoController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        ),
                        onChanged: (value) {
                          _kullaniciGirisCubit.resetInactivityTimer();
                        },
                        enabled: !isProcessing,
                      ),
                    ),
                  ],
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
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                const SizedBox(height: 10),
                const Text(
                  "Adet",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: adetController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  ),
                  onChanged: (value) {
                    _kullaniciGirisCubit.resetInactivityTimer();
                  },
                  enabled: !isProcessing,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Sicil No",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: sicilNoController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  sicilNoController.text.isEmpty
                      ? "Sicil No girilmedi"
                      : "Girilen Sicil No: ${sicilNoController.text}",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Sayım No",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: sayimNoController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  ),
                  onChanged: (value) {
                    _kullaniciGirisCubit.resetInactivityTimer();
                  },
                  enabled: !isProcessing,
                ),
                const SizedBox(height: 20),
                BlocListener<AmbarSayimCubit, AmbarSayimState>(
                  listener: (context, state) {
                    if (state.message != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message!),
                          backgroundColor: state.message!.contains("Hata") ? Colors.red : Colors.green,
                        ),
                      );
                    }
                  },
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isProcessing
                          ? null
                          : () {
                        if (rafNoController.text.isEmpty ||
                            gozNoController.text.isEmpty ||
                            barkodNoController.text.isEmpty ||
                            adetController.text.isEmpty ||
                            sayimNoController.text.isEmpty ||
                            sicilNoController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Tüm alanlar doldurulmalıdır!')),
                          );
                          return;
                        }

                        setState(() {
                          isProcessing = true;
                        });

                        _kullaniciGirisCubit.resetInactivityTimer();
                        context.read<AmbarSayimCubit>().kaydetAmbarSayim(
                          rafNoController.text,
                          gozNoController.text,
                          barkodNoController.text,
                          adetController.text,
                          sayimNoController.text,
                        );

                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (mounted) {
                            setState(() {
                              isProcessing = false;
                              barkodNoController.clear();
                            });
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        disabledBackgroundColor: Colors.grey,
                      ),
                      child: isProcessing
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Okut"),
                    ),
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

