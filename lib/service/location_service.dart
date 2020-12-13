import 'dart:async';

import 'package:flutter_map/model/user_location.dart';
import 'package:location/location.dart';

class LocationService {
  Location location = Location();

  StreamController<UserLocation> _locationStreamController =
      StreamController<UserLocation>();
  Stream<UserLocation> get locationStream => _locationStreamController.stream;

  LocationService() {
    //di contstructor location service meminta permission terlebih dahulu
    //meminta permission untuk lokasi dari user, kemudian jalan fungsi dengan parameter parmission status
    location.requestPermission().then((permissionStatus) => {
          //jika sudah di berikan izin
          if (permissionStatus == PermissionStatus.granted)
            {
              //melisten location data
              location.onLocationChanged.listen((locationData) => {
                    if (locationData != null)
                      {
                        //sink to user location
                        _locationStreamController.add(UserLocation(
                            latitude: locationData.latitude,
                            longitude: locationData.longitude))
                      }
                  })
            }
        });
  }

  void dispose() => _locationStreamController.close();
}
