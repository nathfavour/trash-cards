import 'package:flutter/material.dart';

class CryptoCard extends StatelessWidget {
  final String coinName;
  final String network;
  final String address;
  final double rotationAngle;
  final double scale;

  const CryptoCard({
    required this.coinName,
    required this.network,
    required this.address,
    this.rotationAngle = 0.0,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY(rotationAngle)
        ..scale(scale),
      alignment: Alignment.center,
      child: Container(
        width: 300,
        height: 180,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _getCardColors(coinName),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 15,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                coinName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              Text(
                network,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Text(
                address,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _getCardColors(String coin) {
    switch (coin) {
      case 'BTC':
        return [Colors.orange[800]!, Colors.orange[400]!];
      case 'ETH':
        return [Colors.blue[800]!, Colors.blue[400]!];
      default:
        return [Colors.purple[800]!, Colors.purple[400]!];
    }
  }
}
