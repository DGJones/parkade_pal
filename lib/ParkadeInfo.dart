import 'package:xml/xml.dart' as xml;

class CalgaryParkades {
  final List<ParkadeInfo> _parkadesInfo = new List<ParkadeInfo>();
  DateTime lastUpdate;

  initializeFromRssData(String rssData){
    var document = xml.parse(rssData);
    _parkadesInfo.clear();
    var items = document.findAllElements('item');
    for (var item in items) {
      _parkadesInfo.add(new ParkadeInfo(item));
    }
    lastUpdate = new DateTime.now();
  }

  get parkadesInfo => _parkadesInfo;
}

class ParkadeInfo {
  final _regExStalls = new RegExp(r".*\b(\d+)\b.*\b(\d+)\b.*");
  final _regExTitle = new RegExp(r".*\b(\d+)\b - (.+)");
  String name;
  int availableStalls, accessibleStalls;
  String publishedAt;

  ParkadeInfo(xml.XmlElement data) {
    _parseTitle(data);
    _parstStalls(data);
    publishedAt = data.findElements("pubDate").first.text;
  }

  void _parstStalls(xml.XmlElement data) {
    var stalls = data.findElements("content:encoded").first.text;
    var matches = _regExStalls.allMatches(stalls);
    availableStalls = int.parse(matches.first[1]);
    accessibleStalls = int.parse(matches.first[2]);
  }

  void _parseTitle(xml.XmlElement data) {
    var title = data.findElements("title").first.text;
    var matches = _regExTitle.allMatches(title);
    name = matches.first[2];
  }
}