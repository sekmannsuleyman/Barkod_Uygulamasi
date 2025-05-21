import 'package:bien_proje/kullanici_girisi.dart';
import 'package:bien_proje/ui/cubit/kullanici_giris_cubit/kullanici_giris_cubit.dart';
import 'package:bien_proje/ui/views/ada_no_kaydet/ada_no_kaydet.dart';
import 'package:bien_proje/ui/views/ambar_sayim/ambar_sayim.dart';
import 'package:bien_proje/ui/views/Paletleme/paletleme.dart';
import 'package:bien_proje/ui/views/ean_sorgu/ean_sorgu.dart';
import 'package:bien_proje/ui/views/id_sorgu/id_sorgu.dart';
import 'package:bien_proje/ui/views/isemrinebaglisuretim_giris/is_emrine_bagli_uretim.dart';
import 'package:bien_proje/ui/views/numune_no/numune_ada_no_kaydet.dart';
import 'package:bien_proje/ui/views/sarfa_cikis/sarfa_cikis.dart';
import 'package:bien_proje/ui/views/Sayim/sayim.dart';
import 'package:bien_proje/ui/views/sevkiyat_yukleme/sevkiyat_yukleme.dart';
import 'package:bien_proje/ui/views/transfer_hareketleri/transfer_hareketleri.dart';
import 'package:bien_proje/ui/views/uretim_giris/uretim_giris.dart';
import 'package:bien_proje/ui/views/urun_sorgu/urun_sorgu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Anasayfa extends StatefulWidget {
  const Anasayfa({super.key});

  @override
  State<Anasayfa> createState() => _AnasayfaState();
}

class _AnasayfaState extends State<Anasayfa> {
  late final KullaniciGirisCubit _kullaniciGirisCubit;

  @override
  void initState() {
    super.initState();
    _kullaniciGirisCubit = context.read<KullaniciGirisCubit>();
    print('Anasayfa: initState - Zamanlayıcı başlatılıyor');
    _kullaniciGirisCubit.startInactivityTimer();
  }

  @override
  void dispose() {
    print('Anasayfa: dispose - Zamanlayıcı durduruluyor');
    _kullaniciGirisCubit.stopInactivityTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<KullaniciGirisCubit, String>(
      listener: (context, state) {
        print('Anasayfa: BlocListener tetiklendi, state: $state');
        if ((state == 'loggedOut' || state == 'logoutError') && mounted) {
          print('Anasayfa: Çıkış durumu algılandı, giriş ekranına yönlendiriliyor');
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Kullanicigiris()),
                (route) => false,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Anasayfa"),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: ElevatedButton(
                onPressed: () async {
                  _kullaniciGirisCubit.resetInactivityTimer();
                  print('Çıkış butonuna basıldı');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Çıkış yapılıyor...'), duration: Duration(seconds: 1)),
                  );
                  await _kullaniciGirisCubit.cikisYap();
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
        body: GestureDetector(
          onTap: () {
            print('Anasayfa: Kullanıcı etkileşimi: Dokunma');
            _kullaniciGirisCubit.resetInactivityTimer();
          },
          onPanUpdate: (details) {
            print('Anasayfa: Kullanıcı etkileşimi: Kaydırma');
            _kullaniciGirisCubit.resetInactivityTimer();
          },
          behavior: HitTestBehavior.opaque,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _kullaniciGirisCubit.resetInactivityTimer();
                      print('Sevkiyat Yükleme butonuna basıldı');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SevkiyatYukleme()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      "Sevkiyat Yükleme",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              _kullaniciGirisCubit.resetInactivityTimer();
                              print('Üretim Giriş butonuna basıldı');
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const Uretimgiris()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                            ),
                            child: const Text("Üretim Giriş"),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              _kullaniciGirisCubit.resetInactivityTimer();
                              print('İş Emrine Bağlı Üretim Giriş butonuna basıldı');
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const Isemrinebagliuretim()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                            ),
                            child: const Text("İş Emrine Bağlı Üretim Giriş"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              _kullaniciGirisCubit.resetInactivityTimer();
                              print('Paletleme butonuna basıldı');
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const Paletleme()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                            ),
                            child: const Text("Paletleme"),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              _kullaniciGirisCubit.resetInactivityTimer();
                              print('ID Sorgu butonuna basıldı');
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const Idsorgu()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                            ),
                            child: const Text("ID Sorgu"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _kullaniciGirisCubit.resetInactivityTimer();
                      print('Transfer Hareketleri butonuna basıldı');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TransferHareketleri()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      "Transfer Hareketleri",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _kullaniciGirisCubit.resetInactivityTimer();
                      print('Sarfa Çıkış butonuna basıldı');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SarfaCikis()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      "Sarfa Çıkış",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              _kullaniciGirisCubit.resetInactivityTimer();
                              print('Sayım butonuna basıldı');
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const Sayim()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                            ),
                            child: const Text("Sayım"),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              _kullaniciGirisCubit.resetInactivityTimer();
                              print('Ambar Sayım butonuna basıldı');
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const Ambarsayim()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                            ),
                            child: const Text("Ambar Sayım"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              _kullaniciGirisCubit.resetInactivityTimer();
                              print('Ada No Kaydet/Ada Sorgula butonuna basıldı');
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const Adanokaydet()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                            ),
                            child: const Text("Ada No Kaydet\nAda Sorgula"),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              _kullaniciGirisCubit.resetInactivityTimer();
                              print('Numune Ada No Kaydet/Ada Sorgula butonuna basıldı');
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const Numuneadanokaydet()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                            ),
                            child: const Text("Numune Ada No Kaydet/Ada Sorgula"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              _kullaniciGirisCubit.resetInactivityTimer();
                              print('Ürün Sorgu butonuna basıldı');
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const Urunsorgu()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                            ),
                            child: const Text("Ürün Sorgu"),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              _kullaniciGirisCubit.resetInactivityTimer();
                              print('Ean Sorgu butonuna basıldı');
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const Eansorgu()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                            ),
                            child: const Text("Ean Sorgu"),
                          ),
                        ),
                      ),

                    ],

                  ),
                ),
                Image.asset(
                  'resimler/bien.png',
                  width: 250,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ],

            ),
          ),
        ),
      ),
    );
  }
}