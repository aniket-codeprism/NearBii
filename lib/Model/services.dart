class ServicesList {
  static List<ServicesData> list = [];
  static List<ServicesData> alldata = [];
}

class TitleList {
  static List<String> data = [];
  static List<String> allData = [];
}

class ServicesData {
  final String title;
  final List<dynamic> category;

  ServicesData({required this.title, required this.category});
}
