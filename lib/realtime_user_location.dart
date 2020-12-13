

import 'package:flutter/material.dart';
import 'package:flutter_map/model/user_location.dart';
import 'package:flutter_map/service/location_service.dart';

class LocationPage extends StatefulWidget {
  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  LocationService locationService = LocationService();

  @override
  void dispose() {
    super.dispose();
    locationService.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Realtime update for user location')
      ),
      body: StreamBuilder<UserLocation>(
        stream: locationService.locationStream,
              builder:(_, snapshot) => (snapshot.hasData) ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Latitude'),
              Text(snapshot.data.latitude.toString(), style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold
              ),),
              SizedBox(height: 20),
              Text('Longitude'),
              Text(snapshot.data.longitude.toString(), style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold
              ),),
            ],
          )
        ) : SizedBox()
      ),
    );
  }
}