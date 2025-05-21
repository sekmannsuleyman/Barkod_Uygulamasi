import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../ana_sayfa.dart';
import '../../../kullanici_girisi.dart';
import '../../../widgets/barkod_okuyucu.dart';
import '../../cubit/kullanici_giris_cubit/kullanici_giris_cubit.dart';
import '../../cubit/transfer_hareketleri_cubit/malzeme_donusum_cubit.dart';
import 'emir_kalan.dart';
import 'transfer_hareketleri.dart';

class Malzemedonusum extends StatefulWidget {
  const Malzemedonusum({super.key});

  @override
  State<Malzemedonusum> createState() => _MalzemedonusumState();
}

class _MalzemedonusumState extends State<Malzemedonusum> {
  final emirNoController = TextEditingController();
  final eskiBarkodNoController = TextEditingController();
  final yeniBarkodNoController = TextEditingController();
  late final KullaniciGirisCubit _kullaniciGirisCubit;
  bool isProcessing = false;
  bool barkodOkumaAktif = false;
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
    emirNoController.dispose();
    eskiBarkodNoController.dispose();
    yeniBarkodNoController.dispose();
    super.dispose();
  }

  Future<void> _barkodOku(TextEditingController controller) async {
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
          barkodOkumaAktif = false;
          isProcessing = false;
        });
      }
      _kullaniciGirisCubit.resetInactivityTimer();
    }
  }

  void _okutIslem() {
    if (isProcessing) return;

    final emirNo = emirNoController.text.trim();
    final eskiBarkodNo = eskiBarkodNoController.text.trim();
    final yeniBarkodNo = yeniBarkodNoController.text.trim();

    if (emirNo.isEmpty) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Emir No boş olamaz!')),
      );
      return;
    }

    if (eskiBarkodNo.isEmpty) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Eski Barkod No boş olamaz!')),
      );
      return;
    }

    if (eskiBarkodNo.length != 12) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Eski Barkod No 12 karakter olmalıdır!')),
      );
      return;
    }

    if (yeniBarkodNo.isEmpty) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Yeni Barkod No boş olamaz!')),
      );
      return;
    }

    if (yeniBarkodNo.length != 12) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Yeni Barkod No 12 karakter olmalıdır!')),
      );
      return;
    }

    setState(() {
      isProcessing = true;
      statusMessage = ''; // Yeni işlem öncesi mesajı sıfırla
    });

    print('Okut işlemi başlatılıyor...');
    _kullaniciGirisCubit.resetInactivityTimer();
    context.read<MalzemeDonusumCubit>().kaydetMalzemeDonusumCubit(
      emirNo,
      eskiBarkodNo,
      yeniBarkodNo,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<KullaniciGirisCubit, String>(
      listener: (context, state) {
        print('Malzemedonusum: KullaniciGirisCubit durumu: $state');
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
                onPressed:
                    isProcessing
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
        body: BlocConsumer<MalzemeDonusumCubit, MalzemeDonusumState>(
          listener: (context, state) {
            print('MalzemeDonusumCubit durumu: $state');
            if (state is MalzemeDonusumSuccess) {
              print('Okut işlemi başarılı: ${state.sonuc}');
              _scaffoldMessengerKey.currentState?.showSnackBar(
                SnackBar(
                  content: Text('Başarılı: ${state.sonuc}'),
                  backgroundColor: Colors.green,
                ),
              );
              setState(() {
                isProcessing = false;
                emirNoController.clear();
                eskiBarkodNoController.clear();
                yeniBarkodNoController.clear();
                statusMessage = 'Malzeme dönüşüm işlemi başarıyla tamamlandı.';
              });
            } else if (state is MalzemeDonusumError) {
              print('Okut işlemi hata: ${state.hata}');
              _scaffoldMessengerKey.currentState?.showSnackBar(
                SnackBar(
                  content: Text('Hata: ${state.hata}'),
                  backgroundColor: Colors.red,
                ),
              );
              setState(() {
                isProcessing = false;
                statusMessage = 'Hata: Malzeme dönüşüm işlemi başarısız.';
              });
            } else if (state is MalzemeDonusumLoading) {
              print('Okut işlemi yükleniyor...');
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              child: Padding(
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
                                    print('Transfer butonuna basıldı');
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => const TransferHareketleri(),
                                      ),
                                    );
                                  },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            disabledBackgroundColor: Colors.grey,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 12,
                            ),
                          ),
                          child: const Text(
                            "Transfer",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                        ElevatedButton(
                          onPressed:
                              isProcessing
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
                            disabledBackgroundColor: Colors.grey,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 12,
                            ),
                          ),
                          child: const Text(
                            "Emir Kalan",
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
                        "Malzeme Dönüşümü",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildTextField("Emir No", emirNoController),
                    const SizedBox(height: 12),
                    _buildBarkodRow("Eski Barkod No", eskiBarkodNoController),
                    const SizedBox(height: 12),
                    _buildBarkodRow("Yeni Barkod No", yeniBarkodNoController),
                    const SizedBox(height: 10),
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
                    // Kalıcı uyarı mesajı
                    Text(
                      statusMessage,
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            statusMessage.contains('Hata')
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
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          onChanged: (_) => _kullaniciGirisCubit.resetInactivityTimer(),
          enabled: !isProcessing,
        ),
      ],
    );
  }

  Widget _buildBarkodRow(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                onChanged: (_) => _kullaniciGirisCubit.resetInactivityTimer(),
                enabled: !isProcessing,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.qr_code_scanner,
                size: 30,
                color: Colors.black54,
              ),
              onPressed: isProcessing ? null : () => _barkodOku(controller),
            ),
          ],
        ),
      ],
    );
  }
}
