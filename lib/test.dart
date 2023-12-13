// ignore_for_file: avoid_print, unused_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddPage extends StatefulWidget {
  const AddPage({Key? key}) : super(key: key);

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  List<String> routes = [];
  String selectedStartLocation = "";
  String selectedDestination = "";
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _availableSeats = TextEditingController();
  final TextEditingController _controllerStart = TextEditingController();
  final TextEditingController _controllerEnd = TextEditingController();
  final TextEditingController _controllerTime = TextEditingController();

  @override
  void initState() {
    print("here");
    super.initState();
    print("here");
    // Call a function to fetch routes from Firestore when the widget is initialized
    fetchRoutes();
  }

  Future<void> fetchRoutes() async {
    try {
      // Access the Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Get the 'routes' document
      DocumentSnapshot<Map<String, dynamic>> routesDocument = await firestore
          .collection('routes')
          .doc('aKiq3bmcXkHquU5g6ynO')
          .get();

      // Extract the 'routes' field from the document
      List<dynamic> routesList = routesDocument.get('routes');
      print("here");

      // Update the state with the fetched routes
      setState(() {
        routes = List<String>.from(routesList);
        print("here");
        print(routes);
        // Set default values if needed
        selectedStartLocation = routes.isNotEmpty ? routes[0] : "";
        selectedDestination = routes.isNotEmpty ? routes[0] : "";
      });
    } catch (e) {
      print("Error fetching routes from Firestore: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: iconBack(context),
        title: const Text("Add Rides", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _controllerTime,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.access_time),
                            filled: true,
                            fillColor: Colors.white70,
                            hintText: "add time",
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Can't be Empty";
                            } else {
                              return null;
                            }
                          },
                        ),
                        TextFormField(
                          controller: _controllerStart,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.location_on),
                            filled: true,
                            fillColor: Colors.white70,
                            hintText: "add start point",
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Can't be Empty";
                            } else {
                              return null;
                            }
                          },
                        ),
                        TextFormField(
                          controller: _controllerEnd,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.location_on),
                            filled: true,
                            fillColor: Colors.white70,
                            hintText: "add end point",
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Can't be Empty";
                            } else {
                              return null;
                            }
                          },
                        ),
                        TextFormField(
                          controller: _availableSeats,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.event_seat_sharp),
                            filled: true,
                            fillColor: Colors.white70,
                            hintText: "add seats",
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Can't be Empty";
                            } else {
                              return null;
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildDropdown(
                    selectedStartLocation,
                    'From',
                    routes,
                    (value) {
                      setState(() {
                        selectedStartLocation = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildDropdown(
                    selectedDestination,
                    'To',
                    routes,
                    (value) {
                      setState(() {
                        selectedDestination = value!;
                      });
                    },
                  ),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.black),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        // Access the Firestore instance
                        FirebaseFirestore firestore =
                            FirebaseFirestore.instance;

                        // Get the current user
                        User? user = FirebaseAuth.instance.currentUser;

                        if (user != null) {
                          // Add a new ride to the 'rides' collection
                          DocumentReference rideReference =
                              await firestore.collection('rides').add({
                            'driverId': user.uid,
                            'time': _controllerTime.text,
                            'start': selectedStartLocation,
                            'end': selectedDestination,
                            'availableSeats': int.parse(_availableSeats.text),
                          });

                          // Add the 'bookings' subcollection inside the ride document
                          await rideReference.collection('bookings').add({
                            // Add booking details as needed
                          });

                          _controllerTime.clear();
                          _controllerStart.clear();
                          _controllerEnd.clear();
                          _availableSeats.clear();
                        } else {
                          print("User not logged in.");
                        }
                      } catch (e) {
                        print("Error adding ride to Firestore: $e");
                      }
                    }
                  },
                  child: const Text("Add Ride",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget iconBack(BuildContext context) {
    return IconButton(
      icon: const Icon(
        IconData(
          0xe093,
          fontFamily: 'MaterialIcons',
          matchTextDirection: true,
        ),
        color: Colors.white,
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }

  Widget _buildDropdown(String value, String label, List<String> items,
      Function(String?) onChanged) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        items: items.map<DropdownMenuItem<String>>((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        isExpanded: true,
      ),
    );
  }
}
