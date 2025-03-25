import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../anaSayfa.dart';
import '../../../kullanicigiris.dart';

class Urunsorgu extends StatefulWidget {
  const Urunsorgu({super.key});

  @override
  State<Urunsorgu> createState() => _UrunsorguState();
}

class _UrunsorguState extends State<Urunsorgu> {
  var urunIdNoController = TextEditingController();
  bool benzerParti = false; // Checkbox için
  bool tabloGoster = false; // Tabloları göstermek için
  List<Map<String, dynamic>> tabloVerileri = []; // Web servisten gelecek dinamik veri

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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Kullanicigiris(),
                  ),
                );
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ürün ID Sorgu başlığı
              const Text(
                "Ürün ID Sorgu",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 15),
        
              // Ürün ID No
              const Text(
                "Ürün ID No",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: urunIdNoController,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
        
              // Benzer Parti Checkbox
              Row(
                children: [
                  Checkbox(
                    value: benzerParti,
                    onChanged: (bool? value) {
                      setState(() {
                        benzerParti = value ?? false;
                      });
                    },
                  ),
                  const Text("Benzer Parti", style: TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 20),
        
              // Okut Butonu
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      tabloGoster = true;
        
                      // **Simülasyon için sahte veri ekliyoruz.**
                      // Gerçek projede burası web servisten çekilecek.
                      tabloVerileri = [
                        {
                          "malzemeKodu": "ABC123",
                          "malzemeAdi": "Seramik Karosu",
                          "partiNo": "P12345",
                          "adaNo": "A001",
                          "detaylar": [
                            {"adaNo": "A001", "sayi": 10, "miktar": 50, "durum": "Stokta"},
                            {"adaNo": "A002", "sayi": 8, "miktar": 40, "durum": "Stokta"},
                          ]
                        },
                        {
                          "malzemeKodu": "XYZ789",
                          "malzemeAdi": "Granit Mermer",
                          "partiNo": "P67890",
                          "adaNo": "A002",
                          "detaylar": [
                            {"adaNo": "A003", "sayi": 5, "miktar": 25, "durum": "Beklemede"},
                            {"adaNo": "A004", "sayi": 7, "miktar": 35, "durum": "Gönderildi"},
                          ]
                        }
                      ];
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 100,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    "Okut",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
        
              const SizedBox(height: 20),
        
              // **Birden Fazla Tabloyu Dinamik Olarak Göster**
              if (tabloGoster)
                Column(
                  children: tabloVerileri.map((urun) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text("Malzeme Kodu: ${urun['malzemeKodu']}",
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text("Malzeme Adı: ${urun['malzemeAdi']}"),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text("Parti No: ${urun['partiNo']}"),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text("Ada No: ${urun['adaNo']}"),
                              ),
        
                              // **Detay Tablosu**
                              Table(
                                border: TableBorder.all(),
                                columnWidths: const {
                                  0: FlexColumnWidth(2),
                                  1: FlexColumnWidth(1),
                                  2: FlexColumnWidth(2),
                                  3: FlexColumnWidth(2),
                                },
                                children: [
                                  // Başlık Satırı
                                  const TableRow(
                                    decoration: BoxDecoration(color: Colors.grey),
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text("Ada No", style: TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text("Sayı", style: TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text("Miktar", style: TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text("Durum", style: TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                  // **Dinamik Veri Satırları**
                                  ...urun['detaylar'].map<TableRow>((detay) {
                                    return TableRow(
                                      children: [
                                        Padding(padding: EdgeInsets.all(8.0), child: Text(detay["adaNo"])),
                                        Padding(padding: EdgeInsets.all(8.0), child: Text(detay["sayi"].toString())),
                                        Padding(padding: EdgeInsets.all(8.0), child: Text(detay["miktar"].toString())),
                                        Padding(padding: EdgeInsets.all(8.0), child: Text(detay["durum"])),
                                      ],
                                    );
                                  }).toList(),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
