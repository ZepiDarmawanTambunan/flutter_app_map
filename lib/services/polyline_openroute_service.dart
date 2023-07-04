import 'package:http/http.dart' as http;
import 'dart:convert';

class PolyLineOpenRouteService{
    final String url = 'https://api.openrouteservice.org/v2/directions/';
  final String apiKey =
      '5b3ce3597851110001cf62483b96f106534a4cd889501129c38f4b54';
  final String pathParam = 'driving-car'; // Change it if you want

  final double startLat;
  final double startLng;
  final double endLat;
  final double endLng;
  
  PolyLineOpenRouteService({
    required double this.startLat,
    required double this.startLng,
    required double this.endLat,
    required double this.endLng,
  });

  Future getData() async {
    try {
      http.Response response = await http.get(Uri.parse(
        '$url$pathParam?api_key=$apiKey&start=$startLng,$startLat&end=$endLng,$endLat'));
      if (response.statusCode == 200) {
        String data = response.body;
        print(data);
        return jsonDecode(data);
      } else {
          throw Exception("error ${response.statusCode}");
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}