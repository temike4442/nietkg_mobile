class Ad {
  String title;
  String content;
  String category;
  String number;
  String name;
  String region;
  String address;
  String date;
  int price;
  int views;
  String valute;
  List<String> images;
  Ad(this.title, this.content, this.category, this.number, this.name,
      this.region, this.address, this.price, this.valute,this.date,this.views, this.images);
}

class Short_ad {
  int pk;
  String title;
  int price;
  List<String> images;
  String valute;
  String region;
  String date;
  String is_vip;

  Short_ad(
    this.pk,
    this.title,
    this.price,
    this.valute,
    this.images,
    this.region,
    this.date,
      this.is_vip
  );
}

class StoryItems {
  String type;
  String src;
  StoryItems(this.type, this.src);
}

class Story {
  String title;
  int category;
  List<StoryItems> items;
  Story(this.title, this.items, this.category);
}
