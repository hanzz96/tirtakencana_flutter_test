import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/api_service.dart';
import '../bloc/customer_bloc/customer_bloc.dart';

class BaseUrlSettings extends StatefulWidget {
  final bool showAsDialog;

  const BaseUrlSettings({Key? key, this.showAsDialog = false}) : super(key: key);

  @override
  _BaseUrlSettingsState createState() => _BaseUrlSettingsState();
}

class _BaseUrlSettingsState extends State<BaseUrlSettings> {
  final TextEditingController _urlController = TextEditingController();
  bool _isTesting = false;
  bool _isValid = false;
  String _testResult = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentUrl();
  }

  void _loadCurrentUrl() async {
    _urlController.text = ApiConfig.baseUrl;
    _validateUrl(_urlController.text);
  }

  void _validateUrl(String url) {
    final uri = Uri.tryParse(url);
    setState(() {
      _isValid = uri != null && uri.isAbsolute;
    });
  }

  Future<void> _testConnection() async {
    if (!_isValid) return;

    setState(() {
      _isTesting = true;
      _testResult = '';
    });

    try {
      final service = ApiService(client: http.Client());
      final isConnected = await service.testConnection();

      setState(() {
        _testResult = isConnected ? '✅ Connection Successful!' : '❌ Connection Failed';
      });
    } catch (e) {
      setState(() {
        _testResult = '❌ Error: $e';
      });
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  Future<void> _saveBaseUrl() async {
    if (!_isValid) return;

    final newUrl = _urlController.text.trim();
    ApiConfig.baseUrl = newUrl;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Base URL updated successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    context.read<CustomerBloc>().add(LoadCustomers());

    if (widget.showAsDialog) {
      Navigator.of(context).pop();
    }
  }

  void _resetToDefault() {
    _urlController.text = 'http://10.0.2.2:8000/api/v1';
    _validateUrl(_urlController.text);
  }

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Important: use min
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'API Configuration',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          SizedBox(height: 16),

          Text(
            'Base URL',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),

          TextField(
            controller: _urlController,
            decoration: InputDecoration(
              hintText: 'Enter API base URL...',
              border: OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                onPressed: () => _urlController.clear(),
              ),
              errorText: _isValid ? null : 'Please enter a valid URL',
            ),
            onChanged: _validateUrl,
          ),
          SizedBox(height: 8),

          // Common URLs - Make this section more compact
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Select:',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  _buildUrlChip('http://192.168.100.6:8000'),
                  _buildUrlChip('http://localhost:8000'),
                  _buildUrlChip('https://your-domain.com'),
                ],
              ),
            ],
          ),
          SizedBox(height: 12),

          // Test Result
          if (_testResult.isNotEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _testResult.contains('✅') ? Colors.green[50] : Colors.red[50],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _testResult.contains('✅') ? Colors.green : Colors.red,
                ),
              ),
              child: Text(
                _testResult,
                style: TextStyle(
                  fontSize: 12,
                  color: _testResult.contains('✅') ? Colors.green[800] : Colors.red[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          SizedBox(height: 12),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isTesting ? null : _testConnection,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: _isTesting
                      ? SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : Text(
                    'TEST',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isValid ? _saveBaseUrl : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'SAVE',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 8),

          Center(
            child: TextButton(
              onPressed: _resetToDefault,
              child: Text(
                'Reset to Default',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (widget.showAsDialog) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SingleChildScrollView( // ADD THIS - Makes dialog scrollable
          child: content,
        ),
      );
    } else {
      return SingleChildScrollView( // ADD THIS for non-dialog usage
        child: content,
      );
    }
  }

  Widget _buildUrlChip(String baseUrl) {
    final fullUrl = '$baseUrl/api/v1';
    return GestureDetector(
      onTap: () {
        _urlController.text = fullUrl;
        _validateUrl(fullUrl);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: Text(
          baseUrl,
          style: TextStyle(
            fontSize: 10,
            color: Colors.blue[700],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}