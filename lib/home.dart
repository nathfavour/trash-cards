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
  final Map<String, List<Map<String, String>>> removedCards = {};
  double _bottomSheetHeight = 100;
  double _cardSectionScale = 1.0;
  int currentCardIndex = 0; // Added property

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
        duration: Duration(milliseconds: 300),
        child: Stack(
          children: [
            _buildBackground(),
            SafeArea(
              child: Column(
                children: [
                  _buildAppBar(),
                  Expanded(
                    child: AnimatedScale(
                      scale: _cardSectionScale,
                      duration: Duration(milliseconds: 300),
                      child: ListView.builder(
                        itemCount: cryptoSections.length,
                        itemBuilder: (context, sectionIndex) {
                          return _buildCryptoSection(sectionIndex);
                        },
                      ),
                    ),
                  ),
                  _buildExpandableBottomSheet(),
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
    return Container(
      height: 250, // Reduced height for compactness
      margin: EdgeInsets.symmetric(vertical: 5.0), // Reduced margin
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  section.crypto,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.refresh, color: Colors.white),
                  onPressed: () => _restoreRemovedCards(section.crypto),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: List.generate(section.wallets.length, (index) {
                return Positioned(
                  top: 0,
                  left: 20 + (index * 8.0), // Reduced offset for compactness
                  right: 20 - (index * 8.0),
                  child: _buildDraggableCard(section, index, sectionIndex),
                );
              }).reversed.toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableCard(
      CryptoSection section, int index, int sectionIndex) {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        double slide = _dragOffset;
        if (index == currentCardIndex) {
          // Now valid
          slide = _dragOffset;
        }
        return Transform.translate(
          offset: Offset(slide, 0),
          child: Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateZ((_dragOffset / 3000) * pi),
            child: Opacity(
              opacity: 1.0 - ((_dragOffset.abs() / 300).clamp(0.0, 0.5)),
              child: GestureDetector(
                onHorizontalDragUpdate: (details) =>
                    _handleDragUpdate(details, sectionIndex, index),
                onHorizontalDragEnd: (details) =>
                    _handleDragEnd(details, sectionIndex, index),
                child: CryptoCard(
                  coinName: section.wallets[index]['coin']!,
                  network: section.wallets[index]['network']!,
                  address: section.wallets[index]['address']!,
                  rotationAngle: 0.0,
                  scale: 1.0 - (index * 0.05),
                ),
              ),
            ),
          ),
        );
      },
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
      _animateCardOut(
        velocity > 0 ? Direction.right : Direction.left,
        sectionIndex,
        cardIndex,
      );
    } else {
      _resetCard();
    }
  }

  void _animateCardOut(Direction direction, int sectionIndex, int cardIndex) {
    final targetX = direction == Direction.right ? 500.0 : -500.0;

    Animation<double> slideOutAnimation = Tween<double>(
      begin: _dragOffset,
      end: targetX,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    slideOutAnimation.addListener(() {
      setState(() {
        _dragOffset = slideOutAnimation.value;
      });
    });

    _slideController.forward().then((_) {
      setState(() {
        final removedCard =
            cryptoSections[sectionIndex].wallets.removeAt(cardIndex);
        if (!removedCards.containsKey(cryptoSections[sectionIndex].crypto)) {
          removedCards[cryptoSections[sectionIndex].crypto] = [];
        }
        removedCards[cryptoSections[sectionIndex].crypto]!.add(removedCard);
        _dragOffset = 0;
      });
      _slideController.reset();
    });
  }

  void _resetCard() {
    setState(() => _dragOffset = 0);
  }

  void _restoreRemovedCards(String crypto) {
    if (removedCards.containsKey(crypto) && removedCards[crypto]!.isNotEmpty) {
      setState(() {
        final sectionIndex =
            cryptoSections.indexWhere((s) => s.crypto == crypto);
        if (sectionIndex != -1) {
          cryptoSections[sectionIndex]
              .wallets
              .add(removedCards[crypto]!.removeLast());
        }
      });
    }
  }

  Widget _buildExpandableBottomSheet() {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        setState(() {
          _bottomSheetHeight -= details.delta.dy;
          _bottomSheetHeight = _bottomSheetHeight.clamp(100.0, 400.0);
          _cardSectionScale = 1.0 - ((_bottomSheetHeight - 100) / 600);
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        height: _bottomSheetHeight,
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
            Expanded(
              child: SingleChildScrollView(
                child: _bottomSheetHeight > 200
                    ? _buildExpandedQuickActions()
                    : _buildQuickActions(),
              ),
            ),
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
