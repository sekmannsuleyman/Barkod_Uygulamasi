import 'package:bien_proje/data/repo/bilgilerdao_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MalzemeDonusumCubit extends Cubit<void>{
  MalzemeDonusumCubit():super(0);
  var krepo= BilgilerDaoRepository();
  Future<void> kaydetMalzemeDonusumCubit( String emirNo,String eskiBarkodNo,String yeniBarkodNo) async{


    krepo.kaydetMalzemeDonusumCubit(emirNo,eskiBarkodNo,yeniBarkodNo);



  }


}