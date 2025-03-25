import 'package:bien_proje/data/repo/bilgilerdao_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SevkiyatYuklemeCubit extends Cubit <void>{

  SevkiyatYuklemeCubit():super(0);
  var krepo= BilgilerDaoRepository();
  Future<void> kaydetSevkiyatYuklemeCubit( String emirNo,String barkodNo,String agirlik) async{


    krepo.kaydetSevkiyatYuklemeCubit(emirNo,barkodNo,agirlik);



  }




}