import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:discover/providers/get_location.dart';
import 'package:location/location.dart' as geoloc;
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';

class RecommendedPlacesScreen extends StatefulWidget {
  const RecommendedPlacesScreen({Key? key}) : super(key: key);

  @override
  State<RecommendedPlacesScreen> createState() =>
      _RecommendedPlacesScreenState();
}

class _RecommendedPlacesScreenState extends State<RecommendedPlacesScreen> {
  // late geoloc.Location location;

  @override
  void initState() {
    super.initState();
  }

  String getPrettyJSONString(jsonObject) {
    var encoder = new JsonEncoder.withIndent("     ");
    return encoder.convert(jsonObject);
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<LocationProvider>(context, listen: false).enableBackGps();

    return FutureBuilder(
      future: Provider.of<LocationProvider>(context, listen: false)
          .getContinousLocation(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Recommended Places'),
          ),
          body: Consumer<LocationProvider>(
            builder: (ctx, loc, _) {
              DateTime date = DateTime.now();
              DateTime now = DateTime.now();
              String date1 = DateFormat('yyyy-M-dd').format(now);
              var place = loc.significant_places.places[date1.toString()];
              // print(place!.values.elementAt(0));

              return Container(
                margin: const EdgeInsets.all(10),
                height: 800,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ListTile(
                        leading: Icon(Icons.gps_fixed),
                        title: Text('Current Geo Cordinate'),
                        subtitle: Text(
                            '${loc.locData?.latitude}, ${loc.locData?.longitude} \n${date.toString()}'),
                      ),
                      ListTile(
                        leading: Icon(Icons.place_outlined),
                        title: Text('Extracted Places'),
                        // subtitle: place != null
                        //     ? Text('${getPrettyJSONString(place)}')
                        //     : Text('Null'),
                      ),
                      Divider(),
                      if (place != null) RecommendedPlacs(place: place),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class RecommendedPlacs extends StatelessWidget {
  final place;
  const RecommendedPlacs({Key? key, required this.place}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: place != null ? place.length : 0,
      itemBuilder: (BuildContext ctx1, int index) {
        var lat = place?.values.elementAt(index)[0];
        var long = place?.values.elementAt(index)[1];
        var dura = place?.values.elementAt(index)[2];

        // return ListTile(
        //   leading: Icon(Icons.place_outlined),
        //   title: Text('$lat, $long'),
        //   subtitle: Text('$dura'),
        // );

        return FutureBuilder(
          future: placemarkFromCoordinates(lat, long),
          builder: (ctx1, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    '${snapshot.error} occured',
                  ),
                );
              } else if (snapshot.hasData) {
                final data = snapshot.data as List;
                Placemark placeMark = data[0];
                String name = placeMark.name ?? "";
                String subLocality = placeMark.subLocality ?? '';
                String locality = placeMark.locality ?? '';
                String administrativeArea = placeMark.administrativeArea ?? '';
                String postalCode = placeMark.postalCode ?? '';
                String country = placeMark.country ?? '';
                String address =
                    "${name}, ${subLocality}, ${locality}, ${administrativeArea} ${postalCode}, ${country}";

                return ListTile(
                  leading: Icon(Icons.place),
                  title: Text(address),
                  subtitle: Text('${lat},${long}'),
                );
              }
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        );
      },
    )
        //
        );
  }
}
