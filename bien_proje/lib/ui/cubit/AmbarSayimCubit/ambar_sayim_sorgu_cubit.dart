import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repo/bilgilerdao_repository.dart';

class AmbarSayimSorguCubit extends Cubit<void> {
  AmbarSayimSorguCubit():super(0);

  var krepo=BilgilerDaoRepository();
  Future<void> kaydetAmbarSayimSorgu(String rafNo,String gozNo,String barkodNo) async{


    krepo.kaydetAmbarSayimSorgu(rafNo,gozNo,barkodNo );



  }


}