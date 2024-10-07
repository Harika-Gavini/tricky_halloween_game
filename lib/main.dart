import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

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

  @override
  void initState() {
    super.initState();
    _initializeObjects();
    _selectCorrectItem();
    _startMovement();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // Initialize random positions and directions for each object
  void _initializeObjects() {
    objectPositions = List.generate(5, (index) {
      return Offset(random.nextDouble() * 300, random.nextDouble() * 500);
    });

    // Give each object a random direction to move in
    objectDirections = List.generate(5, (index) {
      double dx = random.nextBool() ? 1.0 : -1.0;
      double dy = random.nextBool() ? 1.0 : -1.0;
      return Offset(dx, dy);
    });
  }

  void _selectCorrectItem() {
    // Define possible spooky objects
    final spookyItems = ['ghost', 'pumpkin', 'bat'];
    // Randomly select one as the correct item
    correctItem = spookyItems[random.nextInt(spookyItems.length)];
  }

  void _startMovement() {
    _timer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      setState(() {
        // Update the position of each object
        for (int i = 0; i < objectPositions.length; i++) {
          Offset newPos = objectPositions[i] + objectDirections[i] * 3;

          // Make sure objects stay within screen bounds
          if (newPos.dx < 0 || newPos.dx > MediaQuery.of(context).size.width - 80) {
            objectDirections[i] = Offset(-objectDirections[i].dx, objectDirections[i].dy);
          }
          if (newPos.dy < 0 || newPos.dy > MediaQuery.of(context).size.height - 80) {
            objectDirections[i] = Offset(objectDirections[i].dx, -objectDirections[i].dy);
          }

          objectPositions[i] = objectPositions[i] + objectDirections[i] * 3;
        }
      });
    });
  }

  // Function to handle tap on the object
  void _handleItemTap(String tappedItem) {
    if (tappedItem == correctItem) {
      setState(() {
        showSuccess = true;
        showFailure = false;
      });
    } else {
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
          // Background Image
          Positioned.fill(
            child: Image.asset(
              '/Users/joisedivya/halloween_game/assets/dark_background.png', // Make sure to use a dark, spooky background image.
              fit: BoxFit.cover,
            ),
          ),

          // Animated Spooky Objects
          ..._buildMovingSpookyObjects(),

          // Success Message
          if (showSuccess) _buildSuccessMessage(),

          // Failure Message
          if (showFailure) _buildFailureMessage(),
        ],
      ),
    );
  }

  // Function to build the moving spooky objects
  List<Widget> _buildMovingSpookyObjects() {
    final imageAssets = {
      'ghost': '/Users/joisedivya/halloween_game/assets/ghost.png', // Make sure these images are transparent PNGs
      'pumpkin': '/Users/joisedivya/halloween_game/assets/pumpkin.png',
      'bat': '/Users/joisedivya/halloween_game/assets/bat.png'
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

  // Success message with glowing animation
  Widget _buildSuccessMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'You found the correct item!',
            style: TextStyle(fontSize: 30, color: Colors.green, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Icon(Icons.star, size: 100, color: Colors.yellow),
        ],
      ),
    );
  }

  // Spooky failure reaction with animation
  Widget _buildFailureMessage() {
    return Container(
      color: Colors.red.withOpacity(0.5), // Flash red color
      child: Center(
        child: Text(
          'Wrong Item! Try Again!',
          style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
