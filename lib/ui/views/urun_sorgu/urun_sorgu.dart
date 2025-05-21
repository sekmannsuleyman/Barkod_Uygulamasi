// lib/ui/views/urun_sorgu.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../ana_sayfa.dart';
import '../../../kullanici_girisi.dart';
import '../../cubit/kullanici_giris_cubit/kullanici_giris_cubit.dart';
import '../../cubit/urun_sorgu_cubit/urun_sorgu_cubit.dart';

class Urunsorgu extends StatefulWidget {
  const Urunsorgu({super.key});

  @override
  State<Urunsorgu> createState() => _UrunsorguState();
}

class _UrunsorguState extends State<Urunsorgu> {
  final urunIdNoController = TextEditingController();
  bool benzerParti = false;
  bool tabloGoster = false;

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
    urunIdNoController.dispose();
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
              MaterialPageRoute(builder: (context) => const Anasayfa()),
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
      body: Stack(
        children: [
          // Ortalanmış, şeffaf arka plan görseli
          Center(
            child: Opacity(
              opacity: 0.6,
              child: Image.asset(
                'resimler/bien.png',
                width: 200,
                height: 200,
              ),
            ),
          ),
          // Orijinal içeriğimiz
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Ürün ID Sorgu",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 15),

                  const Text(
                    "Ürün ID No",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    controller: urunIdNoController,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Checkbox(
                        value: benzerParti,
                        onChanged: (value) {
                          setState(() {
                            benzerParti = value ?? false;
                          });
                        },
                      ),
                      const Text("Benzer Parti", style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<UrunSorguCubit>().urunSorgula(
                          urunIdNoController.text.trim(),
                          benzerParti,
                        );
                        setState(() {
                          tabloGoster = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                      ),
                      child: const Text("Okut", style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (tabloGoster)
                    BlocBuilder<UrunSorguCubit, List<Map<String, dynamic>>>(
                      builder: (context, tabloVerileri) {
                        if (tabloVerileri.isEmpty) {
                          return const Text("Veri yükleniyor...");
                        }

                        // PartiNo’ya göre grupla
                        final grouped = <String, List<Map<String, dynamic>>>{};
                        for (var row in tabloVerileri) {
                          final batch = row['BATCHNUM'];
                          grouped.putIfAbsent(batch, () => []);
                          grouped[batch]!.add(row);
                        }

                        return Column(
                          children: grouped.entries.map((entry) {
                            final urun = entry.value.first;
                            final detaylar = entry.value;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Malzeme Kodu: ${urun['MATERIAL']}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold, color: Colors.red),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text("Malzeme Adı: ${urun['STEXT']}"),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text("Parti No: ${urun['BATCHNUM']}"),
                                      ),

                                      Table(
                                        border: TableBorder.all(),
                                        columnWidths: const {
                                          0: FlexColumnWidth(2),
                                          1: FlexColumnWidth(1),
                                          2: FlexColumnWidth(2),
                                          3: FlexColumnWidth(2),
                                        },
                                        children: [
                                          const TableRow(
                                            decoration: BoxDecoration(color: Colors.grey),
                                            children: [
                                              Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text("Ada No",
                                                      style: TextStyle(fontWeight: FontWeight.bold))),
                                              Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text("Sayı",
                                                      style: TextStyle(fontWeight: FontWeight.bold))),
                                              Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text("Miktar",
                                                      style: TextStyle(fontWeight: FontWeight.bold))),
                                              Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text("Durum",
                                                      style: TextStyle(fontWeight: FontWeight.bold))),
                                            ],
                                          ),
                                          ...detaylar.map((d) => TableRow(
                                            children: [
                                              Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text(d["ADANO"] ?? "")),
                                              Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text(d["SAYI"] ?? "")),
                                              Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text(d["QUANTITY"] ?? "")),
                                              Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Text(d["DURUM"] ?? "")),
                                            ],
                                          )),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            );
                          }).toList(),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
