import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../ana_sayfa.dart';
import '../../../kullanici_girisi.dart';
import '../../../widgets/barkod_okuyucu.dart';
import '../../cubit/kullanici_giris_cubit/kullanici_giris_cubit.dart';
import '../../cubit/sayim_cubit/sayim_sorgu_cubit.dart';
import 'sayim.dart';
import 'sayim_gerial.dart';

class Sayimsorgu extends StatefulWidget {
  const Sayimsorgu({super.key});

  @override
  State<Sayimsorgu> createState() => _SayimsorguState();
}

class _SayimsorguState extends State<Sayimsorgu> {
  final rafNoController = TextEditingController();
  final barkodNoController = TextEditingController();
  late final KullaniciGirisCubit _kullaniciGirisCubit;
  bool barkodOkumaAktif = false;
  bool isProcessing = false;

  List<Map<String, String>> sonucListesi = [];
  String? hataMesaji;

  @override
  void initState() {
    super.initState();
    _kullaniciGirisCubit = context.read<KullaniciGirisCubit>();
    _kullaniciGirisCubit.startInactivityTimer();
  }

  @override
  void dispose() {
    _kullaniciGirisCubit.stopInactivityTimer();
    rafNoController.dispose();
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
    } finally {
      if (mounted) {
        setState(() {
          barkodOkumaAktif = false;
          isProcessing = false;
        });
      }
    }
  }

  Future<void> _sorgula() async {
    _kullaniciGirisCubit.resetInactivityTimer();

    if (rafNoController.text.isEmpty || barkodNoController.text.isEmpty) {
      setState(() {
        hataMesaji = "Raf No ve Barkod No boş olamaz.";
      });
      return;
    }

    setState(() {
      isProcessing = true;
      sonucListesi = [];
      hataMesaji = null;
    });

    try {
      final cubit = context.read<SayimSorguCubit>();
      await cubit.kaydetSayimSorguCubit(
        rafNoController.text.trim(),
        barkodNoController.text.trim(),
      );
      setState(() {
        sonucListesi = cubit.state.data;
        hataMesaji = cubit.state.error;
        if (sonucListesi.isEmpty && hataMesaji == null) {
          hataMesaji = "Kayıt bulunamadı.";
        }
      });
    } catch (e) {
      setState(() {
        hataMesaji = "Sorgu başarısız: ${e.toString()}";
      });
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (barkodOkumaAktif) return _buildScaffold();

    return BlocListener<KullaniciGirisCubit, String>(
      listener: (context, state) {
        if ((state == 'loggedOut' || state == 'logoutError') && mounted) {
          if (!barkodOkumaAktif) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const Kullanicigiris()),
                  (route) => false,
            );
          }
        }
      },
      child: _buildScaffold(),
    );
  }

  Scaffold _buildScaffold() {
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: () {
            _kullaniciGirisCubit.resetInactivityTimer();
            Navigator.push(context, MaterialPageRoute(builder: (_) => const Anasayfa()));
          },
          child: const Text("Anasayfa", style: TextStyle(color: Colors.white)),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: ElevatedButton(
              onPressed: isProcessing ? null : () async {
                _kullaniciGirisCubit.resetInactivityTimer();
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
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMenuButtons(),
            const SizedBox(height: 15),
            _buildTitle(),
            const SizedBox(height: 15),
            _buildTextField("Raf No", rafNoController),
            const SizedBox(height: 12),
            _buildBarkodRow("Barkod No", barkodNoController),
            const SizedBox(height: 15),
            _buildOkutButton(),
            const SizedBox(height: 10),
            if (isProcessing)
              const Center(
                child: CircularProgressIndicator(),
              ),
            if (hataMesaji != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  hataMesaji!,
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            if (sonucListesi.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: sonucListesi.length,
                  itemBuilder: (context, index) {
                    final row = sonucListesi[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: row.entries
                              .map((e) => Text("${e.key}: ${e.value}", style: const TextStyle(fontSize: 14)))
                              .toList(),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: isProcessing ? null : () {
            _kullaniciGirisCubit.resetInactivityTimer();
            Navigator.push(context, MaterialPageRoute(builder: (_) => const Sayim()));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
            disabledBackgroundColor: Colors.grey,
          ),
          child: const Text("Sayım", style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
        ElevatedButton(
          onPressed: isProcessing ? null : () {
            _kullaniciGirisCubit.resetInactivityTimer();
            Navigator.push(context, MaterialPageRoute(builder: (_) => const Sayimgerial()));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
            disabledBackgroundColor: Colors.grey,
          ),
          child: const Text("Geri Al", style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(5),
      ),
      child: const Text(
        "Sayım Sorgu",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
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
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
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
              onPressed: isProcessing ? null : _barkodOku,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOkutButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isProcessing ? null : _sorgula,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          disabledBackgroundColor: Colors.grey,
        ),
        child: const Text("Okut", style: TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }
}

