import 'package:ProjectCommunicationSystem/screen/utils/universal_variables.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CachedImage extends StatelessWidget {
  final String url;
  final String name;
  final String time;
  CachedImage({@required this.url, @required this.name, @required this.time});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        height: 350,
        child: Hero(
          tag: new Text('imageHero'),
          child: CachedNetworkImage(
            imageUrl: url,
            placeholder: (context, url) => Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailScreen(
                      url: url,
                      name: name,
                      time: time,
                    )));
      },
    );
  }
}

class DetailScreen extends StatelessWidget {
  final String url;
  final String name;
  final String time;
  DetailScreen({@required this.url, @required this.name, @required this.time});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: UniversalVariables.menuColor,
        title:Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18
              ),
            ),
            SizedBox(width: 5),
            Text(
              time,
              style: Theme.of(context).textTheme.caption,
            ),
          ],
        ),
      ),
      body: Container(
        child: Center(
          child: Hero(
            tag: new Text('imageHero'),
            child: InteractiveViewer(
              child: CachedNetworkImage(
                  fit: BoxFit.fitWidth,
                  imageUrl: url,
                  placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(),
                      )),
            ),
          ),
        ),
      ),
    );
  }
}
