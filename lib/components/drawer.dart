import 'package:flutter/material.dart';
import 'package:orchestra_app/components/my_list_tile.dart';
import 'package:orchestra_app/pages/home_page.dart';
import 'package:orchestra_app/theme/dark_theme.dart';
import 'package:orchestra_app/theme/light_theme.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import '../pages/profile_page.dart';
import '../pages/scores_page.dart';
import '../theme/theme_provider.dart';

class MyDrawer extends StatefulWidget {
  final void Function()? onProfileTap;
  final void Function()? onSignOut;
  final void Function()? onScoresTap;

  const MyDrawer({Key? key, this.onProfileTap, this.onSignOut, this.onScoresTap}) : super(key: key);

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
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        bool isLightMode = themeProvider.getTheme == lightTheme;

        Widget drawerContent = Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(children: [
              // header
              DrawerHeader(
                child: Image.asset(
                  'assets/images/lojmLogoRemovebgWhite.png',
                  fit: BoxFit.fill
                ),
              ),
              MyListTile(
                icon: Icons.home,
                text: 'H O M E',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage()));
                },
              ),
              MyListTile(
                icon: Icons.person,
                text: 'P R O F I L E',
                onTap: widget.onProfileTap,
              ),
              MyListTile(
                icon: Icons.music_note,
                text: 'S C O R E S',
                onTap: widget.onScoresTap,
              ),
            ]),
            Column(children: [
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
                    isLightMode ? 'D A R K  M O D E' : 'L I G H T  M O D E',
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
              Padding(
                padding: const EdgeInsets.only(bottom: 25.0),
                child: MyListTile(
                  icon: Icons.logout,
                  text: 'L O G O U T',
                  onTap: widget.onSignOut,
                ),
              ),
            ]),
          ],
        );

        return Drawer(
          backgroundColor: Colors.grey[900],
          child: isLandscape ? SingleChildScrollView(child: drawerContent) : drawerContent,
        );
      },
    );
  }
}
