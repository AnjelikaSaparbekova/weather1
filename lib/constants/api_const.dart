class ApiConst {
  static const String apiKey = "d482965ae47ddde32c75d8fb43eda7a3";
  static const String cityName = "moscow";
  static const String api =
      "https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey";
  static String getIcon(String icon, int size) {
    return "https://openweathermap.org/img/wn/$icon@${size}x.png";
  }
}
