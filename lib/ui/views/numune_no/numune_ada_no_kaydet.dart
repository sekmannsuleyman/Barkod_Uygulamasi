import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../ana_sayfa.dart';
import '../../../kullanici_girisi.dart';
import '../../cubit/kullanici_giris_cubit/kullanici_giris_cubit.dart';
import '../../cubit/numune_no_cubit/numune_ada_kaydet_cubit.dart';
import 'numune_ada_sorgula.dart';

class Numuneadanokaydet extends StatefulWidget {
  const Numuneadanokaydet({super.key});

  @override
  State<Numuneadanokaydet> createState() => _NumuneadanokaydetState();
}

class _NumuneadanokaydetState extends State<Numuneadanokaydet> {
  var malzemeKoduController = TextEditingController();
  var rafNoController = TextEditingController();
  var gozNoController = TextEditingController();
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
    malzemeKoduController.dispose();
    rafNoController.dispose();
    gozNoController.dispose();
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
    if (malzemeKoduController.text.isEmpty ||
        rafNoController.text.isEmpty ||
        gozNoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Malzeme Kodu, Raf No ve Göz No boş olamaz!')),
      );
      return;
    }

    setState(() {
      isProcessing = true;
    });

    try {
      await context.read<NumuneAdaKaydetCubit>().kaydetNumuneAdaKaydet(
        malzemeKoduController.text,
        rafNoController.text,
        gozNoController.text,
      );
      setState(() {
        malzemeKoduController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kayıt başarısız: $e')),
      );
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
      child: BlocListener<NumuneAdaKaydetCubit, NumuneAdaKaydetState>(
        listener: (context, state) {
          if (state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!),
                backgroundColor: state.message!.contains("Hata") ? Colors.red : Colors.green,
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
                    kullaniciGirisCubit.resetInactivityTimer();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Çıkış yapılıyor...')),
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 20.0, left: 30),
                      child: ElevatedButton(
                        onPressed: isProcessing
                            ? null
                            : () {
                          kullaniciGirisCubit.resetInactivityTimer();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const Numuneadasorgula()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 12),
                          disabledBackgroundColor: Colors.grey,
                        ),
                        child: const Text(
                          "Numune Ada Sorgula",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Malzeme Kodu",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    TextField(
                      controller: malzemeKoduController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(10),
                      ),
                      maxLength: 30,
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
                            "Raf No",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          TextField(
                            controller: rafNoController,
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
                            "Göz No",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          TextField(
                            controller: gozNoController,
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
                const SizedBox(height: 2),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Sicil No",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                    const SizedBox(height: 8),
                    Text(
                      sicilNoController.text.isEmpty
                          ? "Sicil No girilmedi"
                          : "Girilen Sicil No: ${sicilNoController.text}",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isProcessing ? null : _kaydet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      disabledBackgroundColor: Colors.grey,
                    ),
                    child: isProcessing
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      "Okut",
                      style: TextStyle(fontSize: 18, color: Colors.white),
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