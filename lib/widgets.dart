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
              color: Colors.black45,
              blurRadius: 20,
              offset: Offset(0, 15),
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
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 10,
                      color: Colors.black26,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
              Spacer(),
              Text(
                network,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: 8),
              Text(
                address,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  letterSpacing: 1.4,
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
        return [Colors.orangeAccent, Colors.deepOrange];
      case 'ETH':
        return [Colors.blueAccent, Colors.lightBlue];
      case 'ARB':
        return [Colors.greenAccent, Colors.teal];
      case 'LTC':
        return [Colors.grey, Colors.blueGrey];
      case 'SOL':
        return [Colors.purpleAccent, Colors.deepPurple];
      default:
        return [Colors.pinkAccent, Colors.purple];
    }
  }
}
