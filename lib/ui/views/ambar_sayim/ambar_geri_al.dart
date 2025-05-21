import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../ana_sayfa.dart';
import '../../../kullanici_girisi.dart';
import '../../../widgets/barkod_okuyucu.dart';
import '../../cubit/ambar_sayim_cubit/ambar_gerial_cubit.dart';
import '../../cubit/kullanici_giris_cubit/kullanici_giris_cubit.dart';
import 'ambar_sayim_sorgu.dart';
import 'ambar_sayim.dart';

class Ambargerial extends StatefulWidget {
  const Ambargerial({super.key});

  @override
  State<Ambargerial> createState() => _AmbargerialState();
}

class _AmbargerialState extends State<Ambargerial> {
  var barkodNoController = TextEditingController();
  late final KullaniciGirisCubit _kullaniciGirisCubit;
  bool barkodOkumaAktif = false;
  bool isProcessing = false;
  String statusMessage = ''; // Kalıcı uyarı mesajı için

  @override
  void initState() {
    super.initState();
    _kullaniciGirisCubit = context.read<KullaniciGirisCubit>();
    _kullaniciGirisCubit.startInactivityTimer();
  }

  @override
  void dispose() {
    _kullaniciGirisCubit.stopInactivityTimer();
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
              print('AppBar: Anasayfa\'ya yönlendiriliyor');
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
                  print('Çıkış butonuna basıldı');
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
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1.0),
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
                          MaterialPageRoute(builder: (context) => const Ambarsayimsorgu()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                        disabledBackgroundColor: Colors.grey,
                      ),
                      child: const Text(
                        "Sorgu",
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
                    "Sayım Geri Al",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
              const SizedBox(height: 30),
              BlocConsumer<AmbarGerialCubit, AmbarGerialState>(
                listener: (context, state) {
                  if (state.message != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message!),
                        backgroundColor: state.isError ? Colors.red : Colors.green,
                      ),
                    );
                    setState(() {
                      isProcessing = false;
                      statusMessage = state.message!;
                    });
                  }
                },
                builder: (context, state) {
                  return Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isProcessing
                              ? null
                              : () {
                            if (barkodNoController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Barkod No alanı doldurulmalıdır!')),
                              );
                              return;
                            }

                            setState(() {
                              isProcessing = true;
                              statusMessage = ''; // Yeni işlem öncesi mesajı sıfırla
                            });

                            _kullaniciGirisCubit.resetInactivityTimer();
                            print('Okut butonuna basıldı');

                            context.read<AmbarGerialCubit>().kaydetAmbarGerial(
                              barkodNoController.text,
                            );
                          },
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
                      // Kalıcı uyarı mesajı
                      Text(
                        statusMessage,
                        style: TextStyle(
                          fontSize: 16,
                          color: statusMessage.toLowerCase().contains("hata") ||
                              statusMessage.toLowerCase().contains("bulunamadı")
                              ? Colors.red
                              : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}