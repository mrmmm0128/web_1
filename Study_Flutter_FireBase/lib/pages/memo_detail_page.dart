import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:study_flutter_firebase/pages/show_history_page.dart';
import 'package:study_flutter_firebase/pages/suggest_next_pay.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:study_flutter_firebase/pages/explain.dart';
import 'package:study_flutter_firebase/pages/privacypolicy.dart';
import 'package:study_flutter_firebase/pages/servicerule.dart';
import 'package:study_flutter_firebase/pages/our_information.dart';
import 'dart:html' as html;

class MemoDetailPage extends StatefulWidget {
  const MemoDetailPage(
      {required this.memoId, required this.collectionName, Key? key})
      : super(key: key);
  final String memoId;
  final String collectionName;

  @override
  _MemoDetailPageState createState() => _MemoDetailPageState();
}

class _MemoDetailPageState extends State<MemoDetailPage> {
  String title = "";
  List<String> participants = [];
  List<TextEditingController> _amountControllers = []; // 金額のテキストフィールド用のコントローラ
  List<TextEditingController> _memoControllers = []; // メモのテキストフィールド用のコントローラ
  Map<String, List<Map<String, dynamic>>> amounts = {}; // 支払履歴を保持するマップ
  List<String> settlementResults = [];
  List<String> currencies = [
    'USD',
    'AED',
    'AFN',
    'ALL',
    'AMD',
    'ANG',
    'AOA',
    'ARS',
    'AUD',
    'AWG',
    'AZN',
    'BAM',
    'BBD',
    'BDT',
    'BGN',
    'BHD',
    'BIF',
    'BMD',
    'BND',
    'BOB',
    'BRL',
    'BSD',
    'BTN',
    'BWP',
    'BYN',
    'BZD',
    'CAD',
    'CDF',
    'CHF',
    'CLP',
    'CNY',
    'COP',
    'CRC',
    'CUP',
    'CVE',
    'CZK',
    'DJF',
    'DKK',
    'DOP',
    'DZD',
    'EGP',
    'ERN',
    'ETB',
    'EUR',
    'FJD',
    'FKP',
    'FOK',
    'GBP',
    'GEL',
    'GGP',
    'GHS',
    'GIP',
    'GMD',
    'GNF',
    'GTQ',
    'GYD',
    'HKD',
    'HNL',
    'HRK',
    'HTG',
    'HUF',
    'IDR',
    'ILS',
    'IMP',
    'INR',
    'IQD',
    'IRR',
    'ISK',
    'JEP',
    'JMD',
    'JOD',
    'JPY',
    'KES',
    'KGS',
    'KHR',
    'KID',
    'KMF',
    'KRW',
    'KWD',
    'KYD',
    'KZT',
    'LAK',
    'LBP',
    'LKR',
    'LRD',
    'LSL',
    'LYD',
    'MAD',
    'MDL',
    'MGA',
    'MKD',
    'MMK',
    'MNT',
    'MOP',
    'MRU',
    'MUR',
    'MVR',
    'MWK',
    'MXN',
    'MYR',
    'MZN',
    'NAD',
    'NGN',
    'NIO',
    'NOK',
    'NPR',
    'NZD',
    'OMR',
    'PAB',
    'PEN',
    'PGK',
    'PHP',
    'PKR',
    'PLN',
    'PYG',
    'QAR',
    'RON',
    'RSD',
    'RUB',
    'RWF',
    'SAR',
    'SBD',
    'SCR',
    'SDG',
    'SEK',
    'SGD',
    'SHP',
    'SLE',
    'SLL',
    'SOS',
    'SRD',
    'SSP',
    'STN',
    'SYP',
    'SZL',
    'THB',
    'TJS',
    'TMT',
    'TND',
    'TOP',
    'TRY',
    'TTD',
    'TVD',
    'TWD',
    'TZS',
    'UAH',
    'UGX',
    'UYU',
    'UZS',
    'VES',
    'VND',
    'VUV',
    'WST',
    'XAF',
    'XCD',
    'XDR',
    'XOF',
    'XPF',
    'YER',
    'ZAR',
    'ZMW',
    'ZWL'
  ];
  List<String?> selectedCurrencies = [];
  final String apiKey = 'YOUR_API_KEY'; // APIキーを入れてください
  List<String> memoEntries = List.filled(100, ""); // メモの内容を保持するリスト
  List<String> selectedParticipants = []; // 選択された参加者のリスト

