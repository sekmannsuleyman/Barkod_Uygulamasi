import 'package:bien_proje/ui/views/sevkiyat_yukleme/sevkiyat_yukleme.dart';
import 'package:bien_proje/ui/views/sevkiyat_yukleme/sevkiyat_yukleme_iptal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../ana_sayfa.dart';
import '../../../kullanici_girisi.dart';
import '../../cubit/kullanici_giris_cubit/kullanici_giris_cubit.dart';
import '../../cubit/sevkiyat_yukleme_cubit/sevkiyat_yukleme_sorgu_cubit.dart';

class Sevkiyatsorgu extends StatefulWidget {
  const Sevkiyatsorgu({super.key});

  @override
  State<Sevkiyatsorgu> createState() => _SevkiyatsorguState();
}

class _SevkiyatsorguState extends State<Sevkiyatsorgu> {
  var emirNoController = TextEditingController();
  bool banyoSorgu = false;
  bool sorgulandiMi = false;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    context.read<KullaniciGirisCubit>().startInactivityTimer();
  }

  @override
  void dispose() {
    context.read<KullaniciGirisCubit>().stopInactivityTimer();
    emirNoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldMessengerKey,
      appBar: AppBar(
        title: InkWell(
          onTap: () {
            context.read<KullaniciGirisCubit>().resetInactivityTimer();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Anasayfa()),
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
              onPressed: () async {
                context.read<KullaniciGirisCubit>().resetInactivityTimer();
                _scaffoldMessengerKey.currentState?.showSnackBar(
                  const SnackBar(content: Text('Çıkış yapılıyor...')),
                );
                await context.read<KullaniciGirisCubit>().cikisYap();
                if (context.read<KullaniciGirisCubit>().state == 'loggedOut') {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const Kullanicigiris()),
                        (route) => false,
                  );
                } else {
                  _scaffoldMessengerKey.currentState?.showSnackBar(
                    const SnackBar(content: Text('Çıkış işlemi başarısız oldu')),
                  );
                }
              },
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
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SevkiyatYukleme())),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 65, vertical: 12),
                  ),
                  child: const Text("Yükleme", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Sevkiyatyuklemeiptal())),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 65, vertical: 12),
                  ),
                  child: const Text("İptal", style: TextStyle(color: Colors.white, fontSize: 16)),
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
                "Sevkiyat Yükleme Sorgu",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: emirNoController,
                    decoration: const InputDecoration(
                      labelText: "Emir No",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => context.read<KullaniciGirisCubit>().resetInactivityTimer(),
                  ),
                ),
                const SizedBox(width: 10),
                Checkbox(
                  value: banyoSorgu,
                  onChanged: (bool? value) {
                    setState(() {
                      banyoSorgu = value!;
                    });
                    context.read<KullaniciGirisCubit>().resetInactivityTimer();
                  },
                ),
                const Text("Banyo Sorgu"),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (emirNoController.text.isEmpty) {
                    _scaffoldMessengerKey.currentState?.showSnackBar(
                      const SnackBar(content: Text('Emir No boş olamaz!')),
                    );
                    return;
                  }
                  setState(() {
                    sorgulandiMi = true;
                  });
                  context.read<KullaniciGirisCubit>().resetInactivityTimer();
                  context.read<SevkiyatYuklemeSorguCubit>().kaydetSevkiyatYuklemeSorguCubit(
                    emirNoController.text,
                    banyoSorgu,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                ),
                child: const Text("Okut", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
            if (sorgulandiMi)
              Expanded(
                child: BlocConsumer<SevkiyatYuklemeSorguCubit, List<Map<String, String>>>(
                  listener: (context, state) {
                    if (state.isEmpty && sorgulandiMi) {
                      _scaffoldMessengerKey.currentState?.showSnackBar(
                        const SnackBar(
                          content: Text('Sorgu başarısız: Kayıt bulunamadı veya hata oluştu.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  builder: (context, liste) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 13.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 375),
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(Colors.grey[200]),
                            dataRowColor: WidgetStateProperty.all(Colors.white),
                            border: TableBorder.all(color: Colors.black54, width: 1),
                            columnSpacing: 20,
                            columns: const [
                              DataColumn(label: Text("MALZEME", style: TextStyle(fontWeight: FontWeight.bold)),),
                              DataColumn(label: Text("PARTİ", style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text("KALAN", style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text("BİRİM", style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: liste.isNotEmpty
                                ? liste.map((veri) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(veri['MALZEME'] ?? '')),
                                  DataCell(Text(veri['PARTI'] ?? '')),
                                  DataCell(Text(veri['KALAN'] ?? '')),
                                  DataCell(Text(veri['BIRIM'] ?? '')),
                                ],
                              );
                            }).toList()
                                : [
                              const DataRow(
                                cells: [
                                  DataCell(Text("Kayıt Bulunamadı")),
                                  DataCell(Text("-")),
                                  DataCell(Text("0.0")),
                                  DataCell(Text("-")),
                                ],
                              ),
                            ],
                          ),
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
}