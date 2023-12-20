// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'local_database.dart'; // Import the local database class

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocalDatabase _localDatabase = LocalDatabase();

  String firstname = '';
  String email = '';
  String phone = '';
  String id = '';

  @override
  void initState() {
    super.initState();
    _loadDataForCurrentUser();
  }

  Future<void> _loadDataForCurrentUser() async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        // Fetch data from Firestore using the user's UID
        DocumentSnapshot<Map<String, dynamic>> snapshot =
            await FirebaseFirestore.instance
                .collection('drivers')
                .doc(user.uid)
                .get();

        if (snapshot.exists) {
          Map<String, dynamic> driverData = snapshot.data() ?? {};

          // Save data to the local SQLite database
          await _localDatabase.insertDriver(driverData);

          // Update the UI with the loaded data
          _loadDataFromLocalDb();
        } else {
          print('Driver details not found for user with UID: ${user.uid}');
        }
      } else {
        print('No user is currently logged in.');
      }
    } catch (error) {
      print('Error fetching data from Firestore: $error');
    }
  }

  _loadDataFromLocalDb() async {
    Map<String, dynamic> driver = await _localDatabase.getDriver();

    print('Local Database - Loaded Driver Data: $driver');

    setState(() {
      firstname = driver['firstName'] ?? '';
      email = driver['email'] ?? '';
      phone = driver['phone'] ?? '';
      id = driver['id'] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: firstname.isNotEmpty
            ? _buildProfileCard()
            : const CircularProgressIndicator(),
      ),
    );
  }

  _buildProfileCard() {
    return ListView(
      shrinkWrap: true,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            color: Colors.white,
            elevation: 8.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildProfileInfo(Icons.person, "Name", firstname),
                  _buildProfileInfo(Icons.email, "Email", email),
                  _buildProfileInfo(Icons.phone, "Phone Number", phone),
                  _buildProfileInfo(Icons.confirmation_num, "ID", id),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
        Center(
          child: TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfo(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.black,
            size: 30.0,
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$label:',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
