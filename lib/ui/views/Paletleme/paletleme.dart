import 'package:bien_proje/ana_sayfa.dart';
import 'package:bien_proje/kullanici_girisi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../widgets/barkod_okuyucu.dart';
import '../../cubit/kullanici_giris_cubit/kullanici_giris_cubit.dart';
import '../../cubit/paletleme_cubit/paletleme_cubit.dart';
import 'palet_silme.dart';

class Paletleme extends StatefulWidget {
  const Paletleme({super.key});

  @override
  State<Paletleme> createState() => _PaletlemeState();
}

class _PaletlemeState extends State<Paletleme> {
  final kutuBarkodController = TextEditingController();
  final paletBarkodController = TextEditingController();
  late final KullaniciGirisCubit _kullaniciGirisCubit;
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
    kutuBarkodController.dispose();
    paletBarkodController.dispose();
    super.dispose();
  }

  Future<void> _barkodOku(TextEditingController controller) async {
    if (isProcessing) return;

    _kullaniciGirisCubit.resetInactivityTimer();
    setState(() {
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
                  controller.text = barcode;
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
          controller.text = result;
        });
      }
    } catch (e) {
      if (mounted) {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('Barkod okuma hatası: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
      _kullaniciGirisCubit.resetInactivityTimer();
    }
  }

  void _okutIslem() {
    if (isProcessing) return;

    final kutuBarkod = kutuBarkodController.text.trim();
    final paletBarkod = paletBarkodController.text.trim();

    if (kutuBarkod.isEmpty || paletBarkod.isEmpty) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Kutu Barkod ve Palet Barkod boş olamaz!')),
      );
      return;
    }

    if (kutuBarkod.length != 12 || paletBarkod.length != 12) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Kutu Barkod ve Palet Barkod 12 karakter olmalıdır!')),
      );
      return;
    }

    setState(() {
      isProcessing = true;
      statusMessage = ''; // Yeni işlem öncesi mesajı sıfırla
    });

    print('Okut işlemi başlatılıyor...');
    _kullaniciGirisCubit.resetInactivityTimer();
    context.read<PaletlemeCubit>().kaydetPaletlemeCubit(kutuBarkod, paletBarkod);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<KullaniciGirisCubit, String>(
      listener: (context, state) {
        print('Paletleme: KullaniciGirisCubit durumu: $state');
        if ((state == 'loggedOut' || state == 'logoutError') && mounted) {
          print('Çıkış yapıldı, giriş ekranına yönlendiriliyor');
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Kullanicigiris()),
                (route) => false,
          );
        }
      },
      child: Scaffold(
        key: _scaffoldMessengerKey,
        appBar: AppBar(
          title: InkWell(
            onTap: () {
              _kullaniciGirisCubit.resetInactivityTimer();
              Navigator.push(context, MaterialPageRoute(builder: (_) => const Anasayfa()));
            },
            child: const Text(
              "Anasayfa",
              style: TextStyle(color: Colors.white, decoration: TextDecoration.underline),
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
        body: BlocConsumer<PaletlemeCubit, PaletlemeState>(
          listener: (context, state) {
            print('PaletlemeCubit durumu: $state');
            if (state is PaletlemeSuccess) {
              print('Okut işlemi başarılı: ${state.sonuc}');
              _scaffoldMessengerKey.currentState?.showSnackBar(
                SnackBar(
                  content: Text(state.sonuc), // Sunucudan gelen mesajı doğrudan göster
                  backgroundColor: Colors.green,
                ),
              );
              setState(() {
                isProcessing = false;
                kutuBarkodController.clear();
                statusMessage = state.sonuc; // Sunucudan gelen mesajı kalıcı olarak göster
              });
            } else if (state is PaletlemeError) {
              print('Okut işlemi hata: ${state.hata}');
              _scaffoldMessengerKey.currentState?.showSnackBar(
                SnackBar(
                  content: Text(state.hata), // Hata mesajını doğrudan göster
                  backgroundColor: Colors.red,
                ),
              );
              setState(() {
                isProcessing = false;
                statusMessage = state.hata; // Hata mesajını kalıcı olarak göster
              });
            } else if (state is PaletlemeLoading) {
              print('Okut işlemi yükleniyor...');
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isProcessing
                          ? null
                          : () {
                        _kullaniciGirisCubit.resetInactivityTimer();
                        print('Silme butonuna basıldı');
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const Paletsilme()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        disabledBackgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      child: const Text("Silme"),
                    ),
                  ),
                  const SizedBox(height: 6),
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
                        "Paletleme",
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
                        "Kutu Barkod",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: kutuBarkodController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.all(10),
                              ),
                              onChanged: (_) => _kullaniciGirisCubit.resetInactivityTimer(),
                              enabled: !isProcessing,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.qr_code_scanner, size: 30, color: Colors.black54),
                            onPressed: isProcessing ? null : () => _barkodOku(kutuBarkodController),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Palet Barkod",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: paletBarkodController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.all(10),
                              ),
                              onChanged: (_) => _kullaniciGirisCubit.resetInactivityTimer(),
                              enabled: !isProcessing,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.qr_code_scanner, size: 30, color: Colors.black54),
                            onPressed: isProcessing ? null : () => _barkodOku(paletBarkodController),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isProcessing ? null : _okutIslem,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            disabledBackgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
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
                          color: statusMessage.toLowerCase().contains("hata") || statusMessage.toLowerCase().contains("bulunamadı")
                              ? Colors.red
                              : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}