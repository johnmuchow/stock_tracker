class Stock {

  final String companyName;
  final String symbol;

  // The following are dynamic as using double generates an error 
  // when the API returns values with no decimal (e.g. 12 vs 12.0).
  final dynamic latestPrice;
  final dynamic low;
  final dynamic high;
  final dynamic week52High;
  final dynamic change;
  final dynamic changePercent;
  final dynamic peRatio;
  final dynamic previousClose;
  
  // Default constructor.
  Stock(this.companyName, this.symbol, this.latestPrice, 
        this.low, this.high, this.week52High, this.change, 
        this.changePercent, this.peRatio, this.previousClose);
  
  // Named constructor, create object from JSON.
  Stock.fromJson(Map<String, dynamic> json)
      : companyName = (json['companyName'] != null ? json['companyName'] : ""),
        symbol = (json['symbol'] != null ? json['symbol'] : ""),
        latestPrice = (json['latestPrice'] != null ? json['latestPrice'] : 0.0),
        low = (json['low'] != null ? json['low'] : 0.0), 
        high = (json['high'] != null ? json['high'] : 0.0),
        week52High = (json['week52High'] != null ? json['week52High'] : 0.0),
        change = (json['change'] != null ? json['change'] : 0.0),
        changePercent = (json['changePercent'] != null ? json['changePercent'] : 0.0),
        peRatio = (json['peRatio'] != null ? json['peRatio'] : 0.0),
        previousClose = (json['previousClose'] != null ? json['previousClose'] : 0.0);
}