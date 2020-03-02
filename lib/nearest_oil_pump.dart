import 'package:flutter/material.dart';
import 'package:flutter_nearest_oil_pump/place_details.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:location/location.dart' as LocationManager;

const kGoogleApiKey = "your map api key";
GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

class NearestOilPump extends StatefulWidget {
  @override
  _NearestOilPumpState createState() => _NearestOilPumpState();
}

class _NearestOilPumpState extends State<NearestOilPump> {
  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  GoogleMapController mapController;
  List<PlacesSearchResult> places = [];
  bool isLoading = false;
  String errorMessage;
  PlacesDetailsResponse _place;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget expandedChild;
    if (isLoading) {
      expandedChild = Center(child: CircularProgressIndicator(value: null));
    } else if (errorMessage != null) {
      expandedChild = Center(
        child: Text(errorMessage),
      );
    } else {
      expandedChild = buildPlacesList();


    }



    return Scaffold(
        key: homeScaffoldKey,
        appBar: AppBar(
          title: const Text("Nearest Oil Pump"),
        ),
        body: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: Column(
              children: <Widget>[
                Container(
                  child: SizedBox(
                      height: 200.0,
                      child: GoogleMap(
                        myLocationEnabled: true,
                        onMapCreated: _onMapCreated,
                        initialCameraPosition:
                            CameraPosition(target: LatLng(0.0, 0.0)),
                        markers: _markers,
                      )),
                ),
                Expanded(child: expandedChild)
              ],
            ),
          ),
        ));
  }

  void refresh() async {
    final center = await getUserLocation();

    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: center == null ? LatLng(0, 0) : center, zoom: 15.0)));
    getNearbyPlaces(center);
  }

  void refreshByCenter(LatLng center) async {
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: center == null ? LatLng(0, 0) : center, zoom: 15.0)));
    getNearbyPlaces(center);
  }

  void fetchLatLongById(String placeId) async {
    PlacesDetailsResponse place = await _places.getDetailsByPlaceId(placeId);

    if (place.status == "OK") {
      this._place = place;

      final location = _place.result.geometry.location;
      final lat = location.lat;
      final lng = location.lng;
      final center = LatLng(lat, lng);
      refreshByCenter(center);
    }
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    refresh();
  }

  Future<LatLng> getUserLocation() async {
    LocationManager.LocationData currentLocation;
    final location = LocationManager.Location();
    try {
      currentLocation = await location.getLocation();
      final lat = currentLocation.latitude;
      final lng = currentLocation.longitude;
      final center = LatLng(lat, lng);
      return center;
    } on Exception {
      currentLocation = null;
      return null;
    }
  }

  void getNearbyPlaces(LatLng center) async {
    setState(() {
      this.isLoading = true;
      this.errorMessage = null;
    });

    final location = Location(center.latitude, center.longitude);
    final result =
        await _places.searchNearbyWithRadius(location, 1000, type: "gas_station");

    setState(() {
      this.isLoading = false;
      if (result.status == "OK") {
        this.places = result.results;
        result.results.forEach((f) {
/*          final markerOptions = MarkerOptions(
//              icon: BitmapDescriptor.fromAsset('assets/images/mosqueone.png'),
              icon: isIOS? BitmapDescriptor.fromAsset('assets/images/mosquetwo.png'):BitmapDescriptor.fromAsset('assets/images/mosqueone.png'),
              position:
              LatLng(f.geometry.location.lat, f.geometry.location.lng),
              infoWindowText: InfoWindowText("${f.name}", "${f.types?.first}"));
          mapController.addMarker(markerOptions);*/
          _markers.add(Marker(
              markerId: MarkerId(
                  LatLng(f.geometry.location.lat, f.geometry.location.lng)
                      .toString()),
//          icon: BitmapDescriptor.fromAsset('assets/images/mosqueone.png'),
              icon:  BitmapDescriptor.fromAsset('assets/images/gasoline.png'),
              position:
                  LatLng(f.geometry.location.lat, f.geometry.location.lng),
              infoWindow: InfoWindow(
                  title: "${f.name}", snippet: "${f.types?.first}")));
        });
      } else {
        this.errorMessage = result.errorMessage;
      }
    });
  }

  void onError(PlacesAutocompleteResponse response) {
    homeScaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text(response.errorMessage)),
    );
  }


  Future<Null> showDetailPlace(String placeId) async {
    if (placeId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PlaceDetailWidget(placeId)),
      );
    }
  }

  ListView buildPlacesList() {
    final placesWidget = places.map((f) {
      List<Widget> list = [
        Padding(
          padding: EdgeInsets.only(bottom: 4.0),
          child: Text(
            f.name,
//            style: Theme.of(context).textTheme.subtitle,
            style: TextStyle(color: Colors.black, fontSize: 15.0),
          ),
        )
      ];
      if (f.formattedAddress != null) {
        list.add(Padding(
          padding: EdgeInsets.only(bottom: 2.0),
          child: Text(
            f.formattedAddress,
            style: TextStyle(color: Colors.black, fontSize: 13.0),
          ),
        ));
      }

      if (f.vicinity != null) {
        list.add(Padding(
          padding: EdgeInsets.only(bottom: 2.0),
          child: Text(
            f.vicinity,
            style: TextStyle(color: Colors.black, fontSize: 12.0),
          ),
        ));
      }

      if (f.types?.first != null) {
        list.add(Padding(
          padding: EdgeInsets.only(bottom: 2.0),
          child: Text(
            f.types.first,
            style: TextStyle(color: Colors.black, fontSize: 12.0),
          ),
        ));
      }

      return Card(
        color: Colors.grey,
        elevation: 1.0,
        child: InkWell(
          onTap: () {
            showDetailPlace(f.placeId);
          },
          highlightColor: Colors.lightBlueAccent,
          splashColor: Colors.red,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: list,
            ),
          ),
        ),
      );
    }).toList();

    return ListView(shrinkWrap: true, children: placesWidget);
  }
}
