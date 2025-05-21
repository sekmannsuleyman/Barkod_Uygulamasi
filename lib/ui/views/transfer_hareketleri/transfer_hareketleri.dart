import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../ana_sayfa.dart';
import '../../../kullanici_girisi.dart';
import '../../../widgets/barkod_okuyucu.dart';
import '../../cubit/kullanici_giris_cubit/kullanici_giris_cubit.dart';
import '../../cubit/transfer_hareketleri_cubit/transfer_hareketleri_cubit.dart';
import 'emir_kalan.dart';
import 'malzeme_donusum.dart';

class TransferHareketleri extends StatefulWidget {
  const TransferHareketleri({super.key});

  @override
  State<TransferHareketleri> createState() => _TransferHareketleriState();
}

class _TransferHareketleriState extends State<TransferHareketleri> {
  final adaNoController = TextEditingController();
  final siraNoController = TextEditingController();
  final emirNoController = TextEditingController();
  final barkodNoController = TextEditingController();
  late final KullaniciGirisCubit _kullaniciGirisCubit;
  bool barkodOkumaAktif = false;
  bool isProcessing = false;
  String statusMessage = ''; // Kalıcı uyarı mesajı için
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
    adaNoController.dispose();
    siraNoController.dispose();
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

    final adaNo = adaNoController.text.trim();
    final siraNo = siraNoController.text.trim();
    final emirNo = emirNoController.text.trim();
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

    if (emirNo.isEmpty) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Emir No boş olamaz!')),
      );
      return;
    }

    if (emirNo.length < 10) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('Emir No 10 veya daha fazla karakter olmalıdır!'),
        ),
      );
      return;
    }

    if (barkodNo.isEmpty) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Barkod No boş olamaz!')),
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

    print('Okut işlemi başlatılıyor...');
    _kullaniciGirisCubit.resetInactivityTimer();
    context.read<TransferHareketleriCubit>().kaydetTransferHareketleriCubit(
      adaNo,
      siraNo,
      emirNo,
      barkodNo,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<KullaniciGirisCubit, String>(
      listener: (context, state) {
        print('TransferHareketleri: KullaniciGirisCubit durumu: $state');
        if ((state == 'loggedOut' || state == 'logoutError') &&
            mounted &&
            !barkodOkumaAktif) {
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Anasayfa()),
              );
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
        body: BlocConsumer<TransferHareketleriCubit, TransferHareketleriState>(
          listener: (context, state) {
            print('TransferHareketleriCubit durumu: $state');
            if (state is TransferHareketleriSuccess) {
              print('Okut işlemi başarılı: ${state.sonuc}');
              _scaffoldMessengerKey.currentState?.showSnackBar(
                SnackBar(
                  content: Text('Başarılı: ${state.sonuc}'),
                  backgroundColor: Colors.green,
                ),
              );
              setState(() {
                isProcessing = false;
                barkodNoController.clear();
                statusMessage = 'Başarılı: ${state.sonuc}';
              });
            } else if (state is TransferHareketleriError) {
              print('Okut işlemi hata: ${state.hata}');
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
            } else if (state is TransferHareketleriLoading) {
              print('Okut işlemi yükleniyor...');
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(18.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: isProcessing
                              ? null
                              : () {
                            _kullaniciGirisCubit.resetInactivityTimer();
                            print('Malzeme Dönüşüm butonuna basıldı');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const Malzemedonusum(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 12,
                            ),
                            disabledBackgroundColor: Colors.grey,
                          ),
                          child: const Text(
                            "Malzeme Dönüşüm",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                        const SizedBox(width: 4),
                        ElevatedButton(
                          onPressed: isProcessing
                              ? null
                              : () {
                            _kullaniciGirisCubit.resetInactivityTimer();
                            print('Emir Kalan butonuna basıldı');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const Emirkalan(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 45,
                              vertical: 12,
                            ),
                            disabledBackgroundColor: Colors.grey,
                          ),
                          child: const Text(
                            "Emir Kalan",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField("Ada No", adaNoController),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField("Sıra No", siraNoController),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildTextField("Emir No", emirNoController),
                    const SizedBox(height: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
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
                    // Kalıcı uyarı mesajı
                    Text(
                      statusMessage,
                      style: TextStyle(
                        fontSize: 16,
                        color: statusMessage.toLowerCase().contains("hata") ||
                            statusMessage.toLowerCase().contains("bulunamadı") ||
                            statusMessage.toLowerCase().contains("stokta değil")
                            ? Colors.red
                            : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(10),
          ),
          onChanged: (_) => _kullaniciGirisCubit.resetInactivityTimer(),
          enabled: !isProcessing,
        ),
      ],
    );
  }
}