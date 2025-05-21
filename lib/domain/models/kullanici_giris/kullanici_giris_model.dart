class KullaniciModel {
  final bool success;
  final String? pid;
  final String? adi;
  final String? message;

  KullaniciModel({
    required this.success,
    this.pid,
    this.adi,
    this.message,
  });
}