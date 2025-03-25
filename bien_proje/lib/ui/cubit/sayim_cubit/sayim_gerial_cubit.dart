import 'package:bien_proje/data/repo/bilgilerdao_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SayimGerialCubit extends Cubit<void>{

  SayimGerialCubit():super(0);
  var krepo= BilgilerDaoRepository();
  Future<void> kaydetSayimGerialCubit( String barkodNo) async{


    krepo.kaydetSayimGerialCubit(barkodNo);



  }


}