import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'includes/loads.dart';

List<XFile> images = [];
late String title;
late String content;
int category = 1;
late String number;
late String name;
int region = 1;
late String address;
late int price;
int valute = 1;

TextEditingController titleController = new TextEditingController();
TextEditingController contentController = new TextEditingController();
TextEditingController numberController = new TextEditingController();
TextEditingController nameController = new TextEditingController();
TextEditingController addressController = new TextEditingController();
TextEditingController priceController = new TextEditingController();

final _formKey = GlobalKey<FormState>();

class AddTabWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AddTabWidgetState();
}

class AddTabWidgetState extends State<AddTabWidget> {
  final ImagePicker _picker = ImagePicker();
  int _send_status = 0;
  final snackBar = SnackBar(
    content: Text('Yay! A SnackBar!'),
  );

  Widget buildGridView() {
    return GridView.count(
      crossAxisCount: 3,
      children: List.generate(images.length, (index) {
        return Image.file(File(images[index].path));
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanDown: (_) {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Жарыя кошуу'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Center(
              child: _send_status == 0
                  ? Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            controller: titleController,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              icon: Icon(Icons.title),
                              hintText: 'Тема*',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Тема сөзсүз жазылуусу керек';
                              }
                              return null;
                            },
                          ),
                          TextField(
                            controller: contentController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              icon: Icon(Icons.content_paste),
                              labelText: 'мүнөздөмөсү',
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text('Категория'),
                          FutureBuilder(
                            future: getCategories(),
                            builder: (context, AsyncSnapshot snapshot) {
                              return DropdownButtonFormField<dynamic>(
                                value: 1,
                                items: snapshot.data,
                                onChanged: (value) {
                                  setState(() {
                                    category = value;
                                  });
                                },
                                validator: (value){
                                  if (value == 999){
                                    return 'Категория тандаңыз..';
                                  }
                                  return null;
                                },
                              );
                            },
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text('Регион'),
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
                                validator: (value){
                                  if (value == 999){
                                    return 'Регион тандаңыз..';
                                  }
                                  return null;
                                },
                              );
                            },
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            controller: addressController,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              icon: Icon(Icons.location_on_outlined),
                              labelText: 'Адрес',
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            controller: priceController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              icon: Icon(Icons.content_paste),
                              labelText: 'баасы*',
                              hintText: '0 = келишим баа',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Баа көрсөтүнүз..';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text('Валюта'),
                          FutureBuilder(
                            future: getValutes(),
                            builder: (context, AsyncSnapshot snapshot) {
                              return DropdownButtonFormField<dynamic>(
                                value: valute,
                                items: snapshot.data,
                                onChanged: (value) {
                                  setState(() {
                                    valute = value;
                                  });
                                },
                              );
                            },
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            controller: nameController,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              icon: Icon(Icons.content_paste),
                              labelText: 'Аты*',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Атыңыз..';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            controller: numberController,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              icon: Icon(Icons.content_paste),
                              labelText: 'Телефон номери*',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'номер жазыңыз..';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              primary: Colors.white,
                              backgroundColor: Colors.teal,
                              onSurface: Colors.grey,
                            ),
                            onPressed: loadAssets,
                            child: Text('Сүрөт тандоо'),
                          ),
                          images.length != 0
                              ? Text(images[0].name.toString())
                              : Text('Сүрөт тандала элек'),
                          images.length != 0
                              ? SizedBox(
                                  child: buildGridView(),
                                  height: 200,
                                )
                              : SizedBox(
                                  child: buildGridView(),
                                  height: 50,
                                ),
                          ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    _send_status = 1;
                                  });
                                  await postData().then((value) {
                                    setState(() {
                                      _send_status = 0;
                                    });
                                    images.clear();
                                    titleController.clear();
                                    contentController.clear();
                                    numberController.clear();
                                    nameController.clear();
                                    addressController.clear();
                                    priceController.clear();
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Dialog(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        20.0)),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(8))),
                                              height: 370,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(12.0),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Сиздин жарыяңыз серверге ийгиликтүү жөнөтүлдү. Администратор текшергенден кийин  жарыяңыз көрүнө баштайт.',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 11),
                                                    ),
                                                    SizedBox(
                                                      height: 20,
                                                    ),
                                                    Text(
                                                        'Сиздин жарыянын номери: ' +
                                                            value.toString(),
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16)),
                                                    SizedBox(
                                                      width: 320.0,
                                                      child: ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                                shadowColor: Color(
                                                                    0xFF1BC0C5)),
                                                        onPressed: () {
                                                          int count = 0;
                                                          Navigator.of(context)
                                                              .popUntil((_) =>
                                                                  count++ >= 2);
                                                        },
                                                        child: Text(
                                                          "Ок",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        });
                                  }).catchError((error, stackTrace) {
                                    print("inner: $error");
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text(error.toString()),
                                    ));
                                    setState(() {
                                      _send_status = 0;
                                    });
                                    return Future.error('Ошибка!!!');
                                  });
                                }
                              },
                              child: Text('Жөнөтүү'))
                        ],
                      ),
                    )
                  : CircularProgressIndicator(),
            ),
          ),
        ),
      ),
    );
  }

  void loadAssets() async {
    List<XFile> resultlist = await _picker.pickMultiImage(imageQuality: 75);

    if (resultlist!.isNotEmpty) {
      images.addAll(resultlist);
    }

    /*if (!mounted) return;*/

    setState(() {});
  }
}

Future postData() async {
  Dio dio = new Dio();
  List<MultipartFile> _images = [];

  if (images.length != 0) {
    for (int i = 0; i < images.length; i++) {
      _images.add(await MultipartFile.fromFile(images[i].path,
          contentType: MediaType('image', 'jpg')));
    }
  }

  FormData formData = new FormData.fromMap({
    "title": titleController.text,
    "content": contentController.text,
    "number": numberController.text,
    "name": nameController.text,
    "address": addressController.text,
    "price": priceController.text == null ? 0 : priceController.text,
    "category": category,
    "region": region,
    "valute": valute,
    'images': _images
  });
  try {
    var response = await dio.post('https://www.jaria.kg/apis/v1/create/',
        data: formData,
        options: Options(
            headers: {'Content-type': 'application/json; charset=UTF-8'}));
    return response.data;
  } catch (e) {
    print(e);
  }
}
