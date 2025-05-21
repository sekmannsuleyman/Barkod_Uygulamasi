import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../ana_sayfa.dart';
import '../../../kullanici_girisi.dart';
import '../../../widgets/barkod_okuyucu.dart';
import '../../cubit/kullanici_giris_cubit/kullanici_giris_cubit.dart';
import '../../cubit/sarfa_cikis_cubit/sarfa_cikis_cubit.dart';
import 'sarfa_sorgu.dart';

class SarfaCikis extends StatefulWidget {
  const SarfaCikis({super.key});

  @override
  State<SarfaCikis> createState() => _SarfaCikisState();
}

class _SarfaCikisState extends State<SarfaCikis> {
  final barkodNoController = TextEditingController();
  final maliyetMerkeziController = TextEditingController();
  final depoController = TextEditingController(text: '500'); // Varsayılan değer
  final miktarController = TextEditingController(text: '0,000');
  late final KullaniciGirisCubit _kullaniciGirisCubit;

  bool barkodOkumaAktif = false;
  bool isProcessing = false;
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
    barkodNoController.dispose();
    maliyetMerkeziController.dispose();
    depoController.dispose();
    miktarController.dispose();
    super.dispose();
  }

  Future<void> _barkodOku() async {
    if (isProcessing) return;

    _kullaniciGirisCubit.resetInactivityTimer();
    setState(() {
      barkodOkumaAktif = true;
      isProcessing = true;
    });

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BarkodOkuyucu(
          onBarkodDetected: (code) {
            if (mounted) {
              setState(() {
                barkodNoController.text = code;
              });
            }
          },
        ),
      ),
    );

    if (mounted) {
      setState(() {
        barkodOkumaAktif = false;
        isProcessing = false;
      });
    }
    _kullaniciGirisCubit.resetInactivityTimer();
  }

  void _okutIslem() {
    if (isProcessing) return;

    final barkodNo = barkodNoController.text.trim();
    final maliyetMerkezi = maliyetMerkeziController.text.trim();
    final depo = depoController.text.trim();
    final miktar = miktarController.text.trim();

    if (barkodNo.isEmpty) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Barkod No boş olamaz!')),
      );
      return;
    }

    if (maliyetMerkezi.isEmpty) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Maliyet Merkezi boş olamaz!')),
      );
      return;
    }

    if (maliyetMerkezi.length != 6) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Maliyet Merkezi 6 karakter olmalıdır!')),
      );
      return;
    }

    if (depo.isEmpty) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Depo boş olamaz!')),
      );
      return;
    }

    if (miktar.isEmpty) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Miktar boş olamaz!')),
      );
      return;
    }

    double? miktarDouble;
    try {
      miktarDouble = double.parse(miktar.replaceAll(',', '.'));
      if (miktarDouble <= 0) {
        throw Exception();
      }
    } catch (e) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Miktar geçersiz bir sayı formatında!')),
      );
      return;
    }

    setState(() {
      isProcessing = true;
    });

    print('Okut işlemi başlatılıyor...');
    _kullaniciGirisCubit.resetInactivityTimer();
    context.read<SarfaCikisCubit>().kaydetSarfaCikisCubit(
      barkodNo,
      maliyetMerkezi,
      depo,
      miktar,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<KullaniciGirisCubit, String>(
      listener: (context, state) {
        if ((state == 'loggedOut' || state == 'logoutError') && mounted && !barkodOkumaAktif) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const Kullanicigiris()),
                (route) => false,
          );
        }
      },
      child: _buildScaffold(),
    );
  }

  Scaffold _buildScaffold() {
    return Scaffold(
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
      body: BlocConsumer<SarfaCikisCubit, SarfaCikisState>(
        listener: (context, state) {
          if (state is SarfaCikisSuccess) {
            print('Sarfa çıkış başarılı: ${state.sonuc}');
            _scaffoldMessengerKey.currentState?.showSnackBar(
              SnackBar(
                content: Text('Başarılı: ${state.sonuc}'),
                backgroundColor: Colors.green,
              ),
            );
            setState(() {
              isProcessing = false;
              barkodNoController.clear();
              miktarController.text = '0,000';
            });
          } else if (state is SarfaCikisError) {
            print('Sarfa çıkış hata: ${state.hata}');
            _scaffoldMessengerKey.currentState?.showSnackBar(
              SnackBar(
                content: Text('Hata: ${state.hata}'),
                backgroundColor: Colors.red,
              ),
            );
            setState(() {
              isProcessing = false;
            });
          } else if (state is SarfaCikisConfirm) {
            setState(() {
              isProcessing = false;
            });
            final result = state.result;
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Onay'),
                  content: Text(
                    'Bu işlemden sonra kalan stok adedi ${result['kalanMiktar']} olacaktır. İşleme devam edilsin mi?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          isProcessing = false;
                        });
                      },
                      child: const Text('Hayır'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          isProcessing = true;
                        });
                        context.read<SarfaCikisCubit>().confirmSarfaCikis(
                          barkodNoController.text,
                          maliyetMerkeziController.text,
                          depoController.text,
                          miktarController.text,
                        );
                      },
                      child: const Text('Evet'),
                    ),
                  ],
                );
              },
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: isProcessing
                            ? null
                            : () {
                          _kullaniciGirisCubit.resetInactivityTimer();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const Sarfasorgu()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 12),
                          disabledBackgroundColor: Colors.grey,
                        ),
                        child: const Text("Sorgu", style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text(
                      "Sarfa Çıkış",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildBarkodRow("Barkod No", barkodNoController, _barkodOku),
                  const SizedBox(height: 12),
                  _buildTextField("Maliyet Merkezi", maliyetMerkeziController),
                  const SizedBox(height: 12),
                  _buildTextField("Depo", depoController),
                  const SizedBox(height: 12),
                  _buildTextField("Miktar", miktarController, isNumber: true),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isProcessing ? null : _okutIslem,
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
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

  Widget _buildBarkodRow(String label, TextEditingController controller, VoidCallback onScanPressed) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                onChanged: (_) => _kullaniciGirisCubit.resetInactivityTimer(),
                enabled: !isProcessing,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.qr_code_scanner, size: 30, color: Colors.black54),
              onPressed: isProcessing ? null : onScanPressed,
            ),
          ],
        ),
      ],
    );
  }
}