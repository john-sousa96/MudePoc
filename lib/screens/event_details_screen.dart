import 'package:flutter/material.dart';
import 'package:mudepocflutter/models/event.dart';
import 'package:mudepocflutter/db/checkin_db.dart';
import 'package:mudepocflutter/models/checkin_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:mudepocflutter/screens/checkin_map_screen.dart';
import 'package:latlong2/latlong.dart';

class EventDetailsScreen extends StatefulWidget {
  final Event event;

  const EventDetailsScreen({super.key, required this.event});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  bool _isRegistered = false;
  bool _isLoading = true;
  CheckInModel? _lastCheckIn;

  @override
  void initState() {
    super.initState();
    _loadCheckInStatus();
  }

  Future<void> _loadCheckInStatus() async {
    try {
      final checkIns = await CheckInDatabase.getCheckInsForEvent(widget.event.id!);
      setState(() {
        _isRegistered = checkIns.isNotEmpty;
        _lastCheckIn = checkIns.isNotEmpty ? checkIns.last : null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar check-ins: $e')),
      );
    }
  }

  Future<void> _registerForEvent() async {
    setState(() {
      _isRegistered = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Inscrição confirmada com sucesso!')),
    );
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackBar('O serviço de localização está desativado.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackBar('Permissão de localização negada.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackBar('Permissão de localização negada permanentemente. Ative nas configurações.');
      return;
    }

    await _performCheckIn();
  }

  Future<void> _performCheckIn() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      final now = DateTime.now();
      final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(now);

      final checkIn = CheckInModel(
        eventId: widget.event.id!,
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: formattedDate,
      );

      // Mostrar mapa com confirmação
      final confirmed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => CheckInMapScreen(
            initialLocation: LatLng(position.latitude, position.longitude),
          ),
        ),
      );

      if (confirmed ?? false) {
        await CheckInDatabase.insertCheckIn(checkIn);
        await _loadCheckInStatus();
        _showSnackBar('Check-in realizado com sucesso!');
      }
    } catch (e) {
      _showSnackBar('Erro ao realizar check-in: ${e.toString()}');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.event.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[300],
              ),
              child: Icon(Icons.event, size: 50, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            Text(
              widget.event.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 5),
                Text('${widget.event.date} às ${widget.event.time}'),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: 5),
                Text(widget.event.location),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Descrição do Evento:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              'Descrição detalhada do evento será exibida aqui.',
            ),
            const SizedBox(height: 30),

            if (!_isRegistered)
              ElevatedButton(
                onPressed: _registerForEvent,
                child: const Text('Inscrever-se no Evento'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),

            if (_isRegistered && _lastCheckIn == null)
              ElevatedButton(
                onPressed: _checkLocationPermission,
                child: const Text('Fazer Check-in no Local'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.green,
                ),
              ),

            if (_lastCheckIn != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Último Check-in:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Data/Hora: ${_lastCheckIn!.timestamp}'),
                  Text('Localização: ${_lastCheckIn!.latitude.toStringAsFixed(4)}, ${_lastCheckIn!.longitude.toStringAsFixed(4)}'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _checkLocationPermission,
                    child: const Text('Refazer Check-in'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}