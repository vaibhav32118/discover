import 'package:discover/providers/cluster.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:location/location.dart' as geoloc;
import 'package:google_place/google_place.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

class LocationProvider extends ChangeNotifier {
  GooglePlace? googlePlace;
  List<SearchResult>? nearByResults;
  Map<int, Uint8List> images = {};
  geoloc.LocationData? locData;
  Location? loc;

  Cluster current_cluster = Cluster();
  Locat? pending_location;
  SignificantPlaces significant_places = SignificantPlaces();
  int d = 5;
  int t = 10;

  geoloc.Location location = geoloc.Location();

  void enableBackGps() {
    location.enableBackgroundMode(enable: true);
  }

  Future<Location?> getCurrentUserLocation() async {
    try {
      final locData = await location.getLocation();
      final loc = Location(lat: locData.latitude, lng: locData.longitude);
      return loc;
    } catch (error) {
      return null;
    }
  }

  double getDistanceBetweenCLusterLocatio(Cluster clus, Locat location) {
    var lat1 = clus.mean_location!.latitude!;
    var long1 = clus.mean_location!.longitude!;
    var lat2 = location.latitude;
    var long2 = location.longitude;

    //print('${lat1},${long1},${lat2},${long2}');

    double distanceInMeters =
        Geolocator.distanceBetween(lat1, long1, lat2, long2);
    //print(distanceInMeters);
    return distanceInMeters;
  }

  void buildCluster(Locat gpslog) {
    if (current_cluster.mean_location == null) {
      current_cluster.mean_location = gpslog;
    } else if (getDistanceBetweenCLusterLocatio(current_cluster, gpslog) <= d) {
      current_cluster.addLoc(gpslog);
      pending_location = null;
    } else {
      if (pending_location != null) {
        if (current_cluster.duration >= t) {
          significant_places.addPlace(current_cluster);
        }
        current_cluster = Cluster();
        if (current_cluster.mean_location != null) {
          current_cluster.mean_location = pending_location;
        }

        if (getDistanceBetweenCLusterLocatio(current_cluster, gpslog) <= d) {
          current_cluster.addLoc(gpslog);
          pending_location = null;
        } else {
          pending_location = gpslog;
        }
      } else {
        pending_location = gpslog;
      }
    }
  }

  bool flag = false;
  Future<void> getContinousLocation() async {
    location.onLocationChanged.listen((geoloc.LocationData currentLocation) {
      locData = currentLocation;
      Locat location_current = Locat(currentLocation.latitude,
          currentLocation.longitude, currentLocation.time!);
      buildCluster(location_current);
      print(significant_places.places);
      notifyListeners();
    });
  }
}
