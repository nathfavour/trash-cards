import 'package:flutter/material.dart';
import 'widgets.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late PageController _pageController;
  double currentPage = 0;
  int currentCardIndex = 0;
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
    {
      'coin': 'ARB',
      'network': 'Arbitrum',
      'address': '0x1234567890abcdef1234567890abcdef12345678'
    },
    {
      'coin': 'LTC',
      'network': 'Litecoin',
      'address': 'LcHK4bsEi6Xm9jHRUWBN2ZwBQcjLBqE8NJ'
    },
    {
      'coin': 'SOL',
      'network': 'Solana',
      'address': '5Kd3NBUAdUnEJ9VY6RasZCtg9k3R8ZXWVcvG7bjqB2uE'
    },
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
                    child: Stack(
                      children: List.generate(cryptoCards.length, (index) {
                        if (index < currentCardIndex) {
                          return Container(); // Hide cards that have been swiped
                        }
                        return Positioned(
                          top: 20.0 + (index * 10),
                          left: 20.0 + (index * 10),
                          right: 20.0 + (index * 10),
                          child: GestureDetector(
                            onHorizontalDragEnd: (details) {
                              if (details.primaryVelocity! > 0) {
                                _swipeCard(Direction.right);
                              } else if (details.primaryVelocity! < 0) {
                                _swipeCard(Direction.left);
                              }
                            },
                            child: TweenAnimationBuilder(
                              tween: Tween<double>(
                                  begin: 1.0,
                                  end: index == currentCardIndex ? 1.0 : 0.9),
                              duration: Duration(milliseconds: 300),
                              builder: (context, double value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: CryptoCard(
                                    coinName: cryptoCards[index]['coin']!,
                                    network: cryptoCards[index]['network']!,
                                    address: cryptoCards[index]['address']!,
                                    rotationAngle: 0.0,
                                    scale: 1.0,
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }).reversed.toList(),
                    ),
                  ),
                  _buildQuickActions(),
                  _buildBottomBar(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _swipeCard(Direction direction) {
    setState(() {
      currentCardIndex++;
    });
    // Add swipe out animation based on direction if needed
  }

  Widget _buildQuickActions() {
    return Container(
      height: 100,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildQuickActionTile(Icons.info, 'Details'),
          _buildQuickActionTile(Icons.block, 'Block'),
          _buildQuickActionTile(Icons.refresh, 'Refresh'),
          _buildQuickActionTile(Icons.delete, 'Delete'),
        ],
      ),
    );
  }

  Widget _buildQuickActionTile(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: Colors.blueAccent,
          child: Icon(icon, color: Colors.white),
        ),
        SizedBox(height: 5),
        Text(label, style: TextStyle(color: Colors.white)),
      ],
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
        'Bankcryptt',
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
