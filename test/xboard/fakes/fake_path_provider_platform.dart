// ignore_for_file: depend_on_referenced_packages

import 'dart:io';

import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class FakePathProviderPlatform extends PathProviderPlatform {
  String get _basePath => Directory.systemTemp.path;

  @override
  Future<String?> getApplicationSupportPath() async => _basePath;

  @override
  Future<String?> getTemporaryPath() async => _basePath;

  @override
  Future<String?> getApplicationCachePath() async => _basePath;

  @override
  Future<String?> getDownloadsPath() async => _basePath;

  @override
  Future<String?> getApplicationDocumentsPath() async => _basePath;

  @override
  Future<String?> getLibraryPath() async => _basePath;
}
