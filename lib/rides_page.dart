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
  TextEditingController _searchController = TextEditingController();
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {});
              },
              decoration: const InputDecoration(
                labelText: 'Search Rides',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: ridesCollection
                  .where('driverId', isEqualTo: _user?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<QueryDocumentSnapshot<Map<String, dynamic>>> rides =
                      snapshot.data!.docs;

                  List<QueryDocumentSnapshot<Map<String, dynamic>>>
                      filteredRides = rides
                          .where((ride) => ride['time']
                              .toString()
                              .toLowerCase()
                              .contains(_searchController.text.toLowerCase()))
                          .toList();

                  return ListView.builder(
                    itemCount: filteredRides.length,
                    itemBuilder: (context, index) {
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
                                      leading: const Icon(Icons.access_time),
                                      title: Text("Ride ${index + 1}"),
                                      subtitle: Text(
                                          "${filteredRides[index]['time']}"),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.redAccent),
                                  ),
                                  onPressed: () {
                                    // Implement your logic for handling ride deletion
                                    // For example, you might want to cancel the ride
                                    // by updating the Firestore document.
                                    _deleteRide(filteredRides[index].id);
                                    print("Delete ride button pressed");
                                  },
                                  child: const Text("Delete",
                                      style: TextStyle(color: Colors.white)),
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
                          Text("Searching for rides..."),
                          CircularProgressIndicator()
                        ]),
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to AddRide page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPage()),
          );
        },
        child: const Icon(Icons.add),
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
}
