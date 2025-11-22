import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/customer_bloc/customer_bloc.dart';
import '../models/failed_reason_model.dart';

class GiftConfirmationDialog extends StatefulWidget {
  final String customerName;
  final String custId;
  final List<String> tthNumbers;
  final String currentStatus;

  const GiftConfirmationDialog({
    Key? key,
    required this.customerName,
    required this.custId,
    required this.tthNumbers,
    required this.currentStatus,
  }) : super(key: key);

  @override
  _GiftConfirmationDialogState createState() => _GiftConfirmationDialogState();
}

class _GiftConfirmationDialogState extends State<GiftConfirmationDialog> {
  String? _selectedReason;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<CustomerBloc, CustomerState>(
      listener: (context, state) {
        // Handle state changes dari BLoC
        if (state is CustomerLoaded && !state.isUpdating) {
          // Jika update selesai dan tidak error, close dialog dan show success
          if (_isSubmitting) {
            Navigator.pop(context);
            _showSuccessSnackbar(
                widget.currentStatus == 'Belum Diberikan'
                    ? 'Hadiah berhasil diterima'
                    : 'Status berhasil diubah menjadi terima'
            );
          }
        }

        if (state is CustomerError) {
          // Jika ada error, show error message
          setState(() {
            _isSubmitting = false;
          });
          _showErrorSnackbar('Gagal memproses: ${state.message}');
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 16),
              _buildContent(),
              SizedBox(height: 16),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.card_giftcard, color: Colors.orange, size: 24),
        SizedBox(width: 8),
        Text(
          'Konfirmasi Hadiah',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ingin terima hadiah?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Untuk: ${widget.customerName}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Dokumen: ${widget.tthNumbers.join(', ')}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
            fontFamily: 'Monospace',
          ),
        ),

        if (widget.currentStatus == 'Gagal Diberikan') ...[
          SizedBox(height: 16),
          Text(
            'Ubah status menjadi Terima:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.green,
            ),
          ),
        ]
        else if (widget.currentStatus == 'Belum Diberikan') ...[
          SizedBox(height: 16),
          Text(
            'Pilih alasan penolakan:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(6),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedReason,
                isExpanded: true,
                hint: Text('Pilih alasan...'),
                items: FailedReason.reasons.map((reason) {
                  return DropdownMenuItem<String>(
                    value: reason.value,
                    child: Text(reason.label),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedReason = newValue;
                  });
                },
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    return BlocBuilder<CustomerBloc, CustomerState>(
      builder: (context, state) {
        final isUpdating = state is CustomerLoaded && state.isUpdating;

        return Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: (isUpdating || _isSubmitting) ? null : () => Navigator.pop(context),
                child: Text('BATAL'),
              ),
            ),
            SizedBox(width: 8),

            if (widget.currentStatus != 'Sudah Diterima') ...[
              Expanded(
                child: ElevatedButton(
                  onPressed: (isUpdating || _isSubmitting) ? null : _handleAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: (isUpdating || _isSubmitting)
                      ? SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : Text('TERIMA'),
                ),
              ),
              SizedBox(width: 8),
            ],

            if (widget.currentStatus == 'Belum Diberikan') ...[
              Expanded(
                child: ElevatedButton(
                  onPressed: (isUpdating || _isSubmitting) ? null : _handleReject,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: (isUpdating || _isSubmitting)
                      ? SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : Text('TOLAK'),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  void _handleAccept() {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    // Dispatch event ke BLoC - response akan dihandle oleh listener
    context.read<CustomerBloc>().add(ConfirmGiftAccept(
      custId: widget.custId,
      tthNumbers: widget.tthNumbers,
    ));
  }

  void _handleReject() {
    if (_isSubmitting) return;

    if (_selectedReason == null) {
      _showErrorSnackbar('Harap pilih alasan penolakan');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Dispatch event ke BLoC - response akan dihandle oleh listener
    context.read<CustomerBloc>().add(ConfirmGiftReject(
      custId: widget.custId,
      tthNumbers: widget.tthNumbers,
      failedReason: _selectedReason!,
    ));
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}