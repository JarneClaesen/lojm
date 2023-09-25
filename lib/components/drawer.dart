import 'package:flutter/material.dart';
import 'package:orchestra_app/components/my_list_tile.dart';
import 'package:orchestra_app/theme/dark_theme.dart';
import 'package:orchestra_app/theme/light_theme.dart';
import 'package:provider/provider.dart';
import 'dart:math';


import '../theme/theme_provider.dart';

class MyDrawer extends StatefulWidget {
  final void Function()? onProfileTap;
  final void Function()? onSignOut;

  const MyDrawer({
    Key? key,
    this.onProfileTap,
    this.onSignOut,
  }) : super(key: key);

  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {

        bool isLightMode = themeProvider.getTheme == lightTheme;

        return Drawer(
          backgroundColor: Colors.grey[900],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(children: [
                // header
                DrawerHeader(
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 64,
                    )),
                // home list tile
                MyListTile(
                  icon: Icons.home,
                  text: 'H O M E',
                  onTap: () {
                    Navigator.pushNamed(context, '/home');
                  },
                ),

                // profile list tile
                MyListTile(
                  icon: Icons.person,
                  text: 'P R O F I L E',
                  onTap: widget.onProfileTap,
                ),
              ]),

              Column(
                children: [
                  // Dark mode / Light mode toggle button
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: ListTile(
                      leading: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _controller.value * 2 * pi,
                            child: Icon(
                              isLightMode ? Icons.dark_mode : Icons.light_mode,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                      title: Text(
                        isLightMode ? 'L I G H T  M O D E' : 'D A R K  M O D E',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        if (_controller.isCompleted) {
                          _controller.reverse();
                        } else {
                          _controller.forward();
                        }
                        Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                      },
                    ),
                  ),

                  // logout list tile
                  Padding(
                    padding: const EdgeInsets.only(bottom: 25.0),
                    child: MyListTile(
                      icon: Icons.logout,
                      text: 'L O G O U T',
                      onTap: widget.onSignOut,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
