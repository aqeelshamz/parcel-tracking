import 'package:get/get.dart';

import '../screens/add_shipment_screen.dart';
import '../screens/my_shipments_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/track_package_screen.dart';
import 'app_routes.dart';

/// GetPage table — maps route names to screens.
class AppPages {
  AppPages._();

  static const String initial = AppRoutes.shipments;

  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.shipments,
      page: () => const MyShipmentsScreen(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: AppRoutes.addShipment,
      page: () => const AddShipmentScreen(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.trackPackage,
      page: () => const TrackPackageScreen(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsScreen(),
      transition: Transition.rightToLeftWithFade,
    ),
  ];
}
