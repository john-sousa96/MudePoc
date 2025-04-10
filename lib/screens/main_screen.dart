import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../db/checkin_db.dart';
import '../models/checkin_model.dart';
import 'checkin_map_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  Future<void> _handleCheckIn(BuildContext context) async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permissão de localização negada.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permissão permanentemente negada. Vá nas configurações.'),
        ),
      );
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    final location = LatLng(position.latitude, position.longitude);

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckInMapScreen(initialLocation: location),
      ),
    );


    if (result != null && result is LatLng) {
      final now = DateTime.now().toIso8601String();
      final checkin = CheckInModel(
        latitude: result.latitude,
        longitude: result.longitude,
        timestamp: now,
      );

      await CheckInDatabase.insertCheckIn(checkin);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Check-In salvo com sucesso!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tela Principal')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _handleCheckIn(context),
          child: const Text('Fazer Check-In'),
        ),
      ),
    );
  }
}