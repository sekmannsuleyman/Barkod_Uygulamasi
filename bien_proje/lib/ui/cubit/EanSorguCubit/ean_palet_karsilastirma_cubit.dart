import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repo/bilgilerdao_repository.dart';

class EanPaletKarsilastirmaCubit extends Cubit<void> {

  EanPaletKarsilastirmaCubit():super(0);

  var krepo=BilgilerDaoRepository();
  Future<void> kaydetEanPaletKarsilastirmaCubit(String paletId,String eanNo) async{


    krepo.kaydetEanPaletKarsilastirmaCubit(paletId,eanNo);



  }


}