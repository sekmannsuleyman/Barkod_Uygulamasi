import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../ana_sayfa.dart';
import '../../../kullanici_girisi.dart';
import '../../../widgets/barkod_okuyucu.dart';
import '../../cubit/kullanici_giris_cubit/kullanici_giris_cubit.dart';
import '../../cubit/sevkiyat_yukleme_cubit/sevkiyat_yukleme_iptal_cıbit.dart';
import 'sevkiyat_sorgu.dart';
import 'sevkiyat_yukleme.dart';

class Sevkiyatyuklemeiptal extends StatefulWidget {
  const Sevkiyatyuklemeiptal({super.key});

  @override
  State<Sevkiyatyuklemeiptal> createState() => _SevkiyatyuklemeiptalState();
}

class _SevkiyatyuklemeiptalState extends State<Sevkiyatyuklemeiptal> {
  final emirNoController = TextEditingController();
  final barkodNoController = TextEditingController();
  late final KullaniciGirisCubit _kullaniciGirisCubit;
  bool barkodOkumaAktif = false;
  bool isProcessing = false;
  String statusMessage = ''; // Durum mesajı için yeni değişken
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
    emirNoController.dispose();
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
      }
      _kullaniciGirisCubit.resetInactivityTimer();
    }
  }

  void _okutuIsle() {
    if (isProcessing) return;

    if (emirNoController.text.isEmpty || barkodNoController.text.isEmpty) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Emir No ve Barkod No alanları doldurulmalıdır!')),
      );
      return;
    }

    setState(() {
      isProcessing = true;
      statusMessage = ''; // Yeni işlem öncesi mesajı sıfırla
    });

    _kullaniciGirisCubit.resetInactivityTimer();

    context.read<SevkiyatYuklemeIptalCubit>().kaydetSevkiyatYuklemeIptalCubit(
      emirNoController.text,
      barkodNoController.text,
    );
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
        return false;
      },
      child: BlocListener<KullaniciGirisCubit, String>(
        listener: (context, state) {
          print('KullaniciGirisCubit durumu: $state');
          if ((state == 'loggedOut' || state == 'logoutError') && mounted) {
            if (!barkodOkumaAktif && !isProcessing) {
              print('Çıkış yapıldı, giriş ekranına yönlendiriliyor');
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const Kullanicigiris()),
                    (route) => false,
              );
            } else {
              print('Barkod okuma veya işlem sırasında logout engellendi.');
            }
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
          body: BlocConsumer<SevkiyatYuklemeIptalCubit, SevkiyatYuklemeIptalState>(
            listener: (context, state) {
              if (mounted) {
                if (state.message != null) {
                  print('Okut işlemi tamamlandı - Mesaj: ${state.message}');
                  _scaffoldMessengerKey.currentState?.showSnackBar(
                    SnackBar(
                      content: Text(
                        state.message!.contains("Hata")
                            ? "Sevkiyat iptal işlemi başarısız oldu. Sunucu ile bağlantı sağlanamadı."
                            : "Sevkiyat iptal işlemi başarıyla tamamlandı.",
                      ),
                      backgroundColor: state.message!.contains("Hata") ? Colors.red : Colors.green,
                      action: state.message!.contains("Hata")
                          ? SnackBarAction(
                        label: 'Yeniden Dene',
                        textColor: Colors.white,
                        onPressed: () {
                          _okutuIsle();
                        },
                      )
                          : null,
                    ),
                  );
                  setState(() {
                    isProcessing = false;
                    emirNoController.clear();
                    barkodNoController.clear();
                    statusMessage = state.message!.contains("Hata")
                        ? "İptal işlemi başarısız: ${state.message}"
                        : "İptal işlemi onaylandı.";
                  });
                }
              }
            },
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.all(15.0),
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
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const SevkiyatYukleme()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(horizontal: 65, vertical: 12),
                            disabledBackgroundColor: Colors.grey,
                          ),
                          child: const Text("Yükleme", style: TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                        ElevatedButton(
                          onPressed: isProcessing
                              ? null
                              : () {
                            _kullaniciGirisCubit.resetInactivityTimer();
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const Sevkiyatsorgu()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(horizontal: 65, vertical: 12),
                            disabledBackgroundColor: Colors.grey,
                          ),
                          child: const Text("Sorgu", style: TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(5)),
                      child: const Text(
                        "Sevkiyat Yükleme İptal",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text("Emir No", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    TextField(
                      controller: emirNoController,
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
                            decoration: const InputDecoration(border: OutlineInputBorder()),
                            onChanged: (value) => _kullaniciGirisCubit.resetInactivityTimer(),
                            enabled: !isProcessing,
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(Icons.qr_code_scanner, size: 32, color: Colors.black54),
                          onPressed: isProcessing ? null : _barkodOku,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isProcessing ? null : _okutuIsle,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          disabledBackgroundColor: Colors.grey,
                        ),
                        child: state.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("Okut", style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Durum mesajını ekranda göster
                    Text(
                      statusMessage,
                      style: TextStyle(
                        fontSize: 16,
                        color: statusMessage.contains("başarısız") ? Colors.red : Colors.green,
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