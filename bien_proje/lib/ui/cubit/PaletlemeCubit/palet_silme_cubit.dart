import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repo/bilgilerdao_repository.dart';

class PaletSilmeCubit extends Cubit<void> {

  PaletSilmeCubit():super(0);
  var krepo=BilgilerDaoRepository();
  Future<void> kaydetPaletSilmeCubit( String kutuBarkod ) async{


    krepo.kaydetPaletSilmeCubit(kutuBarkod);



  }
}