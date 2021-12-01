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

final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

class AddTabWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AddTabWidgetState();
}

class AddTabWidgetState extends State<AddTabWidget> {
  final snackBar = SnackBar(
      content: Text(
          'Отправлено на сервер. Будет доступно после одобрения Администратора.'));
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

  void validateAndSave() async {
    final FormState? form = _formKey.currentState;
    if (form!.validate()) {
      await postData();
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      print('Form is invalid');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Добавить своё'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Form(
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
                    return (value != null) ? null : 'Заполните поле';
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
                      return (value != null) ? null : 'Заполните поле';
                    }),
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
                      return (value != null) ? null : 'Заполните поле';
                    }),
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
                      return (value != null) ? null : 'Заполните поле';
                    }),
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
                    onPressed: () {
                      validateAndSave();
                    },
                    child: Text('Отправить'))
              ],
            ),
          ),
        ),
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
  return response.data;
}
