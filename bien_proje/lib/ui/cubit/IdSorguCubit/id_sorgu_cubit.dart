import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repo/bilgilerdao_repository.dart';

class IdSorguCubit extends Cubit<void> {

  IdSorguCubit():super(0);
  var krepo=BilgilerDaoRepository();
  Future<void> kaydetIdSorguCubit(String idNo) async{


    krepo.kaydetIdSorguCubit(idNo);



  }


}