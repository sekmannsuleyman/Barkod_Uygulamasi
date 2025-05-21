import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../ana_sayfa.dart';
import '../../../kullanici_girisi.dart';
import '../../cubit/kullanici_giris_cubit/kullanici_giris_cubit.dart';
import '../../cubit/transfer_hareketleri_cubit/emir_kalan_cubit.dart';
import 'malzeme_donusum.dart';
import 'transfer_hareketleri.dart';

class Emirkalan extends StatefulWidget {
  const Emirkalan({super.key});

  @override
  State<Emirkalan> createState() => _EmirkalanState();
}

class _EmirkalanState extends State<Emirkalan> {
  final emirNoController = TextEditingController();
  late final KullaniciGirisCubit _kullaniciGirisCubit;
  bool isProcessing = false;
  String statusMessage = ''; // Hata mesajı için
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _kullaniciGirisCubit = context.read<KullaniciGirisCubit>();
    _kullaniciGirisCubit.startInactivityTimer();
  }

  @override
  void dispose() {
    _kullaniciGirisCubit.stopInactivityTimer();
    emirNoController.dispose();
    super.dispose();
  }

  void _okutIslem() {
    if (isProcessing) return;

    final emirNo = emirNoController.text.trim();

    if (emirNo.isEmpty) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Emir No boş olamaz!')),
      );
      return;
    }

    if (emirNo.length != 12) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Emir No 12 karakter olmalıdır!')),
      );
      return;
    }

    setState(() {
      isProcessing = true;
      statusMessage = ''; // Yeni işlem öncesi mesajı sıfırla
    });

    print('Okut işlemi başlatılıyor...');
    _kullaniciGirisCubit.resetInactivityTimer();
    context.read<EmirKalanCubit>().kaydetEmirKalanCubit(emirNo);
  }

  @override
  Widget build(BuildContext context) {
    // Ekran genişliğini al
    final screenWidth = MediaQuery.of(context).size.width;

    return BlocListener<KullaniciGirisCubit, String>(
      listener: (context, state) {
        print('Emirkalan: KullaniciGirisCubit durumu: $state');
        if ((state == 'loggedOut' || state == 'logoutError') && mounted) {
          print('Çıkış yapıldı, giriş ekranına yönlendiriliyor');
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Kullanicigiris()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        key: _scaffoldMessengerKey,
        appBar: AppBar(
          title: InkWell(
            onTap: () {
              _kullaniciGirisCubit.resetInactivityTimer();
              print('AppBar: Anasayfa\'ya yönlendiriliyor');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Anasayfa()),
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
                onPressed:
                    isProcessing
                        ? null
                        : () async {
                          _kullaniciGirisCubit.resetInactivityTimer();
                          print('Çıkış butonuna basıldı');
                          _scaffoldMessengerKey.currentState?.showSnackBar(
                            const SnackBar(content: Text('Çıkış yapılıyor...')),
                          );
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
        body: BlocConsumer<EmirKalanCubit, EmirKalanState>(
          listener: (context, state) {
            print('EmirKalanCubit durumu: $state');
            if (state is EmirKalanSuccess) {
              print('Okut işlemi başarılı: ${state.sonuc}');
              _scaffoldMessengerKey.currentState?.showSnackBar(
                const SnackBar(
                  content: Text('Başarılı: Emir kalan sorgusu tamamlandı.'),
                  backgroundColor: Colors.green,
                ),
              );
              setState(() {
                isProcessing = false;
                statusMessage = ''; // Başarı mesajı kaldırıldı
              });
            } else if (state is EmirKalanError) {
              print('Okut işlemi hata: ${state.hata}');
              _scaffoldMessengerKey.currentState?.showSnackBar(
                SnackBar(
                  content: Text('Hata: ${state.hata}'),
                  backgroundColor: Colors.red,
                ),
              );
              setState(() {
                isProcessing = false;
                statusMessage = 'Hata: Emir kalan sorgusu başarısız.';
              });
            } else if (state is EmirKalanLoading) {
              print('Okut işlemi yükleniyor...');
            }
          },
          builder: (context, state) {
            List<Map<String, String>> results = [];
            if (state is EmirKalanSuccess) {
              results = state.sonuc;
            }

            // Sabit sütunlar
            const columns = [
              'K',
              'MALZEME',
              'PARTI',
              'MIKTAR',
              'OKUNAN',
              'KALAN',
            ];

            // Sonuçlar boşsa veya hata varsa "KAY YOK" satırı
            final displayResults =
                results.isEmpty
                    ? [
                      {
                        'K': '0',
                        'MALZEME': 'KAYIT YOK',
                        'PARTI': '',
                        'MIKTAR': '0.0',
                        'OKUNAN': '0.0',
                        'KALAN': '0.0',
                      },
                    ]
                    : results.asMap().entries.map((entry) {
                      int index = entry.key;
                      var row = entry.value;
                      return {
                        'K': index.toString(),
                        'MALZEME': row['MALZEME'] ?? '',
                        'PARTI': row['PARTI'] ?? '',
                        'MIKTAR': row['MIKTAR'] ?? '0.0',
                        'OKUNAN': row['OKUNAN'] ?? '0.0',
                        'KALAN': row['KALAN'] ?? '0.0',
                      };
                    }).toList();

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed:
                              isProcessing
                                  ? null
                                  : () {
                                    _kullaniciGirisCubit.resetInactivityTimer();
                                    print('Transfer butonuna basıldı');
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => const TransferHareketleri(),
                                      ),
                                    );
                                  },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            disabledBackgroundColor: Colors.grey,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 12,
                            ),
                          ),
                          child: const Text(
                            "Transfer",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                        ElevatedButton(
                          onPressed:
                              isProcessing
                                  ? null
                                  : () {
                                    _kullaniciGirisCubit.resetInactivityTimer();
                                    print('Malzeme Dönüşüm butonuna basıldı');
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const Malzemedonusum(),
                                      ),
                                    );
                                  },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            disabledBackgroundColor: Colors.grey,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 12,
                            ),
                          ),
                          child: const Text(
                            "Malzeme Dönüşüm",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
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
                        "Transfer Emir Kalan",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Emir No",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    TextField(
                      controller: emirNoController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      onChanged:
                          (_) => _kullaniciGirisCubit.resetInactivityTimer(),
                      enabled: !isProcessing,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isProcessing ? null : _okutIslem,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          disabledBackgroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
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
                    const SizedBox(height: 10),
                    // Hata mesajı yalnızca hata durumunda gösterilecek
                    if (statusMessage.isNotEmpty)
                      Text(
                        statusMessage,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(height: 20),
                    // Tablo yalnızca sorgu tamamlandığında gösterilecek
                    if (state is EmirKalanSuccess || state is EmirKalanError)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: DataTable(
                            columnSpacing:
                                15, // Sütunlar arası boşluk artırıldı
                            headingRowHeight: 50, // Başlık yüksekliği artırıldı
                            dataRowHeight: 50, // Satır yüksekliği artırıldı
                            border: TableBorder.all(
                              color:
                                  Colors.black, // Sütun sınırları netleştirildi
                              width: 1.0,
                            ),
                            columns:
                                columns
                                    .map(
                                      (column) => DataColumn(
                                        label: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxWidth:
                                                screenWidth /
                                                5, // Sütun genişliği artırıldı
                                          ),
                                          child: Text(
                                            column,
                                            style: const TextStyle(
                                              fontSize:
                                                  14, // Yazı boyutu artırıldı
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                            rows:
                                displayResults.map((row) {
                                  return DataRow(
                                    cells:
                                        columns.map((column) {
                                          return DataCell(
                                            ConstrainedBox(
                                              constraints: BoxConstraints(
                                                maxWidth:
                                                    screenWidth /
                                                    5, // Sütun genişliği artırıldı
                                              ),
                                              child: Text(
                                                row[column] ?? '',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ), // Yazı boyutu artırıldı
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
