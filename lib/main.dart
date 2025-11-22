import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'screens/home_screen.dart';
import 'bloc/customer_bloc/customer_bloc.dart';
import 'bloc/gift_bloc/gift_bloc.dart'; // Import GiftBloc
import 'services/api_service.dart';
import 'config/api_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiConfig.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CustomerBloc>(
          create: (context) => CustomerBloc(
            apiService: ApiService(client: http.Client()),
          )..add(LoadCustomers()),
        ),
        BlocProvider<GiftBloc>( // Tambah GiftBloc
          create: (context) => GiftBloc(
            apiService: ApiService(client: http.Client()),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Customer Gift App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}