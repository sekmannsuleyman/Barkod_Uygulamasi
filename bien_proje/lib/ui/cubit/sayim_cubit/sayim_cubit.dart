import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repo/bilgilerdao_repository.dart';

class SayimCubit extends Cubit<void>{

  SayimCubit():super(0);
  var krepo=BilgilerDaoRepository();
  Future<void> kaydetSayimCubit( String adoNo,
      String siraNo,String barkodNo,String sayimNo) async{


    krepo.kaydetSayimCubit(adoNo,siraNo,barkodNo,sayimNo);



  }


}