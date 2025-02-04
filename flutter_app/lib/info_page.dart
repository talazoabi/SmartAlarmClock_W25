import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'layout_page.dart';

class InfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.lightBlue[50],
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LayoutPage()),
            );
          },
        ),
        title: const Text(
          'Initialization Guide',
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildButtonSection(context),
            _buildStepCard(1, "Connect to WiseRise WiFi", "Ensure your device is connected to the WiseRise WiFi network.\nPassword: '123456789'."),
            _buildStepCard(2, "Access Configuration", "Open a web browser and enter '192.168.4.1' in the address bar."),
            _buildStepCard(3, "Select Your Network", "Click on 'Configure WiFi' and choose the desired WiFi network for your clock."),
            _buildStepCard(4, "Enter Network Credentials", "Input your WiFi password in the designated field and click 'Save' to apply the settings."),
            _buildStepCard(5, "All Done", "Your WiseRise device is now successfully connected and ready for use."),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard(int step, String title, String description) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.lightBlue[50],
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Step $step: $title",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (step == 5)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Icon(CupertinoIcons.smiley),
                  ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonSection(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.lightBlue[50],
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Buttons Guide",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              "Press a button for more info.",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCircularButton(context, Icons.power_settings_new, "Turn Off Screen", Colors.red,
                    "Press this button to turn on/off the clock screen."),
                _buildCircularButton(context, Icons.volume_up, "Speak", Colors.black,
                    "Press this button to announce the current clock screen."),
                _buildCircularButton(context, Icons.snooze, "Snooze/Stop", Colors.black,
                    "Press this button a short press to snooze the alarm and a long press to stop the alarm."),
                _buildCircularButton(context, Icons.arrow_forward, "Next Screen", Colors.black,
                    "Press this button to navigate to the next screen.\n1. Clock\n2. Date\n"
                        "3. Day\n4. Tasks\n5. Weather"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularButton(BuildContext context, IconData icon, String label, Color color, String message) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: null,
          onPressed: () => _showCustomDialog(context, label, message),
          backgroundColor: color,
          shape: CircleBorder(),
          child: Icon(icon, color: Colors.white),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.black),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showCustomDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.lightBlue[50],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text(message, style: TextStyle(fontSize: 16, color: Colors.black), textAlign: TextAlign.center),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("OK"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}