import 'dart:async';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'ImageClipper.dart';
import 'image.dart';

CachedNetworkImage createCachedNetworkImage(String imageUrl) {
  return new CachedNetworkImage(
    placeholder: (context, url) => new CircularProgressIndicator(),
    errorWidget: (context, url, error) => Image(
      image: AssetImage(
        "assets/images/image_error.png",
        package: 'html_text',
      ),
    ),
    fadeInDuration: const Duration(seconds: 2),
    fadeOutDuration: const Duration(seconds: 1),
    imageUrl: imageUrl,
    fit: BoxFit.cover,
  );
}

class NetworkImageClipper extends StatefulWidget {
  final String id;
  final String imageUrl;

  NetworkImageClipper(this.imageUrl, {this.id});

  @override
  State<StatefulWidget> createState() {
    return CachedImage();
  }
}

class CachedImage extends State<NetworkImageClipper> {
  ImageClipper clipper;

  CachedImage();

  @override
  void initState() {
    super.initState();
    clip(widget.imageUrl, context);
  }

  @override
  Widget build(BuildContext context) {
    getImageSingleFilePath(widget.id, widget.imageUrl);

    return ImageClipperInstance().containsUrl(widget.imageUrl)
        ? clipper == null
            ? Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              )
            : _createCustomPaint(context)
        : CachedNetworkImage(
            placeholder: (context, url) => new CircularProgressIndicator(),
            errorWidget: (context, url, error) => Image(
              image: AssetImage("assets/images/image_error.png",
                  package: 'html_text'),
            ),
            imageUrl: widget.imageUrl,
            fit: BoxFit.cover,
          );
  }

  Future<String> getImageSingleFilePath(String id, String imageUrl) async {
    return await DefaultCacheManager().getSingleFile(imageUrl).then((file) {
      addImageToArticleImageFilePathMap(id, '"$imageUrl"', '"${file?.path}"');
    });
  }

  Future<ui.Image> _loadImage(String url) async {
    ImageStream imageStream = NetworkImage(url).resolve(ImageConfiguration());
    Completer<ui.Image> completer = Completer<ui.Image>();
    void imageListener(ImageInfo info, bool synchronousCall) {
      ui.Image image = info.image;
      completer.complete(image);
    }

    ImageStreamListener imageStreamListener =
        ImageStreamListener(imageListener);
    imageStream.removeListener(imageStreamListener);
    imageStream.addListener(imageStreamListener);
    return completer.future;
  }

  clip(String url, BuildContext context) async {
    ui.Image uiImage;
    _loadImage(url).then((image) {
      uiImage = image;
    }).whenComplete(() {
      if (2 * window.physicalSize.height < uiImage.height) {
        clipper = ImageClipper(uiImage, context);
        setState(() {
          ImageClipperInstance()
              .addUrl(widget.imageUrl, _createCustomPaint(context));
        });
      } else {
        clipper = null;
      }
    });
  }

  Widget _createCustomPaint(BuildContext context) {
    return Stack(
      children: <Widget>[
        CustomPaint(
          painter: clipper,
          size: Size(MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height),
        ),
        Positioned(
          right: 1,
          bottom: 1,
          child: Image.asset(
            "assets/images/long_picture_icon.png",
            package: 'html_text',
          ),
        ),
      ],
    );
  }
}

class ImageClipperInstance {
  factory ImageClipperInstance() => _getInstance();

  static ImageClipperInstance _instance;

  List<String> clipperImageUrl;

  ImageClipperInstance._() {
    clipperImageUrl = List();
  }

  static ImageClipperInstance _getInstance() {
    if (_instance == null) {
      _instance = ImageClipperInstance._();
    }
    return _instance;
  }

  void addUrl(String url, Widget imageClipperWidget) {
    clipperImageUrl.add(url);
  }

  bool containsUrl(String url) {
    return clipperImageUrl.contains(url);
  }
}