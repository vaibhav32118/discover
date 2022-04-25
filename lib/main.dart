import 'package:discover/providers/cluster.dart';
import 'package:discover/providers/get_location.dart';
import 'package:discover/screens/app_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import './providers/auth.dart';
import './screens/splash_screen.dart';
import './screens/auth_screen.dart';
import './providers/great_places.dart';
import './screens/add_place_screen.dart';
import './screens/place_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx1) => Auth(),
        ),
        ChangeNotifierProvider(
          create: (ctx2) => GreatPlaces(),
        ),
        ChangeNotifierProvider(
          create: (ctx3) => LocationProvider(),
        ),
        ChangeNotifierProvider(
          create: (ctx4) => SignificantPlaces(),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) {
          return MaterialApp(
            title: 'Discover App',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
                primarySwatch: Colors.purple,
                accentColor: Colors.deepOrange,
                visualDensity: VisualDensity.adaptivePlatformDensity),
            home: auth.isAuth
                ? const HomeScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx, authResultSnapshot) =>
                        authResultSnapshot.connectionState ==
                                ConnectionState.waiting
                            ? SplashScreen()
                            : const AuthScreen(),
                  ),
            routes: {
              AddPlaceScreen.routeName: (ctx) => AddPlaceScreen(),
              PlaceDetailScreen.routeName: (ctx) => PlaceDetailScreen(),
            },
          );
        },
      ),
    );
  }
}
