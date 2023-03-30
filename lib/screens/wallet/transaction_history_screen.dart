import 'package:flutter/material.dart';
import 'package:nearbii/constants.dart';
import 'package:nearbii/screens/wallet/wallet_recharge_history_screen.dart';
import 'package:month_year_picker/month_year_picker.dart';

class TransactionHistoryScreen extends StatefulWidget {
  final bool trans;
  const TransactionHistoryScreen(this.trans, {Key? key}) : super(key: key);

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  TextEditingController startDate = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Row(
          children: [
            const SizedBox(
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
              Text(
                widget.trans ? "Transaction History" : "Wallet History",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: kLoadingScreenTextColor,
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: kHomeScreenServicesContainerColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //start date label
                      Container(
                        margin: const EdgeInsets.only(top: 20),
                        child: TextField(
                            controller: startDate,
                            decoration: InputDecoration(
                              suffixIcon: InkWell(
                                  onTap: () async {
                                    final selected = await showMonthYearPicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2019),
                                      lastDate: DateTime.now(),
                                    );
                                    if (selected != null) {
                                      print(
                                          selected); //pickedDate output format => 2021-03-10 00:00:00.000

                                      setState(() {
                                        startDate.text = selected.toString();
                                      }); //formatted date output using intl package =>  2021-03-16
                                    } else {
                                      print("Date is not selected");
                                    }
                                  },
                                  child: const Icon(Icons.calendar_today)),
                              hintText: "Event Start Date *",
                              hintStyle: const TextStyle(
                                  color: Color.fromARGB(255, 203, 207, 207)),
                              enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                color: Color.fromARGB(173, 125, 209, 248),
                              )),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Color.fromARGB(173, 125, 209, 248),
                                    width: 1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Color.fromARGB(173, 125, 209, 248),
                                    width: 1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            )),
                      ),
                      const SizedBox(
                        height: 30,
                      ),

                      //button
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => WalletRechargeHistoryScreen(
                                  startDate: DateTime.parse(startDate.text),
                                  endDate: DateTime.now(),
                                  fromDate: widget.trans),
                            ),
                          ),
                          child: Container(
                            height: 40,
                            width: 173,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: kSignInContainerColor,
                            ),
                            child: const Center(
                              child: Text(
                                "Get Statement",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
