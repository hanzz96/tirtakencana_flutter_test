import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/customer_bloc/customer_bloc.dart';

class ShopFilterDialog extends StatelessWidget {
  final List<String> shopNames;
  final String selectedShop;

  const ShopFilterDialog({
    Key? key,
    required this.shopNames,
    required this.selectedShop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Pilih Toko',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            SizedBox(height: 16),

            // Divider
            Divider(height: 1, color: Colors.grey[300]),
            SizedBox(height: 8),

            // List of shops
            ...shopNames.map((shopName) => Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 4),
                  title: Text(
                    shopName,
                    style: TextStyle(
                      fontSize: 16,
                      color: shopName == selectedShop ? Colors.blue[700] : Colors.grey[800],
                    ),
                  ),
                  leading: Radio<String>(
                    value: shopName,
                    groupValue: selectedShop,
                    onChanged: (value) {
                      _applyFilter(context, value!);
                    },
                  ),
                  trailing: shopName == selectedShop
                      ? Icon(Icons.check, color: Colors.blue[700], size: 20)
                      : null,
                  onTap: () {
                    _applyFilter(context, shopName);
                  },
                ),
                Divider(height: 1, color: Colors.grey[200]),
              ],
            )).toList(),

            SizedBox(height: 16),

            // Close Button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'TUTUP',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applyFilter(BuildContext context, String shopName) {
    // Dispatch event to BLoC to filter customers
    context.read<CustomerBloc>().add(FilterCustomersByShop(shopName));

    // Close dialog
    Navigator.pop(context);
  }
}