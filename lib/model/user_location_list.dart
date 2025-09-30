
class UserLocationData {
/*
{
  "id": 7,
  "city_name": "Lagunes",
  "description": "<p>Lagunes</p>",
  "image": "https://tukki.cssrender.com/storage/app/public/12/64a42b93a5a1e_images.jpeg",
  "latitude": "",
  "longitude": null
} 
*/

  int ?id;
  String ?cityName;
  String ?description;
  String ?image;
  String ?latitude;
  String ?longitude;

  UserLocationData({
     id,
     cityName,
     description,
     image,
    this.latitude,
    this.longitude,
  });
  UserLocationData.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toInt();
    cityName = json['city_name']?.toString();
    description = json['description']?.toString();
    image = json['image']?.toString();
    latitude = json['latitude']?.toString();
    longitude = json['longitude']?.toString();
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['city_name'] = cityName;
    data['description'] = description;
    data['image'] = image;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}

class UserLocationSomeRootEntity {
/*
{
  "status": 200,
  "message": "global.yourLocations_found",
  "data": [
    {
      "id": 7,
      "city_name": "Lagunes",
      "description": "<p>Lagunes</p>",
      "image": "https://tukki.cssrender.com/storage/app/public/12/64a42b93a5a1e_images.jpeg",
      "latitude": "",
      "longitude": null
    }
  ]
} 
*/

  int ?status;
  String ?message;
  List<UserLocationData> ?data;

  UserLocationSomeRootEntity({
    this.status,
    this.message,
    this.data,
  });
  UserLocationSomeRootEntity.fromJson(Map<String, dynamic> json) {
    status = json['status']?.toInt();
    message = json['message']?.toString();
  if (json['data'] != null) {
  final v = json['data'];
  final arr0 = <UserLocationData>[];
  v.forEach((v) {
  arr0.add(UserLocationData.fromJson(v));
  });
    data = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      final v = this.data;
      final arr0 = [];
  for (var v in v!) {
  arr0.add(v.toJson());
  }
      data['data'] = arr0;
    }
    return data;
  }
}
