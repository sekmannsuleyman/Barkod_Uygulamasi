import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../ana_sayfa.dart';
import '../../../kullanici_girisi.dart';
import '../../../widgets/barkod_okuyucu.dart';
import '../../cubit/kullanici_giris_cubit/kullanici_giris_cubit.dart';
import '../../cubit/uretim_giris_cubit/uretim_kismi_iptal.dart';
import 'uretim_giris.dart';
import 'uretim_silme.dart';

class Uretimkismiiptal extends StatefulWidget {
  const Uretimkismiiptal({super.key});

  @override
  State<Uretimkismiiptal> createState() => _UretimkismiiptalState();
}

class _UretimkismiiptalState extends State<Uretimkismiiptal> {
  final TextEditingController belgeNoController = TextEditingController();
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
    belgeNoController.dispose();
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

  void _okutIslem() {
    if (isProcessing) return;

    final belgeNo = belgeNoController.text.trim();
    final paletBarkodNo = barkodNoController.text.trim();

    if (belgeNo.isEmpty) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Belge No girilmelidir!')),
      );
      return;
    }

    if (belgeNo.length < 3) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Belge No en az 3 karakter olmalıdır (örn. DOC123)!')),
      );
      return;
    }

    if (paletBarkodNo.isEmpty) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Palet Barkod No girilmelidir!')),
      );
      return;
    }

    if (paletBarkodNo.length != 12) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Palet Barkod No tam 12 karakter olmalıdır (örn. X03P03536531)!')),
      );
      return;
    }

    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(belgeNo) || !RegExp(r'^[A-Z0-9]+$').hasMatch(paletBarkodNo)) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Belge No ve Palet Barkod No sadece harf ve rakam içermelidir!')),
      );
      return;
    }

    setState(() {
      isProcessing = true;
      statusMessage = '';
    });

    _kullaniciGirisCubit.resetInactivityTimer();

    print('Okut işlemi başlatılıyor - Belge No: $belgeNo, Palet Barkod No: $paletBarkodNo');
    context.read<UretimKismiIptalCubit>().kaydetUretimKismiIptal(
      belgeNo,
      paletBarkodNo,
    );
  }

  void _navigateToScreen(Widget screen) {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => screen),
      );
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
          print('Uretimkismiiptal: KullaniciGirisCubit durumu: $state');
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
                  onPressed: isProcessing
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
          body: BlocConsumer<UretimKismiIptalCubit, UretimKismiIptalState>(
            listener: (context, state) {
              if (!mounted) return;
              if (state is UretimKismiIptalSuccess) {
                print('Üretim kısmi iptal başarılı: ${state.sonuc}');
                _scaffoldMessengerKey.currentState?.showSnackBar(
                  SnackBar(
                    content: Text(state.sonuc),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 5),
                  ),
                );
                setState(() {
                  isProcessing = false;
                  statusMessage = state.sonuc;
                  belgeNoController.clear();
                  barkodNoController.clear();
                });
              } else if (state is UretimKismiIptalError) {
                print('Üretim kısmi iptal hata: ${state.hata}');
                _scaffoldMessengerKey.currentState?.showSnackBar(
                  SnackBar(
                    content: Text(state.hata),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 5),
                  ),
                );
                setState(() {
                  isProcessing = false;
                  statusMessage = state.hata;
                });
              } else if (state is UretimKismiIptalLoading) {
                print('Üretim kısmi iptal yükleniyor...');
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
                            _navigateToScreen(const Uretimgiris());
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
                            "Üretim Giriş",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: isProcessing
                              ? null
                              : () {
                            _kullaniciGirisCubit.resetInactivityTimer();
                            _navigateToScreen(const Uretimsilme());
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
                            "Üretim Silme",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text(
                        "Üretim Kısmı İptal",
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
                      "Belge No",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextField(
                      controller: belgeNoController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Belge No girin (örn. DOC123, en az 3 karakter)',
                      ),
                      onChanged: (_) => _kullaniciGirisCubit.resetInactivityTimer(),
                      enabled: !isProcessing,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Palet Barkod No",
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
                              hintText: '12 karakter barkod (örn. X03P03536531)',
                            ),
                            maxLength: 12,
                            onChanged: (_) =>
                                _kullaniciGirisCubit.resetInactivityTimer(),
                            enabled: !isProcessing,
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
                        onPressed: isProcessing ? null : _okutIslem,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          disabledBackgroundColor: Colors.grey,
                        ),
                        child: isProcessing
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
                        color: statusMessage.toLowerCase().contains("başarıyla")
                            ? Colors.green
                            : Colors.red,
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