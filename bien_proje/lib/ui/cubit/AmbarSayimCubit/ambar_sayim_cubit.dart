import 'package:bien_proje/data/repo/bilgilerdao_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AmbarSayimCubit extends Cubit<void>{
  AmbarSayimCubit():super(0);
  var krepo=BilgilerDaoRepository();
  Future<void> kaydetAmbarSayim(String rafNo,String gozNo,String barkodNo, String adet, String sayimNo) async{


    krepo.kaydetAmbarSayim(rafNo, gozNo, barkodNo, adet, sayimNo);



  }







}