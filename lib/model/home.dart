import '../api_controller/user_controller.dart';
import '../utils/image_util.dart';

enum PostType{
  image,
  video,
  ads,
  caurosel,
  youtubeShorts,
  quote
}

enum PostFeature{
  blank,
  ad,
  testAd,
  poll,
}


class ScrollConfig {
  ScrollConfig({
    this.maxFlingVelocity=8000.0,
    this.minFlingVelocity=400.0,
    this.dragStartDistanceMotionThreshold=7.5,
    this.minFlingDistance=25.0,
    this.mass=0.87,
    this.stiffness=363.0,
    this.ratio=0.87,
  });

 double? maxFlingVelocity,minFlingDistance,
 minFlingVelocity,mass,stiffness,ratio,dragStartDistanceMotionThreshold;

}

class ScrollModel {
  ScrollModel({
    this.title,
    this.description,
    this.value,
    this.max,
  });

  final String? title,description;
  final double? value,max;
}


class HomeModel {
  HomeModel({
    this.title,
    this.image,
    this.date,
    this.subtitle,
    this.category,
    this.isToggle=false,
    this.postType=PostType.image,
    this.postFeature,
    this.videoUrl,
  });
  final String? title,subtitle,image,category,videoUrl;
  final DateTime? date;
  final bool isToggle;
  final PostFeature? postFeature;
  final PostType? postType;

}

List<HomeModel> blogs = [
   HomeModel(
    image: 'assets/images/post1.png',
  title: 'Apple Might Launch iPhone 16 Ultra By 2024 With New High-end Features; Report',
  subtitle:'Apple has recently launched its premium segment smartphones with the'
   ' arrival of the iPhone 14 series, and now all eyes are up for'
   ' the next-gen series. The series includes the iPhone 14, iPhone 14 Plus,'
   ' iPhone 14 Pro, and the iPhone 14 Pro Max.'
   ' All the models are available for sale in India via Amazon. In the latest development.',
  postFeature: PostFeature.testAd,
  postType: PostType.image
 ),
 HomeModel(
  image: 'assets/images/post2.png',
  title: 'Zelensky aide says'
  ' Ukraine peace plan only way to end Russia’s war',
  subtitle: 'Kyiv\'s peace plan is the only way to end Russia\'s war in Ukraine '
  'and the time for mediation efforts has passed,'
  ' a top aide to President Volodymyr Zelensky said.Chief'
  ' diplomatic adviser Ihor Zhovkva told Reuters that Ukraine'
  ' had no interest in a ceasefire that locks in Russian territorial gains,'
  ' and wanted the implementation of its peace plan, which envisages the full'
  ' withdrawal of Russian troops.',
  postFeature: PostFeature.poll,
  postType: PostType.image
 ),
   HomeModel(
     image: 'assets/images/post1.png',
  title: 'Apple Might Launch iPhone 16 Ultra By 2024 With New High-end Features; Report',
  subtitle:'Apple has recently launched its premium segment smartphones with the'
   ' arrival of the iPhone 14 series, and now all eyes are up for'
   ' the next-gen series. The series includes the iPhone 14, iPhone 14 Plus,'
   ' iPhone 14 Pro, and the iPhone 14 Pro Max.'
   ' All the models are available for sale in India via Amazon. In the latest development.',
  postFeature: PostFeature.testAd
 ),
HomeModel(
  image: 'assets/images/post2.png',
  title: 'Zelensky aide says'
  ' Ukraine peace plan only way to end Russia’s war',
  subtitle: 'Kyiv\'s peace plan is the only way to end Russia\'s war in Ukraine '
  'and the time for mediation efforts has passed,'
  ' a top aide to President Volodymyr Zelensky said.Chief'
  ' diplomatic adviser Ihor Zhovkva told Reuters that Ukraine'
  ' had no interest in a ceasefire that locks in Russian territorial gains,'
  ' and wanted the implementation of its peace plan, which envisages the full'
  ' withdrawal of Russian troops.',
  postFeature: PostFeature.blank,
  videoUrl: 'https://www.youtube.com/watch?v=Z8uXPDHi7Fg',
  postType: PostType.video
 ),
   HomeModel(
     image: 'assets/images/ad.png',
  title: 'Apple Might Launch iPhone 16 Ultra By 2024 With New High-end Features; Report',
  subtitle:'Apple has recently launched its premium segment smartphones with the'
   ' arrival of the iPhone 14 series, and now all eyes are up for'
   ' the next-gen series. The series includes the iPhone 14, iPhone 14 Plus,'
   ' iPhone 14 Pro, and the iPhone 14 Pro Max.'
   ' All the models are available for sale in India via Amazon. In the latest development.',
  postFeature: PostFeature.ad
 ),
   HomeModel(
     image: 'assets/images/ad.png',
  title: 'Cyclone Biparjoy: 37,800 people evacuated from coastal areas in Gujarat',
  subtitle:'As Cyclone Biparjoy barrels towards the Kutch coast in Gujarat, the government said they have so far evacuated nearly 37,800 people living near the sea in eight districts of the state.'
  'The powerful cyclone will make landfall near Jakhau port on the evening of June 15, according to India Meteorological Department (IMD).',
  postFeature: PostFeature.blank,
  postType: PostType.youtubeShorts,
  videoUrl: 'https://www.youtube.com/shorts/YGbSja5PnEA'
 ),
 HomeModel(
  image: 'assets/images/post2.png',
  title: 'Zelensky aide says'
  ' Ukraine peace plan only way to end Russia’s war',
  subtitle: 'Kyiv\'s peace plan is the only way to end Russia\'s war in Ukraine '
  'and the time for mediation efforts has passed,'
  ' a top aide to President Volodymyr Zelensky said.Chief'
  ' diplomatic adviser Ihor Zhovkva told Reuters that Ukraine'
  ' had no interest in a ceasefire that locks in Russian territorial gains,'
  ' and wanted the implementation of its peace plan, which envisages the full'
  ' withdrawal of Russian troops.',
  postFeature: PostFeature.poll
 ),
];

