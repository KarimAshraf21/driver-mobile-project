// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/home_page.dart';

class AddPage extends StatefulWidget {
  const AddPage({Key? key}) : super(key: key);

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _availableSeats = TextEditingController();
  final TextEditingController _controllerStart = TextEditingController();
  final TextEditingController _controllerEnd = TextEditingController();
  final TextEditingController _controllerTime = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: iconBack(context),
        title: const Text("Add Notes", style: TextStyle(color: Colors.white)),
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
                        // Add other text form fields as needed
                      ],
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
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
                            'driverId':
                                user.uid, // Include the driver's user ID
                            'time': _controllerTime.text,
                            'start': _controllerStart.text,
                            'end': _controllerEnd.text,
                            'availableSeats': int.parse(_availableSeats.text),
                            // Add other ride details as needed
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
                  child: const Text("Add Ride"),
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
}
