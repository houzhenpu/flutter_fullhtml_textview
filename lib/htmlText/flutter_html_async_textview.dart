import 'package:flutter/material.dart';
import 'package:flutter_app/htmlText/html_parser.dart';
import 'package:flutter_app/htmlText/html_text_style.dart';
import 'package:flutter_app/htmlText/on_tap_data.dart';
import 'package:oktoast/src/toast.dart';

class AsyncHtmlTextView {
  final String data;

  AsyncHtmlTextView(this.data, {EdgeInsetsGeometry padding});

  final Function onTapCallback = (data) {
    if (data is OnTapData) {
      print('data.type--->${data.type}');
      if (data.type == OnTapType.href) {
        showToast(data.url, position: ToastPosition.bottom);
      } else if (data.type == OnTapType.img) {
        showToast(data.url, position: ToastPosition.center);
      } else if (data.type == OnTapType.video) {
        showToast(data.url, position: ToastPosition.bottom);
      }
    }
  };

  build(Function onParserCallback) {
    HtmlParser(
      imagePadding:
          EdgeInsets.only(top: 12.0, left: 0.0, right: 0.0, bottom: 12.0),
      videoPadding:
          EdgeInsets.only(top: 12.0, left: 0.0, right: 0.0, bottom: 12.0),
      htmlTextStyle: HtmlTextStyle(
        hrefTextDecoration: TextDecoration.underline,
        hrefTextColor: Colors.amber,
        height: 1.4,
        fontSize: 15,
        padding: EdgeInsets.only(top: 0.0, left: 0.0, right: 0.0, bottom: 12.0),
        digitalFontWeight: DigitalFontWeight.strong,
        digitalPrefix: '    ',
        pointPrefix: '    ',
        blockQuoteColor: Colors.teal,
        blockQuoteWidth: 5,
        blockQuotMargin: EdgeInsets.only(left: 10, right: 10),
        blockQuotTextMargin: EdgeInsets.only(left: 25),
      ),
    ).parseHtmlToAsync(this.data, onTapCallback: this.onTapCallback).then((nodes) {
      if (onParserCallback != null) {
        onParserCallback(nodes);
      }
    });
  }
}