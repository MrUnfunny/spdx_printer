import 'dart:io';

import 'package:xml/xml.dart';

import 'utils.dart';

// contains number of items in a list. No of items represent number of indented lists
List<int> listChild = [];
// represents indentation level
int indent = 0;

//entry point for parsing and printing the xml to console
void parseXml(XmlDocument xml) {
  for (var node in xml.nodes) {
    if (node.nodeType == XmlNodeType.TEXT) {
      if (node.text.trim().isNotEmpty) {
        print(node.text.replaceAll(RegExp('[ \t]{2,}'), ' ' * indent));
      }
    } else {
      parseNodes(node);
    }
  }
}

void parseNodes(XmlNode node) {
  for (var child in node.nodes) {
    // represents textual data in XML
    if (child.nodeType == XmlNodeType.TEXT && child.text.trim().isNotEmpty) {
      final parentName = child.parentElement.name.toString();
      final nextSibling = (child.nextSibling as XmlElement)?.name?.toString();

      (parentName == 'p' && nextSibling == null) ||
              (parentName == 'item' &&
                  (nextSibling == null || nextSibling == 'list'))
          ? print(child.text
                  .replaceAll(RegExp('[\n][ ]{2,}'), '\n' + '  ' * indent)
                  .replaceAll(RegExp('[ \t]{2,}'), ' ')
                  .trim() +
              '\n')
          : stdout.write(child.text
              .replaceAll(RegExp('[\n][ ]+'), '\n' + '  ' * indent)
              .replaceAll(RegExp('[ \t]{2,}'), ' ')
              .trim());
    }

    // parsing Nodes of type Element
    if (child.nodeType == XmlNodeType.ELEMENT) {
      final elementName = (child as XmlElement).name.toString();

      switch (elementName) {
        case 'crossRef':
        case 'notes':
          print('\n' + child.text);
          break;

        case 'titleText':
          print('\n' + child.text.replaceAll(RegExp('[\n][ ]+'), '\n').trim());
          break;

        case 'copyrightText':
          coloredPrint('\n' + child.text.trim() + '\n\n', TextColor.red);
          break;

        // represents lists and increases indentation level for each list
        case 'list':
          indent++;
          listChild.add((child.children.length / 2).floor());
          parseNodes(child);
          break;

        // decrements indentation level by counting number of items in list
        case 'item':
          if (listChild.last == 0) {
            listChild.removeLast();

            if (indent > 0) {
              indent--;
            }
          }

          if (listChild.isNotEmpty) {
            listChild.last--;
          }

          parseNodes(child);
          break;

        // represents Optional text in License
        // Checks if node has any children other than text node. If it has more than
        // one child, end the string with linebreaks.
        case 'optional':
          final lineBreak = child.children.length > 1;

          coloredPrint(
              child.text.replaceAll(RegExp('[ \t]{2,}'), '').trim() + ' ',
              TextColor.blue,
              lineBreak);
          if (lineBreak) print('');
          break;

        // represents Replaceable text in License
        // checks if this is the last child of the parent. If it is, end the string with
        // line break.
        case 'alt':
          final lineBreak =
              child.parentElement.text.trim().endsWith(child.text.trim());
          coloredPrint(
              ' ' +
                  child.text.replaceAll(RegExp('[ \t]{2,}'), ' ').trim() +
                  ' ',
              TextColor.red,
              lineBreak);
          if (lineBreak) print('');
          break;

        case 'bullet':
          coloredPrint(
              '  ' * indent + child.text.trim() + ' ', TextColor.white);
          break;

        default:
          if (listChild.isNotEmpty && listChild.last == 0) {
            indent--;
            listChild.removeLast();
          }
          parseNodes(child);
          break;
      }
    } else {
      parseNodes(child);
    }
  }
}
