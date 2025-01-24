import 'package:flutter/material.dart';
import 'widgets.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late PageController _pageController;
  double currentPage = 0;
  List<Map<String, String>> cryptoCards = [
    {
      'coin': 'BTC',
      'network': 'Bitcoin',
      'address': '1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa'
    },
    {
      'coin': 'ETH',
      'network': 'Ethereum',
      'address': '0x742d35Cc6634C0532925a3b844Bc454e4438f44e'
    },
    // Add more cards here
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.8,
      initialPage: 0,
    )..addListener(() {
        setState(() {
          currentPage = _pageController.page ?? 0;
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        child: Stack(
          children: [
            _buildBackground(),
            SafeArea(
              child: Column(
                children: [
                  _buildAppBar(),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: cryptoCards.length,
                      itemBuilder: (context, index) {
                        final scale = currentPage == index ? 1.0 : 0.9;
                        final rotationAngle = (currentPage - index) * 0.1;

                        return TweenAnimationBuilder(
                          tween: Tween(begin: scale, end: scale),
                          duration: Duration(milliseconds: 300),
                          builder: (context, double value, child) {
                            return CryptoCard(
                              coinName: cryptoCards[index]['coin']!,
                              network: cryptoCards[index]['network']!,
                              address: cryptoCards[index]['address']!,
                              scale: value,
                              rotationAngle: rotationAngle,
                            );
                          },
                        );
                      },
                    ),
                  ),
                  _buildBottomBar(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[900]!,
            Colors.black,
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        'Crypto Cards',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.settings, color: Colors.white),
          onPressed: () {
            // Handle settings action
          },
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
      color: Colors.transparent,
      elevation: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(Icons.home, color: Colors.white),
            onPressed: () {
              // Navigate to home
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // Navigate to notifications
            },
          ),
          IconButton(
            icon: Icon(Icons.person, color: Colors.white),
            onPressed: () {
              // Navigate to profile
            },
          ),
        ],
      ),
    );
  }

  // Add remaining helper methods...
}
