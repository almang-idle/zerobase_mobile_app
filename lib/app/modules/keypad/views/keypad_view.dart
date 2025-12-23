import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:myapp/app/cores/widgets/appbar.dart';
import 'package:myapp/app/modules/keypad/controllers/keypad_controller.dart';

import '../../../cores/bases/base_view.dart';
import '../../../cores/values/app_colors.dart';
import '../widgets/keypad.dart';
import '../widgets/phone_number_display.dart';

class KeypadView extends BaseView<KeypadController> {
  final double _boxWidth = 460;

  @override
  PreferredSizeWidget? appBar(BuildContext context) {
    return MyAppbar.stepProgressAppBar(totalSteps: 5, currentStep: 2);
  }

  @override
  Widget body(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(height: 10),
            SizedBox(
              width: _boxWidth,
              child: const Text(
                '전화번호 뒷자리를 입력해주세요',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.normal),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),
            Obx(() => PhoneNumberDisplay(pin: controller.pin.value)),
            SizedBox(
              width: _boxWidth,
              child: Keypad(
                onNumberPressed: controller.onNumberPressed,
                onBackspacePressed: controller.onBackspacePressed,
              ),
            ),
            // ### 확인 버튼을 여기로 이동 ###
            Obx(() {
              final bool isEnabled = controller.pin.value.length == 4;
              return SizedBox(
                width: _boxWidth,
                height: _boxWidth * 1 / 6,
                child: ElevatedButton(
                  onPressed: isEnabled ? controller.onSubmit : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor:
                        isEnabled ? const Color(0xFF9D9D9D) : AppColors.divider,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    '확인',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.normal,
                      color: isEnabled ? Colors.black : Colors.grey[500],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget? bottomNavigationBar(BuildContext context) {
    return null;
  }
}
