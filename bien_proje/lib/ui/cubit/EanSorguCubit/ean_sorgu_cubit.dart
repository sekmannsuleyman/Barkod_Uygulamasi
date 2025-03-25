import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repo/bilgilerdao_repository.dart';

class EanSorguCubit extends Cubit<void>{
  EanSorguCubit():super(0);
  var krepo=BilgilerDaoRepository();
  Future<void> kaydetEanSorguCubit(String eanNo) async{


    krepo.kaydetEanSorguCubit(eanNo);



  }

}