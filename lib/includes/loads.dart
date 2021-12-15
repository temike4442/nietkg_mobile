import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../includes/category.dart';
import '../includes/Ad.dart';

Future<List<DropdownMenuItem>> getRegions() async {
  final allResponse = await http
      .get(Uri.parse('http://temike.pythonanywhere.com/apis/v1/region_list'));
  List<DropdownMenuItem> listregion = [];
  if (allResponse.statusCode == 200) {
    var jsonData = jsonDecode(utf8.decode(allResponse.bodyBytes));
    listregion.add(DropdownMenuItem(value: 999, child: Text('Все регионы')));
    for (Map<String, dynamic> i in jsonData) {
      DropdownMenuItem _item =
          DropdownMenuItem(value: i['id'], child: Text(i['title']));
      listregion.add(_item);
    }
    return listregion;
  } else {
    print('Error Failed load');
    return listregion;
  }
}

Future<List<Story>> get_stories() async {
  final allResponse = await http
      .get(Uri.parse('http://temike.pythonanywhere.com/apis/v1/story_list'));
  if (allResponse.statusCode == 200) {
    var jsonData = jsonDecode(utf8.decode(allResponse.bodyBytes));
    List<Story> liststory = [];
    for (Map<String, dynamic> i in jsonData) {
      Story _story = Story(i['story_title'], [], i['story_category']);
      for (Map<String, dynamic> s in i['items_set']) {
        StoryItems _item = StoryItems(s['story_type'], s['story_src']);
        _story.items.add(_item);
      }
      liststory.add(_story);
    }
    return liststory;
  } else {
    print('Error Failed load');
    return [];
  }
}

Future<List<DropdownMenuItem>> getCategories() async {
  List<DropdownMenuItem> listcategory = [];
  final allResponse = await http
      .get(Uri.parse('http://temike.pythonanywhere.com/apis/v1/category_list'));
  if (allResponse.statusCode == 200) {
    var jsonData = jsonDecode(utf8.decode(allResponse.bodyBytes));
    listcategory
        .add(DropdownMenuItem(value: 999, child: Text('Все категории')));
    for (Map<String, dynamic> i in jsonData) {
      DropdownMenuItem _item =
          DropdownMenuItem(value: i['id'], child: Text(i['title']));
      listcategory.add(_item);
    }
    return listcategory;
  } else {
    print('Error Failed load');
    return listcategory;
  }
}

Future<List<Category>> getCategories_menu() async {
  List<Category> listcategory = [
    Category(0, 'Все', 'http://temike.pythonanywhere.com/media/icons/all.png')
  ];
  final allResponse = await http
      .get(Uri.parse('http://temike.pythonanywhere.com/apis/v1/category_list'));
  if (allResponse.statusCode == 200) {
    var jsonData = jsonDecode(utf8.decode(allResponse.bodyBytes));
    for (Map<String, dynamic> i in jsonData) {
      listcategory.add(new Category(i['id'], i['title'], i['icon']));
    }
    return listcategory;
  } else {
    print('Error Failed load');
    return listcategory;
  }
}

Future<List<Short_ad>> get_ads() async {
  final allResponse =
      await http.get(Uri.parse('http://temike.pythonanywhere.com/apis/v1/'));
  if (allResponse.statusCode == 200) {
    var jsonData = jsonDecode(utf8.decode(allResponse.bodyBytes));
    List<Short_ad> listAd = [];
    for (Map<String, dynamic> i in jsonData) {
      Short_ad shortAd =
          Short_ad(i['pk'], i['title'], i['price'], i['valute'].toString(), [],i['region'].toString());
      for (Map<String, dynamic> s in i['images_set']) {
        shortAd.images.add(s['image']);
      }
      listAd.add(shortAd);
    }
    return listAd;
  } else {
    print('Error Failed load');
    return [];
  }
}


Future<List<DropdownMenuItem>> getValutes() async {
  final allResponse = await http
      .get(Uri.parse('http://temike.pythonanywhere.com/apis/v1/valute_list'));
  if (allResponse.statusCode == 200) {
    var jsonData = jsonDecode(utf8.decode(allResponse.bodyBytes));
    List<DropdownMenuItem> listvalute = [];
    for (Map<String, dynamic> i in jsonData) {
      DropdownMenuItem _item =
          DropdownMenuItem(value: i['id'], child: Text(i['title']));
      listvalute.add(_item);
    }
    return listvalute;
  } else {
    print('Error Failed load');
    return [];
  }
}
