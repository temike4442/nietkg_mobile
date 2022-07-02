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
  bool is_change = false;
  late Future<List<Short_ad>> list_ad;
  late Future<List<Story>> story_list;
  late Future<List<DropdownMenuItem>> list_category;
  late Future<List<DropdownMenuItem>> list_region;

  @override
  void initState() {
    super.initState();
    category = widget.cat_id;
    list_ad = _load_ad('https://jaria.kg/apis/v1/category/$category/$region/');
    story_list = get_stories('https://jaria.kg/apis/v1/story_list/$category');
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
                      is_change = true;
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
                      is_change = true;
                      category = value;
                    });
                  },
                );
              },
            ),
            ElevatedButton(
                onPressed: is_change ? () {
                  FocusScope.of(context).requestFocus(FocusNode());
                  story_list = get_stories('http://jaria.kg/apis/v1/story_list/$category');
                  setState(() {
                    request_status = 0;
                    is_change = false;
                  });
                  list_ad = _load_ad('https://jaria.kg/apis/v1/category/$category/$region/');
                } : null,
                child: Text('Применить')),
            Divider(),
            request_status==0 ? CircularProgressIndicator(): FutureBuilder(
                future: story_list,
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData && snapshot.data.length != 0)  {
                    return Container(
                      height: 110,
                      child: ListView.builder(
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
                      ),
                    );
                  } else
                    return SizedBox(height: 1,);
                }),
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
                        title: Text(
                          snapshot.data[index].title,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                        leading: snapshot.data[index].images.length ==
                            0
                            ? Image.asset(
                            'assets/images/no_image.jpg',
                            width: 90)
                            :
                        Image.network(
                          snapshot.data[index].images[0]
                              .toString(),
                          width: 90,
                        ),
                        subtitle: snapshot.data[index].price
                            .toString() ==
                            '0'
                            ? Column(
                          children: [
                            snapshot.data[index].is_vip == 'true' ?
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.lightBlueAccent,borderRadius: BorderRadius.circular(5),),
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Text('VIP'),
                              ),):SizedBox(),
                            SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(width: 135,child:Text(snapshot.data[index].region),),
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
                              mainAxisAlignment: MainAxisAlignment
                                  .center,
                              children: [
                                Text(snapshot.data[index].date),
                              ],
                            )
                          ],
                        )
                            : Column(
                          children: [
                            snapshot.data[index].is_vip == 'true' ?
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.lightBlueAccent,borderRadius: BorderRadius.circular(5),),
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Text('VIP',),
                              ),):SizedBox(),
                            SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(width: 135,child:Text(snapshot.data[index].region),),
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
                              mainAxisAlignment: MainAxisAlignment
                                  .center,
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
                                  builder: (context) =>
                                      AdDetail(
                                          pk: snapshot.data[index].pk,
                                          title:
                                          snapshot.data[index]
                                              .title)));
                        },
                      );
                    },
                  );
                } else  {
                  return Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Нет обьявлений',
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ],
                  );
                }
              },
            ),
            SizedBox(
              height: 20,
            ),
            Text('Страница $_index_page из $_count_ad'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (_prev_url == null || _prev_url == '')
                  TextButton.icon(
                      onPressed: null,
                      icon: Icon(Icons.navigate_before),
                      label: Text('Пред.'))
                else
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        request_status = 0;
                        _index_page--;
                      });
                      list_ad = _load_ad(_prev_url);
                    },
                    icon: Icon(
                      Icons.navigate_before,
                      color: Colors.white,
                    ),
                    label:
                    Text('Пред.', style: TextStyle(color: Colors.white)),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                    ),
                  ),
                if (_next_url == null || _next_url == '')
                  TextButton.icon(
                      onPressed: null,
                      icon: Icon(Icons.navigate_next),
                      label: Text('След.'))
                else
                  TextButton.icon(
                      onPressed: () {
                        setState(() {
                          request_status = 0;
                          _index_page++;
                        });
                        list_ad = _load_ad(_next_url);
                      },
                      icon: Icon(
                        Icons.navigate_next,
                        color: Colors.white,
                      ),
                      label: Text(
                        'След.',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                      )),
              ],
            ),
            SizedBox(
              height: 70,
            )
          ],
        ),
        )
      ),
    ));
  }

  Future<List<Short_ad>> _load_ad(String url) async {
    final allResponse = await http.get(Uri.parse(url));
    if (allResponse.statusCode == 200) {
      var jsonData = jsonDecode(utf8.decode(allResponse.bodyBytes));
      var result = jsonData['results'];
      List<Short_ad> listAd = [];
      for (Map<String, dynamic> i in result) {
        Short_ad shortAd = Short_ad(
            i['pk'],
            i['title'],
            i['price'],
            i['valute'].toString(),
            [],
            i['region'].toString(),i['date'],i['is_vip'].toString());
        for (Map<String, dynamic> s in i['images_set']) {
          shortAd.images.add(s['image']);
        }
        listAd.add(shortAd);
      }
      var _count_page = (jsonData['count'] ) ~/ 20;
      if (jsonData['count'] % 20 != 0) _count_page++;
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
