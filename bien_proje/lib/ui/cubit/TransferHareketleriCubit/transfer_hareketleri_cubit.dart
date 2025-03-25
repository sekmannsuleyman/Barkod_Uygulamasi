import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repo/bilgilerdao_repository.dart';

class TransferHareketleriCubit extends Cubit<void>{

  TransferHareketleriCubit():super(0);
  var krepo= BilgilerDaoRepository();
  Future<void> kaydetTransferHareketleriCubit( String adaNo,String siraNo,String emirNo,String barkodNo) async{


    krepo.kaydetTransferHareketleriCubit(adaNo,siraNo,emirNo,barkodNo);



  }


}