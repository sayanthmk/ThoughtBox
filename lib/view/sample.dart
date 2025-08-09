import 'package:flutter/material.dart';

class ChangePage extends StatelessWidget {
  const ChangePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                Text('data'),
                Text('data'),
              ],
            ),
            const SizedBox(height: 10),
            const Row(
              children: [
                Chip(label: Text('History')),
                Chip(label: Text('Classic')),
                Chip(
                    label: Text('Biography'),
                    backgroundColor: Colors.blueAccent,
                    labelStyle: TextStyle(color: Colors.white)),
                Chip(label: Text('Cartoon')),
              ],
            ),
            Expanded(
              // The fix: Wrap the ListView.builder in an Expanded widget
              child: ListView.builder(
                itemCount: 5, // Example: Create 5 items
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height:
                          300, // Fixed height for each item to match the original design
                      child: Stack(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  height: 300,
                                  width:
                                      200, // Decreased the width of the red container
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Container(
                                  height: 250,
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(20),
                                    ),
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  // This container acts as a spacer, as in the original design
                                  width: 200,
                                  height: 400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