List<HomeModel> cms = [
 HomeModel(
  title: allMessages.value.joinUs ?? 'Join Us',
 ),
  HomeModel(
  title: allMessages.value.aboutUs ?? 'About Us',
 ),
  HomeModel(
  title:allMessages.value.advertise ?? 'Advertise',
 ),
];



List<HomeModel>  posts = [
  HomeModel(
    image: Img.img1,
    title: 'KKR’s Rinku Singh adds glorious chapter to IPL story',
    date: DateTime.now(),
    category: 'Sports'
  ),
   HomeModel(
    image: Img.img2,
    title: 'Narenndra modi is the country\'s pride',
    date: DateTime.now(),
    category: 'Politics'
  ),
  HomeModel(
    image: Img.cat1,
    title: 'Expose: you’re losing money by not using...',
    date: DateTime.now(),
    category: 'Finance'
  ),    
   HomeModel(
    image: Img.cat2,
    title: 'The 10 worst relapse prevention worksheets in...',
    date: DateTime.now(),
    category: 'News'
  ),  
     HomeModel(
    image: Img.cat3,
    title: 'How analysis essays are the new analysis essays',
    date: DateTime.now(),
    category: 'Business'
  ),     
  HomeModel(
    image: Img.img1,
    title: 'KKR’s Rinku Singh adds glorious chapter to IPL story',
    date: DateTime.now(),
    category: 'Sports'
  ),
   HomeModel(
    image: Img.img2,
    title: 'Narenndra modi is the country\'s pride',
    date: DateTime.now(),
    category: 'Politics'
  ),
   HomeModel(
    image: Img.cat4,
    title: 'Narenndra modi is the country\'s pride',
    date: DateTime.now(),
    category: 'India'
  ),
  HomeModel(
    image: Img.cat1,
    title: 'Expose: you’re losing money by not using...',
    date: DateTime.now(),
    category: 'Cars'
  ),  
     HomeModel(
    image: Img.cat1,
    title: 'How analysis essays are the new analysis essays',
    date: DateTime.now(),
    category: 'Business'
  ),     
  HomeModel(
    image: Img.img1,
    title: 'KKR’s Rinku Singh adds glorious chapter to IPL story',
    date: DateTime.now(),
    category: 'Sports'
  ),
  HomeModel(
    image: Img.cat1,
    title: 'Expose: you’re losing money by not using...',
    date: DateTime.now(),
    category: 'Finance'
  ),    
   HomeModel(
    image: Img.cat2,
    title: 'The 10 worst relapse prevention worksheets in...',
    date: DateTime.now(),
    category: 'News'
  ),  
     HomeModel(
    image: Img.cat3,
    title: 'How analysis essays are the new analysis essays',
    date: DateTime.now(),
    category: 'Business'
  ),     
  HomeModel(
    image: Img.img1,
    title: 'KKR’s Rinku Singh adds glorious chapter to IPL story',
    date: DateTime.now(),
    category: 'Sports'
  ),
   HomeModel(
    image: Img.img2,
    title: 'Narenndra modi is the country\'s pride',
    date: DateTime.now(),
    category: 'Politics'
  ),
];

List<HomeModel>  categories = [
  HomeModel(
    image: Img.img1,
    title: 'Cars'
  ),
  HomeModel(
    image: Img.img1,
    title: 'Cars'),
  HomeModel(
    image: Img.cat1,
    title:'Games'),
 HomeModel(
    image: Img.img1,
    title: 'Science'),
 HomeModel(
    image: Img.cat2,
    title: 'Business'),
 HomeModel(
    image: Img.img1,
    title: 'World Affairs'),
 HomeModel(
    image: Img.cat3,
    title: 'Health'),
 HomeModel(
    image: Img.img1,
    title: 'Culture'),
 HomeModel(
    image: Img.cat2,
    title: 'Personal Growth'),
 HomeModel(
    image: Img.img1,
    title: 'Sports'),
  HomeModel(
    image: Img.img1,
    title: 'Card'),
 HomeModel(
    image: Img.cat3,
    title:  'Learning')
];

 List<String> list = [
  'Cars',
  'Games',
  'Science',
  'Business',
  'World Affairs',
  'Health',
  'Culture',
  'Personal Growth',
  'Sports',
  'Card',
  'Learning'
 ];