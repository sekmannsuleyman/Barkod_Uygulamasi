import 'package:bien_proje/data/repo/bilgilerdao_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmirKalanCubit extends Cubit<void>{
  EmirKalanCubit():super(0);
  var krepo=BilgilerDaoRepository();
  Future<void> kaydetEmirKalanCubit( String emirNo) async{


    krepo.kaydetEmirKalanCubit(emirNo);



  }


}