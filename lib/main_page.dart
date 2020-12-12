import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:here_sdk/mapview.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/routing.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  HereMapController _controller;
  MapPolyline _mapPolyLine;
  bool _activePolyLine = false;

  //list untuk menyimpan tempat2 wisata yg ada di palembang
  List<GeoCoordinates> places;
  //menyimpan marker2 dari list di atas
  List<MapMarker> markers;

  //lokasi awal
  GeoCoordinates initialLocation = GeoCoordinates(-3.0026799, 104.7657554);

  @override
  void dispose() {
    //ketika controllernya tidak null, maka jalankan finalize / akhiri
    _controller?.finalize();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    places = [
      GeoCoordinates(-2.9961041, 104.7616614), // kampung kapitan
      GeoCoordinates(-3.0231046, 104.782534), // jakabaring sport center
      GeoCoordinates(-2.9508758, 104.7284836), // musium bala putra dewa
      GeoCoordinates(-2.9917713, 104.7626595), // jembatan ampera
    ];
    markers = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      HereMap(
        onMapCreated: _onMapCreated,
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: RaisedButton(
            child: Text('Cari Wisata Terdekat'),
            onPressed: () {
              // if (_activePolyLine == false) {
              //   _controller.mapScene.removeMapPolyline(_mapPolyLine);
              //   _activePolyLine = true;
              // } else {
              //   _activePolyLine = false;
              //   _controller.mapScene.addMapPolyline(_mapPolyLine);
              // }
              
              //urutkan tempat wisata berdasarkan jaraknya
              //membandingkan jarak marker1 dengan initial location / lokasi, awal dan marker2 dengan initial location / lokasi
              markers.sort((marker1, marker2) => initialLocation
                  .distanceTo(marker1.coordinates)
                  .compareTo(initialLocation.distanceTo(marker2.coordinates)));

              //membuang marker yang terdekat / reddot
              _controller.mapScene.removeMapMarker(markers[0]);
              //lalu gambar ulang menjadi thumb-up
              drawMarker(_controller, 0, markers[0].coordinates, path: 'assets/images/thumbs-up.png');
            }),
      )
    ]));
  }

  Future<MapMarker> drawMarker(HereMapController hereMapController,
      int drawOrder, GeoCoordinates geoCoordinates,
      {String path = 'assets/images/circle.png'}) async {
    //load gambar
    ByteData fileData = await rootBundle.load(path);
    //ubah menjadi pixel data / unsign integer
    Uint8List pixelData = fileData.buffer.asUint8List();
    //format gambar
    MapImage mapImage =
        MapImage.withPixelDataAndImageFormat(pixelData, ImageFormat.png);

    MapMarker mapMarker = MapMarker(geoCoordinates, mapImage);
    mapMarker.drawOrder = drawOrder;
    hereMapController.mapScene.addMapMarker(mapMarker);

    //mengembalikan nilai dari marker
    return mapMarker;
  }

  Future<void> drawPin(HereMapController hereMapController, int drawOrder,
      GeoCoordinates geoCoordinates) async {
    //load gambar
    ByteData fileData = await rootBundle.load('assets/images/pin.png');
    //ubah menjadi pixel data / unsign integer
    Uint8List pixelData = fileData.buffer.asUint8List();
    //format gambar
    MapImage mapImage =
        MapImage.withPixelDataAndImageFormat(pixelData, ImageFormat.png);

    Anchor2D anchor2d = Anchor2D.withHorizontalAndVertical(0.5, 1);

    MapMarker mapMarker =
        MapMarker.withAnchor(geoCoordinates, mapImage, anchor2d);
    mapMarker.drawOrder = drawOrder;
    hereMapController.mapScene.addMapMarker(mapMarker);
  }

  Future<void> drawRoute(GeoCoordinates start, GeoCoordinates end,
      HereMapController hereMapController) async {
    //inisialisasi routing engine yang bertugas menghitung jarak
    RoutingEngine routingEngine = RoutingEngine();

    //buat waypoint
    Waypoint startWaypoint = Waypoint.withDefaults(start);
    Waypoint endWaypoint = Waypoint.withDefaults(end);

    //list waypoint
    List<Waypoint> waypoints = [startWaypoint, endWaypoint];
    routingEngine.calculateCarRoute(waypoints, CarOptions.withDefaults(),
        (RoutingError routingError, List routes) {
      if (routingError == null) {
        var route = routes.first;

        //inisialisasi polyline / garis
        GeoPolyline reouteGeoPolyLine = GeoPolyline(route.polyline);

        //buat visualisasi representasi untuk polyline / garis

        //ketebalan
        double depth = 20;

        _mapPolyLine = MapPolyline(reouteGeoPolyLine, depth, Colors.blue);

        //pasang di controller untuk digambar di peta
        hereMapController.mapScene.addMapPolyline(_mapPolyLine);
      }
    });

    //Hitung rutenya
  }

  void _onMapCreated(HereMapController hereMapController) {
    _controller = hereMapController;
    // Mengatur tema peta
    hereMapController.mapScene.loadSceneForMapScheme(MapScheme.normalDay,
        (MapError error) {
      if (error != null) {
        print('Map scene not loaded. MapError: ${error.toString()}');
        //return kosong , untuk mengentikan fungsi
        return;
      }

      drawMarker(hereMapController, 0, initialLocation);
      drawPin(hereMapController, 0, initialLocation);
      // drawRoute(GeoCoordinates(-3.0026799, 104.7657554),
      //     GeoCoordinates(-2.9995109, 104.7601542), hereMapController);

      //membuat marker dari tempat2 wisata lain
      places.forEach((element) {
        drawMarker(hereMapController, 0, element)
            .then((marker) => markers.add(marker));
      });

      const double distanceToEarthInMeters = 15000;
      hereMapController.camera
          .lookAtPointWithDistance(initialLocation, distanceToEarthInMeters);
    });
  }
}
