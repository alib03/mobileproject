import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(CurrencyConverterApp());

class CurrencyConverterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Converter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLogin = true;

  Future<void> authenticate(String endpoint) async {
    final response = await http.post(
      Uri.parse('http://  /currency_converter/$endpoint.php'),
      body: {
        'username': usernameController.text,
        'password': passwordController.text,
      },
    );

    final responseData = json.decode(response.body);
    if (responseData['success']) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt('user_id', responseData['user_id']);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CurrencyConverter()),
      );
    } else {
      // Handle authentication failure
      print(responseData['error']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLogin ? 'Login' : 'Register'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => authenticate(isLogin ? 'login' : 'register'),
              child: Text(isLogin ? 'Login' : 'Register'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  isLogin = !isLogin;
                });
              },
              child: Text(isLogin ? 'Create an account' : 'Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class CurrencyConverter extends StatefulWidget {
  @override
  _CurrencyConverterState createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<CurrencyConverter> {
  String fromCurrency = 'USD';
  String toCurrency = 'EUR';
  TextEditingController amountController = TextEditingController();
  String convertedAmount = '';
  List<Map<String, dynamic>> conversionHistory = [];

  final Map<String, double> exchangeRates = {
    'USDEUR': 1.08461,
    'USDLBP': 89400.0,
    'EURLBP': 97101.6,
    'EURUSD': 1 / 1.08461,
    'LBPUSD': 1 / 89400.0,
    'LBPEUR': 1 / 97101.6,
  };

  final Map<String, String> currencyFlags = {
    'USD': 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a9/Flag_of_the_United_States_%28DoS_ECA_Color_Standard%29.svg/640px-Flag_of_the_United_States_%28DoS_ECA_Color_Standard%29.svg.png',
    'EUR': 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b7/Flag_of_Europe.svg/2560px-Flag_of_Europe.svg.png',
    'LBP': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQO4xLf-Is-6NHsd4bQjqvEiepuN2SZgfHLhXN84cbsnkcxM_wAycO1NHXA2Ekp8IhHMTk&usqp=CAU',
  };

  String formatAmount(String currency, double amount) {
    if (currency == 'LBP') {
      return amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+$)'),
            (Match m) => '${m[1]},',
      );
    } else {
      return amount.toStringAsFixed(2);
    }
  }

  Future<void> convertCurrency() async {
    double amount = double.parse(amountController.text);
    double rate = exchangeRates['$fromCurrency$toCurrency'] ?? 1.0;
    double result = amount * rate;

    setState(() {
      convertedAmount = formatAmount(toCurrency, result);
      conversionHistory.add({
        'from': fromCurrency,
        'to': toCurrency,
        'amount': amount,
        'result': result,
      });
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');

    if (userId != null) {
      await http.post(
        Uri.parse('http://  /currency_converter//store_history.php'),
        body: {
          'user_id': userId.toString(),
          'from_currency': fromCurrency,
          'to_currency': toCurrency,
          'amount': amount.toString(),
          'result': result.toString(),
        },
      );
    }
  }

  void clearHistory() {
    setState(() {
      conversionHistory.clear();
    });
  }

  Future<void> navigateToHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');

    if (userId != null) {
      final response = await http.get(
        Uri.parse('http://  /currency_converter/get_history.php?user_id=$userId'),
      );

      final List<dynamic> fetchedHistory = json.decode(response.body);
      setState(() {
        conversionHistory = fetchedHistory.map((e) => e as Map<String, dynamic>).toList();
      });
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConversionHistory(conversionHistory: conversionHistory),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Currency Converter'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: 'Amount',
              ),
              keyboardType: TextInputType.number,
            ),
            DropdownButton<String>(
              value: fromCurrency,
              onChanged: (String? newValue) {
                setState(() {
                  fromCurrency = newValue!;
                });
              },
              items: currencyFlags.keys
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: <Widget>[
                      Image.network(
                        currencyFlags[value]!,
                        width: 30,
                        height: 20,
                      ),
                      SizedBox(width: 10),
                      Text(value),
                    ],
                  ),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              value: toCurrency,
              onChanged: (String? newValue) {
                setState(() {
                  toCurrency = newValue!;
                });
              },
              items: currencyFlags.keys
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: <Widget>[
                      Image.network(
                        currencyFlags[value]!,
                        width: 30,
                        height: 20,
                      ),
                      SizedBox(width: 10),
                      Text(value),
                    ],
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: convertCurrency,
              child: Text('Convert'),
            ),
            SizedBox(height: 20),
            Text(
              'Converted Amount: $convertedAmount',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: navigateToHistory,
              child: Text('View History'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: clearHistory,
              child: Text('Clear History'),
            ),
          ],
        ),
      ),
    );
  }
}

class ConversionHistory extends StatelessWidget {
  final List<Map<String, dynamic>> conversionHistory;

  ConversionHistory({required this.conversionHistory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conversion History'),
      ),
      body: ListView.builder(
        itemCount: conversionHistory.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> conversion = conversionHistory[index];
          return ListTile(
            title: Text(
              '${conversion['amount']} ${conversion['from']} = ${conversion['result']} ${conversion['to']}',
            ),
          );
        },
      ),
    );
  }
}
