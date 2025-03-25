import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repo/bilgilerdao_repository.dart';

class UretimGirisCubit extends Cubit<void>{

  UretimGirisCubit():super(0);
  var krepo= BilgilerDaoRepository();
  Future<void> kaydetUretimGirisCubit( String emirNo,String barkodNo) async{


    krepo.kaydetUretimGirisCubit(emirNo,barkodNo);



  }



}