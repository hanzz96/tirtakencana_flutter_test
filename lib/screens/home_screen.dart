import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/customer_bloc/customer_bloc.dart';
import '../widgets/customer_card.dart';
import '../widgets/total_gift_card.dart';
import '../widgets/base_url_settings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedShop;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildSettingsBar(),
            // Header dengan dropdown
            _buildHeader(context),
            // Content area
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsBar() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end, // Posisikan ke kanan
        children: [
          // Tombol Settings
          IconButton(
            icon: Icon(Icons.settings, color: Colors.grey[600], size: 22),
            onPressed: () => _showSettingsDialog(context),
            tooltip: 'Pengaturan API',
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return BlocBuilder<CustomerBloc, CustomerState>(
      builder: (context, state) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
          ),
          child: Row(
            children: [
              // ⬅️ Dropdown flexible
              Expanded(
                child: _buildShopDropdown(context, state),
              ),

              SizedBox(width: 12),

              // ➡️ Total Gift Card dengan lebar menyesuaikan
              IntrinsicWidth(
                child: TotalGiftCard(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShopDropdown(BuildContext context, CustomerState state) {
    List<String> shopOptions = ['Semua Toko'];

    if (state is CustomerLoaded) {
      shopOptions.addAll(state.customers.map((c) => c.name).toSet().toList());
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedShop ?? 'Semua Toko',
          isExpanded: true, // make it fill Expanded
          icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          items: shopOptions.map((String shop) {
            return DropdownMenuItem<String>(
              value: shop,
              child: Text(
                shop,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedShop = newValue;
            });
            context.read<CustomerBloc>().add(FilterCustomersByShop(newValue!));
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    return BlocBuilder<CustomerBloc, CustomerState>(
      builder: (context, state) {
        if (state is CustomerLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Memuat data...',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        if (state is CustomerError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  state.message,
                  style: TextStyle(fontSize: 16, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<CustomerBloc>().add(LoadCustomers());
                  },
                  child: Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        if (state is CustomerLoaded) {
          if (state.filteredCustomers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.store_mall_directory, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Tidak ada customer ditemukan',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<CustomerBloc>().add(RefreshCustomers());
            },
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: state.filteredCustomers.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: Colors.grey[300],
                thickness: 1,
              ),
              itemBuilder: (context, index) {
                final customer = state.filteredCustomers[index];
                return CustomerCard(customer: customer);
              },
            ),
          );
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => BaseUrlSettings(showAsDialog: true),
    );
  }
}