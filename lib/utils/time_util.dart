   import 'package:intl/intl.dart';

String timeFormat(DateTime? date,{String pattern = 'dd MMM yyyy'}) {
  final DateFormat formatter =  DateFormat(pattern);
  final String formatted = formatter.format(date!);
  //  final static String endformat = formatter.format(end!);

  return formatted; // something like 2013-04-20
}