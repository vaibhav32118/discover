import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';
import 'package:location/location.dart' as geoloc;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NearByPlacesScreen extends StatefulWidget {
  const NearByPlacesScreen({Key? key}) : super(key: key);

  @override
  State<NearByPlacesScreen> createState() => _NearByPlacesScreenState();
}

class _NearByPlacesScreenState extends State<NearByPlacesScreen> {
  GooglePlace? googlePlace;
  List<SearchResult>? nearByResults;
  Map<int, Uint8List> images = {};
  geoloc.LocationData? locData;
  Location? loc;
  var snapshot;

  @override
  void initState() {
    String apiKey = dotenv.env['API_KEY']!;
    // 'AIzaSyC1zyhWR2YxPv5UGXh4HMEU70x1iv9EaQy'
    googlePlace = GooglePlace(apiKey);
    snapshot = getNearByPlaces();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Near By Places'),
      ),
      body: Container(
        margin: const EdgeInsets.all(10),
        child: FutureBuilder(
          future: snapshot,
          builder: (BuildContext context, AsyncSnapshot snapShot) {
            if (snapShot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView.builder(
              itemCount: nearByResults != null ? nearByResults!.length : 0,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  margin: const EdgeInsets.all(5),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PlacePhoto(
                        nearByResults: nearByResults,
                        images: images,
                        index: index,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: nearByResults![index].name != null
                            ? Text(
                                nearByResults![index].name!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                ),
                              )
                            : Text(
                                'Name',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                ),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: nearByResults![index].types != null
                            ? ClipRect(
                                child: Text(
                                nearByResults![index].types![0],
                              ))
                            : Text('Type'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: nearByResults![index].geometry != null
                            ? ClipRect(
                                child: Text(
                                    'Latitude: ${nearByResults![index].geometry!.location!.lat.toString()}  Longitude: ${nearByResults![index].geometry!.location!.lng.toString()}'),
                              )
                            : Text('Location'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: nearByResults![index].vicinity != null
                            ? Text(nearByResults![index].vicinity!)
                            : Text('Address'),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          snapshot = getNearByPlaces();
          setState(() {});
        },
        child: const Icon(Icons.refresh),
        backgroundColor: Colors.purple,
      ),
    );
  }

  Future<Location?> _getCurrentUserLocation() async {
    try {
      locData = await geoloc.Location().getLocation();
      loc = Location(lat: locData!.latitude, lng: locData!.longitude);
      return loc;
    } catch (error) {
      return null;
    }
  }

  Future<void> getNearByPlaces() async {
    var loc;
    try {
      locData = await geoloc.Location().getLocation();
      print(locData);
      loc = Location(lat: locData!.latitude, lng: locData!.longitude);
    } catch (error) {}
    int index = 0;
    var result = await googlePlace!.search.getNearBySearch(
      loc,
      5000,
    );
    if (result != null && result.results != null && mounted) {
      nearByResults = result.results;

      for (var place in nearByResults!) {
        if (place.photos != null) {
          for (var photo in place.photos!) {
            var result =
                await googlePlace!.photos.get(photo.photoReference!, 400, 400);
            if (result != null) {
              images[index] = result;
              index++;
              break;
            } else {
              index++;
            }
          }
        } else {
          index++;
        }
      }
    }
  }
}

class PlacePhoto extends StatelessWidget {
  const PlacePhoto({
    Key? key,
    required this.nearByResults,
    required this.images,
    required this.index,
  }) : super(key: key);

  final List<SearchResult>? nearByResults;
  final Map<int, Uint8List> images;
  final int index;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: nearByResults![index].photos != null ? 230 : 100,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: nearByResults![index].photos != null
              ? Image.memory(
                  images[index]!,
                  fit: BoxFit.fill,
                )
              : const SizedBox(
                  height: 100,
                  child: Icon(Icons.image),
                ),
        ),
      ),
    );
  }
}
