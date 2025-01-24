import 'package:flutter/material.dart';
import 'widgets.dart';
import 'dart:math';

enum Direction {
  left,
  right,
}

class CryptoSection {
  final String crypto;
  final List<Map<String, String>> wallets;

  CryptoSection({required this.crypto, required this.wallets});
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  double _dragOffset = 0;
  bool _isBottomExpanded = false;

  List<CryptoSection> cryptoSections = [
    CryptoSection(crypto: 'BTC', wallets: [
      {
        'coin': 'BTC',
        'network': 'Bitcoin',
        'address': '1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa'
      },
      {
        'coin': 'BTC',
        'network': 'Bitcoin',
        'address': '1BoatSLRHtKNngkdXEeobR76b53LETtpyT'
      },
      // Add more BTC wallets here
    ]),
    CryptoSection(crypto: 'ETH', wallets: [
      {
        'coin': 'ETH',
        'network': 'Ethereum',
        'address': '0x742d35Cc6634C0532925a3b844Bc454e4438f44e'
      },
      {
        'coin': 'ETH',
        'network': 'Ethereum',
        'address': '0x53d284357ec70cE289D6D64134DfAc8E511c8a3D'
      },
      // Add more ETH wallets here
    ]),
    // Add more sections for ARB, LTC, SOL, etc.
  ];

  int _expandedSectionIndex = -1;

  @override
  void initState() {
    super.initState();
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
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
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
                    child: ListView.builder(
                      itemCount: cryptoSections.length,
                      itemBuilder: (context, sectionIndex) {
                        return _buildCryptoSection(sectionIndex);
                      },
                    ),
                  ),
                  _buildBottomSheet(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCryptoSection(int sectionIndex) {
    final section = cryptoSections[sectionIndex];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              section.crypto,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 10),
          Container(
            height: 220,
            child: Stack(
              children: List.generate(section.wallets.length, (index) {
                if (index < 0) return Container();
                return Positioned(
                  top: index * 15.0,
                  left: index * 10.0,
                  right: index * 10.0,
                  child: GestureDetector(
                    onHorizontalDragUpdate: (details) =>
                        _handleDragUpdate(details, sectionIndex, index),
                    onHorizontalDragEnd: (details) =>
                        _handleDragEnd(details, sectionIndex, index),
                    child: AnimatedBuilder(
                      animation: _slideController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_dragOffset, 0),
                          child: Opacity(
                            opacity: 1.0 - (_slideController.value * 0.5),
                            child: CryptoCard(
                              coinName: section.wallets[index]['coin']!,
                              network: section.wallets[index]['network']!,
                              address: section.wallets[index]['address']!,
                              rotationAngle: 0.0,
                              scale: 1.0,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              }).reversed.toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _handleDragUpdate(
      DragUpdateDetails details, int sectionIndex, int cardIndex) {
    setState(() {
      _dragOffset += details.delta.dx;
    });
  }

  void _handleDragEnd(DragEndDetails details, int sectionIndex, int cardIndex) {
    final velocity = details.velocity.pixelsPerSecond.dx;
    if (velocity.abs() > 1000 || _dragOffset.abs() > 100) {
      _animateCardOut(velocity > 0 ? Direction.right : Direction.left,
          sectionIndex, cardIndex);
    } else {
      _resetCard();
    }
  }

  void _animateCardOut(Direction direction, int sectionIndex, int cardIndex) {
    _slideController.forward().then((_) {
      setState(() {
        cryptoSections[sectionIndex].wallets.removeAt(cardIndex);
        _dragOffset = 0;
      });
      _slideController.reset();
    });
  }

  void _resetCard() {
    setState(() => _dragOffset = 0);
  }

  Widget _buildBottomSheet() {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (details.delta.dy < -10 && !_isBottomExpanded) {
          setState(() {
            _isBottomExpanded = true;
          });
        } else if (details.delta.dy > 10 && _isBottomExpanded) {
          setState(() {
            _isBottomExpanded = false;
          });
        }
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        height: _isBottomExpanded ? 250 : 100,
        decoration: BoxDecoration(
          color: Colors.blueGrey[900]?.withOpacity(0.8),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white54,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            _isBottomExpanded
                ? _buildExpandedQuickActions()
                : _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedQuickActions() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: GridView.count(
        crossAxisCount: 2,
        children: [
          _buildQuickActionTile(Icons.info, 'Details'),
          _buildQuickActionTile(Icons.block, 'Block'),
          _buildQuickActionTile(Icons.refresh, 'Refresh'),
          _buildQuickActionTile(Icons.delete, 'Delete'),
          // Add more actions here
        ],
      ),
    );
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
