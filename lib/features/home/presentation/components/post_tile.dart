import 'dart:convert';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:matrix_edge_website/config/stripe_constants.dart';
import 'package:matrix_edge_website/features/auth/domain/entities/user.dart';
import 'package:matrix_edge_website/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:matrix_edge_website/features/post/domain/entities/post.dart';
import 'package:matrix_edge_website/features/post/presentation/cubits/post_cubit.dart';
import 'package:matrix_edge_website/features/profile/domain/entities/user_profile.dart';
import 'package:matrix_edge_website/features/profile/presentation/cubit/user_profile_cubit.dart';
import 'package:http/http.dart' as http;

class PostTile extends StatefulWidget {
  final Post post;
  final void Function()? onDeletePressed;

  const PostTile({
    super.key,
    required this.post,
    required this.onDeletePressed,
  });

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  late final postCubit = context.read<PostCubit>();
  late final profileCubit = context.read<UserProfileCubit>();

  bool isOwnPost = false;

  MatrixEdgeUser? currentUser;

  UserProfile? userProfile;

  Map<String, dynamic>? paymentIntent;

  bool isLoading = false; // For UX during payment

  Future<Map<String, dynamic>?> createPaymentIntent(
    String amount,
    String currency,
  ) async {
    try {
      var secretKey = stripeSecretKey;

      // Parse amount as double, multiply by 100 for cents, and convert to int
      final parsedAmount = double.tryParse(amount);
      if (parsedAmount == null) {
        throw FormatException('Invalid amount format: $amount');
      }
      final amountInCents = (parsedAmount * 100).toInt();

      Map<String, dynamic> body = {
        "amount": amountInCents.toString(),
        "currency": currency,
        "payment_method_types[]": "card",
      };

      var response = await http.post(
        Uri.parse("https://api.stripe.com/v1/payment_intents"),
        headers: {
          "Authorization": "Bearer $secretKey",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: body,
      );

      return jsonDecode(response.body);
    } catch (error) {
      print("Error creating payment intent: $error");
      return null;
    }
  }

  // Mobile-specific: Use Payment Sheet
  Future<void> makeMobilePayment(String amount) async {
    final paymentIntent = await createPaymentIntent(amount, "usd");
    if (paymentIntent == null) return;

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: paymentIntent["client_secret"],
        merchantDisplayName: "Test Payment",
      ),
    );

    try {
      await Stripe.instance.presentPaymentSheet();
      if (!mounted) return; // Guard against async context issues
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Payment successful!")));
      // Optional: Refresh posts or trigger cubit event
      // postCubit.refreshPosts();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Payment failed: $error")));
    }
  }

  // Web-specific: Use CardFormField and confirm with PaymentMethodParams
  Future<void> makeWebPayment(String amount) async {
    // final paymentIntent = await createPaymentIntent(amount, "usd");
    // if (paymentIntent == null) return;

    // final controller = CardFormEditController();

    // if (!mounted) return; // Early guard

    // showDialog(
    //   context: context,
    //   builder: (context) => AlertDialog(
    //     title: Text("Enter Card Details for \$$amount"),
    //     content: Column(
    //       mainAxisSize: MainAxisSize.min,
    //       children: [
    //         CardFormField(controller: controller),
    //         if (isLoading) CircularProgressIndicator(),
    //       ],
    //     ),
    //     actions: [
    //       TextButton(
    //         onPressed: () => Navigator.of(context).pop(),
    //         child: Text("Cancel"),
    //       ),
    //       TextButton(
    //         onPressed: () async {
    //           if (!controller.details.complete) {
    //             if (!mounted) return;
    //             ScaffoldMessenger.of(context).showSnackBar(
    //               SnackBar(content: Text("Please complete card details")),
    //             );
    //             return;
    //           }
    //           setState(() => isLoading = true);
    //           try {
    //             // Confirm payment directly with card form data
    //             await Stripe.instance.confirmPayment(
    //               paymentIntentClientSecret: paymentIntent["client_secret"],
    //               params: PaymentMethodParams.cardFromForm(
    //                 paymentMethodData: PaymentMethodData(
    //                   billingDetails: BillingDetails(),
    //                 ),
    //               ),
    //             );

    //             if (!mounted) return;
    //             ScaffoldMessenger.of(
    //               context,
    //             ).showSnackBar(SnackBar(content: Text("Payment successful!")));
    //             // Optional: Refresh posts or trigger cubit event
    //             // postCubit.refreshPosts();
    //           } catch (error) {
    //             if (!mounted) return;
    //             ScaffoldMessenger.of(context).showSnackBar(
    //               SnackBar(content: Text("Payment failed: $error")),
    //             );
    //           } finally {
    //             if (mounted) {
    //               setState(() => isLoading = false);
    //               Navigator.of(context).pop();
    //             }
    //           }
    //         },
    //         child: Text("Pay"),
    //       ),
    //     ],
    //   ),
    // );
  }

  Future<void> makePayment(String amount) async {
    if (kIsWeb) {
      await makeWebPayment(amount);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Web payment not supported yet!")));
    } else {
      await makeMobilePayment(amount);
    }
  }

  @override
  void initState() {
    super.initState();

    getCurrentUser();
    fetchPostUser();
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    final currentUser = authCubit.currentUser;
    isOwnPost = widget.post.userId == currentUser!.uid;
  }

  Future<void> fetchPostUser() async {
    final fetchedUser = await profileCubit.getUserProfile(widget.post.userId);
    if (fetchedUser != null) {
      setState(() {
        userProfile = fetchedUser;
      });
    }
  }

  void showOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Post?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel"),
          ),
          TextButton(onPressed: widget.onDeletePressed, child: Text("Delete")),
        ],
      ),
    );
  }

  // Confirm payment before proceeding
  void confirmAndPay(String amount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Payment of \$$amount?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              makePayment(amount);
            },
            child: Text("Pay"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: GestureDetector(
          onTap: () {
            confirmAndPay(widget.post.amount);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                userProfile?.profileImageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: userProfile!.profileImageUrl,
                        imageBuilder: (context, imageProvider) => Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      )
                    : const Icon(Icons.person),

                const SizedBox(width: 10),

                Text(
                  "${widget.post.userName}: ",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),

                const SizedBox(width: 10),

                Flexible(
                  child: Text(
                    "Information (preview):\n${widget.post.text.substring(0, min(widget.post.text.length, 20))}",
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ),

                Spacer(),

                if (isOwnPost)
                  IconButton(onPressed: showOptions, icon: Icon(Icons.delete)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
