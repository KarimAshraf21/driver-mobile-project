// ignore_for_file: avoid_print, unused_import

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
  List<String> locations = ['Campus', 'Nasr City 1', 'Tagamoa', 'Maadi'];
  String selectedStartLocation = "Campus";
  String selectedDestination = 'Nasr City 1';
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _availableSeats = TextEditingController();
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
                          controller: _availableSeats,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.event_seat_sharp),
                            filled: true,
                            fillColor: Colors.white70,
                            hintText: "add available seats",
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Can't be Empty";
                            } else {
                              return null;
                            }
                          },
                        ),
                        // Remove TextFormField widgets for start and end points
                        // Add other text form fields as needed
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildDropdown(
                    selectedStartLocation,
                    'From',
                    locations,
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
                    locations,
                    (value) {
                      setState(() {
                        selectedDestination = value!;
                      });
                    },
                  ),
                ),
                //////////////////////////////////////////////////////////////
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
                          // Clearing other text form fields as needed
                          _availableSeats.clear();

                          // Navigate back to the previous screen
                          Navigator.pop(context);
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
