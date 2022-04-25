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
    snapshot =
        _getCurrentUserLocation().then((value) => getNearByPlaces(value!));
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
          builder: (BuildContext context, snapShot) {
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
                        padding: const EdgeInsets.all(2.0),
                        child: Text(
                          nearByResults![index].name!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: ClipRect(
                            child: Text(
                          nearByResults![index].types![0],
                        )),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(2),
                        child: ClipRect(
                          child: Text(
                              'Latitude: ${nearByResults![index].geometry!.location!.lat.toString()}  Longitude: ${nearByResults![index].geometry!.location!.lng.toString()}'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(nearByResults![index].formattedAddress!),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     setState(() {
      //       getNearByPlaces(loc!);
      //     });
      //   },
      //   child: const Icon(Icons.refresh),
      // ),
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

  Future<void> getNearByPlaces(Location loc) async {
    int index = 0;
    var result = await googlePlace!.search.getNearBySearch(
      loc,
      5000,
      type: 'attractions',
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
      height: 230,
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
                  height: 230,
                  child: Icon(Icons.no_flash_outlined),
                ),
        ),
      ),
    );
  }
}
