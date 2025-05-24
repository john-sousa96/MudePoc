import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:mudepocflutter/db/checkin_db.dart';
import 'package:mudepocflutter/models/checkin_model.dart';
import 'package:mudepocflutter/models/event.dart';
import 'package:mudepocflutter/screens/checkin_map_screen.dart';

class EventDetailsScreen extends StatefulWidget {
  final Event event;

  const EventDetailsScreen({super.key, required this.event});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  bool _isRegistered = false;
  bool _isLoading = true;
  bool _isLoadingLocation = true;
  CheckInModel? _lastCheckIn;
  LatLng? _eventLocation;

  @override
  void initState() {
    super.initState();
    _loadCheckInStatus();
    _convertAddressToLatLng();
  }

  Future<void> _convertAddressToLatLng() async {
    try {
      final locations = await locationFromAddress(widget.event.location);
      if (locations.isNotEmpty) {
        setState(() {
          _eventLocation = LatLng(locations.first.latitude, locations.first.longitude);
          _isLoadingLocation = false;
        });
      } else {
        setState(() => _isLoadingLocation = false);
      }
    } catch (e) {
      print('Erro ao converter endereço: $e');
      setState(() => _isLoadingLocation = false);
    }
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
      setState(() => _isLoading = false);
      _showSnackBar('Erro ao carregar check-ins: $e');
    }
  }

  Future<void> _registerForEvent() async {
    setState(() => _isRegistered = true);
    _showSnackBar('Inscrição confirmada com sucesso!');
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return _showSnackBar('O serviço de localização está desativado.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return _showSnackBar('Permissão de localização negada.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return _showSnackBar('Permissão de localização negada permanentemente. Ative nas configurações.');
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildMapContent(LatLng location, {double height = 200}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: height,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: location,
            initialZoom: 15.0,
            interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.mudepocflutter',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: location,
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
      ),
    );
  }

  Widget _buildLocationUnavailable({double height = 200}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[300],
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 50, color: Colors.grey),
            Text('Localização não disponível'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final orangeColor = const Color(0xFFF99226);
    final roundedButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: orangeColor,
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.name),
        backgroundColor: orangeColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mapa do local do evento
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              shadowColor: orangeColor,
              child: _isLoadingLocation
                  ? const Center(child: CircularProgressIndicator())
                  : (_eventLocation != null
                  ? _buildMapContent(_eventLocation!)
                  : _buildLocationUnavailable()),
            ),
            const SizedBox(height: 20),
            Text(
              widget.event.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: orangeColor),
                const SizedBox(width: 5),
                Text('${widget.event.date} às ${widget.event.time}'),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: orangeColor),
                const SizedBox(width: 5),
                Text(widget.event.location),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Descrição do Evento:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: orangeColor,
              ),
            ),
            const SizedBox(height: 5),
            Text('${widget.event.description}'),
            const SizedBox(height: 30),

            if (!_isRegistered)
              ElevatedButton(
                onPressed: _registerForEvent,
                style: roundedButtonStyle,
                child: const Text('Inscrever-se no Evento'),
              ),

            if (_isRegistered && _lastCheckIn == null)
              ElevatedButton(
                onPressed: _checkLocationPermission,
                style: roundedButtonStyle,
                child: const Text('Fazer Check-in no Local'),
              ),

            if (_lastCheckIn != null) ...[
              Text(
                'Último Check-in:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: orangeColor,
                ),
              ),
              Text('Data/Hora: ${_lastCheckIn!.timestamp}'),
              const SizedBox(height: 10),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                shadowColor: orangeColor,
                child: _buildMapContent(
                  LatLng(_lastCheckIn!.latitude, _lastCheckIn!.longitude),
                  height: 150,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _checkLocationPermission,
                style: roundedButtonStyle,
                child: const Text('Refazer Check-in'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}