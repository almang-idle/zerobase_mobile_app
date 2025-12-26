import 'dart:async';

import 'package:flutter/cupertino.dart'
    show
        CupertinoAlertDialog,
        CupertinoDialogAction,
        CupertinoButton,
        CupertinoColors;
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:myapp/app/cores/values/app_colors.dart';
import 'package:myapp/app/services/device_service.dart';

import '../../../routes/app_pages.dart';

class ScanDevicesDialog extends StatefulWidget {
  const ScanDevicesDialog({super.key});

  @override
  State<ScanDevicesDialog> createState() => _ScanDevicesDialogState();
}

class _ScanDevicesDialogState extends State<ScanDevicesDialog> {
  DeviceService get deviceService => Get.find<DeviceService>();

  // 각 디바이스의 연결 중 상태를 추적
  final RxMap<String, bool> _connectingDevices = <String, bool>{}.obs;

  @override
  void initState() {
    super.initState();
    // Dialog가 열릴 때마다 연결 상태 초기화
    _connectingDevices.clear();
    // Dialog가 열릴 때 자동으로 5초 스캔 시작
    deviceService.startScanWithDuration();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent, // 배경을 투명하게 하고 Container로 스타일링
      insetPadding: EdgeInsets.zero, // 기본 패딩 제거 (필요시 조절)
      child: Container(
        width: Get.width * 0.25, // 📌 요청하신 가로 사이즈 (화면의 30%)
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6, // iOS 다이얼로그 배경색
          borderRadius: BorderRadius.circular(14), // iOS 스타일 둥근 모서리
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          // 내용물만큼만 세로 차지 (최대 높이는 아래 SizedBox로 제한됨)
          children: [
            // --- 1. Title Area ---
            const Padding(
              padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
              child: Text(
                'Scanning for Devices',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.black, // iOS 타이틀 기본색
                ),
              ),
            ),

            // --- 2. Content Area ---
            Obx(() {
              final devices = deviceService.scannedDevices;
              return SizedBox(
                height: Get.height * 0.6, // 요청하신 세로 높이
                child: devices.isEmpty
                    ? const Center(child: Text("No devices found"))
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: devices.length,
                        itemBuilder: (context, index) {
                          final device = devices[index];
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
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
                                          const SizedBox(height: 4),
                                          Text(
                                            'id: ${device.id}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: device.name.isNotEmpty
                                                  ? AppColors.primary
                                                  : AppColors.gray,
                                            ),
                                            overflow: TextOverflow
                                                .ellipsis, // ID가 길 경우 처리
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Obx(() {
                                      final isConnecting =
                                          _connectingDevices[device.id] ??
                                              false;
                                      return ElevatedButton(
                                        onPressed: isConnecting
                                            ? null
                                            : () async {
                                                _connectingDevices[device.id] =
                                                    true;
                                                deviceService
                                                    .connectToDevice(device.id)
                                                    .then((_) {
                                                  Get.offAllNamed(Routes.MAIN);
                                                }).catchError((e) {
                                                  _connectingDevices[
                                                      device.id] = false;
                                                });
                                              },
                                        style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12),
                                            minimumSize: Size(60, 36)),
                                        child: Text(
                                            isConnecting
                                                ? 'Connecting...'
                                                : 'Connect',
                                            style: TextStyle(fontSize: 12)),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                              const Divider(height: 1, color: Colors.grey),
                            ],
                          );
                        },
                      ),
              );
            }),

            const Divider(height: 1, color: Colors.grey),

            // --- 3. Action Area (Scan) ---
            // CupertinoDialogAction 모양 흉내내기
            SizedBox(
              width: double.infinity,
              height: 45, // iOS 액션 버튼 표준 높이와 비슷하게
              child: Obx(() {
                final isScanning = deviceService.isScanning.value;
                return CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: isScanning
                      ? null
                      : () {
                          // 5초 스캔 시작
                          deviceService.startScanWithDuration();
                        },
                  child: Text(
                    isScanning ? 'Scanning...' : 'Scan',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: isScanning
                            ? CupertinoColors.inactiveGray
                            : CupertinoColors.activeBlue),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
