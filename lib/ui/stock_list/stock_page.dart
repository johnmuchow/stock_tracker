import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:stock_tracker/model/stock.dart';
import 'package:stock_tracker/ui/stock_list/stock_card.dart';
import 'package:stock_tracker/auth/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//------------------------------------------------------
//
//------------------------------------------------------
class StockPage extends StatefulWidget {
  StockPage({this.onSuccessfulLogout});

  // Callback to root_page upon successful logout.
  final VoidCallback onSuccessfulLogout;

  @override
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  //------------------------------------------------------
  //
  //------------------------------------------------------
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    String user = AuthProvider.of(context).baseAuth.userId();

    // Get quotes from remote API
    refreshStockQuotesForUser(user);
  }

  //------------------------------------------------------
  // Build widget.
  //------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    String _user = AuthProvider.of(context).baseAuth.userId();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[900],
        title: Text('Stock Tracker'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddNewStockSymbolForm()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder(

          // For the current user, get data
          stream: Firestore.instance.collection(_user).snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData || _user == null)
              return Center(child: CircularProgressIndicator());
            else
              return ProcessFirestoreDocuments(documents: snapshot.data.documents);
          }),
      drawer: sideDrawer(),
    );
  }

  //------------------------------------------------------
  // Firebase logout and callback to root_page.
  //------------------------------------------------------
  void _signout() async {
    try {
      AuthProvider.of(context).baseAuth.signOut();
      widget.onSuccessfulLogout();
    } catch (e) {
      print(e);
    }
  }

  //------------------------------------------------------
  // Drawer for logout option.
  //------------------------------------------------------
  Drawer sideDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
                child: Text('Stock Tracker',
                    style:
                        TextStyle(color: Colors.grey[50], fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              
              Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 20.0),
                child: Text('Version 1.0.0',
                      style:
                          TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              
              ListTile(
                title: Text('Logout', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                leading: Icon(Icons.exit_to_app),
                onTap: () {
                  _signout();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

//------------------------------------------------------
// Called as part of Firebase StreamBuilder with list
// of documents.
//------------------------------------------------------
class ProcessFirestoreDocuments extends StatelessWidget {
  final List<DocumentSnapshot> documents;

  ProcessFirestoreDocuments({this.documents});

  String _user;

  @override
  Widget build(BuildContext context) {
    _user = AuthProvider.of(context).baseAuth.userId();

    //------------------------------------------------------
    // // No documents (stocks) for the current user.
    //------------------------------------------------------
    if (documents.length == 0) {
      return Container(
        height: 130.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Card(
                color: Theme.of(context).cardColor,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 8.0,
                    bottom: 8.0,
                    left: 10.0,
                    right: 10.0,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.warning),
                    title: const Text(
                      'You currently have no stock symbols to display. Tap "+" option in the upper right to add a new symbol.',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {},
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      //------------------------------------------------------
      // Build list of Stock objects from document(s).
      //------------------------------------------------------
      var stockList = <Stock>[];
      documents.forEach((d) {
        stockList.add(Stock(
            d.data['stock']['companyName'],
            d.data['stock']['symbol'],
            d.data['stock']['latestPrice'],
            d.data['stock']['low'],
            d.data['stock']['high'],
            d.data['stock']['week52High'],
            d.data['stock']['change'],
            d.data['stock']['changePercent'],
            d.data['stock']['peRatio'],
            d.data['stock']['previousClose']));
      });

      return RefreshIndicator(
          displacement: 3.0,
          child: ListView.builder(
            itemCount: stockList.length,
            itemBuilder: (context, index) {
              // Unique value to identify each row.
              final item = stockList[index].hashCode.toString();

              return Dismissible(
                child: StockCard(
                  stockList[index],
                ),
                key: Key(item),
                background: Container(color: Colors.red[600]),
                onDismissed: (direction) {
                  removeStockSymbolFromFirebase(_user, documents[index]);
                },
              );
            },
          ),
          onRefresh: () {
            return new Future.delayed(const Duration(seconds: 2), () {
              _processRefresh();
            });
          });
    }
  }

  //------------------------------------------------------
  // Pull-to-refresh, query API and update all quotes.
  //------------------------------------------------------
  Future<Null> _processRefresh() async {
    return (refreshStockQuotesForUser(_user));
  }
}

//------------------------------------------------------
// Form to add new stock symbols.
//------------------------------------------------------
class AddNewStockSymbolForm extends StatefulWidget {
  @override
  _AddNewStockSymbolForm createState() => _AddNewStockSymbolForm();
}

class _AddNewStockSymbolForm extends State<AddNewStockSymbolForm> {
  bool _verifyingStockSymbolExists = false;

  // To facilitate showing snackbar messages.
  BuildContext _scaffoldContext;

  // Get data from TextFormField.
  var _stockSymbolController = TextEditingController();

  // The authenticated user, needed for Firebase.
  String _user;

  //------------------------------------------------------
  // When button is pressed, verify stock symbol is valid
  // and add to Firebase.
  //------------------------------------------------------
  void buttonPressedHandler() {
    setState(() {
      _verifyingStockSymbolExists = true;
    });

    // Call API to verify if user entered a valid stock symbol.
    verifyIfStockSymbolIsValid(_stockSymbolController.text).then((result) {
      // If symbol is valid, we're done.
      if (result != null) {
        // Ensure progress indicator is shown for at least 2 seconds.
        // Pass in user and stock symbol entered.
        new Future.delayed(const Duration(seconds: 2), () {
          addStockSymbolToFirebase(_user, result);
          Navigator.pop(context);
        });
      } else {
        // Ensure progress indicator is shown for at least 2 seconds.
        // (see onPressed in RaisedButton).
        new Future.delayed(const Duration(seconds: 2), () {
          setState(() {
            _verifyingStockSymbolExists = false;

            // Use the scaffold context saved previously.
            Scaffold.of(_scaffoldContext).showSnackBar(
              new SnackBar(
                backgroundColor: Colors.blueGrey[50],
                content: Text('Unknown stock symbol. Please try again.',
                    style: TextStyle(color: Colors.blueGrey[700])),
              ),
            );
          });
        });
      }
    });
  }

  //------------------------------------------------------
  // Build widget.
  //------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    
    // The authenticated user, needed for Firebase.
    _user = AuthProvider.of(context).baseAuth.userId();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[900],
        title: Text("Add New Stock Symbol"),
      ),
      body: Builder(builder: (BuildContext context) {
        // To facilitate showing snackbar messages.
        _scaffoldContext = context;

        return Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(40.0, 0.0, 40.0, 0.0),
              child: TextFormField(
                controller: _stockSymbolController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'Stock Symbol',
                ),
              ),
            ),
            Center(
              child: RaisedButton(
                  color: Colors.blue[800],
                  child: _verifyingStockSymbolExists == false
                      ? Text('Add', style: TextStyle(fontSize: 18.0))
                      : SizedBox(
                          child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.blue), strokeWidth: 3.0),
                          height: 17.0,
                          width: 17.0,
                        ),
                  onPressed: () {
                    if (_stockSymbolController.text.isEmpty) {
                      // Use the scaffold context saved previously.
                      Scaffold.of(_scaffoldContext).showSnackBar(
                        new SnackBar(
                          backgroundColor: Colors.blueGrey[50],
                          content: Text('Please enter a stock symbol and try again.',
                              style: TextStyle(color: Colors.blueGrey[700])),
                        ),
                      );
                    } else
                      buttonPressedHandler();
                  }),
            ),
          ],
        );
      }),
    );
  }
}

