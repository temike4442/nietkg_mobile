import 'dart:async';
import 'dart:convert';
import 'package:nietkg/about.dart';
import 'package:nietkg/addtab.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:nietkg/log.dart';
import 'addetail.dart';
import 'story_view/store_page_view.dart';
import 'includes/loads.dart';
import 'category.dart';
import 'includes/Ad.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          brightness: Brightness.light,
          accentColor: Colors.cyan[600],
          primaryColor: Colors.lightBlue[800]),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
        Duration(seconds: 3),
        () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MainScreen())));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
        child: Container(
          color: Colors.white,
          child:
          Center(child: Image.asset('assets/images/launch.png')),
        ),
    );
  }
}

class MainScreen extends StatefulWidget {
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  TextEditingController searchController = new TextEditingController();
  int region = 999;
  int category = 999;
  int requeststatus = 0;
  int _count_ad = 0;
  int _index_page = 1;
  String _prev_url = '';
  String _next_url = '';
  late Future<List<Short_ad>> list_ad;
  late Future<List<DropdownMenuItem>> list_category;
  late Future<List<DropdownMenuItem>> list_region;

  @override
  void initState() {
    super.initState();
    list_ad = get_ads('http://jaria.kg/apis/v1/');
    list_category = getCategories();
    list_region = getRegions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Jaria KG',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LogPage()));
              },
              icon: Icon(
                Icons.space_dashboard_outlined,
                size: 35,
                color: Colors.black,
              )),
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AboutPage()));
              },
              icon: Icon(
                Icons.mark_email_read_outlined,
                size: 35,
                color: Colors.black,
              )),
        ],
        backgroundColor: Colors.grey[50],
      ),
      body: SingleChildScrollView(
        physics: ScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      primary: Colors.pink,
                    ),
                    onPressed: () {
                      showFilterDialog(context);
                    },
                    child: Column(
                      children: <Widget>[
                        Icon(
                          Icons.tune,
                          color: Colors.black,
                        ),
                        Text(
                          "Фильтр",
                          style: TextStyle(color: Colors.black),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                      child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), labelText: 'Поиск...'),
                  )),
                  IconButton(
                      onPressed: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        setState(() {
                          requeststatus = 1;
                          _index_page = 1;
                        });
                        list_ad = search_ad();
                      },
                      icon: Icon(Icons.search_sharp))
                ],
              ),
              Divider(
                height: 10,
                color: Colors.black,
              ),
              Container(
                height: 90,
                child: FutureBuilder(
                    future: getCategories_menu(),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        return ListView.separated(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.black12,
                                      borderRadius: BorderRadius.circular(8)),
                                  width: 90,
                                  child: Column(
                                    children: [
                                      Image.network(
                                          snapshot.data[index].icon.toString()),
                                      Text(
                                        snapshot.data[index].title,
                                        style: TextStyle(fontSize: 10),
                                      )
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => CategoryTab(
                                              snapshot.data[index].id)));
                                });
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return SizedBox(
                              width: 7,
                            );
                          },
                        );
                      } else
                        return CircularProgressIndicator();
                    }),
              ),
              Divider(
                height: 10,
                color: Colors.black,
              ),
              Container(
                  height: 110,
                  child: FutureBuilder(
                      future: get_stories('http://jaria.kg/apis/v1/story_list'),
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
              requeststatus == 1
                  ? CircularProgressIndicator()
                  : FutureBuilder(
                      future: list_ad,
                      builder: (context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData && snapshot.data.length != 0) {
                          return ListView.separated(
                            separatorBuilder:
                                (BuildContext context, int index) => Divider(),
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
                                leading: snapshot.data[index].images.length == 0
                                    ? Image.asset('assets/images/no_image.jpg',
                                        width: 90)
                                    : Image.network(
                                        snapshot.data[index].images[0]
                                            .toString(),
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
                                              title:
                                                  snapshot.data[index].title)));
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
                                style:
                                    TextStyle(color: Colors.red, fontSize: 16),
                              ),
                            ],
                          );
                        } else if (snapshot.hasError) {
                          return Text("${snapshot.error}");
                        }
                        return CircularProgressIndicator();
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
                          requeststatus = 1;
                          _index_page--;
                        });
                        list_ad = get_ads(_prev_url);
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
                            requeststatus = 1;
                            _index_page++;
                          });
                          list_ad = get_ads(_next_url);
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
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => AddTabWidget()));
          },
          child: Icon(Icons.add)),
    );
  }

  void showFilterDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              height: 300,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Параметры поиска',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    SizedBox(
                      height: 20,
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
                    SizedBox(
                      height: 20,
                    ),
                    FutureBuilder(
                      future: list_category,
                      builder: (context, AsyncSnapshot snapshot) {
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
                    SizedBox(
                      width: 320.0,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shadowColor: Color(0xFF1BC0C5)),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Выбрать",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future<List<Short_ad>> get_ads(String _url) async {
    final allResponse = await http.get(Uri.parse(_url));
    if (allResponse.statusCode == 200) {
      var jsonData = jsonDecode(utf8.decode(allResponse.bodyBytes));
      var result = jsonData['results'];
      List<Short_ad> listAd = [];
      for (Map<String, dynamic> i in result) {
        Short_ad shortAd = Short_ad(i['pk'], i['title'], i['price'],
            i['valute'].toString(), [], i['region'].toString(), i['date']);
        for (Map<String, dynamic> s in i['images_set']) {
          shortAd.images.add(s['image']);
        }
        listAd.add(shortAd);
      }
      var _count_page = (jsonData['count']) ~/ 4;
      if (jsonData['count'] % 4 != 0) _count_page++;
      setState(() {
        _count_ad = _count_page;
        _next_url = jsonData['next'];
        _prev_url = jsonData['previous'];
        requeststatus = 0;
      });
      return listAd;
    } else {
      print('Error Failed load');
      setState(() {
        requeststatus = 0;
      });
      return [];
    }
  }

  Future<List<Short_ad>> search_ad() async {
    String text = searchController.text;
    String url = '';
    if (text != '') {
      url =
          'http://jaria.kg/apis/v1/search/$text/$region/$category/';
    } else {
      url =
          'http://jaria.kg/apis/v1/category/$category/$region/';
    }
    final allResponse = await http.get(Uri.parse(url));
    if (allResponse.statusCode == 200) {
      var jsonData = jsonDecode(utf8.decode(allResponse.bodyBytes));
      var result = jsonData['results'];
      List<Short_ad> listAd = [];
      for (Map<String, dynamic> i in result) {
        Short_ad shortAd = Short_ad(i['pk'], i['title'], i['price'],
            i['valute'].toString(), [], i['region'].toString(), i['date']);
        for (Map<String, dynamic> s in i['images_set']) {
          shortAd.images.add(s['image']);
        }
        listAd.add(shortAd);
      }
      var _count_page = (jsonData['count']) ~/ 4;
      if (jsonData['count'] % 4 != 0) _count_page++;
      setState(() {
        _count_ad = _count_page;
        _next_url = jsonData['next'];
        _prev_url = jsonData['previous'];
        requeststatus = 0;
      });
      return listAd;
    } else {
      print('Search Failed load');
      setState(() {
        requeststatus = 0;
      });
      return [];
    }
  }
}
