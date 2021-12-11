import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'includes/loads.dart';

List<Asset> images = <Asset>[];
String _error = '';
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

final  _formKey = GlobalKey<FormState>();

class AddTabWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AddTabWidgetState();
}

class AddTabWidgetState extends State<AddTabWidget> {
  int _send_status = 0;

  Widget buildGridView() {
    return GridView.count(
      crossAxisCount: 3,
      children: List.generate(images.length, (index) {
        Asset asset = images[index];
        return AssetThumb(
          asset: asset,
          width: 300,
          height: 300,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    titleController.clear();
    contentController.clear();
    numberController.clear();
    nameController.clear();
    addressController.clear();
    priceController.clear();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Добавить своё'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Center( child: _send_status ==0 ? Form(
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
                    hintText: 'Заголовок*',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Не может быть пустым..';
                    }
                    return null;
                  },
                ),
                TextField(
                  controller: contentController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.content_paste),
                    labelText: 'Описание',
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
                      labelText: 'Цена*',
                      hintText: '0 = договорная',
                    ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Не может быть пустым..';
                    }
                    return null;
                  },),
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
                      labelText: 'Имя*',
                    ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Не может быть пустым..';
                    }
                    return null;
                  },),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                    controller: numberController,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.content_paste),
                      labelText: 'Номер телефона*',
                    ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Не может быть пустым..';
                    }
                    return null;
                  },),
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
                  child: Text('Выберите фото'),
                ),
                images.length != 0
                    ? Text(images[0].name.toString())
                    : Text('Фото не выбрано'),
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
                      if (_formKey.currentState!.validate()){
                        setState(() {
                          _send_status =1;
                        });
                        await postData().then((value) {
                          setState(() {
                            _send_status = 0;
                          });
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0)),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(Radius.circular(8))),
                                    height: 270,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Ваше обьявление успешно отправлено на сервер. Обьявление будет доступным после того, как Администратор одобрит ваше обьявление.',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold, fontSize: 11),
                                          ),
                                          SizedBox(height: 20,),
                                          Text('Номер обьявления: '+value.toString(),style: TextStyle(
                                              fontWeight: FontWeight.bold, fontSize: 16)),
                                          SizedBox(
                                            width: 320.0,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  shadowColor: Color(0xFF1BC0C5)),
                                              onPressed: () {
                                                int count = 0;
                                                Navigator.of(context).popUntil((_) => count++ >= 2);
                                              },
                                              child: Text(
                                                "Ок",
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
                        });
                      }
                    },
                    child: Text('Отправить'))
              ],
            ),
          ) : CircularProgressIndicator(),
        ),),
      ),
    );
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = <Asset>[];
    String error = 'No Error Detected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 10,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Добавить фото",
          allViewTitle: "Все фотографии",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }

    if (!mounted) return;

    setState(() {
      images = resultList;
      _error = error;
    });
  }
}

Future postData() async {
  Dio dio = new Dio();
  List<MultipartFile> _images = [];
  if (images.length != 0) {
    for (int i = 0; i < images.length; i++) {
      _images.add(await MultipartFile.fromFile(
          await FlutterAbsolutePath.getAbsolutePath(images[i].identifier)));
    }
  }
  String url = 'http://temike.pythonanywhere.com/apis/v1/create/';

  FormData formData = new FormData.fromMap({
    "title": titleController.text,
    "content": contentController.text,
    "number": numberController.text,
    "name": nameController.text,
    "address": addressController.text,
    "price": priceController.text == null ? 0 : priceController.text,
    "views": 0,
    "is_active": 'False',
    "category": category,
    "region": region,
    "valute": valute,
    'images': _images
  });
  var response = await dio.post(url,
      data: formData,
      options: Options(
          headers: {'Content-type': 'application/json; charset=UTF-8'}));
  print(response.data);
  return response.data;
}
