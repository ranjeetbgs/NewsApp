import 'package:flutter/material.dart';
import 'package:incite/api_controller/news_repo.dart';
import 'package:incite/utils/nav_util.dart';
import 'package:incite/widgets/app_bar.dart';
import 'package:incite/widgets/pdf.dart';

import '../api_controller/user_controller.dart';
import 'live_news.dart';

class EnewsPage extends StatefulWidget {
  const EnewsPage({super.key});

  @override
  State<EnewsPage> createState() => _EnewsPageState();
}

class _EnewsPageState extends State<EnewsPage> {

  @override
  void initState() {
      getENews(context).then((value) {
      setState(() { });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          Navigator.pop(context);
        }
      },
      child:Scaffold(
        body: CustomScrollView(
          slivers: [
             CommonAppbar(
              title:allMessages.value.eNews ?? 'E-news',
            ),
             const SliverToBoxAdapter(
              child: SizedBox(height: 10),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: eNews.isEmpty ? [
                   ...List.generate(5, (index) => const Padding(
                     padding:  EdgeInsets.symmetric(horizontal: 20),
                     child: ListShimmer(),
                   ))
                ] : [
                  ...eNews.map((e) => LiveWidget(
                    padding: const EdgeInsets.only(top: 16,bottom: 16,),
                    title: e.name,
                    fontWeight: FontWeight.w500,
                    image: e.image,
                    onTap: () {
                      Navigator.push(context,PagingTransform(widget:  PdfViewWidget(
                        model: e,
                      )));
                    },
                  )
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}