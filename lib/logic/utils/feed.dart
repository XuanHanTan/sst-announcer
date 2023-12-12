import 'package:html/parser.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:xml/xml.dart';

String? getNextPageXmlLink(XmlDocument document) {
  var filteredDoc = document.children[2].descendantElements;

  for (var elements in filteredDoc) {
    if (elements.name.local == "link") {
      for (var attribute in elements.attributes) {
        if (attribute.name.local == "rel" && attribute.value == "next") {
          return HtmlUnescape().convert(elements.attributes.last.value);
        }
      }
    }
  }

  return null;
}

//here goes the function
String? parseHtmlString(String htmlString) {
  final document = parse(htmlString);
  final String? parsedString = parse(document.body?.text).documentElement?.text;

  return parsedString;
}
