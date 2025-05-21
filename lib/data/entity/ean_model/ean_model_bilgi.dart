import 'package:xml/xml.dart';

class EanModel {
  final String aciklama;
  final String kod;
  final String miktar;

  EanModel({
    required this.aciklama,
    required this.kod,
    required this.miktar,
  });

  factory EanModel.fromXml(XmlElement element) {
    return EanModel(
      aciklama: element.getElement('STEXT')?.text.trim() ?? '',
      kod: element.getElement('MATERIAL')?.text.trim() ?? '',
      miktar: '',
    );
  }
}