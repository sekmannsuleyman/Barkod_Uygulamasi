import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repo/bilgilerdao_repository.dart';

class AdaSorgulaCubit extends Cubit<void>{
  AdaSorgulaCubit():super(0);

  var krepo= BilgilerDaoRepository();

  Future<void> kaydetadasorgula (String adaNo,String siraNo) async {

    krepo.kaydetadasorgula(adaNo, siraNo);


  }





}