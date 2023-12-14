// ignore_for_file: avoid_print, unused_import, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package
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
  int selectedSeats = 1;
  String selectedTime = '5:30pm';
  double selectedPrice = 0.0;
  DateTime selectedDate = DateTime.now();

  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _controllerPrice = TextEditingController();
  final TextEditingController _controllerDate = TextEditingController();

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
                        DropdownButtonFormField<int>(
                          value: selectedSeats,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.event_seat_sharp),
                            filled: true,
                            fillColor: Colors.white70,
                            hintText: "Choose available seats",
                          ),
                          items: [1, 2, 3].map((int seats) {
                            return DropdownMenuItem<int>(
                              value: seats,
                              child: Text(seats.toString()),
                            );
                          }).toList(),
                          onChanged: (int? value) {
                            setState(() {
                              selectedSeats = value!;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return "Please choose the number of available seats";
                            } else {
                              return null;
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedTime,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.access_time),
                            filled: true,
                            fillColor: Colors.white70,
                            hintText: "Choose time",
                          ),
                          items: ['5:30pm', '7:00am'].map((String time) {
                            return DropdownMenuItem<String>(
                              value: time,
                              child: Text(time),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              selectedTime = value!;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return "Please choose the time";
                            } else {
                              return null;
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _controllerPrice,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.attach_money),
                            filled: true,
                            fillColor: Colors.white70,
                            hintText: "Enter price",
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter the price";
                            } else {
                              return null;
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _controllerDate,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.date_range),
                            filled: true,
                            fillColor: Colors.white70,
                            hintText: "Enter date",
                          ),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2101),
                            );
                            if (pickedDate != null &&
                                pickedDate != selectedDate) {
                              setState(() {
                                selectedDate = pickedDate;
                                _controllerDate.text =
                                    DateFormat('dd-MM-yyyy').format(pickedDate);
                              });
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter the date";
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
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.black),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Validate if either the start or destination is "Campus"
                      if (selectedStartLocation != 'Campus' &&
                          selectedDestination != 'Campus') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Either start or destination should be Campus.'),
                          ),
                        );
                        return;
                      }
                      if (selectedStartLocation == selectedDestination) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Start and destination should be different.'),
                          ),
                        );
                        return;
                      }

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
                            'time': selectedTime,
                            'start': selectedStartLocation,
                            'end': selectedDestination,
                            'availableSeats': selectedSeats,
                            'price': double.parse(_controllerPrice.text),
                            'date': selectedDate,
                          });

                          // Add the 'bookings' subcollection inside the ride document
                          await rideReference.collection('bookings').add({
                            // Add booking details as needed
                          });

                          // Clearing form fields
                          setState(() {
                            selectedSeats = 1;
                            selectedTime = '5:30pm';
                            selectedPrice = 0.0;
                            selectedDate = DateTime.now();
                            _controllerPrice.clear();
                            _controllerDate.clear();
                          });

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
