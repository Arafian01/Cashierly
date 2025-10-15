import 'package:flutter/material.dart';
import '../model/barang_satuan.dart';
import '../model/barang.dart';

class CartItem {
  final BarangSatuan barangSatuan;
  final Barang? barang; // Optional for display purposes
  int quantity;
  double get subtotal => barangSatuan.hargaJual * quantity;

  CartItem({
    required this.barangSatuan,
    this.barang,
    this.quantity = 1,
  });
}

class CartProvider with ChangeNotifier {
  List<CartItem> _cartItems = [];
  
  List<CartItem> get cartItems => _cartItems;
  
  int get totalItems {
    return _cartItems.fold(0, (total, item) => total + item.quantity);
  }
  
  // Count of unique items (not quantity)
  int get uniqueItemCount {
    return _cartItems.length;
  }
  
  double get totalAmount {
    return _cartItems.fold(0.0, (total, item) => total + item.subtotal);
  }
  
  bool isInCart(String barangSatuanId) {
    return _cartItems.any((item) => item.barangSatuan.id == barangSatuanId);
  }
  
  void addToCart(BarangSatuan barangSatuan, {Barang? barang}) {
    final existingIndex = _cartItems.indexWhere((item) => item.barangSatuan.id == barangSatuan.id);
    
    if (existingIndex >= 0) {
      _cartItems[existingIndex].quantity += 1;
    } else {
      _cartItems.add(CartItem(barangSatuan: barangSatuan, barang: barang));
    }
    notifyListeners();
  }
  
  void removeFromCart(String barangSatuanId) {
    _cartItems.removeWhere((item) => item.barangSatuan.id == barangSatuanId);
    notifyListeners();
  }
  
  void updateQuantity(String barangSatuanId, int quantity) {
    final existingIndex = _cartItems.indexWhere((item) => item.barangSatuan.id == barangSatuanId);
    
    if (existingIndex >= 0) {
      if (quantity > 0) {
        _cartItems[existingIndex].quantity = quantity;
      } else {
        _cartItems.removeAt(existingIndex);
      }
      notifyListeners();
    }
  }
  
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
  
  void clearError() {
    // Add error handling if needed in the future
    notifyListeners();
  }
}
