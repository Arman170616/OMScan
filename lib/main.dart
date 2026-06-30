import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'providers/language_provider.dart';
import 'screens/scanner_screen.dart';
import 'theme/app_theme.dart';
import 'utils/printer_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppTheme.bgDark1,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const OMScanApp());
}

class OMScanApp extends StatelessWidget {
  const OMScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => PrinterState()),
        ChangeNotifierProvider(create: (_) => AppLanguage()),
      ],
      child: MaterialApp(
        title: 'OMScan',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (ctx, nav) => Consumer<AppLanguage>(
          builder: (_, lang, _) => Directionality(
            textDirection: lang.direction,
            child: nav!,
          ),
        ),
        home: const ScannerScreen(),
      ),
    );
  }
}
