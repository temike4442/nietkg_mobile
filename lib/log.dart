
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Trigger{
    String title;
    String date;
    Trigger(this.title,this.date);
}

class LogPage extends StatefulWidget{
  LogPage({Key? key}) : super(key: key);
  @override
  _LogPageState createState()=>_LogPageState();
}

class _LogPageState extends State<LogPage>{
  int requeststatus = 0;
  late Future<List<Trigger>> list_trigger;

  @override
  void initState() {
    super.initState();
    list_trigger = get_triggers('http://www.jaria.kg/apis/v1/triggers/');
  }

  @override
  Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(title: Text('Лента'),),
     body: SingleChildScrollView(
       physics: ScrollPhysics(),
      child: requeststatus == 1
           ? CircularProgressIndicator()
           : FutureBuilder(
         future: list_trigger,
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
                   subtitle: Text(snapshot.data[index].date),
                   onTap: () {
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
                   'Не дал результатов',
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
     ),
   );
  }
  Future<List<Trigger>> get_triggers(String _url) async {
    final allResponse = await http.get(Uri.parse(_url));
    if (allResponse.statusCode == 200) {
      var jsonData = jsonDecode(utf8.decode(allResponse.bodyBytes));
      List<Trigger> listAd = [];
      for (Map<String, dynamic> i in jsonData) {
        Trigger _trigger = Trigger(i['title'], i['date']);
        listAd.add(_trigger);
      }
      setState(() {
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
}