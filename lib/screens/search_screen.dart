import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_place/google_place.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GooglePlace? googlePlace;
  List<AutocompletePrediction>? predictions = [];
  Timer? _debounce;

  @override
  void initState() {
    String apiKey = dotenv.env['API_KEY']!;
    googlePlace = GooglePlace(apiKey);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(right: 20, left: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                decoration: InputDecoration(
                  labelText: "Search",
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(15)),
                  enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black54,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(15)),
                ),
                onChanged: (value) {
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                  _debounce = Timer(const Duration(milliseconds: 250), () {
                    if (value.isNotEmpty) {
                      autoCompleteSearch(value);
                    } else {
                      setState(() {
                        predictions = [];
                      });
                    }
                  });
                },
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: predictions!.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(
                          Icons.pin_drop_rounded,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(predictions![index].description!),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.white, width: 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      onTap: () {
                        debugPrint(predictions![index].placeId);
                        debugPrint(predictions![index].description!);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsPage(
                              placeId: predictions![index].placeId,
                              googlePlace: googlePlace,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 10),
                child: Image.asset("assets/powered_by_google.png"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void autoCompleteSearch(String value) async {
    var result = await googlePlace!.autocomplete.get(value);

    if (result != null && result.predictions != null && mounted) {
      setState(() {
        predictions = result.predictions!;
      });
    }
  }
}

class DetailsPage extends StatefulWidget {
  final String? placeId;
  final GooglePlace? googlePlace;

  const DetailsPage({Key? key, this.placeId, this.googlePlace})
      : super(key: key);

  @override
  _DetailsPageState createState() => _DetailsPageState(placeId, googlePlace);
}

class _DetailsPageState extends State<DetailsPage> {
  final String? placeId;
  final GooglePlace? googlePlace;

  _DetailsPageState(this.placeId, this.googlePlace);

  DetailsResult? detailsResult;
  List<Uint8List> images = [];

  @override
  void initState() {
    getDetils(placeId!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(detailsResult != null && detailsResult!.name != null
            ? detailsResult!.name!
            : 'Details'),
        backgroundColor: Colors.purple,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () {
          getDetils(placeId!);
        },
        child: const Icon(Icons.refresh),
      ),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(right: 6, left: 6, top: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: 250,
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.memory(
                            images[index],
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListView(
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.only(left: 15, top: 10),
                        child: const Text(
                          "Details",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      detailsResult != null && detailsResult!.types != null
                          ? Container(
                              margin: const EdgeInsets.only(left: 15, top: 10),
                              height: 50,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: detailsResult!.types!.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: const EdgeInsets.only(right: 10),
                                    child: Chip(
                                      label: Text(
                                        detailsResult!.types![index],
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      backgroundColor: Colors.purple,
                                    ),
                                  );
                                },
                              ),
                            )
                          : Container(),
                      Container(
                        margin: const EdgeInsets.only(left: 7, top: 10),
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.playlist_add_check_circle_sharp),
                          ),
                          title: Text(
                            detailsResult != null && detailsResult!.name != null
                                ? 'Name: ${detailsResult!.name}'
                                : "Name: -",
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 7, top: 10),
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.location_on),
                          ),
                          title: Text(
                            detailsResult != null &&
                                    detailsResult!.formattedAddress != null
                                ? 'Address: ${detailsResult!.formattedAddress}'
                                : "Address: -",
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 7, top: 10),
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.location_searching),
                          ),
                          title: Text(
                            detailsResult != null &&
                                    detailsResult!.geometry != null &&
                                    detailsResult!.geometry!.location != null
                                ? 'Geometry \nLatitude: ${detailsResult!.geometry!.location!.lat.toString()} \nLongitude: ${detailsResult!.geometry!.location!.lng.toString()}'
                                : "Geometry: -",
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 7, top: 10),
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.link),
                          ),
                          title: Text(
                            detailsResult != null &&
                                    detailsResult!.website != null
                                ? 'Website: \n${detailsResult!.website}'
                                : "Website: -",
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 7, top: 10),
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.rate_review),
                          ),
                          title: Text(
                            detailsResult != null &&
                                    detailsResult!.rating != null
                                ? 'Rating: ${detailsResult!.rating.toString()}'
                                : "Rating: -",
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 7, top: 10),
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.timelapse),
                          ),
                          title: Text(
                            detailsResult != null &&
                                    detailsResult!.utcOffset != null
                                ? 'UTC Offset: ${detailsResult!.utcOffset.toString()} Min'
                                : "UTC Offset: -",
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 7, top: 10),
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.attach_money),
                          ),
                          title: Text(
                            detailsResult != null &&
                                    detailsResult!.priceLevel != null
                                ? 'Price level: ${detailsResult!.priceLevel.toString()}'
                                : "Price level: -",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 10),
                child: Image.asset("assets/powered_by_google.png"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void getDetils(String placeId) async {
    var result = await googlePlace!.details.get(placeId);
    if (result != null && result.result != null && mounted) {
      setState(() {
        detailsResult = result.result;
        images = [];
      });

      if (result.result!.photos != null) {
        for (var photo in result.result!.photos!) {
          getPhoto(photo.photoReference!);
        }
      }
    }
  }

  void getPhoto(String photoReference) async {
    var result = await googlePlace!.photos.get(photoReference, 400, 400);
    if (result != null) {
      setState(() {
        images.add(result);
      });
    }
  }
}
