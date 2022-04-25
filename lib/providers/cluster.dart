import 'package:flutter/material.dart';
import 'dart:async';
import 'package:location/location.dart';

import 'package:provider/provider.dart';

class Locat {
  final latitude;
  final longitude;
  final double timestamp;

  Locat(this.latitude, this.longitude, this.timestamp);
}

class Cluster {
  Locat? mean_location;
  int duration = 0;
  DateTime? arrival_time;
  DateTime? leaving_time;
  List<Locat> location_set = [];

  Cluster();

  Locat meanPosition(Locat loc1, Locat loc2) {
    final lat = (loc1.latitude! + loc2.latitude!) / 2;
    final long = (loc1.longitude! + loc2.longitude!) / 2;

    return Locat(lat, long, 0);
  }

  void addLoc(Locat location) {
    location_set.add(location);

    if (mean_location == null) {
      mean_location = location;
    } else {
      mean_location = meanPosition(mean_location!, location);
    }

    arrival_time ??=
        DateTime.fromMillisecondsSinceEpoch(location.timestamp.toInt());
    leaving_time =
        DateTime.fromMillisecondsSinceEpoch(location.timestamp.toInt());
    var dur = leaving_time!.difference(arrival_time!);
    duration = dur.inSeconds;
  }
}

class SignificantPlaces extends ChangeNotifier {
  Map<String, Map<String, dynamic>> places = {};
  void addPlace(Cluster cluster) {
    String key1 =
        '${cluster.arrival_time!.year}-${cluster.arrival_time!.month}-${cluster.arrival_time!.day}';
    String key2 =
        '${cluster.arrival_time!.hour}:${cluster.arrival_time!.minute}';
    List value = [
      cluster.mean_location!.latitude,
      cluster.mean_location!.longitude,
      cluster.duration
    ];
    if (!places.containsKey(key1)) {
      places[key1] = {key2: value};
    } else {
      places[key1]![key2] = value;
    }
  }
}
