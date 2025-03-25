import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repo/bilgilerdao_repository.dart';

class SarfaCikisCubit extends Cubit<void> {
  SarfaCikisCubit():super(0);
  var krepo=BilgilerDaoRepository();
  Future<void> kaydetSarfaCikisCubit( String barkodNo,String maliyetMerkezi,String depo,String miktar) async{


    krepo.kaydetSarfaCikisCubit(barkodNo,maliyetMerkezi,depo,miktar);



  }

}