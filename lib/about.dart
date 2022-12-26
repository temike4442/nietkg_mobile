import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Биз жөнүндө'),),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Text('Байланышуу үчүн:')),
              TextButton.icon(onPressed: () async{
                var whatsappnumber ="+996702777796";
                var whatsappAndroid =Uri.parse("whatsapp://send?phone=$whatsappnumber");
                //var whatsappAndroid =Uri.parse("https://wa.me/$whatsappnumber");
                if (await canLaunchUrl(whatsappAndroid)) {
                  await launchUrl(whatsappAndroid);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Не установлен Whatsapp"),
                    ),
                  );
                }
              }, icon: Image.asset('assets/images/whatsapp.png',height: 60,), label: Text('Whatsapp: +996702777796')),

              TextButton.icon(onPressed: () async {
                var instaUrl ="https://www.instagram.com/jaria.kg/";
                await canLaunch(instaUrl)? launch(instaUrl):print("instaUrl не установлен");
              }, icon: Image.asset('assets/images/instagram.png',height: 60,), label: Text('Instagram: Jaria.kg')),
              SizedBox(height: 30,),
              Container(child: Text('''
                          Jaria.kg максаты?
                Долбоордун максаты - Жалал-Абад облусунун районундагы шаар-айылдарынын тургундарына атайын жасалган, жаңылык-жарыяларды кабардар кылып турган тиркеме. 
                Адамдын убактысын үнөмдөйт. Жерибиздин социалдык жана технологиялык өнүгүүсүнө түрткү болот деп ишенебиз.
                Тиркемени колдонуу оңой – регистрация, анкета толтуруунун кереги жок.Жарыяларды бат табуу үчүн, “Издөө” функциясын колдонуңуз. Негизги категориялар: спорт, автоунаа, турак жай, электроника, мал-чарба, жумуш издөө, жумуш берүү, ден-соолук, мүлк, буюм сатуу, кызмат көрсөтүү, ж.б.
                '''),),
              /*Text('''
                  Цель проекта Jaria.kg
              Специальное приложение по размещению объявлений для жителей Жалалабатской области; сэкономит время людей; способствует социальному и технологическому развитию местности. 
              Использование приложения легко, не нужно заполнять никакую анкету. Чтобы найти подходящее объявление, пользуйтесь функцией “Найти”. 
              Основные категории:Спорт, автомобили, недвижимость, электроника, сельское хозяйство, поиск и предложение работы, здоровье, продажа вещей, оказание услуг и т.д. 
''',style: TextStyle(color: Colors.indigoAccent),),*/
              TextButton.icon(onPressed: () async {
                var instaUrl ="https://play.google.com/store/apps/details?id=com.jaria.jaria_kg";
                await canLaunch(instaUrl)? launch(instaUrl):print("instaUrl не установлен");
              }, icon: Image.asset('assets/images/launch.png',height: 60,), label: Text('Тиркемени баалоо')),
            ],
          ),
        ),
      ),
    );


  }

}