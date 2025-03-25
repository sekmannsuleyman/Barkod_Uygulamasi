import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repo/bilgilerdao_repository.dart';

class PaletlemeCubit extends Cubit<void> {

  PaletlemeCubit():super(0);
  var krepo=BilgilerDaoRepository();
  Future<void> kaydetPaletlemeCubit( String kutuBarkod,String paletBarkod) async{


    krepo.kaydetPaletlemeCubit(kutuBarkod,paletBarkod);



  }


}