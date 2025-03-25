import 'package:bien_proje/data/repo/bilgilerdao_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdanoKaydetCubit extends Cubit<void>{

  AdanoKaydetCubit():super(0);
  var krepo= BilgilerDaoRepository();

  Future<void> kaydet (String emirNo,String adaNo,String siraNo) async {

  krepo.kaydetAda(emirNo, adaNo, siraNo);


  }


}