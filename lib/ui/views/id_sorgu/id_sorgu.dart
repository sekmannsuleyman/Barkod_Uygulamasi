import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../ana_sayfa.dart';
import '../../../kullanici_girisi.dart';
import '../../cubit/id_sorgu_cubit/id_sorgu_cubit.dart';
import '../../cubit/kullanici_giris_cubit/kullanici_giris_cubit.dart';

class Idsorgu extends StatefulWidget {
  const Idsorgu({super.key});

  @override
  State<Idsorgu> createState() => _IdsorguState();
}

class _IdsorguState extends State<Idsorgu> {
  var idNoController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<IdSorguCubit>().temizle();
  }

  @override
  void initState() {
    super.initState();
    // Hareketsizlik zamanlayıcısını başlat
    context.read<KullaniciGirisCubit>().startInactivityTimer();
  }

  @override
  void dispose() {
    // Hareketsizlik zamanlayıcısını durdur
    context.read<KullaniciGirisCubit>().stopInactivityTimer();
    idNoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Anasayfa()),
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
                ScaffoldMessenger.of(context).showSnackBar(
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
                  ScaffoldMessenger.of(context).showSnackBar(
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
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text(
                  "Id Sorgu",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "ID No",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextField(
                  controller: idNoController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(10),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  if (idNoController.text.trim().isEmpty) return;
                  context.read<IdSorguCubit>().kaydetIdSorguCubit(
                    idNoController.text.trim(),
                  );
                },
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
            ),
            const SizedBox(height: 20),
            Expanded(
              child: BlocBuilder<IdSorguCubit, List<Map<String, dynamic>>?>(
                builder: (context, veriler) {
                  if (veriler == null) {
                    return const SizedBox();
                  }

                  if (veriler.isEmpty) {
                    return const Center(child: Text("Kıyaslanacak kayıt bulunamadı."));
                  }

                  final grouped = <String, List<Map<String, dynamic>>>{};
                  for (var row in veriler) {
                    final batch = row['BATCHNUM'] ?? 'Bilinmiyor';
                    grouped.putIfAbsent(batch, () => []).add(row);
                  }

                  return ListView(
                    children: grouped.entries.map((entry) {
                      final ana = entry.value.first;

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Malzeme Kodu: ${ana['MATERIAL']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text("Malzeme Adı: ${ana['STEXT']}", style: const TextStyle(fontSize: 14)),
                              Text("Parti No: ${ana['BATCHNUM']}", style: const TextStyle(fontSize: 14)),
                              const SizedBox(height: 12),
                              Table(
                                border: TableBorder.all(color: Colors.grey.shade400),
                                columnWidths: const {
                                  0: FlexColumnWidth(2),
                                  1: FlexColumnWidth(1),
                                  2: FlexColumnWidth(2),
                                },
                                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                children: [
                                  const TableRow(
                                    decoration: BoxDecoration(color: Color(0xFFE0E0E0)),
                                    children: [
                                      Padding(padding: EdgeInsets.all(8), child: Text("Ada No", style: TextStyle(fontWeight: FontWeight.bold))),
                                      Padding(padding: EdgeInsets.all(8), child: Text("Adet", style: TextStyle(fontWeight: FontWeight.bold))),
                                      Padding(padding: EdgeInsets.all(8), child: Text("ID", style: TextStyle(fontWeight: FontWeight.bold))),
                                    ],
                                  ),
                                  ...entry.value.map((e) {
                                    return TableRow(
                                      decoration: BoxDecoration(color: Colors.grey.shade100),
                                      children: [
                                        Padding(padding: const EdgeInsets.all(8), child: Text(e['ADANO'] ?? '')),
                                        Padding(padding: const EdgeInsets.all(8), child: Text(e['QUANTITY'] ?? '')),
                                        Padding(padding: const EdgeInsets.all(8), child: Text(e['ID'] ?? '')),
                                      ],
                                    );
                                  }),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
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