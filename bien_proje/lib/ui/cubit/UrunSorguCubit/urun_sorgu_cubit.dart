import 'package:bien_proje/data/repo/bilgilerdao_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UrunSorguCubit extends Cubit<void>{

  UrunSorguCubit():super(0);
  var krepo=BilgilerDaoRepository();
  Future<void> kaydetUrunSorguCubit( String urunIdNo) async{


    krepo.kaydetUrunSorguCubit(urunIdNo);



  }


}