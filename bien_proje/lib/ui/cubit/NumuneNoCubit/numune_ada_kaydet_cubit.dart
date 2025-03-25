import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repo/bilgilerdao_repository.dart';

class NumuneAdaKaydetCubit extends Cubit<void> {

  NumuneAdaKaydetCubit():super(0);

  var krepo=BilgilerDaoRepository();
  Future<void> kaydetNumuneAdaKaydetCubit(String malzemeKodu, String rafNo,String gozNo) async{


    krepo.kaydetNumuneAdaKaydetCubit(malzemeKodu,rafNo,gozNo);



  }




}