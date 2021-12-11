import 'dart:async';
import 'dart:convert';
import 'package:nietkg/addtab.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';
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
        Duration(seconds: 2),
        () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MainScreen())));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: Colors.white,
        child: FlutterLogo(
          size: MediaQuery.of(context).size.height,
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  TextEditingController searchController = new TextEditingController();
  String filterText = 'Все обьявления';
  int region = 999;
  List<DropdownMenuItem> categories_dropdown = [];
  int category = 999;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'NIETKG',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.account_box_outlined,
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
                    obscureText: true,
                    controller: searchController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), labelText: 'Поиск...'),
                  )),
                  IconButton(onPressed: () {}, icon: Icon(Icons.search_sharp))
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
                                          builder: (context) => SearchTab(snapshot.data[index].id)));
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
              Text(
                'VIP',
                style: TextStyle(fontSize: 18),
              ),
              Container(
                  height: 50,
                  child: FutureBuilder(
                      future: get_stories(),
                      builder: (context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData) {
                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                  child: CircleAvatar(
                                    backgroundColor: Colors.red[300],
                                    radius: 28.0,
                                    child: snapshot.data[index].items[0].type ==
                                            'jpg'
                                        ? CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                snapshot
                                                    .data[index].items[0].src
                                                    .toString()),
                                            radius: 22.0,
                                          )
                                        : CircleAvatar(
                                            backgroundColor: Colors.green,
                                            radius: 22.0,
                                          ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => StoryPageView(
                                                story: snapshot
                                                    .data[index].items)));
                                  });
                            },
                          );
                        } else
                          return CircularProgressIndicator();
                      })),
              Divider(
                height: 10,
                color: Colors.black,
              ),
              Text(filterText),
              FutureBuilder(
                future: get_ads(),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.data == null) {
                    return Container(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if (snapshot.hasData) {
                    return ListView.separated(
                      separatorBuilder: (BuildContext context, int index) =>
                          Divider(
                        height: 5,
                        color: Colors.black,
                      ),
                      scrollDirection: Axis.vertical,
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(snapshot.data[index].title),
                          leading: snapshot.data[index].images.length == 0
                              ? Image.asset(
                                  'assets/images/no_image.jpg',
                                  width: 100,
                                )
                              : Image.network(
                                  snapshot.data[index].images[0].toString(),
                                  width: 100,
                                ),
                          subtitle: snapshot.data[index].price.toString() == '0'
                              ? Text('Договорная',
                                  style: TextStyle(fontWeight: FontWeight.bold))
                              : Row(
                                  children: [
                                    Text(
                                      snapshot.data[index].price.toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(snapshot.data[index].valute.toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
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
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  return CircularProgressIndicator();
                },
              ),
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
                      'Фильтр обьявлений',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    SizedBox(
                      height: 20,
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
                    SizedBox(
                      height: 20,
                    ),
                    FutureBuilder(
                      future: getCategories(),
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
}
