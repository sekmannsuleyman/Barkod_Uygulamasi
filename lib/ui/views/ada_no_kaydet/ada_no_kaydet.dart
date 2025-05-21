import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../ana_sayfa.dart';
import '../../../kullanici_girisi.dart';
import '../../cubit/ada_no_kaydet_cubit/adano_kaydet_cubit.dart';
import '../../cubit/kullanici_giris_cubit/kullanici_giris_cubit.dart';
import 'ada_sorgula.dart';

class Adanokaydet extends StatefulWidget {
  const Adanokaydet({super.key});

  @override
  State<Adanokaydet> createState() => _AdanokaydetState();
}

class _AdanokaydetState extends State<Adanokaydet> {
  var paletNoController = TextEditingController();
  var adaNoController = TextEditingController();
  var siraNoController = TextEditingController();
  var sicilNoController = TextEditingController();
  late final KullaniciGirisCubit kullaniciGirisCubit;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    kullaniciGirisCubit = context.read<KullaniciGirisCubit>();
    _loadSicilNo();
    kullaniciGirisCubit.startInactivityTimer();
  }

  @override
  void dispose() {
    kullaniciGirisCubit.stopInactivityTimer();
    paletNoController.dispose();
    adaNoController.dispose();
    siraNoController.dispose();
    sicilNoController.dispose();
    super.dispose();
  }

  Future<void> _loadSicilNo() async {
    final prefs = await SharedPreferences.getInstance();
    final sicilNo = prefs.getString('kullanici_id') ?? '';
    setState(() {
      sicilNoController.text = sicilNo;
    });
  }

  Future<void> _kaydet() async {
    if (paletNoController.text.isEmpty ||
        adaNoController.text.isEmpty ||
        sicilNoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Palet No, Ada No ve Sicil No boş olamaz!'),
        ),
      );
      return;
    }

    if (paletNoController.text.length != 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Palet No 12 karakter olmalıdır!')),
      );
      return;
    }

    if (sicilNoController.text.length != 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sicil No 8 karakter olmalıdır!')),
      );
      return;
    }

    setState(() {
      isProcessing = true;
    });

    try {
      await context.read<AdanoKaydetCubit>().kaydet(
        paletNoController.text,
        adaNoController.text,
        siraNoController.text,
      );
      setState(() {
        paletNoController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Kayıt başarısız: $e')));
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<KullaniciGirisCubit, String>(
      listener: (context, state) {
        if ((state == 'loggedOut' || state == 'logoutError') && mounted) {
          print('Çıkış yapıldı, giriş ekranına yönlendiriliyor');
          Future.microtask(() {
            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const Kullanicigiris()),
                (route) => false,
              );
            }
          });
        }
      },
      child: BlocListener<AdanoKaydetCubit, AdanoKaydetState>(
        listener: (context, state) {
          if (state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!),
                backgroundColor:
                    state.message!.contains("Hata") ? Colors.red : Colors.green,
              ),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: InkWell(
              onTap: () {
                kullaniciGirisCubit.resetInactivityTimer();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Anasayfa()),
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
                  onPressed:
                      isProcessing
                          ? null
                          : () async {
                            kullaniciGirisCubit.resetInactivityTimer();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Çıkış yapılıyor...'),
                              ),
                            );
                            await kullaniciGirisCubit.cikisYap();
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
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed:
                            isProcessing
                                ? null
                                : () {
                                  kullaniciGirisCubit.resetInactivityTimer();
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const Adasorgula(),
                                    ),
                                  );
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 12,
                          ),
                          disabledBackgroundColor: Colors.grey,
                        ),
                        child: const Text(
                          "Ada Sorgula",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text(
                      "Ada No Kaydet",
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
                      "Palet No",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextField(
                      controller: paletNoController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(10),
                      ),
                      maxLength: 12,
                      enabled: !isProcessing,
                      onChanged: (value) {
                        kullaniciGirisCubit.resetInactivityTimer();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 1),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Ada No",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextField(
                            controller: adaNoController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.all(10),
                            ),
                            maxLength: 8,
                            enabled: !isProcessing,
                            onChanged: (value) {
                              kullaniciGirisCubit.resetInactivityTimer();
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Sıra No",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextField(
                            controller: siraNoController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.all(10),
                            ),
                            maxLength: 4,
                            enabled: !isProcessing,
                            onChanged: (value) {
                              kullaniciGirisCubit.resetInactivityTimer();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 1),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Sicil No",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextField(
                      controller: sicilNoController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(10),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 10),
                    Text(
                      sicilNoController.text.isEmpty
                          ? "Sicil No girilmedi"
                          : "Girilen Sicil No: ${sicilNoController.text}",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isProcessing ? null : _kaydet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      disabledBackgroundColor: Colors.grey,
                    ),
                    child:
                        isProcessing
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              "Okut",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
