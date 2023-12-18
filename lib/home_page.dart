// ignore_for_file: file_names, unused_import, unused_field

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/rides_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '/profile_page.dart';
import 'requests_page.dart';
import 'package:flutter/material.dart';

String firstname = '';
String phone = '';
String id = '';
String email = '';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
        firstname = _userData!['firstName'];
        phone = _userData!['phone'];
        id = _userData!['id'];
        email = _userData!['email'];
      });
    }
  }

  int _currentIndex = 0;

  final List<Widget> _pages = [
    const RidePage(),
    const RequestsPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: _currentIndex == 0
          ? buildBookingPageAppBar()
          : _currentIndex == 1
              ? buildRequestsPageAppBar()
              : buildProfilePageAppBar(),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_taxi),
            label: "Ride",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget buildBookingPageAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      title: Row(
        children: [
          SizedBox(width: 50, child: Image.asset('assets/logo.png')),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hey, $firstname!',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const Text(
                'Add a ride?',
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget buildRequestsPageAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      title: Row(
        children: [
          SizedBox(width: 50, child: Image.asset('assets/logo.png')),
          const SizedBox(width: 8),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Requests',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget buildProfilePageAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      title: Row(
        children: [
          SizedBox(width: 50, child: Image.asset('assets/logo.png')),
          const SizedBox(width: 8),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Driver Profile',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
