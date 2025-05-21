import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../ana_sayfa.dart';
import '../../../kullanici_girisi.dart';
import '../../cubit/ean_sorgu_cubit/ean_sorgu_cubit.dart';
import '../../cubit/kullanici_giris_cubit/kullanici_giris_cubit.dart';
import 'ean_palet_karsilastirma.dart';

class Eansorgu extends StatefulWidget {
  const Eansorgu({super.key});

  @override
  State<Eansorgu> createState() => _EansorguState();
}

class _EansorguState extends State<Eansorgu> {
  final TextEditingController eanNoController = TextEditingController();
  late final KullaniciGirisCubit kullaniciGirisCubit;
  late final EanSorguCubit eanSorguCubit;
  bool _isChecked = false;

  @override
  void initState() {
    super.initState();
    kullaniciGirisCubit = context.read<KullaniciGirisCubit>();
    eanSorguCubit = context.read<EanSorguCubit>();
    kullaniciGirisCubit.startInactivityTimer();
    eanSorguCubit.temizle();
  }

  @override
  void dispose() {
    kullaniciGirisCubit.stopInactivityTimer();
    eanNoController.dispose();
    super.dispose();
  }

  void _cikisYap() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Çıkış yapılıyor...')),
    );
    await kullaniciGirisCubit.cikisYap();

    if (kullaniciGirisCubit.state == 'loggedOut') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Kullanicigiris()),
            (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Çıkış işlemi başarısız oldu')),
      );
    }
  }

  void _eanSorgula() {
    final ean = eanNoController.text.trim();
    if (ean.isNotEmpty) {
      eanSorguCubit.eanSorgula(ean);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir EAN girin.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: () {
            Navigator.pushReplacement(
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
              onPressed: _cikisYap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text("Çıkış"),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEanPaletKarsilastirmaButton(),
            const SizedBox(height: 20),
            _buildSayfaBaslik(),
            const SizedBox(height: 20),
            _buildEanNoInput(),
            const SizedBox(height: 20),
            _buildOkutButton(),
            _buildOzelEanCheckbox(),
            const SizedBox(height: 20),
            Expanded(child: _buildEanSonucTablosu()),
          ],
        ),
      ),
    );
  }

  Widget _buildEanPaletKarsilastirmaButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const Eanpaletkarsilastirma()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
        ),
        child: const Text(
          "Ean-Palet Karşılaştırma",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildSayfaBaslik() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        "Ean Sorgu",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildEanNoInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Ean No",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: eanNoController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(10),
          ),
        ),
      ],
    );
  }

  Widget _buildOkutButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _eanSorgula,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        child: const Text(
          "Okut",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildOzelEanCheckbox() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Checkbox(
            value: _isChecked,
            onChanged: (bool? newValue) {
              setState(() {
                _isChecked = newValue ?? false;
              });
            },
          ),
          const Text(
            'Özel Ean',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildEanSonucTablosu() {
    return BlocBuilder<EanSorguCubit, EanSorguState>(
      builder: (context, state) {
        if (state.loading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state.hata != null) {
          return Center(child: Text(state.hata!, style: const TextStyle(color: Colors.red)));
        } else if (state.sorguYapildiMi && state.sonuclar.isEmpty) {
          return const Center(child: Text("Sonuç bulunamadı.", style: TextStyle(fontSize: 16)));
        } else if (state.sonuclar.isNotEmpty) {
          return ListView(
            children: [
              Table(
                border: TableBorder.all(),
                columnWidths: const {
                  0: FlexColumnWidth(2),
                },
                children: [
                  const TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "AÇIKLAMA",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  ...state.sonuclar.map(
                        (e) => TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(e.aciklama.isEmpty ? '-' : e.aciklama),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
