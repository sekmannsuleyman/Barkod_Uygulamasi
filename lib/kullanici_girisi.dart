import 'package:bien_proje/ui/cubit/kullanici_giris_cubit/kullanici_giris_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bien_proje/ana_sayfa.dart';

class Kullanicigiris extends StatelessWidget {
  const Kullanicigiris({super.key});

  @override
  Widget build(BuildContext context) {
    var kullaniciAdiController = TextEditingController();
    var sifreController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "bien",
          style: TextStyle(
            color: Colors.white,
            fontFamily: "Righteous",
            fontSize: 45,
          ),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: BlocListener<KullaniciGirisCubit, String>(
        listener: (context, state) {
          print('Kullanicigiris: KullaniciGirisCubit durumu: $state');
          if (state == 'success') {
            print('Giriş başarılı, Anasayfa\'ya yönlendiriliyor');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Anasayfa()),
            );
          } else if (state == 'error') {
            print('Giriş başarısız: Hatalı kullanıcı adı veya şifre');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Hatalı kullanıcı adı veya şifre'),
                duration: Duration(seconds: 1),
              ),
            );
          } else if (state == 'loading') {
            print('Giriş yapılıyor...');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Giriş yapılıyor...'),
                duration: Duration(seconds: 1),
              ),
            );
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            Center(
              child: Image.asset(
                'resimler/bien.png',
                width: 250,
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 1),
                      TextField(
                        controller: kullaniciAdiController,
                        decoration: InputDecoration(
                          labelText: 'Kullanıcı Adı',
                          labelStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.blueAccent,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: sifreController,
                        obscureText: true,
                        maxLength: 4,
                        decoration: InputDecoration(
                          labelText: 'Şifre',
                          labelStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.blueAccent,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          if (kullaniciAdiController.text.isEmpty ||
                              sifreController.text.isEmpty) {
                            print('Hata: Kullanıcı adı veya şifre boş');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Lütfen kullanıcı adı ve şifre girin!',
                                ),
                              ),
                            );
                          } else {
                            context
                                .read<KullaniciGirisCubit>()
                                .kaydetKullanciGirisCubit(
                                  kullaniciAdiController.text,
                                  sifreController.text,
                                );
                          }
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          minimumSize: const Size(150, 50),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                        ),
                        child: const Text(
                          "Giriş",
                          style: TextStyle(color: Colors.white, fontSize: 30),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
