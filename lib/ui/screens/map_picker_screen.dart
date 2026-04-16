import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class MapPickerScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const MapPickerScreen({super.key, this.initialLat, this.initialLng});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  final MapController mapController = MapController();

  LatLng current = const LatLng(13.0827, 80.2707);
  LatLng? selected;
  String address = "Tap any location";

  @override
  void initState() {
    super.initState();

    if (widget.initialLat != null && widget.initialLng != null) {
      current = LatLng(widget.initialLat!, widget.initialLng!);
      selected = current;
      getAddress(current);
    } else {
      getCurrentLocation();
    }
  }

  Future<void> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    final pos = await Geolocator.getCurrentPosition();

    current = LatLng(pos.latitude, pos.longitude);

    setState(() {});

    mapController.move(current, 16);
  }

  Future<void> getAddress(LatLng point) async {
    try {
      final places = await placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );

      final p = places.first;

      address = "${p.street}, ${p.locality}, ${p.administrativeArea}";
    } catch (_) {
      address =
          "${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}";
    }

    setState(() {});
    mapController.move(point, 16);
  }

  Future<void> pickPoint(LatLng point) async {
    selected = point;
    await getAddress(point);
  }

  void useLocation() {
    if (selected == null) return;

    Navigator.pop(context, {
      "address": address,
      "lat": selected!.latitude,
      "lng": selected!.longitude,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Location")),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: current,
              initialZoom: 14,
              onTap: (_, point) => pickPoint(point),
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: "com.example.fsm_app",
              ),

              MarkerLayer(
                markers: [
                  Marker(
                    point: current,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.blue,
                      size: 30,
                    ),
                  ),

                  if (selected != null)
                    Marker(
                      point: selected!,
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 42,
                      ),
                    ),
                ],
              ),
            ],
          ),

          Positioned(
            left: 14,
            right: 14,
            bottom: 18,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(address, style: const TextStyle(fontSize: 15)),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selected == null ? null : useLocation,
                    child: const Text("Use This Location"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