//------------------------------------------------------
// Call remote API to validate stock symbol.
//------------------------------------------------------
Future<Stock> verifyIfStockSymbolIsValid(String symbol) async {
  final response =
      await http.get('https://api.iextrading.com/1.0/stock/$symbol/batch?types=quote&last=1');

  if (response.statusCode == 200) {
    // Get Map from JSON.
    Map data = json.decode(response.body);

    // We are after the data in 'quote'
    Map quoteData = data['quote'];

    Stock stockQuote = Stock.fromJson(quoteData);

    return stockQuote;
  } else {
    return null;
  }
}

//------------------------------------------------------
// Add new stock symbol to Firebase for current user.
//------------------------------------------------------
void addStockSymbolToFirebase(String user, Stock stock) {
  Firestore.instance.runTransaction((Transaction transaction) async {
    CollectionReference reference = Firestore.instance.collection(user);

    Map stockMap = {
      'symbol': stock.symbol,
      'companyName': stock.companyName,
      'latestPrice': stock.latestPrice,
      'low': stock.low,
      'high': stock.high,
      'week52High': stock.week52High,
      'change': stock.change,
      'changePercent': stock.changePercent,
      'peRatio': stock.peRatio,
      'previousClose': stock.previousClose
    };

    await reference.add({'stock': stockMap}).whenComplete(() {
      print('Stock added.');
    });
  });
}

//------------------------------------------------------
// Renmove stock symbol from Firebase for current user.
//------------------------------------------------------
void removeStockSymbolFromFirebase(String user, DocumentSnapshot document) {
  Firestore.instance.runTransaction((Transaction transaction) async {
    CollectionReference reference = Firestore.instance.collection(user);

    await reference.document(document.documentID).delete();
  });
}

//------------------------------------------------------
// Call the remote API for each stock.
// Update Firebase with the new data, which will
// trigger an update to the UI.
//------------------------------------------------------
Future<Null> refreshStockQuotesForUser(String user) async {
  Firestore.instance.runTransaction((Transaction transaction) async {
    QuerySnapshot querySnapshot = await Firestore.instance.collection(user).getDocuments();

    // Get all documents (stock quotes).
    var list = querySnapshot.documents;

    list.forEach((doc) async {
      // Get the symbol.
      String symbol = doc.data['stock']['symbol'];

      // Call API for the symbol
      final response =
          await http.get('https://api.iextrading.com/1.0/stock/$symbol/batch?types=quote&last=1');

      if (response.statusCode == 200) {
        // Get Map from JSON.
        Map data = json.decode(response.body);

        // We are after the data in 'quote'
        Map quoteData = data['quote'];

        // Get relevant fields into a Stock object.
        Stock stock = Stock.fromJson(quoteData);

        Map stockMap = {
          'symbol': stock.symbol,
          'companyName': stock.companyName,
          'latestPrice': stock.latestPrice,
          'low': stock.low,
          'high': stock.high,
          'week52High': stock.week52High,
          'change': stock.change,
          'changePercent': stock.changePercent,
          'peRatio': stock.peRatio,
          'previousClose': stock.previousClose
        };

        // Update Firebase
        Firestore.instance.runTransaction((Transaction transaction) async {
          CollectionReference reference = Firestore.instance.collection(user);

          await reference.document(doc.documentID).updateData({'stock': stockMap}).whenComplete(() {
            print('Stock updated.');
          });
        });
      }
    });
  });

  return null;
}
