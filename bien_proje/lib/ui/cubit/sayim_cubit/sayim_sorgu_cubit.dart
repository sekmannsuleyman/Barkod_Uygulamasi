import 'package:bien_proje/data/repo/bilgilerdao_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SayimSorguCubit extends Cubit <void>{
  var krepo= BilgilerDaoRepository();
  SayimSorguCubit():super(0);
  Future<void> kaydetSayimSorguCubit( String rafNo,String barkodNo) async{


    krepo.kaydetSayimSorguCubit(rafNo,barkodNo);



  }


}