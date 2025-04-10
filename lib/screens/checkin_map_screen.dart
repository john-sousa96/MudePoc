import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class CheckInMapScreen extends StatelessWidget {
  final LatLng initialLocation;

  const CheckInMapScreen({super.key, required this.initialLocation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar Local')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: initialLocation,
          initialZoom: 17.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.checkin_app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: initialLocation,
                width: 80,
                height: 80,
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context, initialLocation);
          },
          child: const Text('Confirmar Check-In'),
        ),
      ),
    );
  }
}