
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/svg.dart';
import 'package:incite/utils/theme_util.dart';
import 'package:incite/widgets/tap.dart';
import '../../../api_controller/app_provider.dart';
import '../../../api_controller/user_controller.dart';
import '../../../model/blog.dart';
import '../../../utils/color_util.dart';
import '../../../utils/image_util.dart';
import '../web_view.dart';

class PostFeatureWrap extends StatefulWidget {
  const PostFeatureWrap({
    super.key,
    this.isVolume=false,
    required this.onShare,
    required this.onBookmark,
    required this.model,
     required this.onVoice,
     this.isBookmarkContains=false,
    required  this.provider,
  });

  final VoidCallback onShare, onVoice,onBookmark;
  final Blog model;
  final bool isVolume,isBookmarkContains;
  final AppProvider provider;

  @override
  State<PostFeatureWrap> createState() => _PostFeatureWrapState();
}

class _PostFeatureWrapState extends State<PostFeatureWrap> {
  bool isBookmark=false;

  @override
  Widget build(BuildContext context) {
    var colorFilter2 = dark(context) ? ColorUtil.white :Theme.of(context).primaryColor;
    return Row(
    children: [
         TapInk(
          key: ValueKey(widget.model.isBookmark),
          radius: 6,
          pad: 4,
          onTap:currentUser.value.id == null ?(){
                  Navigator.pushNamed(context, '/LoginPage');
            } :  () {
            widget.onBookmark.call();
            setState(() {});
          },child: SvgPicture.asset(
            widget.provider.permanentIds.contains(widget.model.id) ?
           SvgImg.fillBook : SvgImg.bookmark,
           
            width: 26,height: 26, 
            color: colorFilter2,
          )),
          allSettings.value.isVoiceEnabled  == false ? 
       const SizedBox(): const SizedBox(width: 12),
      allSettings.value.isVoiceEnabled  == false ? 
       const SizedBox(): TapInk(
          pad: 4,
          radius: 6,
          onTap: widget.onVoice,
          child: SizedBox(
            width: 26,
            height: 26,
            child: widget.isVolume ? Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 1.25,color: Theme.of(context).primaryColor)
              ),
              padding:const EdgeInsets.all(0.5),
              child:  Icon(Icons.pause_rounded,size: 21,
              color: dark(context) ?  Colors.white : Theme.of(context).primaryColor),
            ) :  SvgPicture.asset(SvgImg.play, 
             color: colorFilter2,),
          )),
          const SizedBox(width: 12),
         TapInk(
          pad: 4,
          radius: 6,
         onTap: widget.onShare,
          child: SvgPicture.asset(SvgImg.share,
          width: 26,height: 26,
           color: colorFilter2)),
    ],
   );
  }
}

class TitleWidget extends StatelessWidget {
  const TitleWidget({
    super.key,
    this.color,
    required this.title,
    this.size,
  });

  final String? title;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(title ?? 'Apple Might Launch iPhone 16 Ultra By 2024 With New High-end Features; Report',
    style:  TextStyle(
     fontFamily: 'Roboto',
     fontSize: size ?? 18,
     fontWeight: FontWeight.w600,
     height: 1.3,
     color: color 
    ),
    );
  }
}

class Description extends StatelessWidget {
  const Description({
    super.key,
    required this.model,
    this.color,
    this.optionLength=0,
    this.isPoll=false,
  });

  final Blog? model;
  final Color? color;
  final int optionLength;
  final bool isPoll;

//   String convertHtmlToPlainText(String htmlText) {
//   final tempElement = html.Element.html(htmlText);
//   return tempElement.innerText;
// }

  @override
  Widget build(BuildContext context) {

    var htmlPaddings = HtmlPaddings(left: HtmlPadding(0),right: HtmlPadding(0),
                    top: HtmlPadding(0),bottom: HtmlPadding(0));
    return    Html(
                data: model!.description ?? 'Lorem ipsum data can wiit the ckiodf iskf flkfgsdcadsad dbcd bhsdMN DVMMAM',
                style: {
                  "body": Style(
                    margin: Margins(left: Margin(0),right: Margin(0),
                    blockStart:Margin(0) ,
                     blockEnd:Margin(0) ,
                    top: Margin(0),bottom: Margin(0)),
                    fontSize:  FontSize(defaultFontSize.value),
                    fontFamily: 'Roboto',
                   maxLines: isPoll && optionLength == 4  ? 
                    1 : isPoll && optionLength == 3  
                          ? 1
                          : isPoll && optionLength == 2 
                          ? 4
                            : null,
                     color: dark(context) ? color ?? ColorUtil.white : color ?? ColorUtil.textgrey,
                    lineHeight: const LineHeight(1.4),
                    textOverflow: isPoll ? TextOverflow.ellipsis : TextOverflow.visible,
                    padding: htmlPaddings
                  ),
                  "p": Style(
                    fontSize:  FontSize(defaultFontSize.value),
                    fontFamily: 'Roboto',
                     color: dark(context) ? color ?? ColorUtil.white : color ?? ColorUtil.textgrey,
                      //  padding: htmlPaddings
                      lineHeight: const LineHeight(1.4)
                  ),
                  "b": Style(
                    fontSize:  FontSize(defaultFontSize.value),
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w600,
                    color: dark(context) ? color ?? ColorUtil.white : color ?? ColorUtil.textgrey,
                      lineHeight: const LineHeight(1.4),
                       padding: htmlPaddings
                  ),
                   "i": Style(
                    fontSize:  FontSize(defaultFontSize.value),
                    fontFamily: 'Roboto',
                    fontStyle: FontStyle.italic,
                    color: dark(context) ? color ?? ColorUtil.white : color ?? ColorUtil.textgrey,
                       lineHeight: const LineHeight(1.4),
                       padding: htmlPaddings
                  ),
                   "a": Style(
                    fontSize:  FontSize(defaultFontSize.value),
                    fontFamily: 'Roboto',
                   lineHeight: const LineHeight(1.4),
                   textDecoration: TextDecoration.underline,
                    color: Theme.of(context).primaryColor,
                  ),
                  "li": Style(
                    fontSize:  FontSize(defaultFontSize.value),
                    fontFamily: 'Roboto',
                    color: dark(context) ? color ?? ColorUtil.white : color ?? ColorUtil.textgrey,
                    lineHeight: const LineHeight(1.4),
                    padding: HtmlPaddings(
                      left: HtmlPadding(12),
                      right: HtmlPadding(12),
                    )
                  ),
                  "ul": Style(
                    fontSize:  FontSize(defaultFontSize.value),
                    fontFamily: 'Roboto',
                    color: dark(context) ? color ?? ColorUtil.white : color ?? ColorUtil.textgrey,
                    lineHeight: const LineHeight(1.4),
                    padding: HtmlPaddings(
                      left: HtmlPadding(12),
                      right: HtmlPadding(12),
                    )
                  ),
                },
                onLinkTap: (url, context1, element) {
                 Navigator.push(context, CupertinoPageRoute(builder: (context) => CustomWebView(url: url.toString())));
                },
              ); 
}
}
