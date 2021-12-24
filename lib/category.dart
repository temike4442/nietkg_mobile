import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'includes/Ad.dart';
import 'addetail.dart';
import 'includes/loads.dart';
import 'story_view/store_page_view.dart';


class CategoryTab extends StatefulWidget {
  int cat_id =0;
  CategoryTabState createState() => CategoryTabState();
  CategoryTab(this.cat_id);
}

class CategoryTabState extends State<CategoryTab> {
  int region = 999;
  late int category;
  int request_status =0;
  int _count_ad =0;
  int _index_page =1;
  String _prev_url = '';
  String _next_url = '';
  late Future<List<Short_ad>> list_ad;
  late Future<List<Story>> story_list;
  late Future<List<DropdownMenuItem>> list_category;
  late Future<List<DropdownMenuItem>> list_region;

  @override
  void initState() {
    super.initState();
    category = widget.cat_id;
    list_ad = _load_ad('https://temike.pythonanywhere.com/apis/v1/category/$category/$region/');
    list_category = getCategories();
    list_region = getRegions();
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
        Column(
          children: [
            Text('Фильтр и поиск обьявлений'),
            SizedBox(
              height: 10,
            ),
            FutureBuilder(
              future: list_region,
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
              future: list_category,
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
                  story_list = get_stories('https://temike.pythonanywhere.com/apis/v1/story_list/$category');
                  setState(() {
                    request_status = 0;
                  });
                  list_ad = _load_ad('https://temike.pythonanywhere.com/apis/v1/category/$category/$region/');
                },
                child: Text('Найти')),
            SizedBox(
              height: 20,
            ),
            Divider(),
            SizedBox(
              height: 10,
            ),
            Container(
                height: 110,
                child: request_status == 0 ? CircularProgressIndicator(): FutureBuilder(
                    future: story_list,
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return Container(
                              decoration: BoxDecoration(
                                  border:
                                  Border.all(color: Colors.blueAccent)),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: GestureDetector(
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Colors.red[300],
                                          radius: 28.0,
                                          child: snapshot.data[index].items[0]
                                              .type ==
                                              'jpg'
                                              ? CircleAvatar(
                                            backgroundImage:
                                            NetworkImage(snapshot
                                                .data[index]
                                                .items[0]
                                                .src
                                                .toString()),
                                            radius: 26.0,
                                          )
                                              : CircleAvatar(
                                            backgroundColor:
                                            Colors.green,
                                            radius: 22.0,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 90,
                                          child: Text(
                                            snapshot.data[index].title,
                                            style: TextStyle(fontSize: 8),
                                            maxLines: 4,
                                          ),
                                        )
                                      ],
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  StoryPageView(
                                                      story: snapshot
                                                          .data[index]
                                                          .items)));
                                    }),
                              ),
                            );
                          },
                        );
                      } else
                        return CircularProgressIndicator();
                    })),
            Divider(
              height: 10,
              color: Colors.black,
            ),
            request_status == 0 ? CircularProgressIndicator():FutureBuilder(
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
                        contentPadding: EdgeInsets.all(1.0),
                        title: Text(snapshot.data[index].title,style: TextStyle(fontSize: 13,fontWeight: FontWeight.w600),),
                        leading: snapshot.data[index].images.length == 0
                            ? Image.asset('assets/images/no_image.jpg',width: 90)
                            : Image.network(
                          snapshot.data[index].images[0].toString(),
                          width: 90,
                        ),
                        subtitle: snapshot.data[index].price
                            .toString() ==
                            '0'
                            ? Column(
                          children: [
                            SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(snapshot.data[index].region),
                                Text(
                                  'Договорная',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.deepOrange),
                                )
                              ],
                            ),
                            SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(snapshot.data[index].date),
                              ],
                            )
                          ],
                        )
                            : Column(
                          children: [
                            SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(snapshot.data[index].region),
                                Row(
                                  children: [
                                    Text(
                                      snapshot.data[index].price
                                          .toString(),
                                      style: TextStyle(
                                          fontWeight:
                                          FontWeight.w600,
                                          color:
                                          Colors.deepOrange),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      snapshot.data[index].valute
                                          .toString(),
                                      style: TextStyle(
                                          fontWeight:
                                          FontWeight.w600,
                                          color:
                                          Colors.deepOrange),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(snapshot.data[index].date),
                              ],
                            )
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

  Future<List<Short_ad>> _load_ad(String url) async {
    final allResponse = await http.get(Uri.parse(url));
    if (allResponse.statusCode == 200) {
      var jsonData = jsonDecode(utf8.decode(allResponse.bodyBytes));
      var result = jsonData['results'];
      List<Short_ad> listAd = [];
      for (Map<String, dynamic> i in jsonData) {
        Short_ad shortAd = Short_ad(
            i['pk'],
            i['title'],
            i['price'],
            i['valute'].toString(),
            [],
            i['region'].toString(),i['date']);
        for (Map<String, dynamic> s in i['images_set']) {
          shortAd.images.add(s['image']);
        }
        listAd.add(shortAd);
      }
      var _count_page = (jsonData['count'] ) ~/ 4;
      if (jsonData['count'] % 4 != 0) _count_page++;
      setState(() {
        _count_ad = _count_page;
        _next_url = jsonData['next'];
        _prev_url = jsonData['previous'];
        request_status =1;
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
