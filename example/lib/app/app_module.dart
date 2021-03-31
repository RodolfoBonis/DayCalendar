import 'package:example/app/app_controller.dart';
import 'package:example/app/modules/home/home_controller.dart';
import 'package:example/app/modules/home/home_page.dart';
import 'package:flutter_modular/flutter_modular.dart';

class AppModule extends Module {
  @override
  List<Bind> get binds => [
        Bind((i) => AppController()),
        Bind((i) => HomeController()),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute("/", child: (context, args) => HomePage()),
      ];
}
