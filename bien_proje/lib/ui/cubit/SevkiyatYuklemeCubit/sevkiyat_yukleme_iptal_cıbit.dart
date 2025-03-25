import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repo/bilgilerdao_repository.dart';

class SevkiyatYuklemeIptalCubit extends Cubit <void>{
  SevkiyatYuklemeIptalCubit():super(0);
  var krepo= BilgilerDaoRepository();
  Future<void> kaydetSevkiyatYuklemeIptalCubit( String emirNo,String barkodNo) async{


    krepo.kaydetSevkiyatYuklemeIptalCubit(emirNo,barkodNo);



  }



}