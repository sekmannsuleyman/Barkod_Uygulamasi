import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repo/bilgilerdao_repository.dart';

class IsEmrineBagliUretimSilmeCubit extends Cubit<void> {

  IsEmrineBagliUretimSilmeCubit():super(0);
  var krepo=BilgilerDaoRepository();
  Future<void> kaydetIsEmrineBagliuretimSilme(String isEmirNo, String barkodNo) async{


    krepo.kaydetIsEmrineBagliuretimSilme(isEmirNo,barkodNo);



  }




}