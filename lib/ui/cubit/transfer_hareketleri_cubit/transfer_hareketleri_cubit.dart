import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/transfer_hareketleri/transfer_hareketleri_sorgu.dart';

class TransferHareketleriCubit extends Cubit<TransferHareketleriState> {
  final TransferHareketleriSorgu krepo;

  TransferHareketleriCubit(this.krepo) : super(TransferHareketleriInitial());

  Future<void> kaydetTransferHareketleriCubit(
      String adaNo, String siraNo, String emirNo, String barkodNo) async {
    emit(TransferHareketleriLoading());
    try {
      final result = await krepo.kaydetTransferHareketleriCubit(adaNo, siraNo, emirNo, barkodNo);
      emit(TransferHareketleriSuccess(result));
    } catch (e) {
      print('TransferHareketleriCubit hata: $e');
      // Hata mesajını temizle ve emit et
      final errorMessage = e.toString().replaceFirst('Exception: Transfer hareketleri hatası: Exception: Servis Hatası: ', '').replaceFirst('Exception: ', '');
      emit(TransferHareketleriError(errorMessage));
    }
  }
}

abstract class TransferHareketleriState {}

class TransferHareketleriInitial extends TransferHareketleriState {}

class TransferHareketleriLoading extends TransferHareketleriState {}

class TransferHareketleriSuccess extends TransferHareketleriState {
  final String sonuc;
  TransferHareketleriSuccess(this.sonuc);
}

class TransferHareketleriError extends TransferHareketleriState {
  final String hata;
  TransferHareketleriError(this.hata);
}