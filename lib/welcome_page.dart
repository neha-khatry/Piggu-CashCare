import 'package:flutter/material.dart';
import 'LoginPage.dart';


class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[300], // Set the background color to a light green
      body: Stack(
        children: <Widget>[
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'), // Replace with the path to your image
                fit: BoxFit.cover, // Make the image fit the container
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Piggu:CashCare',
                    style: TextStyle(
                      fontSize: 44.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Update the text color to black
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black.withOpacity(0.5),
                          offset: Offset(0.0, 2.0),
                        ),
                      ],
                      fontFamily: 'OpenSans', // Update the font family
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Personal Financial Management with Piggu',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.black, // Update the text color to black
                      shadows: [
                        Shadow(
                          blurRadius: 5.0,
                          color: Colors.black.withOpacity(0.5),
                          offset: Offset(0.0, 2.0),
                        ),
                      ],
                      fontFamily: 'OpenSans', // Update the font family
                    ),
                  ),
                  SizedBox(height: 64.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.login, color: Colors.white,), // Add an icon to the button
                          SizedBox(width: 8.0),
                          Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // Update the text color to white
                              shadows: [
                                Shadow(
                                  blurRadius: 5.0,
                                  color: Colors.black.withOpacity(0.5),
                                  offset: Offset(0.0, 2.0),
                                ),
                              ],
                              fontFamily: 'OpenSans', // Update the font family
                            ),
                          ),
                        ],
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink[800], // Set the button color to a darker green
                      padding: EdgeInsets.zero,
                      shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}