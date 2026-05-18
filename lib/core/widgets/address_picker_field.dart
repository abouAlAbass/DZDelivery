import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class AddressPickerField extends StatefulWidget {
  final String? initialAddressName;
  final double? initialLatitude;
  final double? initialLongitude;
  final Function(String addressName, double latitude, double longitude) onChanged;
  final FormFieldValidator<String>? validator;

  const AddressPickerField({
    super.key,
    this.initialAddressName,
    this.initialLatitude,
    this.initialLongitude,
    required this.onChanged,
    this.validator,
  });

  @override
  State<AddressPickerField> createState() => _AddressPickerFieldState();
}

class _AddressPickerFieldState extends State<AddressPickerField> {
  late TextEditingController _addressController;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(text: widget.initialAddressName);
    _latitude = widget.initialLatitude;
    _longitude = widget.initialLongitude;
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (context) => MapPickerScreen(
          initialLatitude: _latitude,
          initialLongitude: _longitude,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _addressController.text = result['addressName'] ?? '';
        _latitude = result['latitude'];
        _longitude = result['longitude'];
      });
      widget.onChanged(_addressController.text, _latitude!, _longitude!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _addressController,
          decoration: InputDecoration(
            labelText: 'Adresse de livraison',
            prefixIcon: const Icon(Icons.location_on),
            suffixIcon: IconButton(
              icon: const Icon(Icons.map),
              onPressed: _pickLocation,
              tooltip: 'Choisir sur la carte',
            ),
          ),
          onChanged: (val) {
            if (_latitude != null && _longitude != null) {
              widget.onChanged(val, _latitude!, _longitude!);
            }
          },
          validator: widget.validator ?? (val) {
            if (val == null || val.isEmpty) return 'L\'adresse est requise';
            if (_latitude == null || _longitude == null || (_latitude == 0 && _longitude == 0)) {
              return 'Position sur la carte requise';
            }
            return null;
          },
        ),
      ],
    );
  }
}

class MapPickerScreen extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;

  const MapPickerScreen({super.key, this.initialLatitude, this.initialLongitude});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  String _currentAddress = "Sélectionnez un point";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _selectedLocation = LatLng(widget.initialLatitude!, widget.initialLongitude!);
      _getAddressFromLatLng(_selectedLocation!);
    } else {
      _determinePosition();
    }
  }

  Future<void> _determinePosition() async {
    setState(() => _isLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isLoading = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isLoading = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _isLoading = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      LatLng userLoc = LatLng(position.latitude, position.longitude);
      setState(() {
        _selectedLocation = userLoc;
      });
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(userLoc, 15));
      await _getAddressFromLatLng(userLoc);
    } catch (e) {
      debugPrint('Error getting location: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _currentAddress = [
            if (place.street != null && place.street!.isNotEmpty) place.street,
            if (place.locality != null && place.locality!.isNotEmpty) place.locality,
            if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) place.administrativeArea,
          ].whereType<String>().join(', ');
        });
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
      setState(() {
        _currentAddress = 'Position: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const initialTarget = LatLng(36.7538, 3.0588); // Default to Algiers

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choisir une adresse'),
        actions: [
          if (_selectedLocation != null)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                Navigator.of(context).pop({
                  'addressName': _currentAddress,
                  'latitude': _selectedLocation!.latitude,
                  'longitude': _selectedLocation!.longitude,
                });
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLocation ?? initialTarget,
              zoom: 13,
            ),
            onMapCreated: (controller) => _mapController = controller,
            markers: _selectedLocation != null
                ? {
                    Marker(
                      markerId: const MarkerId('selected'),
                      position: _selectedLocation!,
                    )
                  }
                : {},
            onTap: (latLng) {
              setState(() => _selectedLocation = latLng);
              _getAddressFromLatLng(latLng);
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          if (_selectedLocation != null)
            Positioned(
              bottom: 30,
              left: 20,
              right: 60, // Leave space for myLocationButton
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _currentAddress,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
