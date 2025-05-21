import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../ana_sayfa.dart';
import '../../../kullanici_girisi.dart';
import '../../../widgets/barkod_okuyucu.dart';
import '../../cubit/kullanici_giris_cubit/kullanici_giris_cubit.dart';
import '../../cubit/uretim_giris_cubit/uretim_giris_cubit.dart';
import 'uretim_kismi_iptal.dart';
import 'uretim_silme.dart';

class Uretimgiris extends StatefulWidget {
  const Uretimgiris({super.key});

  @override
  State<Uretimgiris> createState() => _UretimgirisState();
}

class _UretimgirisState extends State<Uretimgiris> {
  final TextEditingController emirNoController = TextEditingController();
  final TextEditingController barkodNoController = TextEditingController();
  late final KullaniciGirisCubit _kullaniciGirisCubit;
  bool barkodOkumaAktif = false;
  bool isProcessing = false;
  String statusMessage = '';
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

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
          builder:
              (_) => BarkodOkuyucu(
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

    final emirNo = emirNoController.text.trim();
    final barkodNo = barkodNoController.text.trim();

    if (emirNo.isEmpty) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Emir No boş olamaz!')),
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
      statusMessage = '';
    });

    _kullaniciGirisCubit.resetInactivityTimer();

    context.read<UretimGirisCubit>().uretimGirisYap(emirNo, barkodNo);
  }

  void _navigateToScreen(Widget screen) {
    if (mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    }
  }

  void _navigateAndRemoveUntil(Widget screen) {
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => screen),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _kullaniciGirisCubit.resetInactivityTimer();
        _navigateAndRemoveUntil(const Anasayfa());
        return false;
      },
      child: BlocListener<KullaniciGirisCubit, String>(
        listener: (context, state) {
          print('Uretimgiris: KullaniciGirisCubit durumu: $state');
          if ((state == 'loggedOut' || state == 'logoutError') &&
              mounted &&
              !barkodOkumaAktif) {
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
                _navigateAndRemoveUntil(const Anasayfa());
              },
              child: const Text(
                "Anasayfa",
                style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: ElevatedButton(
                  onPressed:
                      isProcessing
                          ? null
                          : () async {
                            _kullaniciGirisCubit.resetInactivityTimer();
                            print('Çıkış butonuna basıldı');
                            _scaffoldMessengerKey.currentState?.showSnackBar(
                              const SnackBar(
                                content: Text('Çıkış yapılıyor...'),
                              ),
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
          body: BlocConsumer<UretimGirisCubit, UretimGirisState>(
            listener: (context, state) {
              if (!mounted) return;
              if (state is UretimGirisSuccess) {
                print('Üretim giriş başarılı: ${state.sonuc}');
                _scaffoldMessengerKey.currentState?.showSnackBar(
                  const SnackBar(
                    content: Text('Üretim girişi başarıyla tamamlandı.'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 5), // Süreyi artırdım
                  ),
                );
                setState(() {
                  isProcessing = false;
                  statusMessage = 'Üretim girişi başarıyla tamamlandı.';
                  emirNoController.clear();
                  barkodNoController.clear();
                });
              } else if (state is UretimGirisError) {
                print('Üretim giriş hata: ${state.hata}');
                _scaffoldMessengerKey.currentState?.showSnackBar(
                  SnackBar(
                    content: Text(
                      state.hata.contains("Ürün bulunamadı")
                          ? 'Hata: Ürün bulunamadı, lütfen geçerli bir ürün giriniz.'
                          : 'Hata: ${state.hata}',
                    ),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 5), // Süreyi artırdım
                  ),
                );
                setState(() {
                  isProcessing = false;
                  statusMessage =
                      state.hata.contains("Ürün bulunamadı")
                          ? 'Hata: Ürün bulunamadı, lütfen geçerli bir ürün giriniz.'
                          : 'Hata: ${state.hata}';
                });
              } else if (state is UretimGirisLoading) {
                print('Üretim giriş yükleniyor...');
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
                          onPressed:
                              isProcessing
                                  ? null
                                  : () {
                                    _kullaniciGirisCubit.resetInactivityTimer();
                                    _navigateToScreen(const Uretimsilme());
                                  },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 12,
                            ),
                            disabledBackgroundColor: Colors.grey,
                          ),
                          child: const Text(
                            "Üretim Silme",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                        ElevatedButton(
                          onPressed:
                              isProcessing
                                  ? null
                                  : () {
                                    _kullaniciGirisCubit.resetInactivityTimer();
                                    _navigateToScreen(const Uretimkismiiptal());
                                  },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 12,
                            ),
                            disabledBackgroundColor: Colors.grey,
                          ),
                          child: const Text(
                            "Kısmı İptal",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(top: 15),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text(
                        "Üretim Giriş",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Emir No",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextField(
                      controller: emirNoController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(10),
                      ),
                      enabled: !isProcessing,
                      onChanged:
                          (_) => _kullaniciGirisCubit.resetInactivityTimer(),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Barkod No",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
                            enabled: !isProcessing,
                            onChanged:
                                (_) =>
                                    _kullaniciGirisCubit.resetInactivityTimer(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.qr_code_scanner,
                            size: 30,
                            color: Colors.black54,
                          ),
                          onPressed: isProcessing ? null : _barkodOku,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isProcessing ? null : _okutuIsle,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          disabledBackgroundColor: Colors.grey,
                        ),
                        child:
                            isProcessing
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : const Text(
                                  "Okut",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      statusMessage,
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            statusMessage.contains("Hata")
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
