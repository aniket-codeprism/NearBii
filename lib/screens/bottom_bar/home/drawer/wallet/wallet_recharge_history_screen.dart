import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/services/getPymentHistory/getPaymentHistory.dart';

class WalletRechargeHistoryScreen extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final bool fromDate;
  const WalletRechargeHistoryScreen({
    Key? key,
    required this.startDate,
    required this.endDate,
    required this.fromDate,
  }) : super(key: key);

  @override
  State<WalletRechargeHistoryScreen> createState() =>
      _WalletRechargeHistoryScreenState();
}

class _WalletRechargeHistoryScreenState
    extends State<WalletRechargeHistoryScreen> {
  final months = ['March 2022', 'February 2022', 'January 2022'];

  final uid = FirebaseAuth.instance.currentUser!.uid.substring(0, 20);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        leading: Row(
          children: [
            SizedBox(
              width: 35,
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.arrow_back_ios,
                size: 20,
                color: kLoadingScreenTextColor,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Wallet Recharge History label
              Text(
                widget.fromDate ? "Statement" : "Wallet History",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: kLoadingScreenTextColor,
                ),
              ),

              Text(
                widget.startDate.toString().split(" ").first +
                    " to " +
                    widget.endDate.toString().split(" ").first,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 20,
                  color: kLoadingScreenTextColor,
                ),
              ),

              !widget.fromDate
                  ? getPaymentHistory(
                      context, uid, widget.startDate, widget.endDate)
                  : getPaymentHistoryByDate(
                      context, uid, widget.startDate, widget.endDate),
            ],
          ),
        ),
      ),
    );
  }
}
