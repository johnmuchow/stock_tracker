import 'package:flutter/material.dart';
import 'package:stock_tracker/model/stock.dart';

class StockCard extends StatefulWidget {
  final Stock stock;

  StockCard(this.stock);

  @override
  _StockCardState createState() =>
      new _StockCardState(); 
}

class _StockCardState extends State<StockCard> {
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
      child: new Stack(
        children: <Widget>[
          card,
          new Positioned(top: 12.0, right: 12.0, child: currentPrice),
        ],
      ),
    );
  }

  //------------------------------------------------------
  // 
  //------------------------------------------------------
  Widget get card {
    // Name may have multiple parts (Hormel Foods, Inc).
    // Split on ' ' and get first entry.
    String name = widget.stock.companyName.split(" ")[0];

    // If price change is > 0, show in green, otherwise red.
    Color changeColor =
        widget.stock.change >= 0 ? Colors.green[200] : Colors.red[200];

    return new Container(
//      width: MediaQuery.of(context).size.width - 20,
      height: 140.0,
      child: Card(
        color: Theme.of(context).cardColor,
        child: Padding(
          padding: const EdgeInsets.only(
            top: 8.0,
            bottom: 8.0,
            left: 15.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                // Header with name and symbol.
                children: <Widget>[
                  Text(name + ' (' + widget.stock.symbol + ')',
                      style: Theme.of(context).textTheme.headline),
                ],
              ),
              Row(
                children: <Widget>[
                  new Container(
                    width: 65.0,
                    alignment: Alignment(1.0, 0.0),
                    child: Text(
                      
                      'Low: ',
                      style: new TextStyle(
                          fontSize: 16.0, color: Colors.grey[400]),
                    ),
                  ),
                  new Container(
                    width: 70.0,
                    child: Text('${widget.stock.low.toStringAsFixed(2)}'),
                  ),
                  new Container(
                    width: 90.0,
                    alignment: Alignment(1.0, 0.0),
                    child: Text(
                      'Prev Close: ',
                      style: new TextStyle(
                          fontSize: 16.0, color: Colors.grey[400]),
                    ),
                  ),
                  new Container(
                    width: 70.0,
                    child: Text(
                      '${widget.stock.previousClose.toStringAsFixed(2)}',
                      style: new TextStyle(color: Colors.grey[400]),
                    ),
                  ),
                ],
              ),

              Row(
                children: <Widget>[
                  new Container(
                      width: 65.0,
                      alignment: Alignment(1.0, 0.0),
                      child: Text(
                        'High: ',
                        style: new TextStyle(
                            fontSize: 16.0, color: Colors.grey[400]),
                      )),
                  new Container(
                    width: 70.0,
                    child: Text('${widget.stock.high.toStringAsFixed(2)}'),
                  ),
                  new Container(
                      width: 90.0,
                      alignment: Alignment(1.0, 0.0),
                      child: Text(
                        'Change: ',
                        style: new TextStyle(
                            fontSize: 16.0, color: Colors.grey[400]),
                      )),
                  new Container(
                    width: 70.0,
                    child: Text('${widget.stock.change.toStringAsFixed(2)}',
                        style: new TextStyle(color: changeColor)),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  new Container(
                      width: 65.0,
                      alignment: Alignment(1.0, 0.0),
                      child: Text(
                        '52week: ',
                        style: new TextStyle(
                            fontSize: 16.0, color: Colors.grey[400]),
                      )),
                  new Container(
                    width: 70.0,
                    child: Text('${widget.stock.week52High.toStringAsFixed(2)}'),
                  ),
                  new Container(
                      width: 90.0,
                      alignment: Alignment(1.0, 0.0),
                      child: Text(
                        'PE Ratio: ',
                        style: new TextStyle(
                            fontSize: 16.0, color: Colors.grey[400]),
                      )),
                  new Container(
                    width: 70.0,
                    child: Text('${widget.stock.peRatio.toStringAsFixed(2)}'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget get currentPrice {

    // If latest price is > 0, show in green, otherwise red.
    double diff = widget.stock.previousClose - widget.stock.latestPrice;
    Color latestPriceColor = (diff <= 0 ? Colors.green[700] : Colors.red[400]);

    return new Container(
      width: 100,
      height: 35,
      decoration: BoxDecoration(
        borderRadius: new BorderRadius.circular(4.0),
        color: Colors.grey[350],
        border: Border.all(
          color: Colors.white70,
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          '${widget.stock.latestPrice.toStringAsFixed(2)}',
          style: new TextStyle(
            fontSize: 19.0,
            fontWeight: FontWeight.bold,
            color: latestPriceColor,
          ),
        ),
      ),
    );
  }
}