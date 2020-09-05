import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';


class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  Position _currentPosition;
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Set<Marker> markers = {};
  //TextEditingController _textEditingController = TextEditingController();
  String _placeDistance;
  String _startAddress = " ";
  String _destinationAddress = '';
  String _currentAddress;
  CameraPosition _initialCameraPosition =
  CameraPosition(target: LatLng(0.0, 0.0));
  CameraPosition _myHome =
  CameraPosition(target: LatLng(41.0529517, 29.06513130), zoom: 18.0);
  GoogleMapController googleMapController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCurrentLocationMyType2();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildBody(context),
    );
  }

  Container buildBody(BuildContext context) {
    return Container(
      height: MediaQuery
          .of(context)
          .size
          .height,
      width: MediaQuery
          .of(context)
          .size
          .width,
      child: Stack(
        children: <Widget>[
          buildGoogleMap(),
          buildZoomButtonsPadding(),
          buildCurrentLocationButton(),
          buildInfoShowZonePadding(context),
        ],
      ),
    );
  }

  Padding buildInfoShowZonePadding(BuildContext context) {
    return Padding(
            padding: EdgeInsets.only(top: 15, right: 20, left: 70),
            child: Column(
              //crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 10),
                buildStartAddressTextField(context),
                SizedBox(height: 10),
                buildDestinationAddressTextField(context),
                SizedBox(height: 10),
                buildDistanceCalculateButton(),
                buildDistanceShowText(),
              ],
            ),
          );
  }

  Padding buildZoomButtonsPadding() {
    return Padding(
            padding: EdgeInsets.only(left: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                buildZoomInButton(),
                SizedBox(height: 15),
                buildZoomOutButton()
              ],
            ),
          );
  }

  Visibility buildDistanceShowText() {
    return Visibility(
                  visible: _placeDistance == null ? false : true,
                  child: Text(
                    "DISTANCE: $_placeDistance",
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                );
  }

  Container buildDistanceCalculateButton() {
    return Container(
                  child: RaisedButton(
                      onPressed: (_startAddress != " " &&
                          _destinationAddress != " ") ? () async {
                        setState(() {
                          _calculateDistance().then((isCalculated) {
                            if (isCalculated) {
                              _scaffoldKey.currentState.showSnackBar(SnackBar(
                                  content: Text(
                                      "DISTANCE CALCULATED SUCCESS")));
                            } else {
                              _scaffoldKey.currentState.showSnackBar(SnackBar(
                                  content: Text(
                                      "ERROR CALCULATING DISTANCE")));
                            }
                          });
                        });
                      }: null,
                  ),
                );
  }

  Container buildDestinationAddressTextField(BuildContext context) {
    return Container(
                  child: buildCustomTextField(
                    label: "Destination",
                    hint: "Choose Destination Point",
                    initialValue: " ",
                    prefixIcon: Icon(Icons.looks_two),
                    textEditingController: destinationAddressController,
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.8,
                    locationCallBack: (String value) {
                      setState(() {
                        _destinationAddress = value;
                      });
                    },
                  ), // CUSTOM TEXT FIELD
                );
  }

  Container buildStartAddressTextField(BuildContext context) {
    return Container(
                  child: buildCustomTextField(
                    label: "Start",
                    hint: "Choose Starting Point",
                    initialValue: _currentAddress,
                    prefixIcon: Icon(Icons.looks_one),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.my_location),
                      onPressed: () {
                        startAddressController.text = _currentAddress;
                        _startAddress = _currentAddress;
                      },
                    ),
                    textEditingController: startAddressController,
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.8,
                    locationCallBack: (String value) {
                      setState(() {
                        _startAddress = value;
                      });
                    },
                  ), // CUSTOM TEXT FIELD
                );
  }

  Positioned buildCurrentLocationButton() {
    return Positioned(
            bottom: 15,
            right: 15,
            child: Container(
              height: 60,
              width: 60,
              child: FloatingActionButton(
                //CURRENT LOCATION
                elevation: 0,
                child: Icon(Icons.my_location),
                backgroundColor: Colors.grey.withOpacity(0.5),
                onPressed: () {
                  debugPrint(_currentPosition.longitude.toString());
                  debugPrint(_currentPosition.latitude.toString());
                  googleMapController.animateCamera(
                      CameraUpdate.newCameraPosition(CameraPosition(
                          target: LatLng(_currentPosition.latitude,
                              _currentPosition.longitude),
                          zoom: 18.0)));
                },
              ),
            ),
          );
  }

  Container buildZoomOutButton() {
    return Container(
                  height: 30,
                  width: 30,
                  child: FloatingActionButton(
                    //ZOOM OUT
                    elevation: 0,
                    child: Icon(Icons.remove, color: Colors.black87),
                    backgroundColor: Colors.transparent,
                    onPressed: () {
                      googleMapController
                          .animateCamera(CameraUpdate.zoomOut());
                    },
                  ),
                );
  }

  Container buildZoomInButton() {
    return Container(
                  height: 30,
                  width: 30,
                  child: FloatingActionButton(
                    // ZOOM IN
                    elevation: 0,
                    onPressed: () {
                      googleMapController
                          .animateCamera(CameraUpdate.zoomIn());
                    },
                    backgroundColor: Colors.transparent,
                    child: Icon(Icons.add, color: Colors.black87),
                  ),
                );
  }

  GoogleMap buildGoogleMap() {
    return GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            mapType: MapType.normal,
            zoomControlsEnabled: false,
            zoomGesturesEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              googleMapController = controller;
            },
          );
  }

  _getAddress() async {
    try {
      List<Placemark> placeMark = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);
      Placemark places = placeMark[0];
      setState(() {
        _currentAddress =
        "${places.name}, ${places.locality}, ${places.postalCode}, ${places
            .country}";
        startAddressController.text = _currentAddress;
        _startAddress = _currentAddress;
      });
    } catch (e) {
      debugPrint(e);
    }
  }

  Future<bool> _calculateDistance() async {
    try {
      List<Location> startPlaceMark = await locationFromAddress(_startAddress);
      List<Location> destinationPlaceMark =
      await locationFromAddress(_destinationAddress);

      if (startPlaceMark != null && destinationPlaceMark != null) {
        Position startCoordinates = _startAddress == _currentAddress
            ? Position(
          latitude: _currentPosition.latitude,
          longitude: _currentPosition.longitude,
        )
            : Position(
            latitude: startPlaceMark[0].latitude,
            longitude: startPlaceMark[0].longitude);

        Position destinationCoordinates = Position(
            latitude: destinationPlaceMark[0].latitude,
            longitude: destinationPlaceMark[0].longitude);

        Marker startMarker = Marker(
          markerId: MarkerId("$startCoordinates"),
          position:
          LatLng(startCoordinates.latitude, startCoordinates.longitude),
          infoWindow: InfoWindow(title: "Start", snippet: _startAddress),
          icon: BitmapDescriptor.defaultMarker,
        );

        Marker destinationMarker = Marker(
            markerId: MarkerId("$destinationCoordinates"),
            position: LatLng(destinationCoordinates.latitude,
                destinationCoordinates.longitude),
            infoWindow:
            InfoWindow(title: "Destination", snippet: _destinationAddress),
            icon: BitmapDescriptor.defaultMarker);
        markers.add(startMarker);
        markers.add(destinationMarker);

        debugPrint("START COORDINATES: $startCoordinates");
        debugPrint("DESTINATION COORDINATES $destinationCoordinates");

        Position _northEastCoordinates;
        Position _southEastCoordinates;

        if (startCoordinates.latitude <= destinationCoordinates.latitude) {
          _southEastCoordinates = startCoordinates;
          _northEastCoordinates = destinationCoordinates;
        } else {
          _southEastCoordinates = destinationCoordinates;
          _northEastCoordinates = startCoordinates;
        }

        googleMapController.animateCamera(
          CameraUpdate.newLatLngBounds(
              LatLngBounds(
                southwest: LatLng(_southEastCoordinates.latitude,
                    _southEastCoordinates.longitude),
                northeast: LatLng(_northEastCoordinates.latitude,
                    _northEastCoordinates.longitude),
              ),
              100.0),
        );
        double distanceInMeters = await bearingBetween(
            startCoordinates.latitude,
            startCoordinates.longitude,
            destinationCoordinates.latitude,
            destinationCoordinates.longitude);
        setState(() {
          _placeDistance = distanceInMeters.toString();
          debugPrint("DISTANCE: $_placeDistance");
        });
        return true;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return false;
  }

  _getCurrentLocationMyType() async {
    Position position =
    await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
      googleMapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 18.0)));
    });
  }

  _getCurrentLocationMyType2() async {
    await GeolocatorPlatform.instance
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        _currentPosition = position;
        //debugPrint(_currentPosition.longitude.toString());
        //debugPrint(_currentPosition.latitude.toString());
        googleMapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(position.latitude, position.longitude),
                zoom: 18.0)));
      });
      await _getAddress();
    }).catchError((Object e) {
      debugPrint(e.toString());
    });
  }

  _getCurrentLocation() async {

    await _geolocatorPlatform
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position value) async {
      setState(() {
        _currentPosition = value;
        print("CURRENT POSITION $_currentPosition");
        googleMapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(value.latitude, value.longitude), zoom: 18.0)));
      });
    }).catchError((Object e) {
      print(e);
    });
  }

  Widget buildCustomTextField({
    TextEditingController textEditingController,
    String label,
    String hint,
    String initialValue,
    double width,
    Icon prefixIcon,
    Widget suffixIcon,
    Function(String) locationCallBack,
  }) {
    return Container(
      width: width * 0.8,
      child: TextField(
        onChanged: (value) => locationCallBack(value),
        controller: textEditingController,
        decoration: InputDecoration(
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.lightBlue.shade300, width: 2),
          ),
          hintText: hint,
        ),
      ),
    );
  }

}
