import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../services/socket_service.dart';
import '../widgets/ptt_button.dart';
import 'group_screen.dart';

class HomeMapScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String motorLabel;

  const HomeMapScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.motorLabel,
  });

  @override
  State<HomeMapScreen> createState() => _HomeMapScreenState();
}

class _HomeMapScreenState extends State<HomeMapScreen> {
  GoogleMapController? _mapController;
  final _socket = SocketService();
  String? _activeGroupId;
  String? _activeGroupName;

  final Map<String, Marker> _memberMarkers = {};

  @override
  void initState() {
    super.initState();
    _socket.connect('http://163.61.58.25:4000');
    _initLocationStream();

    _socket.onLocationUpdated((data) {
      setState(() {
        _memberMarkers[data['userId']] = Marker(
          markerId: MarkerId(data['userId']),
          position: LatLng(data['lat'], data['lng']),
          infoWindow: InfoWindow(
            title: data['name'],
            snippet: data['motorLabel'], // muncul: nama + jenis motor
          ),
        );
      });
    });
  }

  Future<void> _initLocationStream() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // update tiap pergerakan >10 meter, hemat baterai
      ),
    ).listen((pos) {
      if (_activeGroupId != null) {
        _socket.sendLocation(
          groupId: _activeGroupId!,
          userId: widget.userId,
          name: widget.userName,
          motorLabel: widget.motorLabel,
          lat: pos.latitude,
          lng: pos.longitude,
          heading: pos.heading,
        );
      }
    });
  }

  void _joinGroup(String groupId, String groupName) {
    setState(() {
      _activeGroupId = groupId;
      _activeGroupName = groupName;
    });
    _socket.joinGroup(
      groupId: groupId,
      userId: widget.userId,
      name: widget.userName,
      motorLabel: widget.motorLabel,
    );
  }

  void _onPttHold(bool holding) {
    if (_activeGroupId == null) return;
    if (holding) {
      _socket.pttStart(
        groupId: _activeGroupId!,
        userId: widget.userId,
        name: widget.userName,
        mode: 'ptt',
      );
      // TODO: mulai publish audio ke LiveKit room di sini
    } else {
      _socket.pttStop(groupId: _activeGroupId!, userId: widget.userId);
      // TODO: stop publish audio LiveKit
    }
  }

  void _onOpenMicToggle(bool open) {
    if (_activeGroupId == null) return;
    if (open) {
      _socket.pttStart(
        groupId: _activeGroupId!,
        userId: widget.userId,
        name: widget.userName,
        mode: 'open',
      );
      // TODO: publish audio terus-menerus ke LiveKit room
    } else {
      _socket.pttStop(groupId: _activeGroupId!, userId: widget.userId);
      // TODO: stop publish audio LiveKit
    }
  }

  @override
  void dispose() {
    _socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(-7.2575, 112.7521), // default: Surabaya
              zoom: 14,
            ),
            onMapCreated: (c) => _mapController = c,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: _memberMarkers.values.toSet(),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTopBar(context),
                  const Spacer(),
                  if (_activeGroupId != null)
                    PttControls(
                      onPttHold: _onPttHold,
                      onOpenMicToggle: _onOpenMicToggle,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12)],
      ),
      child: Row(
        children: [
          const CircleAvatar(child: Icon(Icons.groups)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _activeGroupName ?? 'Belum gabung Go Group',
              style: const TextStyle(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GroupScreen()),
              );
              if (result is Map) {
                _joinGroup(result['id'], result['name']);
              }
            },
            child: const Text('Go Group'),
          ),
        ],
      ),
    );
  }
}
