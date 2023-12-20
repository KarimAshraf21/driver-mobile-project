// Import necessary packages
// ignore_for_file: avoid_print, unused_field

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting

import 'add_ride.dart';

class RidePage extends StatefulWidget {
  const RidePage({Key? key}) : super(key: key);

  @override
  State<RidePage> createState() => _RidePageState();
}

class _RidePageState extends State<RidePage> {
  User? _user;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    _getUserInfo();
    super.initState();
  }

  Future<void> _getUserInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> userData = await FirebaseFirestore
          .instance
          .collection('drivers')
          .doc(user.uid)
          .get();

      setState(() {
        _user = user;
        _userData = userData.data();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference<Map<String, dynamic>> ridesCollection =
        FirebaseFirestore.instance.collection('rides');

    DateTime today = DateTime.now();
    DateTime todayStart = DateTime(today.year, today.month, today.day);

    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: ridesCollection
            .where('driverId', isEqualTo: _user?.uid)
            .where('date', isGreaterThanOrEqualTo: todayStart)
            .orderBy('date') // Order by date in ascending order (oldest first)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<QueryDocumentSnapshot<Map<String, dynamic>>> rides =
                snapshot.data!.docs;

            // Sort rides based on date (oldest first)
            rides.sort((a, b) {
              DateTime dateA = (a['date'] as Timestamp).toDate();
              DateTime dateB = (b['date'] as Timestamp).toDate();
              return dateA.compareTo(dateB);
            });

            Map<String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>
                groupedRides = {};

            for (QueryDocumentSnapshot<Map<String, dynamic>> ride in rides) {
              DateTime rideDate = (ride['date'] as Timestamp).toDate();
              String formattedDate =
                  DateFormat('E, dd-MM-yyyy').format(rideDate);

              groupedRides.putIfAbsent(formattedDate, () => []);
              groupedRides[formattedDate]!.add(ride);
            }

            return ListView(
              children: groupedRides.keys.map((String date) {
                List<QueryDocumentSnapshot<Map<String, dynamic>>> ridesOnDate =
                    groupedRides[date]!;

                return Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Align to the left
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        date,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    ...ridesOnDate.map(
                      (QueryDocumentSnapshot<Map<String, dynamic>> ride) {
                        // Extract ride details
                        String time = ride['time'];
                        String start = ride['start'];
                        String end = ride['end'];
                        int availableSeats = ride['availableSeats'];
                        return Card(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Container(
                                  color: Colors.white70,
                                  child: Column(
                                    children: [
                                      ListTile(
                                        title: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(Icons.access_time),
                                                const SizedBox(width: 8),
                                                Text("Time: $time"),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                const Icon(Icons.location_on),
                                                const SizedBox(width: 8),
                                                Text("Start: $start"),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                const Icon(Icons.location_on),
                                                const SizedBox(width: 8),
                                                Text("End: $end"),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                const Icon(
                                                    Icons.event_seat_sharp),
                                                const SizedBox(width: 8),
                                                Text(
                                                    "Available Seats: $availableSeats"),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty
                                          .all<Color>(Colors
                                              .red), // Set background color to black
                                      foregroundColor: MaterialStateProperty
                                          .all<Color>(Colors
                                              .white), // Set icon color to white
                                    ),
                                    onPressed: () {
                                      // Implement your logic for
                                      _deleteRide(ride.id);
                                      print("Delete ride button pressed");
                                    },
                                    child: const Text("Delete"),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              }).toList(),
            );
          } else if (snapshot.hasError) {
            print("Error fetching rides: ${snapshot.error}");
            return const Center(
              child: Text("Error fetching rides"),
            );
          } else {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Fetching rides..."),
                  CircularProgressIndicator(),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to AddRide page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPage()),
          );
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add,
            color: Colors.white), // Set background color to black
      ),
    );
  }

  Future<void> _deleteRide(String rideId) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference rideReference =
          firestore.collection('rides').doc(rideId);

      CollectionReference<Map<String, dynamic>> bookingsCollection =
          rideReference.collection('bookings');

      QuerySnapshot<Map<String, dynamic>> bookingsSnapshot =
          await bookingsCollection.get();

      for (QueryDocumentSnapshot<Map<String, dynamic>> booking
          in bookingsSnapshot.docs) {
        await booking.reference.delete();
      }

      await rideReference.delete();

      print("Ride deleted successfully");
    } catch (e) {
      print("Error deleting ride: $e");
    }
  }
}
