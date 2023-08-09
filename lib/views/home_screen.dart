import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../view_model/location_view_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();
  StreamSubscription<Position>? _positionStreamSubscription;
  final LocationSettings _locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10, // min jarak 10 m utk pembaruan
  );

  @override
  void initState() {
    super.initState();
    final locationViewModel = Provider.of<LocationViewModel>(context, listen: false);
    locationViewModel.getCurrentPosition().catchError((error){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text("${error}", textAlign: TextAlign.center,),),
      );
    });
  }

  void getLocationUpdates({required LocationViewModel locationViewModel}) async {
    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: _locationSettings).listen(
      (Position position) {
        locationViewModel.updateLocation(position);
      },
      onError: (error) {
      },
    );
  }

  void stopLocationStream() {
    _positionStreamSubscription?.cancel();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    final locationViewModel = Provider.of<LocationViewModel>(context, listen: false);
    locationViewModel.resetLocationViewModel();
    stopLocationStream();
    locationViewModel.getCurrentPosition();
    _mapController.future.then((controller) {
      controller.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("======== BUILD");
    final locationViewModel = Provider.of<LocationViewModel>(context, listen: false);
    print("============${locationViewModel.initialCameraPosition.latitude}");

    return Scaffold(
      backgroundColor: Colors.blueGrey[200],
      appBar: AppBar(
        title: Text('Map Screen'),
      ),
      body: Center(
        child: Consumer<LocationViewModel>(
          builder: (context, value, _) {
            return value.initialCameraPosition.latitude != 0
            ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Jenis Perjalanan: ${value.infoDestincation['profile']}"),
                    SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(value.initialCameraPosition.latitude.toString()),
                    SizedBox(width: 8,),
                    Text(value.initialCameraPosition.longitude.toString()),
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Jarak Tujuan: ${(value.infoDestincation['distance'] as num).toStringAsFixed(2)} Meter"),
                    SizedBox(width: 8,),
                    Text("Duration Tujuan: ${(value.infoDestincation['duration'] / 60  as num).toStringAsFixed(2)} Menit"),
                  ],
                ),
                SizedBox(height: 10,),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: value.initialCameraPosition,
                      zoom: 15.0,
                    ),
                    markers: value.markers,
                    polylines: value.polylines,
                    mapType: MapType.normal,
                    myLocationEnabled: true,
                    onTap: (LatLng latLng){
                      value.markers.length >= 2 ?
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: Colors.redAccent,
                          content: Text("tujuan anda sudah ada ! jika ingin ubah tekan tombol hapus", textAlign: TextAlign.center,),),
                        )
                      : 
                      locationViewModel.addDestinationMarker(latLng);
                    },
                    onMapCreated: (GoogleMapController controller) {
                      if (!_mapController.isCompleted) {
                        _mapController.complete(controller);
                      }
                    },
                  ),
                ),
                SizedBox(height: 10,),
              ],
            ) : const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              );
          }
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            onPressed: (){
              getLocationUpdates(locationViewModel: locationViewModel);
            },
              child: Icon(Icons.play_arrow),
            ),
            FloatingActionButton(
              onPressed: stopLocationStream,
              child: Icon(Icons.stop),
            ),
            FloatingActionButton(
              onPressed: (){
                locationViewModel.getPolyLinesDestination(context);
              },
              child: Icon(Icons.route_outlined),
            ),
            FloatingActionButton(
              onPressed: (){
                locationViewModel.resetLocationViewModel();
                stopLocationStream();
                locationViewModel.getCurrentPosition();
              },
              child: Icon(Icons.replay_outlined),
            ),
          ],
        ),
      ),
    );
  }
}