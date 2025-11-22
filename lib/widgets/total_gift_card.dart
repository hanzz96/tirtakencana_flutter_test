import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'gift_summary_modal.dart';
import '../bloc/gift_bloc/gift_bloc.dart';

class TotalGiftCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showGiftSummaryModal(context);
      },
      child: IntrinsicWidth(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.card_giftcard, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                'Total Hadiah',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios,
                  color: Colors.white, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  void _showGiftSummaryModal(BuildContext context) {
    context.read<GiftBloc>().add(LoadGiftSummary());
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => GiftSummaryModal(),
    );
  }
}
