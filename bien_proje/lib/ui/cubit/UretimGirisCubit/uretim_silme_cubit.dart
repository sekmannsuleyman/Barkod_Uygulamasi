import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repo/bilgilerdao_repository.dart';

class UretimSilmeCubit extends Cubit<void>{

  UretimSilmeCubit():super(0);
  var krepo= BilgilerDaoRepository();
  Future<void> kaydetUretimSilmeCubit( String emirNo,String barkodNo) async{


    krepo.kaydetUretimSilmeCubit(emirNo,barkodNo);



  }



}