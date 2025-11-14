import 'package:flutter/cupertino.dart'
    show CupertinoAlertDialog, CupertinoDialogAction;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/app/cores/values/app_colors.dart';
import 'package:myapp/app/services/device_service.dart';

class ScanDevicesDialog extends StatelessWidget {
  const ScanDevicesDialog({super.key});

  DeviceService get deviceService => Get.find<DeviceService>();

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text('Scanning for Devices'),
      content: Obx(() {
        final devices = deviceService.scannedDevices;
        return SizedBox(
          height: Get.height * 0.6,
          width: Get.width * 0.6,
          child: ListView.builder(
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              return Column(
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Text(
                            device.name.isNotEmpty
                                ? device.name
                                : 'Unknown Device',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: device.name.isNotEmpty
                                  ? AppColors.primary
                                  : AppColors.gray,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text('id: ${device.id}',
                              style: TextStyle(
                                fontSize: 12,
                                color: device.name.isNotEmpty
                                    ? AppColors.primary
                                    : AppColors.gray,
                              )),
                        ],
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          deviceService.connectToDevice(device.id);
                          Get.back();
                        },
                        child: const Text('Connect'),
                      ),
                    ],
                  ),
                  const Divider(
                    height: 1,
                  )
                ],
              );
            },
          ),
        );
      }),
      actions: [
        CupertinoDialogAction(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
