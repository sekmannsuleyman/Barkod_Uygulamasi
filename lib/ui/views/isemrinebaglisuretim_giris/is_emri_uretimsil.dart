import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../ana_sayfa.dart';
import '../../../kullanici_girisi.dart';
import '../../../widgets/barkod_okuyucu.dart';
import '../../cubit/kullanici_giris_cubit/kullanici_giris_cubit.dart';
import '../../cubit/is_emrine_bagli_uretim_giris_cubit/is_emrine_bagli_uretim_silme_cubit.dart';
import 'is_emrine_bagli_uretim.dart';

class Isemriuretimsil extends StatefulWidget {
  const Isemriuretimsil({super.key});

  @override
  State<Isemriuretimsil> createState() => _IsemriuretimsilState();
}

class _IsemriuretimsilState extends State<Isemriuretimsil> {
  final isEmirNoController = TextEditingController();
  final barkodNoController = TextEditingController();
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
    isEmirNoController.dispose();
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

  void _okutIslem() {
    if (isProcessing) return;

    final isEmirNo = isEmirNoController.text.trim();
    final barkodNo = barkodNoController.text.trim();

    if (isEmirNo.isEmpty || barkodNo.isEmpty) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('İş Emir No ve Barkod No girilmelidir!')),
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
    context.read<IsEmrineBagliUretimSilmeCubit>().kaydetIsEmrineBagliuretimSilme(
      isEmirNo,
      barkodNo,
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
            MaterialPageRoute(builder: (_) => const Kullanicigiris()),
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
        body: BlocConsumer<IsEmrineBagliUretimSilmeCubit, IsEmrineBagliUretimSilmeState>(
          listener: (context, state) {
            print('IsEmrineBagliUretimSilmeCubit durumu: $state');
            if (state is IsEmrineBagliUretimSilmeSuccess) {
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
            } else if (state is IsEmrineBagliUretimSilmeError) {
              print('Okut işlemi hata: ${state.hata}');
              _scaffoldMessengerKey.currentState?.showSnackBar(
                SnackBar(
                  content: Text('Hata: ${state.hata}'),
                  backgroundColor: Colors.red,
                ),
              );
              setState(() {
                isProcessing = false;
                statusMessage = 'Hata: ${state.hata}';
              });
            } else if (state is IsEmrineBagliUretimSilmeLoading) {
              print('Okut işlemi yükleniyor...');
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isProcessing
                            ? null
                            : () {
                          _kullaniciGirisCubit.resetInactivityTimer();
                          print('Üretim Giriş butonuna basıldı');
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const Isemrinebagliuretim()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          disabledBackgroundColor: Colors.grey,
                        ),
                        child: const Text(
                          "Üretim Giriş",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
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
                          "Üretim Silme",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("İş Emir No"),
                        _buildTextField(isEmirNoController),
                        const SizedBox(height: 10),
                        _buildLabel("Barkod No"),
                        Row(
                          children: [
                            Expanded(child: _buildTextField(barkodNoController)),
                            IconButton(
                              icon: const Icon(Icons.qr_code_scanner, size: 30, color: Colors.black54),
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
                              disabledBackgroundColor: Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
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
                                statusMessage.toLowerCase().contains("silemezsiniz") ||
                                statusMessage.toLowerCase().contains("bulunamadı") ||
                                statusMessage.toLowerCase().contains("stokta değil")
                                ? Colors.red
                                : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
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