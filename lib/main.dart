import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:matrix_edge_website/app.dart';
import 'package:matrix_edge_website/config/firebase_options.dart';
import 'package:matrix_edge_website/config/stripe_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Stripe.publishableKey = stripePublishableKey;

  runApp(MatrixEdgeApp());
}
