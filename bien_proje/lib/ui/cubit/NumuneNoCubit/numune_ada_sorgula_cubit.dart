import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repo/bilgilerdao_repository.dart';

class NumuneAdaSorgulaCubit extends Cubit<void> {

  NumuneAdaSorgulaCubit():super(0);

  var krepo=BilgilerDaoRepository();
  Future<void> kaydetNumuneAdaSorgulaCubit( String rafNo,String gozNo) async{


    krepo.kaydetNumuneAdaSorgulaCubit(rafNo,gozNo);



  }




}