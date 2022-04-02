import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dart_git_hooks/dart_git_hooks.dart';
import 'package:yaml/yaml.dart';

/// 打印版本号
class VersionCommand extends Command<void> {
  @override
  String get description => 'Print dart_git_hooks version.';

  @override
  String get name => 'version';

  /// 增加 v
  VersionCommand() {
    argParser.addOption('v');
  }

  @override
  void run() {
    var f = File(Utils.uri((Utils.getOwnPath() ?? '') + '/pubspec.yaml'));
    var text = f.readAsStringSync();
    Map yaml = loadYaml(text);
    String? version = yaml['version'];
    print(version);
  }
}
