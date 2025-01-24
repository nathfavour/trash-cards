import 'package:flutter/material.dart';
import 'dart:ui';

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
    return Hero(
      tag: 'card_$coinName',
      child: Transform(
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
                color: _getCardColors(coinName)[0].withOpacity(0.3),
                blurRadius: 20,
                offset: Offset(0, 15),
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Stack(
                  children: [
                    _buildShimmerEffect(),
                    _buildCardContent(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return Positioned.fill(
      child: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: [
            Colors.white.withOpacity(0),
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0),
          ],
          stops: [0.0, 0.5, 1.0],
          begin: Alignment(-1.0, -0.5),
          end: Alignment(1.0, 0.5),
        ).createShader(bounds),
        child: Container(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCardContent() {
    return Padding(
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
