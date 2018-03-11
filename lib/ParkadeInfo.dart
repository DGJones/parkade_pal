import 'package:xml/xml.dart' as xml;

class CalgaryParkades {
  final List<ParkadeInfo> _parkadesInfo = new List<ParkadeInfo>();

  initializeFromRssData(String rssData){
    var document = xml.parse(rssData);
    _parkadesInfo.clear();
    var items = document.findAllElements('item');
    for (var item in items) {
      _parkadesInfo.add(new ParkadeInfo(item));
    }
  }

  get parkadesInfo => _parkadesInfo;
}

class ParkadeInfo {
  final _regEx = new RegExp(r".*\b(\d+)\b.*\b(\d+)\b.*");
  String name;
  int availableStalls, accessibleStalls;
  String publishedAt;

  ParkadeInfo(xml.XmlElement data) {
    name = data.findElements("title").first.text;
    publishedAt = data.findElements("pubDate").first.text;
    var stalls = data.findElements("content:encoded").first.text;
    var matches = _regEx.allMatches(stalls);
    availableStalls = int.parse(matches.first[1]);
    accessibleStalls = int.parse(matches.first[2]);
  }
}