import 'package:flutter/material.dart';
import 'widgets.dart';

enum Direction {
  left,
  right,
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late PageController _pageController;
  double currentPage = 0;
  int currentCardIndex = 0;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  double _dragOffset = 0;

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
    {'coin': 'DOT', 'network': 'Polkadot', 'address': '1ABC...'},
    {'coin': 'ADA', 'network': 'Cardano', 'address': 'addr1...'},
    {'coin': 'AVAX', 'network': 'Avalanche', 'address': '0x789...'},
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
    _slideController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(1.5, 0.0),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutCubic,
    ));
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
                      alignment: Alignment.center,
                      children: List.generate(
                        cryptoCards.length,
                        (index) => _buildAnimatedCard(index),
                      ).reversed.toList(),
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

  Widget _buildAnimatedCard(int index) {
    if (index < currentCardIndex) return Container();

    final offset = index - currentCardIndex;
    final topOffset = 20.0 + (offset * 25.0);
    final scale = 1.0 - (offset * 0.05);
    final rotation = (offset * -3.0) * (pi / 180.0);

    return Positioned(
      top: topOffset,
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateZ(rotation)
          ..scale(scale),
        alignment: Alignment.topCenter,
        child: GestureDetector(
          onHorizontalDragUpdate: (details) =>
              _handleDragUpdate(details, index),
          onHorizontalDragEnd: (details) => _handleDragEnd(details, index),
          child: AnimatedBuilder(
            animation: _slideController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_dragOffset, 0),
                child: Opacity(
                  opacity: 1.0 - (_slideController.value * offset * 0.3),
                  child: CryptoCard(
                    coinName: cryptoCards[index]['coin']!,
                    network: cryptoCards[index]['network']!,
                    address: cryptoCards[index]['address']!,
                    rotationAngle: rotation,
                    scale: scale,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleDragUpdate(DragUpdateDetails details, int index) {
    if (index != currentCardIndex) return;
    setState(() {
      _dragOffset += details.delta.dx;
      // Add parallax effect to background
      _updateParallaxOffset(_dragOffset);
    });
  }

  void _handleDragEnd(DragEndDetails details, int index) {
    if (index != currentCardIndex) return;
    final velocity = details.velocity.pixelsPerSecond.dx;
    if (velocity.abs() > 1000 || _dragOffset.abs() > 100) {
      _animateCardOut(velocity > 0 ? Direction.right : Direction.left);
    } else {
      _resetCard();
    }
  }

  void _animateCardOut(Direction direction) {
    _slideController.forward().then((_) {
      setState(() {
        currentCardIndex++;
        _dragOffset = 0;
      });
      _slideController.reset();
      _scaleController.forward();
    });
  }

  void _resetCard() {
    setState(() => _dragOffset = 0);
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
