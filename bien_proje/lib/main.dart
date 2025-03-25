import 'package:bien_proje/kullanicigiris.dart';
import 'package:bien_proje/ui/cubit/AdaNokaydetCubit/ada_sorgula_cubit.dart';
import 'package:bien_proje/ui/cubit/AdaNokaydetCubit/adano_kaydet_cubit.dart';
import 'package:bien_proje/ui/cubit/AmbarSayimCubit/ambar_gerial_cubit.dart';
import 'package:bien_proje/ui/cubit/AmbarSayimCubit/ambar_sayim_cubit.dart';
import 'package:bien_proje/ui/cubit/AmbarSayimCubit/ambar_sayim_sorgu_cubit.dart';
import 'package:bien_proje/ui/cubit/EanSorguCubit/ean_palet_karsilastirma_cubit.dart';
import 'package:bien_proje/ui/cubit/EanSorguCubit/ean_sorgu_cubit.dart';
import 'package:bien_proje/ui/cubit/IdSorguCubit/id_sorgu_cubit.dart';
import 'package:bien_proje/ui/cubit/IsEmrineBagl%C4%B1UretimGirisCubit/is_emrine_bagli_uretim_cubit.dart';
import 'package:bien_proje/ui/cubit/IsEmrineBagl%C4%B1UretimGirisCubit/is_emrine_bagli_uretim_silme.dart';
import 'package:bien_proje/ui/cubit/KullaniciGirisCubit/kullanici_giris_cubit.dart';
import 'package:bien_proje/ui/cubit/NumuneNoCubit/numune_ada_kaydet_cubit.dart';
import 'package:bien_proje/ui/cubit/NumuneNoCubit/numune_ada_sorgula_cubit.dart';
import 'package:bien_proje/ui/cubit/PaletlemeCubit/palet_silme_cubit.dart';
import 'package:bien_proje/ui/cubit/PaletlemeCubit/paletleme_cubit.dart';
import 'package:bien_proje/ui/cubit/SarfaCikisCubit/sarfa_cikis_cubit.dart';
import 'package:bien_proje/ui/cubit/SevkiyatYuklemeCubit/sevkiyat_yukleme_iptal_c%C4%B1bit.dart';
import 'package:bien_proje/ui/cubit/SevkiyatYuklemeCubit/sevkiyat_yukleme_sorgu_cubit.dart';
import 'package:bien_proje/ui/cubit/SevkiyatYuklemeCubit/sevkiyat_yukleme_cubit.dart';
import 'package:bien_proje/ui/cubit/TransferHareketleriCubit/emir_kalan_cubit.dart';
import 'package:bien_proje/ui/cubit/TransferHareketleriCubit/malzeme_donusum_cubit.dart';
import 'package:bien_proje/ui/cubit/TransferHareketleriCubit/transfer_hareketleri_cubit.dart';
import 'package:bien_proje/ui/cubit/UretimGirisCubit/uretim_giris_cubit.dart';
import 'package:bien_proje/ui/cubit/UretimGirisCubit/uretim_kismi_iptal.dart';
import 'package:bien_proje/ui/cubit/UretimGirisCubit/uretim_silme_cubit.dart';
import 'package:bien_proje/ui/cubit/UrunSorguCubit/urun_sorgu_cubit.dart';
import 'package:bien_proje/ui/cubit/sayim_cubit/sayim_cubit.dart';
import 'package:bien_proje/ui/cubit/sayim_cubit/sayim_gerial_cubit.dart';
import 'package:bien_proje/ui/cubit/sayim_cubit/sayim_sorgu_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create:(context)=> AdanoKaydetCubit()),
        BlocProvider(create:(context)=> AdaSorgulaCubit()),
        BlocProvider(create:(context)=> AmbarSayimCubit()),
        BlocProvider(create:(context)=> AmbarSayimSorguCubit()),
        BlocProvider(create:(context)=> AmbarGerialCubit()),
        BlocProvider(create:(context)=> EanSorguCubit()),
        BlocProvider(create:(context)=> EanPaletKarsilastirmaCubit()),
        BlocProvider(create:(context)=> IdSorguCubit()),
        BlocProvider(create:(context)=> IsEmrineBagliuretimCubit()),
        BlocProvider(create:(context)=> IsEmrineBagliUretimSilmeCubit()),
        BlocProvider(create:(context)=> NumuneAdaKaydetCubit()),
        BlocProvider(create:(context)=> NumuneAdaSorgulaCubit()),
        BlocProvider(create:(context)=> PaletlemeCubit()),
        BlocProvider(create:(context)=> PaletSilmeCubit()),
        BlocProvider(create:(context)=> SarfaCikisCubit()),
        BlocProvider(create:(context)=> SayimCubit()),
        BlocProvider(create:(context)=> SayimGerialCubit()),
        BlocProvider(create:(context)=> SayimSorguCubit()),
        BlocProvider(create:(context)=> SevkiyatYuklemeCubit()),
        BlocProvider(create:(context)=> SevkiyatYuklemeSorguCubit()),
        BlocProvider(create:(context)=> SevkiyatYuklemeIptalCubit()),
        BlocProvider(create:(context)=> TransferHareketleriCubit()),
        BlocProvider(create:(context)=> MalzemeDonusumCubit()),
        BlocProvider(create:(context)=> EmirKalanCubit()),
        BlocProvider(create:(context)=> UretimGirisCubit()),
        BlocProvider(create:(context)=> UretimSilmeCubit()),
        BlocProvider(create:(context)=> UretimKismiIptalCubit()),
        BlocProvider(create:(context)=> UrunSorguCubit()),
        BlocProvider(create:(context)=> KullaniciGirisCubit()),


      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(

          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const Kullanicigiris(),
      ),
    );
  }
}

