import 'package:bien_proje/data/repo/bilgilerdao_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UretimKismiIptalCubit extends Cubit<void>{
var krepo= BilgilerDaoRepository();
  UretimKismiIptalCubit():super(0);
  Future<void> kaydetUretimKismiIptalCubit( String belgeNo,String paletBarkodNo) async{


    krepo.kaydetUretimKismiIptalCubit(belgeNo,paletBarkodNo);



  }


}