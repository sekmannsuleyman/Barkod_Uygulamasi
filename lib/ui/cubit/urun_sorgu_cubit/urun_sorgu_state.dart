part of 'urun_sorgu_cubit.dart';

abstract class UrunSorguState {}

class UrunSorguInitial extends UrunSorguState {}

class UrunSorguLoading extends UrunSorguState {}

class UrunSorguLoaded extends UrunSorguState {
  final List<Map<String, dynamic>> veriler;

  UrunSorguLoaded(this.veriler);
}

class UrunSorguError extends UrunSorguState {
  final String mesaj;

  UrunSorguError(this.mesaj);
}
