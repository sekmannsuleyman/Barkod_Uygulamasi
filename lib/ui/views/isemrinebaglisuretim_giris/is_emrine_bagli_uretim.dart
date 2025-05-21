import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../ana_sayfa.dart';
import '../../../kullanici_girisi.dart';
import '../../../widgets/barkod_okuyucu.dart';
import '../../cubit/kullanici_giris_cubit/kullanici_giris_cubit.dart';
import '../../cubit/is_emrine_bagli_uretim_giris_cubit/is_emrine_bagli_uretim_cubit.dart';
import 'is_emri_uretimsil.dart';

class Isemrinebagliuretim extends StatefulWidget {
  const Isemrinebagliuretim({super.key});

  @override
  State<Isemrinebagliuretim> createState() => _IsemrinebagliuretimState();
}

class _IsemrinebagliuretimState extends State<Isemrinebagliuretim> {
  final isEmirNoController = TextEditingController();
  final barkodNoController = TextEditingController();
  final adaNoController = TextEditingController();
  final siraNoController = TextEditingController();
  final sicilNoController = TextEditingController();
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
    _loadSicilNo();
  }

  @override
  void dispose() {
    _kullaniciGirisCubit.stopInactivityTimer();
    isEmirNoController.dispose();
    barkodNoController.dispose();
    adaNoController.dispose();
    siraNoController.dispose();
    sicilNoController.dispose();
    super.dispose();
  }

  Future<void> _loadSicilNo() async {
    final prefs = await SharedPreferences.getInstance();
    final sicilNo = prefs.getString('kullanici_id') ?? '';
    setState(() {
      sicilNoController.text = sicilNo;
    });
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

  void _okutIslem() {
    if (isProcessing) return;

    final isEmirNo = isEmirNoController.text.trim();
    final barkodNo = barkodNoController.text.trim();
    final adaNo = adaNoController.text.trim();
    final siraNo = siraNoController.text.trim();

    if (isEmirNo.isEmpty || barkodNo.isEmpty || adaNo.isEmpty || siraNo.isEmpty) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Tüm alanlar doldurulmalıdır!')),
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
    context.read<IsEmrineBagliuretimCubit>().kaydetIsEmrineBagliuretim(
      isEmirNo,
      barkodNo,
      adaNo,
      siraNo,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<KullaniciGirisCubit, String>(
      listener: (context, state) {
        print('KullaniciGirisCubit durumu: $state');
        if ((state == 'loggedOut' || state == 'logoutError') && mounted && !barkodOkumaAktif) {
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
        body: BlocConsumer<IsEmrineBagliuretimCubit, IsEmrineBagliuretimState>(
          listener: (context, state) {
            print('IsEmrineBagliuretimCubit durumu: $state');
            if (state is IsEmrineBagliuretimSuccess) {
              print('Okut işlemi başarılı: ${state.sonuc}');
              _scaffoldMessengerKey.currentState?.showSnackBar(
                SnackBar(
                  content: Text(state.sonuc), // Sunucudan gelen mesajı doğrudan göster
                  backgroundColor: Colors.green,
                ),
              );
              setState(() {
                isProcessing = false;
                barkodNoController.clear();
                statusMessage = state.sonuc; // Sunucudan gelen mesajı kalıcı olarak göster
              });
            } else if (state is IsEmrineBagliuretimError) {
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
            } else if (state is IsEmrineBagliuretimLoading) {
              print('Okut işlemi yükleniyor...');
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
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
                        print('Üretim Silme butonuna basıldı');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const Isemriuretimsil(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        disabledBackgroundColor: Colors.grey,
                      ),
                      child: const Text(
                        "Üretim Silme",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
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
                      "Üretim Giriş",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildLabel("İş Emir No"),
                  _buildTextField(isEmirNoController),
                  _buildLabel("Barkod No"),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(barkodNoController)),
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
                  _buildLabel("Ada No / Sıra No"),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(adaNoController)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildTextField(siraNoController)),
                    ],
                  ),
                  _buildLabel("Sicil No"),
                  TextField(
                    controller: sicilNoController,
                    readOnly: true,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    sicilNoController.text.isEmpty
                        ? "Sicil No girilmedi"
                        : "Girilen Sicil No: ${sicilNoController.text}",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
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
                          statusMessage.toLowerCase().contains("kayıtlıdır") ||
                          statusMessage.toLowerCase().contains("bulunamadı") ||
                          statusMessage.toLowerCase().contains("stokta değil")
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
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 5),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(border: OutlineInputBorder()),
      onChanged: (_) => _kullaniciGirisCubit.resetInactivityTimer(),
      enabled: !isProcessing,
    );
  }
}