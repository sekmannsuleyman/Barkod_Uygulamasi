  import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repo/bilgilerdao_repository.dart';

class AmbarGerialCubit extends Cubit<void>{

  AmbarGerialCubit():super(0);

  var krepo=BilgilerDaoRepository();
  Future<void> kaydetAmbarGerial(String barkodNo) async{


    krepo.kaydetAmbarGerial(barkodNo,);



  }




}