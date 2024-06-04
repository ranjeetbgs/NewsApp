import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:incite/pages/main/web_view.dart';
import 'package:incite/utils/color_util.dart';
import 'package:incite/utils/image_util.dart';
import 'package:incite/utils/nav_util.dart';
import 'package:incite/widgets/app_bar.dart';

import '../model/cms.dart';

class CmsPage extends StatefulWidget {
  const CmsPage({super.key,this.cms});
  final CmsModel? cms;

  @override
  State<CmsPage> createState() => _CmsPageState();
}

class _CmsPageState extends State<CmsPage> {
  @override
  Widget build(BuildContext context) {
    // var text = parse(widget.cms!.description).body!.text;
    return  Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            CommonAppbar(title: widget.cms!.title ?? 'Join Us'),
            const SliverToBoxAdapter(
              child: SizedBox(height: 10),
            ),
             SliverPadding(
               padding: const EdgeInsets.symmetric(horizontal: 24),
               sliver: SliverToBoxAdapter(
                child: widget.cms!.image!.contains('https') ? 
                CachedNetworkImage(imageUrl:widget.cms!.image.toString(),height: 200 ) 
                : Image.asset(Img.logo,height: 200,),
               ),
             ),
            SliverPadding(
               padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 16),
               sliver: SliverToBoxAdapter(
                child: Html(
                  data: widget.cms!.description ?? 'Lorem ipsum data can wiit the ckiodf iskf flkfgsdcadsad dbcd bhsdMN DVMMAM',
                  style: {
                    "body": Style(
                      fontSize:  FontSize(16),
                      fontFamily: 'Roboto',
                      padding: HtmlPaddings(left: HtmlPadding(0),right: HtmlPadding(0),)
                    ),
                    "p": Style(
                      fontSize:  FontSize(16),
                      fontFamily: 'Roboto',
                        padding: HtmlPaddings(left: HtmlPadding(0),right: HtmlPadding(0),)
                    ),
                    "b": Style(
                      fontSize:  FontSize(16),
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                        padding: HtmlPaddings(left: HtmlPadding(0),right: HtmlPadding(0),)
                    ),
                     "i": Style(
                      fontSize:  FontSize(16),
                      fontFamily: 'Roboto',
                      fontStyle: FontStyle.italic,
                        padding: HtmlPaddings(left: HtmlPadding(0),right: HtmlPadding(0),)
                    ),
                     "a": Style(
                      fontSize:  FontSize(16),
                      fontFamily: 'Roboto',
                      color: Theme.of(context).primaryColor,
                    ),
                  },
                  onLinkTap: (url, context1, element) {
                   Navigator.push(context, PagingTransform(widget: CustomWebView(url: url.toString())));
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}