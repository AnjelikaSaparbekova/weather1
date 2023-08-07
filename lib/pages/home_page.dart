import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather1/components/custom_icon_button.dart';
import 'package:weather1/constants/api_const.dart';
import 'package:weather1/constants/app_colors.dart';
import 'package:weather1/constants/app_text.dart';
import 'package:weather1/constants/app_text_styles.dart';
import 'package:weather1/models/weather_model.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  Future<Position> weatherLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      log(permission.name);
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<WeatherModel?> fetchData() async {
    final dio = Dio();
    final response = await dio.get(ApiConst.api);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final weatherModel = WeatherModel(
        id: response.data["weather"][0]["id"],
        main: response.data["weather"][0]["main"],
        description: response.data["weather"][0]["description"],
        icon: response.data["weather"][0]["icon"],
        temp: response.data["main"]["temp"],
        country: response.data["sys"]["country"],
        city: response.data["name"],
      );

      return weatherModel;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.white,
        title: const Text(AppText.appBar, style: AppTextStyle.appBar),
      ),
      body: FutureBuilder(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.connectionState == ConnectionState.none) {
            return const Center(
              child: Text("Проблемы с сервером"),
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/foto.jpg'),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomIconsButton(
                          onPressed: () {
                            weatherLocation();
                          },
                          icon: Icons.near_me,
                        ),
                        const CustomIconsButton(icon: Icons.location_city),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Text(
                            "${temp(snapshot.data!.temp)}",
                            style: const TextStyle(
                              fontSize: 96,
                              color: AppColors.white,
                            ),
                          ),
                          Image.network(
                              ApiConst.getIcon(snapshot.data!.icon, 4)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            snapshot.data!.description.replaceAll(" ", "\n"),
                            style: const TextStyle(
                              fontSize: 60,
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(width: 40),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Text(
                            snapshot.data!.city,
                            style: const TextStyle(
                              fontSize: 60,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          } else {
            return const Center(child: Text("Неизвестная ошибка..."));
          }
        },
      ),
    );
  }

  int temp(double? temp) {
    return (temp! - 273.15).toInt();
  }
}
