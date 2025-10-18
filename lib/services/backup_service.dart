import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class BackupService {
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.isGranted) {
        return true;
      }
      
      final status = await Permission.storage.request();
      if (status == PermissionStatus.granted) {
        return true;
      }
      
      // For Android 11+ (API 30+), use manageExternalStorage
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      }
      
      final manageStatus = await Permission.manageExternalStorage.request();
      return manageStatus == PermissionStatus.granted;
    }
    
    return true; // iOS doesn't need storage permission for app documents
  }

  static Future<Map<String, dynamic>> collectUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final data = <String, dynamic>{
      'export_info': {
        'timestamp': DateTime.now().toIso8601String(),
        'user_id': user.uid,
        'app_version': '1.0.0',
      },
      'user_profile': {},
      'barang': [],
      'transaksi': [],
      'kategori': [],
    };

    try {
      // Get user profile
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (userDoc.exists) {
        data['user_profile'] = userDoc.data();
      }

      // Get barang data
      final barangQuery = await FirebaseFirestore.instance
          .collection('barang')
          .where('uid', isEqualTo: user.uid)
          .get();
      
      data['barang'] = barangQuery.docs.map((doc) {
        final docData = doc.data();
        docData['id'] = doc.id;
        // Convert Timestamp to ISO string for JSON serialization
        if (docData['tanggal_input'] is Timestamp) {
          docData['tanggal_input'] = (docData['tanggal_input'] as Timestamp).toDate().toIso8601String();
        }
        return docData;
      }).toList();

      // Get transaksi data
      final transaksiQuery = await FirebaseFirestore.instance
          .collection('transaksi')
          .where('uid', isEqualTo: user.uid)
          .get();
      
      data['transaksi'] = transaksiQuery.docs.map((doc) {
        final docData = doc.data();
        docData['id'] = doc.id;
        // Convert Timestamp to ISO string for JSON serialization
        if (docData['tanggal'] is Timestamp) {
          docData['tanggal'] = (docData['tanggal'] as Timestamp).toDate().toIso8601String();
        }
        return docData;
      }).toList();

      // Get kategori data
      final kategoriQuery = await FirebaseFirestore.instance
          .collection('kategori')
          .where('uid', isEqualTo: user.uid)
          .get();
      
      data['kategori'] = kategoriQuery.docs.map((doc) {
        final docData = doc.data();
        docData['id'] = doc.id;
        return docData;
      }).toList();

    } catch (e) {
      throw Exception('Failed to collect data: $e');
    }

    return data;
  }

  static Future<String> saveBackupToFile(Map<String, dynamic> data) async {
    try {
      // Get the directory to save the file
      Directory directory;
      
      if (Platform.isAndroid) {
        // Try to use external storage first
        directory = Directory('/storage/emulated/0/Download');
        if (!directory.existsSync()) {
          // Fallback to app documents directory
          directory = await getApplicationDocumentsDirectory();
        }
      } else {
        // iOS - use documents directory
        directory = await getApplicationDocumentsDirectory();
      }

      // Create filename with timestamp
      final timestamp = DateTime.now();
      final filename = 'inventory_backup_${timestamp.year}${timestamp.month.toString().padLeft(2, '0')}${timestamp.day.toString().padLeft(2, '0')}_${timestamp.hour.toString().padLeft(2, '0')}${timestamp.minute.toString().padLeft(2, '0')}.json';
      
      final file = File('${directory.path}/$filename');

      // Convert data to JSON string
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);

      // Write to file
      await file.writeAsString(jsonString);

      return file.path;
    } catch (e) {
      throw Exception('Failed to save backup file: $e');
    }
  }

  static Future<String> createBackup() async {
    try {
      // Request permission
      final hasPermission = await requestStoragePermission();
      if (!hasPermission) {
        throw Exception('Storage permission denied');
      }

      // Collect user data
      final data = await collectUserData();

      // Save to file
      final filePath = await saveBackupToFile(data);

      return filePath;
    } catch (e) {
      rethrow;
    }
  }

  static Map<String, dynamic> getBackupSummary(Map<String, dynamic> data) {
    return {
      'total_barang': (data['barang'] as List).length,
      'total_transaksi': (data['transaksi'] as List).length,
      'total_kategori': (data['kategori'] as List).length,
      'export_date': data['export_info']['timestamp'],
    };
  }

  static void showBackupDialog(BuildContext context, {
    required VoidCallback onBackup,
    required bool isLoading,
  }) {
    showDialog(
      context: context,
      barrierDismissible: !isLoading,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.backup,
              color: Colors.blue,
            ),
            const SizedBox(width: 12),
            const Text('Backup Data'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data yang akan di-backup:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text('• Semua data barang'),
            const Text('• Riwayat transaksi'),
            const Text('• Data kategori'),
            const Text('• Profil pengguna'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'File backup akan disimpan dalam format JSON di folder Download.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: isLoading ? null : () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: isLoading ? null : onBackup,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Mulai Backup'),
          ),
        ],
      ),
    );
  }
}
