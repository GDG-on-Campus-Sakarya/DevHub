import 'package:flutter/material.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase yapılandırıldığında Firebase.initializeApp(...) çağrısını buraya ekleyin.
  runApp(const DevHubApp());
}
