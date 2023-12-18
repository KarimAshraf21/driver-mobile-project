import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RequestsPage extends StatefulWidget {
  const RequestsPage({Key? key}) : super(key: key);

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  late final StreamController<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      _streamController = StreamController<
          List<QueryDocumentSnapshot<Map<String, dynamic>>>>.broadcast();

  @override
  void initState() {
    super.initState();
    _fetchPendingBookings();
  }

  void _fetchPendingBookings() async {
    // Get the current authenticated user
    var user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Access the Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Step 1: Retrieve the rides for the specific driver
      var ridesQuery = await firestore
          .collection('rides')
          .where('driverId', isEqualTo: user.uid)
          .get();

      // Extract rideIds from the rides
      List<String> rideIds = ridesQuery.docs.map((doc) => doc.id).toList();

      // Step 2: Retrieve pending bookings for the retrieved rides
      var bookingsStream = firestore
          .collection('bookings')
          .where('rideId', whereIn: rideIds)
          .where('status', isEqualTo: 'pending')
          .snapshots();

      bookingsStream.listen((QuerySnapshot<Map<String, dynamic>> data) {
        _streamController.add(data.docs);
      });
    }
  }

  void _acceptBooking(String bookingId) async {
    // Access the Firestore instance
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Update the booking status to 'accepted'
    await firestore.collection('bookings').doc(bookingId).update({
      'status': 'accepted',
    });
  }

  void _rejectBooking(String bookingId) async {
    // Access the Firestore instance
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // You can delete the booking or mark it as 'rejected' based on your requirements
    // For example, marking it as 'rejected':
    await firestore.collection('bookings').doc(bookingId).update({
      'status': 'rejected',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
        stream: _streamController.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<QueryDocumentSnapshot<Map<String, dynamic>>> bookings =
                snapshot.data!;

            if (bookings.isEmpty) {
              return const Center(
                child: Text('No pending bookings.'),
              );
            }

            return ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                var booking = bookings[index].data();

                return ListTile(
                  title: FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(booking['userId'])
                        .get(),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState ==
                          ConnectionState.done) {
                        var userData =
                            userSnapshot.data!.data() as Map<String, dynamic>?;

                        if (userData != null) {
                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('rides')
                                .doc(booking['rideId'])
                                .get(),
                            builder: (context, rideSnapshot) {
                              if (rideSnapshot.connectionState ==
                                  ConnectionState.done) {
                                var rideData = rideSnapshot.data!.data()
                                    as Map<String, dynamic>?;

                                if (rideData != null) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'User: ${userData['firstName'] ?? 'Unknown'}'),
                                      Text(
                                          'UserID: ${userData['id'] ?? 'Unknown'}'),
                                      Text(
                                          'Ride Details: ${rideData['end'] ?? 'Unknown'}'),
                                    ],
                                  );
                                } else {
                                  return const Text('Ride: Unknown');
                                }
                              } else {
                                return const Text('Ride: Loading...');
                              }
                            },
                          );
                        } else {
                          return const Text('User: Unknown');
                        }
                      } else {
                        return const Text('User: Loading...');
                      }
                    },
                  ),
                  subtitle: Text('Status: ${booking['status']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _acceptBooking(bookings[index].id);
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.black,
                        ),
                        child: const Text('Accept'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          _rejectBooking(bookings[index].id);
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.red,
                          backgroundColor: Colors.black,
                        ),
                        child: const Text('Reject'),
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }
}