  @override
  void initState() {
    super.initState();
    _fetchMemoData(); // データを取得
  }

  void _navigateToExplain(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Explain()),
    );
  }

  Future<void> _fetchMemoData() async {
    try {
      DocumentSnapshot memoDoc = await FirebaseFirestore.instance
          .collection(widget.collectionName)
          .doc(widget.memoId)
          .get();

      if (memoDoc.exists) {
        setState(() {
          title = memoDoc['title'] ?? "";
          participants = List<String>.from(memoDoc['participants'] ?? []);
          amounts = Map<String, List<Map<String, dynamic>>>.from(
            memoDoc['amounts']?.map(
                  (key, value) => MapEntry(
                    key,
                    List<Map<String, dynamic>>.from(
                        value.map((entry) => Map<String, dynamic>.from(entry))),
                  ),
                ) ??
                {},
          );
          _amountControllers = List.generate(
              participants.length, (index) => TextEditingController());
          _memoControllers = List.generate(
              participants.length, (index) => TextEditingController());
          // selectedCurrencies に人数分の "JPY" を設定
          selectedCurrencies =
              List.generate(participants.length, (index) => "JPY");
        });
      } else {
        setState(() {
          title = "メモが見つかりません";
          participants = [];
        });
      }
    } catch (e) {
      print("Error fetching memo data: $e");
      setState(() {
        title = "データ取得エラー";
        participants = [];
      });
    }
  }

  Future<double> _convertToJPY(double amount, String? currency) async {
    if (currency == 'JPY') {
      return amount;
    }

    final url =
        'https://v6.exchangerate-api.com/v6/645a1985815f1f802148fe2f/latest/$currency';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final rates = json.decode(response.body)['conversion_rates'];
      if (rates.containsKey('JPY')) {
        double rate = rates['JPY'];
        return amount * rate;
      }
    }
    throw Exception("通貨レートの取得に失敗しました");
  }

  Future<void> saveData() async {
    try {
      DocumentReference memoDocRef = FirebaseFirestore.instance
          .collection(widget.collectionName)
          .doc(widget.memoId);

      for (int i = 0; i < participants.length; i++) {
        String amountText = _amountControllers[i].text;
        double? newAmount = double.tryParse(amountText);

        if (newAmount == null || newAmount == 0) {
          continue;
        }

        String newMemo = memoEntries[i];
        double amountInJPY =
            await _convertToJPY(newAmount, selectedCurrencies[i]);

        if (!amounts.containsKey(participants[i])) {
          amounts[participants[i]] = [];
        }

        amounts[participants[i]]!.add({
          'amount': amountInJPY,
          'originalAmount': newAmount,
          'originalCurrency': selectedCurrencies[i],
          'memo': newMemo,
          'date': Timestamp.now(),
        });

        _amountControllers[i].clear();
      }

      await memoDocRef.update({
        'amounts': amounts,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('データが保存されました')),
      );
    } catch (e) {
      print("Error saving data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('データの保存に失敗しました')),
      );
    }
  }

  void _showHistoryDialog() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return PaymentHistoryPage(
            collectionName: widget.collectionName,
            amounts: amounts, // ここで既存の amounts を渡します
            travelId: widget.memoId, // memoId を渡す
          );
        },
      ),
    );
  }

  void _showSettlementResultsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("清算結果"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: settlementResults.map((result) => Text(result)).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('閉じる'),
            ),
          ],
        );
      },
    );
  }

  void _settlePayments() {
    // 各参加者の合計支払額を計算
    Map<String, double> payMap = {
      for (var entry in amounts.entries)
        entry.key: entry.value
            .fold(0.0, (sum, payment) => sum + (payment['amount'] as double))
    };

    // 清算ロジックを適用
    setState(() {
      settlementResults = seisan(payMap);
    });

    // 清算結果をダイアログで表示
    _showSettlementResultsDialog();
  }

  List<String> seisan(Map<String, double> payMap) {
    int people = payMap.length;
    double sumPay = payMap.values.reduce((a, b) => a + b);
    double aPay = sumPay / people;

    Map<String, double> newPay = {
      for (var entry in payMap.entries) entry.key: entry.value - aPay
    };

    List<String> conceqence = [];

    while (true) {
      double pay = newPay.values.reduce(min);
      List<String> payPeople = newPay.entries
          .where((entry) => entry.value == pay)
          .map((entry) => entry.key)
          .toList();

      double get = newPay.values.reduce(max);
      List<String> getPeople = newPay.entries
          .where((entry) => entry.value == get)
          .map((entry) => entry.key)
          .toList();

      double payment = min(get, pay.abs());

      for (int i = 0; i < min(payPeople.length, getPeople.length); i++) {
        newPay[payPeople[i]] = newPay[payPeople[i]]! + payment;
        newPay[getPeople[i]] = newPay[getPeople[i]]! - payment;
        conceqence
            .add('${payPeople[i]}が${getPeople[i]}に支払い：¥${payment.round()}');
      }

      if (newPay.values.every((value) => (value).abs() < 1e-9)) {
        return conceqence;
      }
    }
  }

  void _showMemoInputDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${participants[index]}のメモ'),
          content: TextField(
            onChanged: (value) {
              setState(() {
                memoEntries[index] = value;
              });
            },
            controller: TextEditingController(text: memoEntries[index]),
            decoration: const InputDecoration(hintText: "メモを入力してください"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('閉じる'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToPrivacyPolicy(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
    );
  }

  // GoogleフォームのURLを開く関数
  void _launchContactForm() {
    html.window.open(
      'https://docs.google.com/forms/d/e/1FAIpQLSfHpmSHm5SBAARgemK39rfeWldmxmLPmfFU0BM1uuUXWYX3Hw/viewform?usp=sf_link',
      '_blank',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(fontFamily: 'Roboto'),
        ),
        backgroundColor: const Color(0xFF75A9D6),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _navigateToExplain(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "メンバー",
                style: TextStyle(fontSize: 30, fontFamily: "Roboto"),
              ),
              const SizedBox(height: 20),
              if (participants.isEmpty)
                const Center(
                  child: Text(
                    "参加者がいません",
                    style: TextStyle(color: Colors.red, fontFamily: "Roboto"),
                  ),
                )
              else
                Column(
                  children: List.generate(participants.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              participants[index],
                              style: const TextStyle(
                                  fontSize: 20, fontFamily: "Roboto"),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Container(
                              width: 100,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.shade100,
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _amountControllers[index],
                                decoration: const InputDecoration(
                                  labelText: '金額',
                                  border: InputBorder.none,
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: DropdownButton<String>(
                                value: selectedCurrencies[index],
                                items: currencies.map((String currency) {
                                  return DropdownMenuItem<String>(
                                    value: currency,
                                    child: Text(currency),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedCurrencies[index] =
                                        newValue ?? "JPY";
                                  });
                                }),
                          ),
                          IconButton(
                            icon: const Icon(Icons.note_add),
                            onPressed: () {
                              _showMemoInputDialog(index);
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              const SizedBox(height: 30),
              Center(
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: ElevatedButton(
                          onPressed: saveData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF75A9D6),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            '保存',
                            style: TextStyle(fontFamily: "Roboto"),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: ElevatedButton(
                          onPressed: _showHistoryDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF75A9D6),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            '履歴を見る',
                            style: TextStyle(fontFamily: "Roboto"),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PaymentSuggestionPage(
                                      collectionName: widget.collectionName,
                                      memoId: widget.memoId)),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF75A9D6),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            '支払提案',
                            style: TextStyle(fontFamily: "Roboto"),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: ElevatedButton(
                          onPressed: _fetchMemoData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF75A9D6),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            '最新情報を取得',
                            style: TextStyle(fontFamily: "Roboto"),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: ElevatedButton(
                          onPressed: _settlePayments,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF75A9D6),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            '清算する',
                            style: TextStyle(
                                fontSize: 18,
                                fontFamily: "Roboto",
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Divider(),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => _navigateToPrivacyPolicy(context),
                child: const Text(
                  'プライバシーポリシー',
                  style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                ),
              ),
              TextButton(
                onPressed: _launchContactForm,
                child: const Text(
                  'お問い合わせ',
                  style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => servicerule(),
                    ),
                  );
                },
                child: const Text(
                  '利用規約',
                  style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AboutUsPage(),
                    ),
                  );
                },
                child: const Text(
                  '運営元情報',
                  style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                ),
              ),
              const Spacer(),
              const SizedBox(height: 200),
            ],
          ),
        ),
      ),
      backgroundColor: const Color(0xFFE0ECF8),
    );
  }
}