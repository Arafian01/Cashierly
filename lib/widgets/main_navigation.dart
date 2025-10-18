import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/barang_page.dart';
import '../pages/transaksi_page.dart';
import '../pages/laporan_page.dart';
import '../pages/akun_page.dart';
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
    const HomePage(),
    const BarangPage(),
    const TransaksiPage(),
    const LaporanPage(),
    const AkunPage(),
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
