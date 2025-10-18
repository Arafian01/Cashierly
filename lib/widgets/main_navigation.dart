import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/barang_screen.dart';
import '../screens/transaksi_screen.dart';
import '../screens/laporan_screen.dart';
import '../screens/akun_screen.dart';
import 'app_bottom_navigation.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex;

  const MainNavigation({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _currentIndex;
  late PageController _pageController;

  final List<Widget> _pages = [
    const HomeScreen(),
    const BarangScreen(),
    const TransaksiScreen(),
    const LaporanScreen(),
    const AkunScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onBottomNavTapped(BottomNavItem item) {
    final index = BottomNavItem.values.indexOf(item);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _pages,
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentItem: BottomNavItem.values[_currentIndex],
        onItemTapped: _onBottomNavTapped,
      ),
    );
  }
}
