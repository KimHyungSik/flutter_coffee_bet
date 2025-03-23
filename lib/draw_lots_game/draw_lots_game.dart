import 'dart:async';
import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../admob/banner_adb.dart';
import '../game_over.dart';
import '../utils/shared_preferences_manager.dart';

class DrawingLotsGameApp extends StatelessWidget {
  const DrawingLotsGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const DrawingLotsGameScreen();
  }
}

class DrawingLotsGameScreen extends StatefulWidget {
  const DrawingLotsGameScreen({super.key});

  @override
  _DrawingLotsGameScreenState createState() => _DrawingLotsGameScreenState();
}

class _DrawingLotsGameScreenState extends State<DrawingLotsGameScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<String> _participants = [];
  final List<String> _winners = [];
  final Random _random = Random();

  bool _isDrawing = false;
  bool _hasDrawn = false;
  int _numWinners = 1;

  late AnimationController _animationController;
  late Animation<double> _animation;

  Timer? _drawingTimer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    _drawingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Column(
        children: [
          // Header area with back button and reset button
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 40, left: 8),
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (!_hasDrawn)
                        IconButton(
                          onPressed: _showSaveParticipantsBottomSheet,
                          icon: const Icon(
                            Icons.save,
                            color: Colors.white,
                          ),
                          tooltip: context.tr("Save_list"),
                        ),
                      if (!_hasDrawn)
                        IconButton(
                          onPressed: _resetGame,
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.white,
                            size: 28,
                          ),
                          tooltip: context.tr("Reset"),
                        ),
                    ],
                  ),
                ),

                // Main content area
                Expanded(
                  child: _hasDrawn
                      ? _buildWinnerDisplay()
                      : _buildDrawingLotsScreen(),
                ),

                // Bottom button area - this will hold either the Draw Winner or Start New Drawing button
                bottomButton(context),
              ],
            ),
          ),
          AdManager.instance.drawLotsGameBannerAd == null
              ? Container()
              : SizedBox(
                  width: AdManager
                      .instance.drawLotsGameBannerAd!.sizes.first.width
                      .toDouble(),
                  height: AdManager
                      .instance.drawLotsGameBannerAd!.sizes.first.height
                      .toDouble(),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child:
                        AdWidget(ad: AdManager.instance.drawLotsGameBannerAd!),
                  ),
                ),
        ],
      ),
    );
  }

  Padding bottomButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        child: _hasDrawn
            ? ElevatedButton(
                onPressed: _restartGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5252),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  context.tr("Start_New_Drawing"),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: ElevatedButton(
                      onPressed: _participants.isEmpty ? null : _startDrawing,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5252),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        disabledBackgroundColor: Colors.grey,
                      ),
                      child: Text(
                        context.tr("Draw_Winner"),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 1,
                    child: IconButton(
                      onPressed: _showLoadParticipantsBottomSheet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        disabledBackgroundColor: Colors.grey,
                      ),
                      icon: const Icon(
                        Icons.file_upload_outlined,
                        color: Colors.white,
                      ),
                      tooltip: context.tr("Load_list"),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDrawingLotsScreen() {
    return Column(
      children: [
        // Title text
        Expanded(
          flex: 2,
          child: Center(
            child: Text(
              context.tr("Add_names_to_start_the_lottery"),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
          ),
        ),

        // Input area
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    maxLength: 10,
                    // Limit input to 10 characters
                    decoration: InputDecoration(
                      hintText: context.tr("Enter_name"),
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      border: InputBorder.none,
                      counterText: "",
                      // Hide the character counter
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                    ),
                    onSubmitted: (value) => _addParticipant(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextButton(
                  onPressed: _addParticipant,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
        ),

        // Participants area with scrolling
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: _participants.isEmpty
                ? const SizedBox.shrink()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${context.tr("Participants")} (${_participants.length})",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: Wrap(
                            spacing: 10, // gap between adjacent chips
                            runSpacing: 10, // gap between lines
                            children:
                                _participants.asMap().entries.map((entry) {
                              int index = entry.key;
                              String name = entry.value;
                              return _buildParticipantsItem(index, name);
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantsItem(int index, String name) {
    // Using intrinsicWidth to make the container size fit the text
    return IntrinsicWidth(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Make row size fit its children
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.cancel, color: Colors.grey),
              iconSize: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => _removeParticipant(index),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantTag(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: Colors.grey[700],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        name,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  Widget _buildWinnerDisplay() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 24),
        if (!_isDrawing)
          Text(
            _winners.length > 1 ? context.tr("Winners") : context.tr("Winner"),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        if (_isDrawing)
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_animation.value * 0.2),
                child: Text(
                  _participants[_currentIndex],
                  style: const TextStyle(
                    color: Colors.yellow,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          )
        else
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _winners
                  .map((winner) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          winner,
                          style: const TextStyle(
                            color: Colors.yellow,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                offset: Offset(2, 2),
                                blurRadius: 10,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }

  void _addParticipant() {
    if (_nameController.text.trim().isNotEmpty) {
      setState(() {
        _participants.add(_nameController.text.trim());
        _nameController.clear();
      });

      // Scroll to the bottom after the UI updates
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _removeParticipant(int index) {
    setState(() {
      _participants.removeAt(index);
      if (_numWinners > _participants.length) {
        _numWinners = _participants.isNotEmpty ? _participants.length : 1;
      }
    });
  }

  void _resetGame() {
    setState(() {
      _participants.clear();
      _nameController.clear();
      _winners.clear();
      _hasDrawn = false;
      _isDrawing = false;
    });
  }

  void _startDrawing() {
    if (_participants.isEmpty) return;

    setState(() {
      _isDrawing = true;
      _hasDrawn = true;
      _winners.clear();
    });

    // Make a copy of the participants list to avoid modifying the original during drawing
    final List<String> candidatesPool = List.from(_participants);

    // Limit winners to the number of participants
    final int actualWinners = _numWinners > candidatesPool.length
        ? candidatesPool.length
        : _numWinners;

    // Start the animation
    int animationStep = 0;
    _drawingTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _currentIndex = _random.nextInt(_participants.length);
      });

      // Animation effect
      if (animationStep % 2 == 0) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }

      animationStep++;

      // End after ~3 seconds
      if (animationStep > 30) {
        timer.cancel();
        _selectWinners(candidatesPool, actualWinners);
      }
    });
  }

  void _selectWinners(List<String> pool, int count) {
    setState(() {
      _isDrawing = false;
      _winners.clear();

      // Select the required number of winners
      for (int i = 0; i < count; i++) {
        if (pool.isEmpty) break;

        final int selectedIndex = _random.nextInt(pool.length);
        _winners.add(pool[selectedIndex]);
        pool.removeAt(selectedIndex); // Remove to avoid duplicate winners
      }
    });
  }

  void _restartGame() {
    setState(() {
      _hasDrawn = false;
      _isDrawing = false;
      _winners.clear();
    });
  }

  // Save participants list bottom sheet
  void _showSaveParticipantsBottomSheet() {
    final TextEditingController nameController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.tr("Save_participant_list"),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: context.tr("Enter_list_name"),
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isNotEmpty) {
                      await SharedPreferencesManager.saveParticipantsList(
                          nameController.text.trim(), _participants);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    context.tr("Save"),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // Load participants list bottom sheet
  void _showLoadParticipantsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return FutureBuilder<Map<String, List<String>>>(
              future: SharedPreferencesManager.getParticipantsLists(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        context.tr("No_saved_lists"),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  );
                }

                final lists = snapshot.data!;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        context.tr("Saved_lists"),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: lists.length,
                        itemBuilder: (context, index) {
                          final name = lists.keys.elementAt(index);
                          final participants = lists[name]!;

                          return GestureDetector(
                            onTap: () {
                              Navigator.pop(context, participants);
                            },
                            child: ListTile(
                              title: Text(
                                name,
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Container(
                                height: 30,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: participants
                                        .map((name) =>
                                            _buildParticipantTag(name))
                                        .toList(),
                                  ),
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.cancel,
                                        color: Colors.grey),
                                    iconSize: 20,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () async {
                                      await SharedPreferencesManager
                                          .deleteParticipantsList(name);
                                      setState(() {});
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    ).then((selectedParticipants) {
      if (selectedParticipants != null) {
        setState(() {
          _participants.clear();
          _participants.addAll(selectedParticipants as List<String>);
        });
      }
    });
  }
}
