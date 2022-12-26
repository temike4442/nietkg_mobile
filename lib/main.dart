import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
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
import 'package:connectivity_plus/connectivity_plus.dart';

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
        Duration(seconds: 1),
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
  late Future<List<Short_ad>> list_ad;
  late Future<List<DropdownMenuItem>> list_category;
  late Future<List<DropdownMenuItem>> list_region;
}

class MainScreenState extends State<MainScreen> with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  TextEditingController searchController = new TextEditingController();
  int region = 999;
  int category = 999;
  int requeststatus = 1;
  int _count_ad = 0;
  int _index_page = 1;
  String _prev_url = '';
  String _next_url = '';
  int connect_internet = 0;

  @override
  void initState() {
    super.initState();
    check_internet();
    widget.list_ad = get_ads('https://jaria.kg/apis/v1/');
    widget.list_category = getCategories();
    widget.list_region = getRegions();
  }

  Future<bool> check_internet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: Image.asset('assets/images/launch.png',
            width: 90),
        title: Text(
          'Jaria KG',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          /*IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LogPage()));
              },
              icon: Icon(
                Icons.space_dashboard_outlined,
                size: 35,
                color: Colors.green,
              )),*/
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AboutPage()));
              },
              icon: Icon(
                Icons.account_balance,
                size: 35,
                color: Colors.green,
              )),
        ],
        backgroundColor: Colors.grey[50],
      ),
      body: RefreshIndicator(
        displacement: 50,
        backgroundColor: Colors.white,
        color: Colors.green,
        triggerMode: RefreshIndicatorTriggerMode.onEdge,
        onRefresh: () async{
          setState(() {
            requeststatus =1;
            widget.list_ad = get_ads('https://jaria.kg/apis/v1/');
          });
        },
        child: SingleChildScrollView(
          physics: ScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FutureBuilder(
                future: check_internet(),
                builder: (context,AsyncSnapshot snapshot) {
                  if (snapshot.data == false) {
                    return Center(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Интернетке байланыш жок...'),
                        ElevatedButton(onPressed: () {
                          check_internet();
                            setState(() {
                              widget.list_ad =
                                  get_ads('https://jaria.kg/apis/v1/');
                              widget.list_category = getCategories();
                              widget.list_region = getRegions();
                            });
                        }, child: Text('Кайталоо'))
                      ],
                    ),);
                  }
                  else
                    return Column(
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
                                      border: OutlineInputBorder(),
                                      labelText: 'Издөө...'),
                                )),
                            IconButton(
                                onPressed: () {
                                  FocusScope.of(context).requestFocus(
                                      FocusNode());
                                  setState(() {
                                    requeststatus = 1;
                                    _index_page = 1;
                                  });
                                  widget.list_ad = search_ad();
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
                                                borderRadius: BorderRadius
                                                    .circular(8)),
                                            width: 90,
                                            child: Column(
                                              children: [
                                                Image.network(
                                                    snapshot.data[index].icon
                                                        .toString()),
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
                                                    builder: (context) =>
                                                        CategoryTab(
                                                            snapshot.data[index]
                                                                .id)));
                                          });
                                    },
                                    separatorBuilder: (BuildContext context,
                                        int index) {
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
                                future: get_stories(
                                    'https://jaria.kg/apis/v1/story_list'),
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
                                              Border.all(
                                                  color: Colors.blueAccent)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: GestureDetector(
                                                child: Column(
                                                  children: [
                                                    CircleAvatar(
                                                      backgroundColor: Colors
                                                          .red[300],
                                                      radius: 28.0,
                                                      child: snapshot.data[index]
                                                          .items[0]
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
                                                        snapshot.data[index]
                                                            .title,
                                                        style: TextStyle(
                                                            fontSize: 8),
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
                          future: widget.list_ad,
                          builder: (context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData && snapshot.data.length != 0) {
                              return ListView.separated(
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                    Divider(),
                                scrollDirection: Axis.vertical,
                                physics: NeverScrollableScrollPhysics(),
                                addAutomaticKeepAlives: true,
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
                                              'Келишим баа',
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
                            } else if (snapshot.hasData) {
                              return Column(
                                children: [
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    'Издөө жыйынтык берген жок..',
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
                        Text('$_index_page / $_count_ad'),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (_prev_url == null || _prev_url == '')
                              TextButton.icon(
                                  onPressed: null,
                                  icon: Icon(Icons.navigate_before),
                                  label: Text('Мурунку'))
                            else
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    requeststatus = 1;
                                    _index_page--;
                                  });
                                  widget.list_ad = get_ads(_prev_url);
                                },
                                icon: Icon(
                                  Icons.navigate_before,
                                  color: Colors.white,
                                ),
                                label:
                                Text('Мурунку',
                                    style: TextStyle(color: Colors.white)),
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.lightBlue,
                                ),
                              ),
                            if (_next_url == null || _next_url == '')
                              TextButton.icon(
                                  onPressed: null,
                                  icon: Icon(Icons.navigate_next),
                                  label: Text('Кийинки'))
                            else
                              TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      requeststatus = 1;
                                      _index_page++;
                                    });
                                    widget.list_ad = get_ads(_next_url);
                                  },
                                  icon: Icon(
                                    Icons.navigate_next,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    'Кийинки',
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
                    );
                }),
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
                      'Издөө параметри',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    FutureBuilder(
                      future: widget.list_region,
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
                      future: widget.list_category,
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
                          "Тандоо",
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
            i['valute'].toString(), [], i['region'].toString(), i['date'],i['is_vip'].toString());
        for (Map<String, dynamic> s in i['images_set']) {
          shortAd.images.add(s['image']);
        }
        listAd.add(shortAd);
      }
      var CountPage = (jsonData['count']) ~/ 20;
      if (jsonData['count'] % 20 != 0) CountPage++;
      setState(() {
        _count_ad = CountPage;
        _next_url = jsonData['next'];
        _prev_url = jsonData['previous'];
        requeststatus = 0;
      });
      print('function returns');
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
          'https://jaria.kg/apis/v1/search/$text/$region/$category/';
    } else {
      url =
          'https://jaria.kg/apis/v1/category/$category/$region/';
    }
    final allResponse = await http.get(Uri.parse(url));
    if (allResponse.statusCode == 200) {
      var jsonData = jsonDecode(utf8.decode(allResponse.bodyBytes));
      var result = jsonData['results'];
      List<Short_ad> listAd = [];
      for (Map<String, dynamic> i in result) {
        Short_ad shortAd = Short_ad(i['pk'], i['title'], i['price'],
            i['valute'].toString(), [], i['region'].toString(), i['date'],i['is_vip'].toString());
        for (Map<String, dynamic> s in i['images_set']) {
          shortAd.images.add(s['image']);
        }
        listAd.add(shortAd);
      }
      var CountPage = (jsonData['count']) ~/ 20;
      if (jsonData['count'] % 20 != 0) CountPage++;
      setState(() {
        _count_ad = CountPage;
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
