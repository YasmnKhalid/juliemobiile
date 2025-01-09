import 'package:flutter/material.dart';
import 'package:juliemobiile/component/text_logo.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';


class GoogleBottomBar extends StatefulWidget {
  final List<Widget> pages;

  const GoogleBottomBar({super.key, required this.pages});

  @override
  State<GoogleBottomBar> createState() => _GoogleBottomBarState();
}

class _GoogleBottomBarState extends State<GoogleBottomBar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title:    const TextLogo(
                  text: 'Julie',
                  fontSize: 30.0,
                  color: Colors.white,
                  borderColor: Color(0xFF624E88),
                  borderWidth: 3.0,
                ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {
               Navigator.of(context).pushReplacementNamed('/videoConference');
            },
          ),
        ],
      ),
      drawer: _customDrawer(context),
      body: widget.pages[_selectedIndex],
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xff6200ee),
        unselectedItemColor: const Color(0xff757575),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          SalomonBottomBarItem(
            icon: Icon(Icons.home),
            title: Text("Home"),
            selectedColor: Colors.purple,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.vaccines),
            title: Text("Medication"),
            selectedColor: Colors.pink,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.task),
            title: Text("Task"),
            selectedColor: Colors.orange,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.medical_information),
            title: Text("Health"),
            selectedColor: Colors.teal,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.forum),
            title: Text("Forum"),
            selectedColor: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _customDrawer(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.5, // Adjust the width of the drawer (75% of screen width)
      child: Drawer(
        child: Container(
          color: const Color(0xFF624E88), // Purple background color
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Color(0xFF624E88), // Purple background for header
                ),
                child: const Text(
                  'Julie',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.account_circle, color: Colors.white),
                title: const Text('Account',
                    style: TextStyle(color: Colors.white)),
                onTap: () async {
                   await _handleAccount(context);
                  // Handle Account action
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings, color: Colors.white),
                title: const Text('Settings',
                    style: TextStyle(color: Colors.white)),
                onTap: () async {
                  // Handle Settings action
                  await _handleSetting(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.white),
                title: const Text('Sign Out',
                    style: TextStyle(color: Colors.white)),
                onTap: () async {
                  await _handleSignOut(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }


Future<void> _handleSignOut(BuildContext context) async {
  try {
    await FirebaseAuth.instance.signOut();
    // Navigate to Login Screen after sign-out
    Navigator.of(context).pushReplacementNamed('/login');
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error signing out: $e')),
    );
  }
}

Future<void> _handleAccount(BuildContext context) async {
  try {
    
    // Navigate to 
    Navigator.of(context).pushReplacementNamed('/account');
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}

Future<void> _handleSetting(BuildContext context) async {
  try {
    
    // Navigate to 
    Navigator.of(context).pushReplacementNamed('/setting');
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}



// class HomeScreen extends StatelessWidget {
//   final List<_NavItem> _navItems = [
//     _NavItem(icon: Icons.home, title: "Home", route: '/home', selectedColor: Colors.blue),
//     _NavItem(icon: Icons.person, title: "Profile", route: '/profile', selectedColor: Colors.green),
//     _NavItem(icon: Icons.settings, title: "Settings", route: '/settings', selectedColor: Colors.red),
//   ];

//   HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Salomon Bottom Bar")),
//       body: Navigator(
//         initialRoute: '/home',
//         onGenerateRoute: (settings) {
//           Widget page;
//           switch (settings.name) {
//             case '/home':
//               page = CaretakerHomePage(user: null,);
//               break;
//             case '/profile':
//               page = ProfilePage();
//               break;
//             case '/settings':
//               page = SettingsPage();
//               break;
//             default:
//               page = CaretakerHomePage(user: null,);
//           }
//           return MaterialPageRoute(builder: (_) => page);
//         },
//       ),
//       bottomNavigationBar: SalomonBottomBar(
//         currentIndex: _getCurrentIndex(context),
//         onTap: (index) {
//           Navigator.of(context).pushReplacementNamed(_navItems[index].route);
//         },
//         items: _navItems
//             .map((item) => SalomonBottomBarItem(
//                   icon: Icon(item.icon),
//                   title: Text(item.title),
//                   selectedColor: item.selectedColor,
//                 ))
//             .toList(),
//       ),
//     );
//   }

//   int _getCurrentIndex(BuildContext context) {
//     final routeName = ModalRoute.of(context)?.settings.name;
//     return _navItems.indexWhere((item) => item.route == routeName);
//   }
// }

// class _NavItem {
//   final IconData icon;
//   final String title;
//   final String route;
//   final Color selectedColor;

//   _NavItem({required this.icon, required this.title, required this.route, required this.selectedColor});
// }
}