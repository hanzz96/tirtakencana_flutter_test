import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/gift_bloc/gift_bloc.dart';
import '../models/gift_summary_model.dart';

class GiftSummaryModal extends StatelessWidget {
  const GiftSummaryModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        color: Colors.white,
        constraints: BoxConstraints(maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header - Background putih
            _buildHeader(context),
            // Content
            Expanded(
              child: _buildContent(),
            ),
            // Footer dengan total
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, // Background putih
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.card_giftcard, color: Colors.orange, size: 24), // Icon orange
          SizedBox(width: 12),
          Text(
            'Total Hadiah',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87, // Text hitam
            ),
          ),
          Spacer(),
          // Tombol X dengan border lingkaran hijau
          Container(
            decoration: BoxDecoration(
              color: Colors.green, // Background hijau
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white, size: 18),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.all(4),
              constraints: BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return BlocBuilder<GiftBloc, GiftState>(
      builder: (context, state) {
        if (state is GiftLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Memuat data hadiah...'),
              ],
            ),
          );
        }

        if (state is GiftError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<GiftBloc>().add(LoadGiftSummary());
                  },
                  child: Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        if (state is GiftLoaded) {
          if (state.gifts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.card_giftcard, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Tidak ada data hadiah'),
                ],
              ),
            );
          }

          return Container(
            color: Colors.white,
            child: ListView.builder(
              // padding: EdgeInsets.all(16),
              itemCount: state.gifts.length,
              itemBuilder: (context, index) {
                final gift = state.gifts[index];
                return _buildGiftItem(gift, index);
              },
            ),
          );

        }

        // Initial state - load data
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<GiftBloc>().add(LoadGiftSummary());
        });

        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildGiftItem(GiftSummary gift, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      color: Colors.white,
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          // Number badge - Tetap ada
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          // Gift info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gift.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          // Total
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${gift.total}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[800],
                ),
              ),
              SizedBox(width: 6),
              Text(
                gift.unit,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return BlocBuilder<GiftBloc, GiftState>(
      builder: (context, state) {
        if (state is GiftLoaded) {
          final totalQuantity = state.gifts.fold(0, (sum, gift) => sum + gift.total);

          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                top: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end, // Posisikan ke kanan
              children: [
                SizedBox(width: 4),
                Text(
                  '$totalQuantity Buah',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                  ),
                ),
              ],
            ),
          );
        }

        return Container();
      },
    );
  }
}