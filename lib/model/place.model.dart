class PlaceModel {
  String? city;
  String? country;
  double? latitude;
  double? longitude;
  String? adress;
  String? dateInicial;
  String? dateFinal;
  int? id;
  String? titulo;

  PlaceModel({
    this.adress,
    this.city,
    this.country,
    this.latitude,
    this.longitude,
    this.dateInicial,
    this.dateFinal,
    this.id,
    this.titulo,
  });

  factory PlaceModel.fromMap(Map<String, dynamic> map) {
    return PlaceModel(
      id: map['id'],
      latitude: map['latitude'] != null
          ? double.tryParse(map['latitude'].toString())
          : null,
      longitude: map['longitude'] != null
          ? double.tryParse(map['longitude'].toString())
          : null,
      dateInicial: map['data_hora_inicio'],
      dateFinal: map['data_hora_fim'],
      titulo: map['titulo'],
      // Campos city, country e adress provavelmente não estão na tabela rotas_points
      // então deixamos como null mesmo
      city: null,
      country: null,
      adress: null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'latitude': latitude?.toString(),
      'longitude': longitude?.toString(),
      'data_hora_inicio': dateInicial,
      'data_hora_fim': dateFinal,
    };
  }
}
