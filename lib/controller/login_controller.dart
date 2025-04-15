import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class LoginController extends GetxController {
  var error_message = "".obs;

  setErrorMessage(newErrorMessage) {
    error_message.value = newErrorMessage;
  }
}
