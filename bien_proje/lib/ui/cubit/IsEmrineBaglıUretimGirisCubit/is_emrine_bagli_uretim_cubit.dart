import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repo/bilgilerdao_repository.dart';

class IsEmrineBagliuretimCubit extends Cubit<void> {

  IsEmrineBagliuretimCubit():super(0);

  var krepo=BilgilerDaoRepository();
  Future<void> kaydetIsEmrineBagliuretim(String isEmirNo, String barkodNo,String adaNo,String siraNo) async{


    krepo.kaydetIsEmrineBagliuretim(isEmirNo,barkodNo,adaNo,siraNo);



  }



}