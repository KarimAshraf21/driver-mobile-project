// ignore_for_file: unnecessary_cast

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    var user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      var ridesQuery = await firestore
          .collection('rides')
          .where('driverId', isEqualTo: user.uid)
          .get();

      List<String> rideIds = ridesQuery.docs.map((doc) => doc.id).toList();

      var bookingsStream = firestore
          .collection('bookings')
          .where('rideId', whereIn: rideIds)
          .where('status', isEqualTo: 'pending')
          .snapshots();

      bookingsStream.listen((QuerySnapshot<Map<String, dynamic>> data) {
        // Filter out bookings that have passed the deadline
        var filteredBookings = data.docs
            .where((booking) =>
                !_hasBookingPassedDeadline(booking.data()['rideId']))
            .toList();

        _streamController.add(filteredBookings);
      });
    }
  }

  bool _hasBookingPassedDeadline(String rideId) {
    // Retrieve the ride data from Firestore
    FirebaseFirestore.instance.collection('rides').doc(rideId).get().then(
      (rideSnapshot) {
        if (rideSnapshot.exists) {
          var rideData = rideSnapshot.data() as Map<String, dynamic>?;

          if (rideData != null) {
            DateTime rideDateTime = DateTime(
              rideData['date'].toDate().year,
              rideData['date'].toDate().month,
              rideData['date'].toDate().day,
              _getHour(rideData['time']),
              _getMinute(rideData['time']),
            );

            DateTime deadline;

            // Check the ride timing and set the booking deadline accordingly
            if (_isMorningRide(rideData['time'])) {
              // For 7 am ride, set the deadline to 11 pm on the previous day
              deadline = rideDateTime.subtract(const Duration(hours: 8));
            } else {
              // For 5:30 pm ride, set the deadline to 4:30 pm on the same day
              deadline = rideDateTime.subtract(const Duration(hours: 1));
            }

            // Check if the booking deadline has passed
            if (DateTime.now().isAfter(deadline)) {
              // Automatically reject the booking
              _rejectBooking(rideId);
              return true;
            }
          }
        }
        return false;
      },
    );
    return false;
  }

  void _acceptBooking(String bookingId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    await firestore.collection('bookings').doc(bookingId).update({
      'status': 'accepted',
    });
  }

  void _rejectBooking(String bookingId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    await firestore.collection('bookings').doc(bookingId).update({
      'status': 'rejected',
    });
  }

  bool _isMorningRide(String time) {
    // Helper function to check if the ride is a morning ride (before 12 pm)
    DateTime rideTime = DateTime(2023, 1, 1, _getHour(time), _getMinute(time));
    return rideTime.isBefore(DateTime(2023, 1, 1, 12, 0));
  }

  int _getHour(String time) {
    // Helper function to extract the hour from the time string
    final parts = time.split(':');
    final hour = int.parse(parts[0]);

    if (time.toLowerCase().contains('pm') && hour != 12) {
      return hour + 12;
    } else if (time.toLowerCase().contains('am') && hour == 12) {
      return 0;
    } else {
      return hour;
    }
  }

  int _getMinute(String time) {
    // Helper function to extract the minute from the time string
    final parts = time.split(':');
    final minute = int.parse(parts[1].replaceAll(RegExp('[a-z]'), ''));

    return minute;
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
                                  DateTime rideDate =
                                      (rideData['date'] as Timestamp).toDate();
                                  String formattedDate =
                                      _getFormattedDate(rideDate);
                                  String rideTime =
                                      rideData['time'] ?? 'Unknown';

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
                                      Text('Date: $formattedDate'),
                                      Text('Time: $rideTime'),
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

  String _getFormattedDate(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }
}
