import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'includes/Ad.dart';
import 'addetail.dart';
import 'includes/loads.dart';


class CategoryTab extends StatefulWidget {
  int cat_id =0;
  CategoryTabState createState() => CategoryTabState();
  CategoryTab(this.cat_id);
}

class CategoryTabState extends State<CategoryTab> {
  int region = 999;
  late int category;
  int request_status =0;
  late Future<List<Short_ad>> list_ad;

  @override
  void initState() {
    super.initState();
    list_ad = _load_ad(widget.cat_id);
    category = widget.cat_id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Категория'),
        ),
        body:SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center( child:
          request_status == 0 ? CircularProgressIndicator():
        Column(
          children: [
            Text('Фильтр и поиск обьявлений'),
            SizedBox(
              height: 10,
            ),
            FutureBuilder(
              future: getRegions(),
              builder: (context, AsyncSnapshot snapshot) {
                return DropdownButtonFormField<dynamic>(
                  value: region,
                  items: snapshot.data,
                  onChanged: (value) {
                    setState(() {
                      region = value;
                    });
                  },
                );
              },
            ),
            FutureBuilder(
              future: getCategories(),
              builder: (context,AsyncSnapshot snapshot) {
                return DropdownButtonFormField<dynamic>(
                  value: category,
                  items: snapshot.data,
                  onChanged: (value) {
                    setState(() {
                      category = value;
                    });
                  },
                );
              },
            ),
            ElevatedButton(
                onPressed: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                  setState(() {
                    request_status = 0;
                    list_ad = _load_ad(category);
                  });
                },
                child: Text('Найти')),
            SizedBox(
              height: 20,
            ),
            //ad_list != null ? Text('Результаты поиска') : Text(''),
            Divider(),
            SizedBox(
              height: 10,
            ),
            FutureBuilder(
              future: list_ad,
              builder: (context,AsyncSnapshot snapshot) {
                if (snapshot.hasData && snapshot.data.length != 0) {
                  return ListView.separated(
                    separatorBuilder: (BuildContext context, int index) =>
                        Divider(),
                    scrollDirection: Axis.vertical,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        title: Text(snapshot.data[index].title),
                        leading: snapshot.data[index].images.length == 0
                            ? Image.asset('assets/images/no_image.jpg')
                            : Image.network(
                          snapshot.data[index].images[0].toString(),
                          width: 100,
                        ),
                        subtitle: snapshot.data[index].price.toString() == '0'
                            ? Text('Договорная')
                            : Row(
                          children: [
                            Text(snapshot.data[index].price.toString()),
                            Text(snapshot.data[index].valute.toString()),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AdDetail(
                                      pk: snapshot.data[index].pk,
                                      title: snapshot.data[index].title)));
                        },
                      );
                    },
                  );
                } else if (snapshot.hasData) {
                  return Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Поиск не дал результатов',
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ],
                  );
                } else {
                  return Text('Ищите что нибудь');
                }
              },
            ),
          ],
        ),)
      ),
    ));
  }

  Future<List<Short_ad>> _load_ad(int cat_id) async {
    final allResponse = await http.get(Uri.parse(
        'https://temike.pythonanywhere.com/apis/v1/category/$cat_id/$region/'));
    if (allResponse.statusCode == 200) {
      var jsonData = jsonDecode(utf8.decode(allResponse.bodyBytes));
      List<Short_ad> listAd = [];
      for (Map<String, dynamic> i in jsonData) {
        Short_ad shortAd = Short_ad(
            i['pk'],
            i['title'],
            i['price'],
            i['valute'].toString(),
            []);
        for (Map<String, dynamic> s in i['images_set']) {
          shortAd.images.add(s['image']);
        }
        listAd.add(shortAd);
      }
      setState(() {
        request_status = 1;
      });
      return listAd;
    } else {
      print('Error Failed load');
      setState(() {
        request_status = 1;
      });
      return [];
    }
  }
}
