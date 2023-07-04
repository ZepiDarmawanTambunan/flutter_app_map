import 'package:flutter/material.dart';
import 'package:flutter_app_map/services/polyline_openroute_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationViewModel with ChangeNotifier {
  List<Position> _positions = [];
  Map<String, dynamic> _infoDestincation = {"distance": 0, "duration": 0, "profile": "belum ada"};
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  LatLng _initialCameraPosition = LatLng(0, 0);

  List<Position> get positions => _positions;
  Map<String, dynamic> get infoDestincation => _infoDestincation;
  Set<Marker> get markers => _markers;
  Set<Polyline> get polylines => _polylines;
  LatLng get initialCameraPosition => _initialCameraPosition;

  Future getCurrentPosition() async {
    try {
        LocationPermission permission = await Geolocator.checkPermission();
        bool isLocationPermissionGranted = permission == LocationPermission.always || permission == LocationPermission.whileInUse;

      if (isLocationPermissionGranted) {
        final currentPosition = await Geolocator.getCurrentPosition();
        _initialCameraPosition = LatLng(currentPosition.latitude, currentPosition.longitude);
        _positions.add(currentPosition);
        _markers.add(Marker(
          markerId: const MarkerId('initialMarker'),
          position: _initialCameraPosition,
        ));
        notifyListeners();
        return true;
      } else {
        LocationPermission permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
          getCurrentPosition();
        }else{
          throw Exception('wajib mengaktifkan aktifkan gps dan internet ! tutup dan buka kembali aplikasi anda');
        }
      }
    } catch (e) {
      throw Exception('wajib mengaktifkan gps dan internet ! tutup dan buka kembali aplikasi anda');
    }
  }

  void updateLocation(Position position) {
    _positions.add(position);

    if (_positions.length >= 2) {
      final previousPosition = _positions[_positions.length - 2];
      final polylineId = PolylineId(_positions.length.toString());
      final newPolyline = Polyline(
        polylineId: polylineId,
        points: [
          LatLng(previousPosition.latitude, previousPosition.longitude),
          LatLng(position.latitude, position.longitude),
        ],
      );
      _polylines.add(newPolyline);
    }

    notifyListeners();
  }

  void addDestinationMarker(LatLng latLng){
    try {
      _markers.add(Marker(
        markerId: const MarkerId('destinationMarker'),
        position: latLng,
      ));
      notifyListeners();
    } catch (e) {
      throw Exception('wajib aktifkan gps dan internet, tutup dan buka kembali aplikasi anda !');
    }
  }

  Future getPolyLinesDestination(BuildContext context) async {
    if(_markers.length >= 2){
      PolyLineOpenRouteService polyLineOpenRouteService = PolyLineOpenRouteService(
        startLat: _markers.first.position.latitude,
        startLng: _markers.first.position.longitude,
        endLat: _markers.last.position.latitude,
        endLng: _markers.last.position.longitude,
      );

      try {
        final data = await polyLineOpenRouteService.getData();
        List<LatLng> polyPoints = [];
        List<dynamic> ls = data['features'][0]['geometry']['coordinates'];
        _polylines.clear();

        for (int i = 0; i < ls.length; i++) {
          polyPoints.add(LatLng(ls[i][1], ls[i][0]));
        }

        Polyline polyline = Polyline(
          polylineId: PolylineId("polyline"),
          color: Colors.lightBlue,
          points: polyPoints,
        );
        _polylines.add(polyline);
        _infoDestincation = {"distance": data['features'][0]['properties']['segments'][0]['distance'], "duration": data['features'][0]['properties']['segments'][0]['duration'], "profile": data['metadata']['query']['profile']};
        notifyListeners();
      } catch (e) {
        throw Exception(e);
      }
    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text("Tujuan anda belum dipilih !", textAlign: TextAlign.center,),),
      );
    }
  }

  void resetLocationViewMolde(){
    _positions = [];
    _markers = {};
    _polylines = {};
    _initialCameraPosition = LatLng(0, 0);
    _infoDestincation= {"distance": 0, "duration": 0, "profile": "belum ada"};
    notifyListeners();
  }

}