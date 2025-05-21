import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../ana_sayfa.dart';
import '../../../kullanici_girisi.dart';
import '../../../widgets/barkod_okuyucu.dart';
import '../../cubit/kullanici_giris_cubit/kullanici_giris_cubit.dart';
import '../../cubit/sevkiyat_yukleme_cubit/sevkiyat_yukleme_cubit.dart';
import 'sevkiyat_sorgu.dart';
import 'sevkiyat_yukleme_iptal.dart';

class SevkiyatYukleme extends StatefulWidget {
  const SevkiyatYukleme({super.key});

  @override
  State<SevkiyatYukleme> createState() => _SevkiyatYuklemeState();
}

class _SevkiyatYuklemeState extends State<SevkiyatYukleme> {
  final sicilNoController = TextEditingController();
  final emirNoController = TextEditingController();
  final barkodNoController = TextEditingController();
  final agirlikController = TextEditingController();
  late final KullaniciGirisCubit _kullaniciGirisCubit;
  bool isProcessing = false;
  String statusMessage = ''; // Durum mesajı için yeni değişken
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  final FocusNode emirNoFocusNode = FocusNode();
  final FocusNode barkodNoFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _kullaniciGirisCubit = context.read<KullaniciGirisCubit>();
    _kullaniciGirisCubit.startInactivityTimer();
    _loadSicilNo();
  }

  @override
  void dispose() {
    // Klavyeyi kapat ve FocusNode'ları temizle
    emirNoFocusNode.unfocus();
    barkodNoFocusNode.unfocus();
    emirNoFocusNode.dispose();
    barkodNoFocusNode.dispose();
    _kullaniciGirisCubit.stopInactivityTimer();
    sicilNoController.dispose();
    emirNoController.dispose();
    barkodNoController.dispose();
    agirlikController.dispose();
    super.dispose();
  }

  Future<void> _loadSicilNo() async {
    final prefs = await SharedPreferences.getInstance();
    final sicilNo = prefs.getString('kullanici_id') ?? '';
    if (mounted) {
      setState(() {
        sicilNoController.text = sicilNo;
      });
    }
  }

  void _barkodOku() async {
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
          isProcessing = false;
        });
      }
      _kullaniciGirisCubit.resetInactivityTimer();
    }
  }

  void _agirlikGetir() {
    if (isProcessing) return;

    _kullaniciGirisCubit.resetInactivityTimer();
    final emirNo = emirNoController.text.trim();
    if (emirNo.isEmpty || emirNo.length < 2) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Geçerli Emir No giriniz.')),
      );
      return;
    }

    setState(() {
      isProcessing = true;
    });

    print('Ağırlık butonuna basıldı');
    context.read<SevkiyatYuklemeCubit>().getAgirlik(emirNo);
  }

  void _okutGonder() {
    if (isProcessing) return;

    _kullaniciGirisCubit.resetInactivityTimer();
    final emirNo = emirNoController.text.trim();
    final barkodNo = barkodNoController.text.trim();
    final sicilNo = sicilNoController.text.trim();

    if (emirNo.isEmpty) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Emir No boş olamaz!')),
      );
      return;
    }
    if (barkodNo.length != 12) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Barkod No 12 karakter olmalıdır!')),
      );
      return;
    }

    setState(() {
      isProcessing = true;
      statusMessage = ''; // Yeni işlem öncesi mesajı sıfırla
    });

    print('Okut butonuna basıldı - İşlem başlıyor');
    context.read<SevkiyatYuklemeCubit>().kaydetSevkiyatYuklemeCubit(emirNo, barkodNo, sicilNo);
  }

  void _navigateToScreen(Widget screen) {
    // Klavyeyi kapat
    emirNoFocusNode.unfocus();
    barkodNoFocusNode.unfocus();
    // Ekran değişimini bir frame sonrasına ertele
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      }
    });
  }

  void _navigateAndRemoveUntil(Widget screen) {
    // Klavyeyi kapat
    emirNoFocusNode.unfocus();
    barkodNoFocusNode.unfocus();
    // Ekran değişimini bir frame sonrasına ertele
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => screen),
              (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _kullaniciGirisCubit.resetInactivityTimer();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Anasayfa()),
              (route) => false,
        );
        return true; // Navigasyon tamamlandı, geri tuşu işlendi
      },
      child: BlocListener<KullaniciGirisCubit, String>(
        listener: (context, state) {
          print('SevkiyatYukleme: KullaniciGirisCubit durumu: $state');
          if ((state == 'loggedOut' || state == 'logoutError') && mounted) {
            if (!isProcessing) {
              print('Çıkış yapıldı, giriş ekranına yönlendiriliyor');
              _navigateAndRemoveUntil(const Kullanicigiris());
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
                _navigateAndRemoveUntil(const Anasayfa());
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
                    await context.read<KullaniciGirisCubit>().cikisYap();
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
          body: GestureDetector(
            onTap: () {
              print('SevkiyatYukleme: Kullanıcı etkileşimi: Dokunma');
              _kullaniciGirisCubit.resetInactivityTimer();
            },
            behavior: HitTestBehavior.opaque,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(width: 1, height: 1),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 17.0),
                          child: ElevatedButton(
                            onPressed: isProcessing
                                ? null
                                : () {
                              _kullaniciGirisCubit.resetInactivityTimer();
                              print('İptal butonuna basıldı');
                              _navigateToScreen(const Sevkiyatyuklemeiptal());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                              disabledBackgroundColor: Colors.grey,
                            ),
                            child: const Text("İptal", style: TextStyle(color: Colors.white, fontSize: 16)),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: ElevatedButton(
                            onPressed: isProcessing
                                ? null
                                : () {
                              _kullaniciGirisCubit.resetInactivityTimer();
                              print('Sorgu butonuna basıldı');
                              _navigateToScreen(const Sevkiyatsorgu());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                              disabledBackgroundColor: Colors.grey,
                            ),
                            child: const Text("Sorgu", style: TextStyle(color: Colors.white, fontSize: 16)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text("Sicil No", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  TextField(
                    controller: sicilNoController,
                    readOnly: true,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    sicilNoController.text.isEmpty ? "Sicil No girilmedi" : "Girilen Sicil No: ${sicilNoController.text}",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  const Text("Emir No", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  TextField(
                    controller: emirNoController,
                    focusNode: emirNoFocusNode,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    onChanged: (value) => _kullaniciGirisCubit.resetInactivityTimer(),
                    enabled: !isProcessing,
                  ),
                  const SizedBox(height: 10),
                  const Text("Barkod No", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: barkodNoController,
                          focusNode: barkodNoFocusNode,
                          decoration: const InputDecoration(border: OutlineInputBorder()),
                          maxLength: 12,
                          onChanged: (value) => _kullaniciGirisCubit.resetInactivityTimer(),
                          enabled: !isProcessing,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.qr_code_scanner, size: 30),
                        onPressed: isProcessing ? null : _barkodOku,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: agirlikController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(border: OutlineInputBorder()),
                          readOnly: true,
                          onChanged: (value) => _kullaniciGirisCubit.resetInactivityTimer(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: isProcessing ? null : _agirlikGetir,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          disabledBackgroundColor: Colors.grey[500],
                        ),
                        child: const Text("Ağırlık", style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  BlocConsumer<SevkiyatYuklemeCubit, SevkiyatYuklemeState>(
                    listener: (context, state) {
                      if (mounted) {
                        if (state.message != null) {
                          print('Okut işlemi tamamlandı - Mesaj: ${state.message}');
                          final isSuccess = state.message!.toLowerCase().contains("başarıyla");
                          _scaffoldMessengerKey.currentState?.showSnackBar(
                            SnackBar(
                              content: Text(state.message!),
                              backgroundColor: isSuccess ? Colors.green : Colors.red,
                            ),
                          );
                          setState(() {
                            isProcessing = false;
                            barkodNoController.clear();
                            statusMessage = state.message!;
                          });
                        } else if (state.agirlik != null) {
                          print('Ağırlık işlemi tamamlandı - Ağırlık: ${state.agirlik}');
                          setState(() {
                            isProcessing = false;
                            agirlikController.text = state.agirlik!;
                          });
                          _scaffoldMessengerKey.currentState?.showSnackBar(
                            const SnackBar(
                              content: Text('Ağırlık başarıyla alındı.'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          print('Okut işlemi - State güncellendi ama mesaj veya ağırlık yok');
                        }
                      }
                    },
                    builder: (context, state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: isProcessing ? null : _okutGonder,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                disabledBackgroundColor: Colors.grey,
                              ),
                              child: isProcessing
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text("Okut", style: TextStyle(fontSize: 18, color: Colors.white)),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            statusMessage,
                            style: TextStyle(
                              fontSize: 16,
                              color: statusMessage.toLowerCase().contains("başarıyla") ? Colors.green : Colors.red,
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
        ),
      ),
    );
  }
}