// ignore_for_file: use_build_context_synchronously, prefer_final_fields, unused_field, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'add_ride.dart';

class RidePage extends StatefulWidget {
  const RidePage({super.key});

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

    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: ridesCollection
            .where('driverId', isEqualTo: _user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<QueryDocumentSnapshot<Map<String, dynamic>>> rides =
                snapshot.data!.docs;

            return ListView.builder(
              itemCount: rides.length,
              itemBuilder: (context, index) {
                // Extract ride details
                String time = rides[index]['time'];
                String start = rides[index]['start'];
                String end = rides[index]['end'];
                int availableSeats = rides[index]['availableSeats'];
                DateTime rideDate =
                    (rides[index]['date'] as Timestamp).toDate();

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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                        const Icon(Icons.date_range),
                                        const SizedBox(width: 8),
                                        Text(
                                            "Date: ${_getFormattedDate(rideDate)}"),
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
                                        const Icon(Icons.event_seat_sharp),
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
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.red), // Set background color to black
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white), // Set icon color to white
                            ),
                            onPressed: () {
                              // Implement your logic for handling ride deletion
                              // For example, you might want to cancel the ride
                              // by updating the Firestore document.
                              _deleteRide(rides[index].id);
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
            );
          } else {
            return const Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Fetching rides..."),
                    CircularProgressIndicator()
                  ]),
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
      // Access the Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Reference to the ride document
      DocumentReference rideReference =
          firestore.collection('rides').doc(rideId);

      // Get a reference to the subcollection
      CollectionReference<Map<String, dynamic>> bookingsCollection =
          rideReference.collection('bookings');

      // Get all documents in the subcollection
      QuerySnapshot<Map<String, dynamic>> bookingsSnapshot =
          await bookingsCollection.get();

      // Delete each document in the subcollection
      for (QueryDocumentSnapshot<Map<String, dynamic>> booking
          in bookingsSnapshot.docs) {
        await booking.reference.delete();
      }

      // Delete the ride document
      await rideReference.delete();

      // You can add additional logic here if needed, for example,
      // notifying the user that the ride has been successfully deleted.
      print("Ride deleted successfully");
    } catch (e) {
      print("Error deleting ride: $e");
      // Handle the error, for example, show an error message to the user.
    }
  }

  String _getFormattedDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
