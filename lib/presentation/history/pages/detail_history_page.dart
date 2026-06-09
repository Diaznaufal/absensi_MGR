import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_absensi_app/data/models/response/attendance_response_model.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/core.dart';

class DetailHistoryPage extends StatefulWidget {
  final Attendance attendance;

  const DetailHistoryPage({super.key, required this.attendance});

  @override
  State<DetailHistoryPage> createState() => _DetailHistoryPageState();
}

class _DetailHistoryPageState extends State<DetailHistoryPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  String? _checkinAddress;
  String? _checkoutAddress;
  bool _isLoadingCheckinAddress = false;
  bool _isLoadingCheckoutAddress = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    // Parse coordinates
    double? latIn;
    double? lonIn;
    double? latOut;
    double? lonOut;

    try {
      if (widget.attendance.latlonIn != null) {
        final parts = widget.attendance.latlonIn!.split(',');
        if (parts.length == 2) {
          latIn = double.tryParse(parts[0].trim());
          lonIn = double.tryParse(parts[1].trim());
        }
      }
      if (widget.attendance.latlonOut != null) {
        final parts = widget.attendance.latlonOut!.split(',');
        if (parts.length == 2) {
          latOut = double.tryParse(parts[0].trim());
          lonOut = double.tryParse(parts[1].trim());
        }
      }
    } catch (e) {
      // Handle parse error
    }

    // Load check-in address
    if (latIn != null && lonIn != null) {
      setState(() => _isLoadingCheckinAddress = true);
      final address = await _getAddressFromCoordinates(latIn, lonIn);
      setState(() {
        _checkinAddress = address;
        _isLoadingCheckinAddress = false;
      });
    }

    // Load check-out address
    if (latOut != null && lonOut != null) {
      setState(() => _isLoadingCheckoutAddress = true);
      final address = await _getAddressFromCoordinates(latOut, lonOut);
      setState(() {
        _checkoutAddress = address;
        _isLoadingCheckoutAddress = false;
      });
    }
  }

  Future<String?> _getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&addressdetails=1');

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'FlutterAbsensiApp/1.0',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'];

        // Build full address with postal code
        List<String> addressParts = [];

        if (address['road'] != null) {
          addressParts.add(address['road']);
        }
        if (address['suburb'] != null || address['village'] != null) {
          addressParts
              .add(address['suburb'] ?? address['village'] ?? address['hamlet']);
        }
        if (address['city'] != null ||
            address['town'] != null ||
            address['city_district'] != null) {
          addressParts.add(address['city'] ??
              address['town'] ??
              address['city_district']);
        }
        if (address['state'] != null) {
          addressParts.add(address['state']);
        }
        if (address['postcode'] != null) {
          addressParts.add(address['postcode']);
        }

        return addressParts.join(', ');
      }
    } catch (e) {
      // Handle error silently
    }
    return null;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 50 && !_isScrolled) {
      setState(() {
        _isScrolled = true;
      });
    } else if (_scrollController.offset <= 50 && _isScrolled) {
      setState(() {
        _isScrolled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('EEEE, dd MMMM yyyy');
    final statusColor = _getStatusColor(widget.attendance.status);
    final statusLabel = _getStatusLabel(widget.attendance.status);

    // Parse latitude and longitude from attendance data
    double? latIn;
    double? lonIn;
    double? latOut;
    double? lonOut;

    try {
      if (widget.attendance.latlonIn != null) {
        final parts = widget.attendance.latlonIn!.split(',');
        if (parts.length == 2) {
          latIn = double.tryParse(parts[0].trim());
          lonIn = double.tryParse(parts[1].trim());
        }
      }
      if (widget.attendance.latlonOut != null) {
        final parts = widget.attendance.latlonOut!.split(',');
        if (parts.length == 2) {
          latOut = double.tryParse(parts[0].trim());
          lonOut = double.tryParse(parts[1].trim());
        }
      }
    } catch (e) {
      // Handle parse error
    }

    // Use check-in location as default map center
    final hasCheckinLocation = latIn != null && lonIn != null;
    final hasCheckoutLocation = latOut != null && lonOut != null;
    final mapCenter = hasCheckinLocation
        ? LatLng(latIn, lonIn)
        : const LatLng(-6.2088, 106.8456); // Default to Jakarta

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: _isScrolled ? Colors.white : const Color(0xFF1e3c72),
            foregroundColor: _isScrolled ? Colors.black : Colors.white,
            elevation: _isScrolled ? 2 : 0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Attendance Detail',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: _isScrolled ? Colors.black : Colors.white,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF1e3c72),
                      Color(0xFF2a5298),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    _getStatusIcon(widget.attendance.status),
                    size: 80,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                color: _isScrolled ? Colors.black : Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.calendar_today_rounded,
                                color: statusColor,
                                size: 24,
                              ),
                            ),
                            const SpaceWidth(16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    dateFormatter.format(
                                        widget.attendance.date ?? DateTime.now()),
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  const SpaceHeight(4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: statusColor.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      statusLabel,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: statusColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SpaceHeight(20),

                  // Unified Card with Time Records + Map + Location
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Time Records Section
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildCompactTimeInfo(
                                      'Check In',
                                      widget.attendance.timeIn ?? '-',
                                      Icons.login_rounded,
                                      AppColors.green,
                                    ),
                                  ),
                                  const SpaceWidth(12),
                                  Expanded(
                                    child: _buildCompactTimeInfo(
                                      'Check Out',
                                      widget.attendance.timeOut ?? '-',
                                      Icons.logout_rounded,
                                      AppColors.red,
                                    ),
                                  ),
                                ],
                              ),
                              // Late/Early Leave Info (compact)
                              if ((widget.attendance.lateMinutes ?? 0) > 0 ||
                                  (widget.attendance.earlyLeaveMinutes ?? 0) > 0) ...[
                                const SpaceHeight(12),
                                Row(
                                  children: [
                                    if ((widget.attendance.lateMinutes ?? 0) > 0)
                                      Expanded(
                                        child: _buildCompactInfoChip(
                                          'Late',
                                          '${widget.attendance.lateMinutes} min',
                                          Icons.schedule_rounded,
                                          Colors.red,
                                        ),
                                      ),
                                    if ((widget.attendance.lateMinutes ?? 0) > 0 &&
                                        (widget.attendance.earlyLeaveMinutes ?? 0) > 0)
                                      const SpaceWidth(8),
                                    if ((widget.attendance.earlyLeaveMinutes ?? 0) > 0)
                                      Expanded(
                                        child: _buildCompactInfoChip(
                                          'Early Leave',
                                          '${widget.attendance.earlyLeaveMinutes} min',
                                          Icons.timelapse_rounded,
                                          Colors.orange,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Map Section
                        if (hasCheckinLocation || hasCheckoutLocation) ...[
                          const Divider(height: 1),
                          ClipRRect(
                            child: SizedBox(
                              height: 200,
                              child: FlutterMap(
                                options: MapOptions(
                                  initialCenter: mapCenter,
                                  initialZoom: 15.0,
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName: 'com.jagoflutter.hris',
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      if (hasCheckinLocation)
                                        Marker(
                                          width: 70.0,
                                          height: 70.0,
                                          point: LatLng(latIn!, lonIn!),
                                          child: Column(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.green,
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  'In',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              const Icon(
                                                Icons.location_on,
                                                color: AppColors.green,
                                                size: 32,
                                              ),
                                            ],
                                          ),
                                        ),
                                      if (hasCheckoutLocation)
                                        Marker(
                                          width: 70.0,
                                          height: 70.0,
                                          point: LatLng(latOut!, lonOut!),
                                          child: Column(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.red,
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  'Out',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              const Icon(
                                                Icons.location_on,
                                                color: AppColors.red,
                                                size: 32,
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Address Section
                          if (_checkinAddress != null ||
                              _checkoutAddress != null ||
                              _isLoadingCheckinAddress ||
                              _isLoadingCheckoutAddress)
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (hasCheckinLocation) ...[
                                    _buildCompactAddressInfo(
                                      'Check In',
                                      _checkinAddress,
                                      _isLoadingCheckinAddress,
                                      AppColors.green,
                                    ),
                                    if (hasCheckoutLocation)
                                      const SpaceHeight(10),
                                  ],
                                  if (hasCheckoutLocation)
                                    _buildCompactAddressInfo(
                                      'Check Out',
                                      _checkoutAddress,
                                      _isLoadingCheckoutAddress,
                                      AppColors.red,
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),

                  const SpaceHeight(20),

                  const SpaceHeight(40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactTimeInfo(
      String label, String time, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SpaceWidth(8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: color.withOpacity(0.7),
                  ),
                ),
                const SpaceHeight(2),
                Text(
                  time,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactInfoChip(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          const SpaceWidth(6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: color.withOpacity(0.7),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactAddressInfo(
      String label, String? address, bool isLoading, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.location_on,
            color: color,
            size: 16,
          ),
        ),
        const SpaceWidth(10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const SpaceHeight(4),
              if (isLoading)
                Row(
                  children: [
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            color.withOpacity(0.6)),
                      ),
                    ),
                    const SpaceWidth(6),
                    Text(
                      'Loading...',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.black.withOpacity(0.4),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                )
              else if (address != null)
                Text(
                  address,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.black.withOpacity(0.6),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                )
              else
                Text(
                  'Address not available',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.black.withOpacity(0.3),
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'on_time':
        return AppColors.green;
      case 'late':
        return Colors.orange;
      case 'absent':
        return AppColors.red;
      default:
        return AppColors.primary;
    }
  }

  String _getStatusLabel(String? status) {
    switch (status?.toLowerCase()) {
      case 'on_time':
        return 'On Time';
      case 'late':
        return 'Late';
      case 'absent':
        return 'Absent';
      default:
        return status ?? 'Unknown';
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'on_time':
        return Icons.check_circle_rounded;
      case 'late':
        return Icons.access_time_rounded;
      case 'absent':
        return Icons.cancel_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }
}
