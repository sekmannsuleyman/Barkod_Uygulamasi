import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repo/bilgilerdao_repository.dart';

class KullaniciGirisCubit extends Cubit<void>{


  var krepo=BilgilerDaoRepository();
  KullaniciGirisCubit():super(0);

  Future<void> kaydetKullanciGirisCubit( String kullaniciAdi, String sifre) async{


    krepo.kaydetKullanciGirisCubit(kullaniciAdi, sifre);


  }


}