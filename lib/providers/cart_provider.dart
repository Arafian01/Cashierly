import 'package:flutter/material.dart';
import '../model/barang.dart';

class CartItem {
  final Barang barang;
  int quantity;
  double get subtotal => barang.harga * quantity;

  CartItem({
    required this.barang,
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
  
  bool isInCart(String barangId) {
    return _cartItems.any((item) => item.barang.id == barangId);
  }
  
  void addToCart(Barang barang) {
    final existingIndex = _cartItems.indexWhere((item) => item.barang.id == barang.id);
    
    if (existingIndex >= 0) {
      _cartItems[existingIndex].quantity += 1;
    } else {
      _cartItems.add(CartItem(barang: barang));
    }
    notifyListeners();
  }
  
  void removeFromCart(String barangId) {
    _cartItems.removeWhere((item) => item.barang.id == barangId);
    notifyListeners();
  }
  
  void updateQuantity(String barangId, int quantity) {
    final existingIndex = _cartItems.indexWhere((item) => item.barang.id == barangId);
    
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
