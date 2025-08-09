import 'package:flutter/material.dart';

class FlightSearchUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final primaryColor = Color(0xFFD81B60); // bright pink for button
    final darkBackground = Color(0xFF20232B); // dark background color

    Widget airportBox(String code, String city) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(code,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 26)),
          SizedBox(height: 4),
          Text(city,
              style: TextStyle(
                  color: Colors.white54,
                  fontWeight: FontWeight.w800,
                  fontSize: 14)),
        ],
      );
    }

    Widget labelValue(String label, String value,
        {bool enabled = true, bool isButton = false}) {
      return Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(),
                style: TextStyle(
                    color: Colors.white54,
                    fontWeight: FontWeight.w800,
                    fontSize: 13)),
            const SizedBox(height: 4),
            Container(
              padding: EdgeInsets.symmetric(
                  vertical: 6, horizontal: isButton ? 20 : 8),
              decoration: isButton
                  ? BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    )
                  : null,
              child: Text(
                value,
                style: TextStyle(
                  color: isButton ? darkBackground : Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: isButton ? 12 : 18,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: darkBackground,
      body: SafeArea(
        minimum: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Search Flights',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900)),
            SizedBox(height: 40),

            // From and To airports with swap icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                airportBox('LAX', 'Los Angeles'),
                Icon(Icons.swap_horiz_rounded, color: Colors.white54, size: 34),
                airportBox('LHR', 'London'),
              ],
            ),
            SizedBox(height: 32),

            // Round trip / One way toggle
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Round Trip',
                      style: TextStyle(
                          color: darkBackground,
                          fontWeight: FontWeight.w900,
                          fontSize: 12)),
                ),
                SizedBox(width: 16),
                Opacity(
                  opacity: 0.4,
                  child: Text(
                    'One Way',
                    style: TextStyle(
                        color: Colors.white54,
                        fontWeight: FontWeight.w900,
                        fontSize: 12),
                  ),
                )
              ],
            ),
            SizedBox(height: 32),

            // Departure and Return dates
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                labelValue('Departure', 'Mon 26 Feb'),
                labelValue('Return', 'Fri 31 Feb', enabled: true),
              ],
            ),
            SizedBox(height: 30),

            // Passengers and Cabin class
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                labelValue('Passengers', '2 Adults'),
                labelValue('Cabin Class', 'Economy', isButton: true),
                Opacity(
                  opacity: 0.4,
                  child: labelValue('First Class', '', enabled: false),
                ),
                Opacity(
                  opacity: 0.4,
                  child: labelValue('Business', '', enabled: false),
                ),
              ],
            ),
            Spacer(),

            // Search Flights Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {},
                child: Text(
                  'Search Flights',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
