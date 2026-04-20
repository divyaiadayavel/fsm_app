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

  // Default to Chennai coordinates
  LatLng current = const LatLng(13.0827, 80.2707);
  LatLng? selected;
  String address = "Tap any location";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    // Logic: If coordinates were passed from the "Create Job" screen text field
    if (widget.initialLat != null && widget.initialLng != null) {
      current = LatLng(widget.initialLat!, widget.initialLng!);
      selected = current;
      getAddress(current);
    } else {
      getCurrentLocation();
    }
  }

  Future<void> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      try {
        final pos = await Geolocator.getCurrentPosition();
        if (mounted) {
          final myLocation = LatLng(pos.latitude, pos.longitude);
          setState(() {
            current = myLocation;
          });
          // Moving to current GPS position with street-level zoom
          mapController.move(myLocation, 18.0);
        }
      } catch (e) {
        debugPrint("Error getting location: $e");
      }
    }
  }

  Future<void> getAddress(LatLng point) async {
    if (!mounted) return;

    setState(() => isLoading = true);

    try {
      final places = await placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );

      if (places.isNotEmpty) {
        final p = places.first;
        // Cleaned up address format to avoid nulls or empty commas
        address =
            "${p.name ?? ''}, ${p.street ?? ''}, ${p.locality ?? ''}, ${p.administrativeArea ?? ''}";
      }
    } catch (_) {
      address =
          "${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}";
    }

    if (mounted) {
      setState(() => isLoading = false);
      // Fixed: Using the point passed into the function with deep zoom
      mapController.move(point, 18.0);
    }
  }

  Future<void> pickPoint(LatLng point) async {
    setState(() {
      selected = point;
    });
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
      appBar: AppBar(
        title: const Text("Select Location"),
        backgroundColor: const Color(0xFF6F63FF),
        foregroundColor: Colors.white,
      ),
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
                  // Blue marker for user's current GPS position
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

                  // Red marker for the "Picked" location
                  if (selected != null)
                    Marker(
                      point: selected!,
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 45,
                      ),
                    ),
                ],
              ),
            ],
          ),
          Positioned(
            left: 14,
            right: 14,
            bottom: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.map, color: Color(0xFF6F63FF)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: isLoading
                            ? const Text(
                                "Fetching address...",
                                style: TextStyle(color: Colors.grey),
                              )
                            : Text(
                                address,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: selected == null || isLoading
                        ? null
                        : useLocation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6F63FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "CONFIRM LOCATION",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
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
