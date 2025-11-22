import 'package:flutter/material.dart';
import '../models/customer_model.dart';
import './gift_confirmation_dialog.dart';

class CustomerCard extends StatelessWidget {
  final Customer customer;

  const CustomerCard({Key? key, required this.customer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// === ROW 1: Nama Toko + Status Badge ===
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama toko — Flexible supaya wrap & tidak overflow
                Expanded(
                  child: Text(
                    customer.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2, // Boleh 1 atau 2
                  ),
                ),

                SizedBox(width: 12),

                // Status badge — tidak memenuhi layar
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(customer.status),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    customer.status,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 8),

            /// === ROW 2: Alamat + Nomor Telepon ===
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ALAMAT (flexible)
                Expanded(
                  child: Text(
                    customer.address,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),

                SizedBox(width: 12),

                // Nomor telp (icon + text)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 6),
                    Text(
                      customer.phoneNo,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 12),

            /// === TTH Documents (chip style) ===
            if (customer.tthDocuments.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: customer.tthDocuments
                    .where((doc) => doc.ttottPNo.isNotEmpty)
                    .map((doc) => _buildTTOttpNoChip(doc.ttottPNo))
                    .toList(),
              ),

            /// === Buttons ===
            if (customer.status == 'Belum Diberikan') ...[
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showConfirmationDialog(context, customer, 'terima'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('TERIMA'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showConfirmationDialog(context, customer, 'tolak'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('TOLAK'),
                    ),
                  ),
                ],
              ),
            ],

            if (customer.status == 'Gagal Diberikan') ...[
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _showConfirmationDialog(context, customer, 'terima'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
                child: Text('UBAH JADI TERIMA'),
              ),
            ],
          ],
        )
    );
  }

  // Widget untuk TTOTTPNo dengan border lingkaran panjang
  Widget _buildTTOttpNoChip(String ttottPNo) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xFF2596be), // Background color #2596be
        borderRadius: BorderRadius.circular(20), // Border lingkaran
        border: Border.all(
          color: Color(0xFF2596be), // Border color sama dengan background
          width: 1,
        ),
      ),
      child: Text(
        ttottPNo,
        style: TextStyle(
          fontSize: 12,
          color: Colors.white, // Text color putih
          fontWeight: FontWeight.w500,
          fontFamily: 'Monospace',
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Sudah Diterima':
        return Colors.green;
      case 'Gagal Diberikan':
        return Colors.red;
      case 'Belum Diberikan':
      default:
        return Colors.orange;
    }
  }

  void _showResultSnackbar(BuildContext context, String action, String customerName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          action == 'terima'
              ? 'Hadiah untuk $customerName berhasil diterima'
              : 'Hadiah untuk $customerName ditolak',
        ),
        backgroundColor: action == 'terima' ? Colors.green : Colors.orange,
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, Customer customer, String action) {
    // Dapatkan semua TTH numbers dari customer
    final tthNumbers = customer.tthDocuments
        .where((doc) => doc.ttottPNo.isNotEmpty)
        .map((doc) => doc.ttottPNo)
        .toList();

    showDialog(
      context: context,
      builder: (context) => GiftConfirmationDialog(
        customerName: customer.name,
        custId: customer.custID,
        tthNumbers: tthNumbers,
        currentStatus: customer.status,
      ),
    );
  }
}