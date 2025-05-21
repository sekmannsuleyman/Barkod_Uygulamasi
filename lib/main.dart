import 'package:bien_proje/data/datasources/ada_no_sorgulari/ada_no_kaydet_sorgu.dart';
import 'package:bien_proje/data/datasources/ada_no_sorgulari/ada_sorgu_sorgu.dart';
import 'package:bien_proje/data/datasources/ambar_sayim_sorgulari/ambar_gerial_sorgu.dart';
import 'package:bien_proje/data/datasources/ambar_sayim_sorgulari/ambar_sayimlar.dart';
import 'package:bien_proje/data/datasources/ean_sorgular/ean_palet_kars%C4%B1last%C4%B1rma_sorgu.dart';
import 'package:bien_proje/data/datasources/ean_sorgular/ean_sorgu.dart';
import 'package:bien_proje/data/datasources/numune_ada_no_sorgular/numune_ada_kaydet_sorgu.dart';
import 'package:bien_proje/data/datasources/numune_ada_no_sorgular/numune_ada_sorgu.dart';
import 'package:bien_proje/data/datasources/sayim_sorgular/sayim_gerial_sorgu.dart';
import 'package:bien_proje/data/datasources/sayim_sorgular/sayim_sorgu_sorgu.dart';
import 'package:bien_proje/data/datasources/sevkiyat_sorgular%C4%B1/sevkiyat_yukleme_sorgu.dart';
import 'package:bien_proje/data/datasources/uretim_giriss/uretim_giris_sorgu.dart';
import 'package:bien_proje/data/datasources/uretim_giriss/uretim_silme_sorgu.dart';
import 'package:bien_proje/data/datasources/urun_id_sorgu/uretim_kismi_iptal_sorgu.dart';
import 'package:bien_proje/kullanici_girisi.dart';
import 'package:bien_proje/ui/cubit/ada_no_kaydet_cubit/ada_sorgula_cubit.dart';
import 'package:bien_proje/ui/cubit/ada_no_kaydet_cubit/adano_kaydet_cubit.dart';
import 'package:bien_proje/ui/cubit/ambar_sayim_cubit/ambar_gerial_cubit.dart';
import 'package:bien_proje/ui/cubit/ambar_sayim_cubit/ambar_sayim_cubit.dart';
import 'package:bien_proje/ui/cubit/ambar_sayim_cubit/ambar_sayim_sorgu_cubit.dart';
import 'package:bien_proje/ui/cubit/ean_sorgu_cubit/ean_palet_karsilastirma_cubit.dart';
import 'package:bien_proje/ui/cubit/ean_sorgu_cubit/ean_sorgu_cubit.dart';
import 'package:bien_proje/ui/cubit/id_sorgu_cubit/id_sorgu_cubit.dart';
import 'package:bien_proje/ui/cubit/is_emrine_bagli_uretim_giris_cubit/is_emrine_bagli_uretim_cubit.dart';
import 'package:bien_proje/ui/cubit/is_emrine_bagli_uretim_giris_cubit/is_emrine_bagli_uretim_silme_cubit.dart';
import 'package:bien_proje/ui/cubit/kullanici_giris_cubit/kullanici_giris_cubit.dart';
import 'package:bien_proje/ui/cubit/numune_no_cubit/numune_ada_kaydet_cubit.dart';
import 'package:bien_proje/ui/cubit/numune_no_cubit/numune_ada_sorgula_cubit.dart';
import 'package:bien_proje/ui/cubit/paletleme_cubit/palet_silme_cubit.dart';
import 'package:bien_proje/ui/cubit/paletleme_cubit/paletleme_cubit.dart';
import 'package:bien_proje/ui/cubit/sarfa_cikis_cubit/sarfa_cikis_cubit.dart';
import 'package:bien_proje/ui/cubit/sayim_cubit/sayim_cubit.dart';
import 'package:bien_proje/ui/cubit/sayim_cubit/sayim_gerial_cubit.dart';
import 'package:bien_proje/ui/cubit/sayim_cubit/sayim_sorgu_cubit.dart';
import 'package:bien_proje/ui/cubit/sevkiyat_yukleme_cubit/sevkiyat_yukleme_cubit.dart';
import 'package:bien_proje/ui/cubit/sevkiyat_yukleme_cubit/sevkiyat_yukleme_iptal_c%C4%B1bit.dart';
import 'package:bien_proje/ui/cubit/sevkiyat_yukleme_cubit/sevkiyat_yukleme_sorgu_cubit.dart';
import 'package:bien_proje/ui/cubit/transfer_hareketleri_cubit/emir_kalan_cubit.dart';
import 'package:bien_proje/ui/cubit/transfer_hareketleri_cubit/malzeme_donusum_cubit.dart';
import 'package:bien_proje/ui/cubit/transfer_hareketleri_cubit/transfer_hareketleri_cubit.dart';
import 'package:bien_proje/ui/cubit/uretim_giris_cubit/uretim_giris_cubit.dart';
import 'package:bien_proje/ui/cubit/uretim_giris_cubit/uretim_kismi_iptal.dart';
import 'package:bien_proje/ui/cubit/uretim_giris_cubit/uretim_silme_cubit.dart';
import 'package:bien_proje/ui/cubit/urun_sorgu_cubit/urun_sorgu_cubit.dart';
import 'package:bien_proje/ui/views/urun_sorgu/urun_sorgu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/datasources/ambar_sayim_sorgulari/ambar_sayim_sayim_sorgu.dart' show AmbarSayimSorguSorgu;
import 'data/datasources/is_emrine_bagliuretim_sorgulamalar/IsEmrineBagliUretimSilmeSorgu.dart';
import 'data/datasources/is_emrine_bagliuretim_sorgulamalar/IsEmrineBagliUretimSorgu.dart';
import 'data/datasources/paletleme_sorgular/palet_silme_sorgu.dart';
import 'data/datasources/paletleme_sorgular/palet_sorgu.dart';
import 'data/datasources/sarfa_cikis_sorgu/sarfa_cikis_sorgu.dart';
import 'data/datasources/sayim_sorgular/sayim_sayim_sorgu.dart';
import 'data/datasources/sevkiyat_sorguları/sevkiyat_yukleme.dart';
import 'data/datasources/sevkiyat_sorguları/sevkiyat_yukleme_iptal_sprgu.dart';
import 'data/datasources/transfer_hareketleri/emir_kalan_sorgu.dart';
import 'data/datasources/transfer_hareketleri/malzeme_donusum_sorgu.dart';
import 'data/datasources/transfer_hareketleri/transfer_hareketleri_sorgu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AdanoKaydetCubit(AdaNoKaydetSorgu())),
        BlocProvider(create: (context) => AdaSorgulaCubit(AdaSorguSorgu())),
        BlocProvider(create: (context) => AmbarSayimCubit(AmbarSayimSorgu())),
        BlocProvider(create: (context) => AmbarSayimSorguCubit(AmbarSayimSorguSorgu())),
        BlocProvider(create: (context) => AmbarGerialCubit(AmbarGerialSorgu())),
        BlocProvider(create: (context) => EanSorguCubit(EanSorgu())),
        BlocProvider(create: (context) => EanPaletKarsilastirmaCubit(EanPaletKarsilastirmaSorgu())),
        BlocProvider(create: (context) => IdSorguCubit()),
        BlocProvider(create: (context) => IsEmrineBagliuretimCubit(IsEmrineBagliUretimGirisSorgu())),
        BlocProvider(create: (context) => IsEmrineBagliUretimSilmeCubit(IsemrineBagliUretimSilmeSorgu())),
        BlocProvider(create: (context) => NumuneAdaKaydetCubit(NumuneAdaKaydetSorgu())),
        BlocProvider(create: (context) => NumuneAdaSorgulaCubit(NumuneAdaSorgu())),
        BlocProvider(create: (context) => PaletlemeCubit(PaletSorgu())),
        BlocProvider(create: (context) => PaletSilmeCubit(PaletSilmeSorgu())),
        BlocProvider(create: (context) => SarfaCikisCubit(SarfaCikisSorgu())),
        BlocProvider(create: (context) => SayimCubit(SayimSayimSorgu())),
        BlocProvider(create: (context) => SayimGerialCubit(SayimGerialSorgu())),
        BlocProvider(create: (context) => SayimSorguCubit(SayimSorguSorgu())),
        BlocProvider(create: (context) => SevkiyatYuklemeCubit(SevkiyatYukleme())),
        BlocProvider(create: (context) => SevkiyatYuklemeSorguCubit(SevkiyatYuklemeSorgu())),
        BlocProvider(create: (context) => SevkiyatYuklemeIptalCubit(SevkiyatYuklemeIptalSorgu())),
        BlocProvider(create: (context) => TransferHareketleriCubit(TransferHareketleriSorgu())),
        BlocProvider(create: (context) => MalzemeDonusumCubit(MalzemeDonusumSorgu())),
        BlocProvider(create: (context) => EmirKalanCubit(EmirKalanSorgu())),
        BlocProvider(create: (context) => UretimGirisCubit(UretimGirisSorgu())),
        BlocProvider(create: (context) => UretimSilmeCubit(UretimSilmeSorgu())),
        BlocProvider(create: (context) => UretimKismiIptalCubit(UretimKismiIptalSorgu())),
        BlocProvider(create: (context) => UrunSorguCubit(), child: const Urunsorgu()),
        BlocProvider(create: (context) => KullaniciGirisCubit()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const Kullanicigiris(),
        builder: (context, child) {
          return GestureDetector(
            onTap: () {
              print('Main: Kullanıcı etkileşimi: Dokunma (Global)');
              context.read<KullaniciGirisCubit>().resetInactivityTimer();
            },
            onPanUpdate: (details) {
              print('Main: Kullanıcı etkileşimi: Kaydırma (Global)');
              context.read<KullaniciGirisCubit>().resetInactivityTimer();
            },
            behavior: HitTestBehavior.opaque,
            child: child,
          );
        },
      ),
    );
  }
}