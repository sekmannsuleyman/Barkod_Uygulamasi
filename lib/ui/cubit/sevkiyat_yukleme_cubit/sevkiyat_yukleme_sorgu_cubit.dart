import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/sevkiyat_sorguları/sevkiyat_yukleme_sorgu.dart';

class SevkiyatYuklemeSorguCubit extends Cubit<List<Map<String, String>>> {
  final SevkiyatYuklemeSorgu krepo;

  SevkiyatYuklemeSorguCubit(this.krepo) : super([]);

  Future<void> kaydetSevkiyatYuklemeSorguCubit(String emirNo, bool banyoSorgu) async {
    try {
      final data = await krepo.kaydetSevkiyatYuklemeSorguCubit(emirNo, banyoSorgu);
      emit(data);
    } catch (_) {
      emit([]);
    }
  }
}