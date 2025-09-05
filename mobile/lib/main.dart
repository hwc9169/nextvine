import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'view/splash_screen.dart';
import 'view/home_screen.dart';
import 'view/camera_screen.dart';
import 'view_model/angle_view_model.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: "scoliosis",
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const ProviderApp());
}

class ProviderApp extends StatelessWidget {
  const ProviderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AngleViewModel(),
      child: MaterialApp(
        title: 'NextVine',
        theme: CustomeTheme.theme,
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => SplashScreen(),
          '/': (context) => HomeScreen(),
          '/camera': (context) => CameraScreen(),
        },
      ),
    );
  }
}
