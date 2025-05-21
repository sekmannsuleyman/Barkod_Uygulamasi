import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../ana_sayfa.dart';
import '../../../kullanici_girisi.dart';
import '../../cubit/kullanici_giris_cubit/kullanici_giris_cubit.dart';
import '../../cubit/sayim_cubit/sayim_gerial_cubit.dart';
import 'sayim.dart';
import 'sayim_sorgu.dart';

class Sayimgerial extends StatefulWidget {
  const Sayimgerial({super.key});

  @override
  State<Sayimgerial> createState() => _SayimgerialState();
}

class _SayimgerialState extends State<Sayimgerial> {
  var barkodNoController = TextEditingController();
  late final KullaniciGirisCubit _kullaniciGirisCubit;
  bool barkodOkumaAktif = false;
  bool isProcessing = false;
  String statusMessage = ''; // Kalıcı uyarı mesajı için
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

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

    print('Barkod okuyucu açılıyor...');
    _kullaniciGirisCubit.resetInactivityTimer();

    setState(() {
      barkodOkumaAktif = true;
      isProcessing = true;
      statusMessage = ''; // Yeni işlem öncesi mesajı sıfırla
    });

    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const BarkodOkuyucuSayimGeriAl()),
      );

      if (!mounted) return;

      setState(() {
        barkodOkumaAktif = false;
        isProcessing = false;
      });

      _kullaniciGirisCubit.resetInactivityTimer();

      if (result != null && result is String) {
        setState(() {
          barkodNoController.text = result;
        });
        print('Barkod değeri set edildi: ${barkodNoController.text}');
      } else {
        print('Barkod tarama iptal edildi veya hata oluştu.');
      }
    } catch (e) {
      print('Barkod okuma hatası: $e');
      if (mounted) {
        setState(() {
          barkodOkumaAktif = false;
          isProcessing = false;
        });

        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('Barkod okuma hatası: $e')),
        );
      }
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
        key: _scaffoldMessengerKey,
        appBar: AppBar(
          title: InkWell(
            onTap: () {
              _kullaniciGirisCubit.resetInactivityTimer();
              print('AppBar: Anasayfa\'ya yönlendiriliyor');
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const Anasayfa()),
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
                  print('Çıkış butonuna basıldı');
                  _scaffoldMessengerKey.currentState?.showSnackBar(
                    const SnackBar(content: Text('Çıkış yapılıyor...')),
                  );
                  await context.read<KullaniciGirisCubit>().cikisYap();
                  if (context.read<KullaniciGirisCubit>().state == 'loggedOut') {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const Kullanicigiris()),
                          (route) => false,
                    );
                  } else {
                    _scaffoldMessengerKey.currentState?.showSnackBar(
                      const SnackBar(content: Text('Çıkış işlemi başarısız oldu')),
                    );
                  }
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
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
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
                          MaterialPageRoute(builder: (context) => const Sayim()),
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
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const Sayimsorgu()),
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
                padding: const EdgeInsets.only(top: 12.0),
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
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
              BlocConsumer<SayimGerialCubit, SayimGerialState>(
                listener: (context, state) {
                  if (state.message != null && mounted) {
                    _scaffoldMessengerKey.currentState?.showSnackBar(
                      SnackBar(
                        content: Text(state.message!),
                        backgroundColor: state.isError ? Colors.red : Colors.green,
                      ),
                    );
                    setState(() {
                      isProcessing = false;
                      barkodNoController.clear();
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
                              _scaffoldMessengerKey.currentState?.showSnackBar(
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

                            context.read<SayimGerialCubit>().kaydetSayimGerialCubit(
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

class BarkodOkuyucuSayimGeriAl extends StatefulWidget {
  const BarkodOkuyucuSayimGeriAl({super.key});

  @override
  State<BarkodOkuyucuSayimGeriAl> createState() => _BarkodOkuyucuSayimGeriAlState();
}

class _BarkodOkuyucuSayimGeriAlState extends State<BarkodOkuyucuSayimGeriAl> {
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!isProcessing) {
          return true;
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Barkod Okuyucu"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: isProcessing
                ? null
                : () {
              Navigator.pop(context);
            },
          ),
        ),
        body: MobileScanner(
          onDetect: (capture) {
            if (isProcessing) return;

            setState(() {
              isProcessing = true;
            });

            try {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String? code = barcodes.first.rawValue;
                if (code != null && code.isNotEmpty) {
                  print('Barkod tarandı: $code');
                  Future.delayed(const Duration(milliseconds: 500), () {
                    Navigator.pop(context, code);
                  });
                } else {
                  setState(() {
                    isProcessing = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Geçersiz barkod. Tekrar deneyiniz.')),
                  );
                }
              } else {
                setState(() {
                  isProcessing = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Barkod tespit edilemedi. Tekrar deneyiniz.')),
                );
              }
            } catch (e) {
              print('Barkod işleme hatası: $e');
              setState(() {
                isProcessing = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Barkod işleme hatası: $e')),
              );
            }
          },
        ),
      ),
    );
  }
}