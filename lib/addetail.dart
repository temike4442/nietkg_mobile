import 'dart:convert';
import 'package:nietkg/my_image_view.dart';
import 'package:flutter/material.dart';
import 'includes/Ad.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class AdDetail extends StatefulWidget {
  int pk = 0;
  String title;
  AdDetail({Key? key, required this.pk, required this.title}) : super(key: key);

  @override
  AdDetailState createState() => AdDetailState();
}

class AdDetailState extends State<AdDetail> {
  late Future<Ad?> ad;
  late String _title;
  @override
  void initState() {
    ad = load_ad(widget.pk.toString());
    _title = widget.title;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[300],
        title: Text(
          _title,
          style: TextStyle(fontSize: 15),
        ),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: ad,
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: Text(
                        snapshot.data.title,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Roboto',
                            fontSize: 18),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    snapshot.data.images.length != 0
                        ? GestureDetector(
                            child: Stack(
                              children: [
                                Image.network(snapshot.data.images[0]),
                                Icon(Icons.aspect_ratio_sharp)
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MyPhotoView(
                                            images: snapshot.data.images,
                                          )));
                            },
                          )
                        : Image.asset('assets/images/no_image.jpg'),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Описание: \n ' + snapshot.data.content,
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Divider(),
                    snapshot.data.price == 0
                        ? lineWidget('Цена: ', 'Договорная', Colors.black)
                        : lineWidget(
                            'Цена: ',
                            snapshot.data.price.toString() +
                                ' ' +
                                snapshot.data.valute.toString(),
                            Colors.black),
                    Divider(),
                    lineWidget('Имя: ', snapshot.data.name, Colors.black),
                    Divider(),
                    GestureDetector(
                      child: lineWidget(
                          'Номер тел: ', snapshot.data.number, Colors.blue),
                      onTap: () {
                        launch("tel://" + snapshot.data.number);
                      },
                    ),

                    Divider(),
                    lineWidget('Регион: ', snapshot.data.region.toString(),
                        Colors.black),
                    Divider(),
                    Wrap(
                      children: [
                        Text('Адрес: ',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                        snapshot.data.address == null
                            ? Text('нет')
                            : Text(snapshot.data.address),
                      ],
                    ),
                    Divider(),
                    lineWidget('Категория: ', snapshot.data.category.toString(),
                        Colors.black)
                    //Text(snapshot.data.content)
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }

  Future<Ad?> load_ad(String pk) async {
    final allResponse = await http
        .get(Uri.parse('http://jaria.kg/apis/v1/' + pk));
    if (allResponse.statusCode == 200) {
      var data = jsonDecode(utf8.decode(allResponse.bodyBytes));
      Ad _ad = Ad(
          data['title'],
          data['content'],
          data['category'],
          data['number'],
          data['name'],
          data['region'],
          data['address'],
          data['price'],
          data['valute'].toString(), []);
      for (Map<String, dynamic> s in data['images_set']) {
        _ad.images.add(s['image']);
      }
      return _ad;
    } else {
      print('Error Failed load');
      return null;
    }
  }

  Widget lineWidget(String _key, String _value, Color _color) {
    return Row(
      children: [
        Text(
          _key,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          width: 10,
        ),
        Text(
          _value != null ? _value : '',
          style: TextStyle(fontSize: 14, color: _color),
        )
      ],
    );
  }
}
