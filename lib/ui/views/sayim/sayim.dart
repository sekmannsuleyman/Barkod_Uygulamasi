import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../ana_sayfa.dart';
import '../../../data/datasources/sayim_sorgular/sayim_sayim_sorgu.dart';
import '../../../kullanici_girisi.dart';
import '../../../widgets/barkod_okuyucu.dart';
import '../../cubit/kullanici_giris_cubit/kullanici_giris_cubit.dart';
import '../../cubit/sayim_cubit/sayim_cubit.dart';
import 'sayim_gerial.dart';
import 'sayim_sorgu.dart';

class Sayim extends StatefulWidget {
  const Sayim({super.key});

  @override
  State<Sayim> createState() => _SayimState();
}

class _SayimState extends State<Sayim> {
  final TextEditingController adaNoController = TextEditingController();
  final TextEditingController siraNoController = TextEditingController();
  final TextEditingController barkodNoController = TextEditingController();
  final TextEditingController sicilNoController = TextEditingController();
  final TextEditingController sayimNoController = TextEditingController();
  late final KullaniciGirisCubit _kullaniciGirisCubit;
  bool isProcessing = false;
  bool logoutBeklemede = false;
  bool barkodOkumaAktif = false;
  String statusMessage = ''; // Kalıcı uyarı mesajı için
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _kullaniciGirisCubit = context.read<KullaniciGirisCubit>();
    _kullaniciGirisCubit.startInactivityTimer();
    _loadSicilNo();
  }

  Future<void> _loadSicilNo() async {
    final prefs = await SharedPreferences.getInstance();
    final kullaniciId = prefs.getString('kullanici_id') ?? '';
    setState(() {
      sicilNoController.text = kullaniciId;
    });
  }

  @override
  void dispose() {
    _kullaniciGirisCubit.stopInactivityTimer();
    adaNoController.dispose();
    siraNoController.dispose();
    barkodNoController.dispose();
    sicilNoController.dispose();
    sayimNoController.dispose();
    super.dispose();
  }

  Future<void> _barkodOku() async {
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
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('Barkod okuma hatası: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          barkodOkumaAktif = false;
          isProcessing = false;
        });

        if (logoutBeklemede) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const Kullanicigiris()),
                (route) => false,
          );
          logoutBeklemede = false;
        }
      }
      _kullaniciGirisCubit.resetInactivityTimer();
    }
  }

  void _okutIslem(BuildContext context) {
    if (isProcessing) return;

    final adaNo = adaNoController.text.trim();
    final siraNo = siraNoController.text.trim();
    final barkodNo = barkodNoController.text.trim();

    if (adaNo.isEmpty) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Ada No boş olamaz!')),
      );
      return;
    }

    if (siraNo.isEmpty) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Sıra No boş olamaz!')),
      );
      return;
    }

    if (barkodNo.isEmpty) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Barkod No boş olamaz!')),
      );
      return;
    }

    setState(() {
      isProcessing = true;
      statusMessage = ''; // Yeni işlem öncesi mesajı sıfırla
    });

    _kullaniciGirisCubit.resetInactivityTimer();

    context.read<SayimCubit>().kaydetSayimCubit(
      adaNo,
      siraNo,
      barkodNo,
      sayimNoController.text.trim(),
      sicilNoController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SayimCubit(SayimSayimSorgu()),
      child: BlocListener<KullaniciGirisCubit, String>(
        listener: (context, state) {
          print('Sayim: KullaniciGirisCubit durumu: $state');
          if ((state == 'loggedOut' || state == 'logoutError') && mounted && !barkodOkumaAktif) {
            if (!isProcessing) {
              print('Çıkış yapıldı, giriş ekranına yönlendiriliyor');
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const Kullanicigiris()),
                    (route) => false,
              );
            } else {
              logoutBeklemede = true;
            }
          }
        },
        child: Scaffold(
          key: _scaffoldMessengerKey,
          appBar: AppBar(
            title: InkWell(
              onTap: () {
                _kullaniciGirisCubit.resetInactivityTimer();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const Anasayfa()),
                      (route) => false,
                );
              },
              child: const Text("Anasayfa", style: TextStyle(color: Colors.white)),
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
          body: BlocConsumer<SayimCubit, SayimState>(
            listener: (context, state) {
              print('SayimCubit durumu: $state');
              if (state is SayimSuccess && mounted) {
                print('Sayım işlemi başarılı: ${state.sonuc}');
                _scaffoldMessengerKey.currentState?.showSnackBar(
                  SnackBar(
                    content: Text(state.sonuc),
                    backgroundColor: Colors.green,
                  ),
                );
                setState(() {
                  isProcessing = false;
                  adaNoController.clear();
                  siraNoController.clear();
                  barkodNoController.clear();
                  sayimNoController.clear();
                  statusMessage = state.sonuc;
                });
              } else if (state is SayimError && mounted) {
                print('Sayım işlemi hata: ${state.hata}');
                _scaffoldMessengerKey.currentState?.showSnackBar(
                  SnackBar(
                    content: Text(state.hata),
                    backgroundColor: Colors.red,
                  ),
                );
                setState(() {
                  isProcessing = false;
                  statusMessage = state.hata;
                });
              } else if (state is SayimLoading) {
                print('Sayım işlemi yükleniyor...');
              }
            },
            builder: (context, state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: isProcessing
                              ? null
                              : () {
                            _kullaniciGirisCubit.resetInactivityTimer();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const Sayimsorgu()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 12),
                            disabledBackgroundColor: Colors.grey,
                          ),
                          child: const Text("Sorgu", style: TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                        ElevatedButton(
                          onPressed: isProcessing
                              ? null
                              : () {
                            _kullaniciGirisCubit.resetInactivityTimer();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const Sayimgerial()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 12),
                            disabledBackgroundColor: Colors.grey,
                          ),
                          child: const Text("Geri Al", style: TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text("Ada No / Sıra No", style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: adaNoController,
                            decoration: const InputDecoration(border: OutlineInputBorder()),
                            enabled: !isProcessing,
                            onChanged: (_) => _kullaniciGirisCubit.resetInactivityTimer(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: siraNoController,
                            decoration: const InputDecoration(border: OutlineInputBorder()),
                            enabled: !isProcessing,
                            onChanged: (_) => _kullaniciGirisCubit.resetInactivityTimer(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text("Barkod No", style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: barkodNoController,
                            decoration: const InputDecoration(border: OutlineInputBorder()),
                            enabled: !isProcessing,
                            onChanged: (_) => _kullaniciGirisCubit.resetInactivityTimer(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.qr_code_scanner, size: 30),
                          onPressed: isProcessing ? null : _barkodOku,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text("Sicil No", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextField(
                      controller: sicilNoController,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      enabled: false, // Değiştirilmesin
                    ),
                    const SizedBox(height: 10),
                    const Text("Sayım No", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextField(
                      controller: sayimNoController,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      enabled: !isProcessing,
                      onChanged: (_) => _kullaniciGirisCubit.resetInactivityTimer(),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isProcessing ? null : () => _okutIslem(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          disabledBackgroundColor: Colors.grey,
                        ),
                        child: isProcessing
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("Okut", style: TextStyle(fontSize: 18, color: Colors.white)),
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
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}