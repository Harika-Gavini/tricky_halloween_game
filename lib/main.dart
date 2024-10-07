import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(HalloweenGame());
}

class HalloweenGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Halloween Game',
      theme: ThemeData.dark(),
      home: HalloweenHomePage(),
    );
  }
}

class HalloweenHomePage extends StatefulWidget {
  @override
  _HalloweenHomePageState createState() => _HalloweenHomePageState();
}

class _HalloweenHomePageState extends State<HalloweenHomePage> {
  final Random random = Random();
  List<Offset> objectPositions = [];
  List<Offset> objectDirections = [];
  String correctItem = "";
  bool showSuccess = false;
  bool showFailure = false;
  late Timer _timer;
  late AudioPlayer _backgroundPlayer;
  late AudioPlayer _jumpScarePlayer;
  late AudioPlayer _successPlayer;

  @override
  void initState() {
    super.initState();
    _initializeAudio();
    _initializeObjects();
    _selectCorrectItem();
    _startMovement();
  }

  void _initializeAudio() async {
    _backgroundPlayer = AudioPlayer();
    _jumpScarePlayer = AudioPlayer();
    _successPlayer = AudioPlayer();

    try {
      // Load and play the background music
      await _backgroundPlayer.setAsset('assets/scary-background.mp3');
      print("Background music loaded successfully.");

      // Set background music to loop
      _backgroundPlayer.setLoopMode(LoopMode.all);
      await _backgroundPlayer.play();
      print("Background music is playing.");
    } catch (e) {
      print("Error loading background music: $e");
    }

    // Load the other sound effects
    await _jumpScarePlayer.setAsset('assets/jumpscare.mp3');
    await _successPlayer.setAsset('assets/winning.mp3');
  }

  @override
  void dispose() {
    _backgroundPlayer.dispose();
    _jumpScarePlayer.dispose();
    _successPlayer.dispose();
    _timer.cancel();
    super.dispose();
  }

  void _initializeObjects() {
    objectPositions = List.generate(5, (index) {
      return Offset(random.nextDouble() * 300, random.nextDouble() * 500);
    });

    objectDirections = List.generate(5, (index) {
      double dx = random.nextBool() ? 1.0 : -1.0;
      double dy = random.nextBool() ? 1.0 : -1.0;
      return Offset(dx, dy);
    });
  }

  void _selectCorrectItem() {
    final spookyItems = ['ghost', 'pumpkin', 'bat'];
    correctItem = spookyItems[random.nextInt(spookyItems.length)];
  }

  void _startMovement() {
    _timer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      setState(() {
        // Update the position of each object
        for (int i = 0; i < objectPositions.length; i++) {
          Offset newPos = objectPositions[i] + objectDirections[i] * 3;

          if (newPos.dx < 0 ||
              newPos.dx > MediaQuery.of(context).size.width - 80) {
            objectDirections[i] =
                Offset(-objectDirections[i].dx, objectDirections[i].dy);
          }
          if (newPos.dy < 0 ||
              newPos.dy > MediaQuery.of(context).size.height - 80) {
            objectDirections[i] =
                Offset(objectDirections[i].dx, -objectDirections[i].dy);
          }

          objectPositions[i] = objectPositions[i] + objectDirections[i] * 3;
        }
      });
    });
  }

  void _handleItemTap(String tappedItem) {
    if (tappedItem == correctItem) {
      _successPlayer.play();
      setState(() {
        showSuccess = true;
        showFailure = false;
        // Stop the jump scare sound when the correct item is clicked
        _jumpScarePlayer.stop();
      });
    } else {
      // Play jump scare sound
      _jumpScarePlayer.stop(); // Stop any previous play before playing again
      _jumpScarePlayer.seek(Duration.zero); // Reset to the beginning
      _jumpScarePlayer.play(); // Play the jump scare sound
      setState(() {
        showFailure = true;
        showSuccess = false;
      });
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          showFailure = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              '/Users/harikagavini/Documents/gsu-course-work/mad/tricky_halloween_game/assets/dark_background.png',
              fit: BoxFit.cover,
            ),
          ),
          ..._buildMovingSpookyObjects(),
          if (showSuccess) _buildSuccessMessage(),
          if (showFailure) _buildFailureMessage(),
        ],
      ),
    );
  }

  List<Widget> _buildMovingSpookyObjects() {
    final imageAssets = {
      'ghost':
          '/Users/harikagavini/Documents/gsu-course-work/mad/tricky_halloween_game/assets/ghost.png',
      'pumpkin':
          '/Users/harikagavini/Documents/gsu-course-work/mad/tricky_halloween_game/assets/pumpkin.png',
      'bat':
          '/Users/harikagavini/Documents/gsu-course-work/mad/tricky_halloween_game/assets/bat.png',
    };

    final itemTypes = imageAssets.keys.toList();

    return List<Widget>.generate(objectPositions.length, (index) {
      final itemType = itemTypes[random.nextInt(itemTypes.length)];
      final image = imageAssets[itemType]!;

      return Positioned(
        left: objectPositions[index].dx,
        top: objectPositions[index].dy,
        child: GestureDetector(
          onTap: () {
            _handleItemTap(itemType);
          },
          child: Image.asset(
            image,
            width: 80,
            height: 80,
          ),
        ),
      );
    });
  }

  Widget _buildSuccessMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'You found the correct item!',
            style: TextStyle(
                fontSize: 30, color: Colors.green, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Icon(Icons.star, size: 100, color: Colors.yellow),
        ],
      ),
    );
  }

  Widget _buildFailureMessage() {
    return Container(
      color: Colors.red.withOpacity(0.5),
      child: Center(
        child: Text(
          'Wrong Item! Try Again!',
          style: TextStyle(
              fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
