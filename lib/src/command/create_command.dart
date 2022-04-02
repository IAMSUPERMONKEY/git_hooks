import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dart_git_hooks/src/utils/hook_utils.dart';
import 'package:dart_git_hooks/src/utils/logging.dart';
import 'package:dart_git_hooks/src/utils/utils.dart';
import 'package:path/path.dart';

import '../hook_template.dart';

String _rootDir = Directory.current.path;

/// 创建命令
class CreateCommand extends Command<void> {
  /// 创建
  CreateCommand() {
    // argParser.addOption('a');
  }

  @override
  String get name => 'create';

  @override
  String get description => '创建 bin/git_hook.dart，并根据 git_hook.dart 文件，创建对应 hook 可执行脚本';

  @override
  Future<void> run() async {
    String? targetPath;
    try {
      targetPath = (argResults?.arguments.isNotEmpty ?? false) ? argResults?.arguments.first : null;
      print('create for $targetPath');
    } on RangeError {
      targetPath = null;
    }
    if (targetPath is String && targetPath.endsWith('.dart')) {
      await copyFile(targetPath: targetPath);
    } else {
      await copyFile();
    }
  }

  /// Create files to `.git/hooks` and [targetPath]
  Future<bool> copyFile({String? targetPath}) async {
    if (targetPath == null) {
      targetPath = 'git_hooks.dart';
    } else {
      if (!targetPath.endsWith('.dart')) {
        print('the file what you want to create is not a dart file');
        exit(1);
      }
    }
    var relativePath = '$_rootDir/$targetPath';
    var hookFile = File(Utils.uri(absolute(_rootDir, relativePath)));
    var logger = Logger.standard();
    try {
      var commonStr = commonHook(Utils.uri(targetPath));
      commonStr = createHeader() + commonStr;
      var progress = logger.progress('create files');
      await hooksCommand((File hookFile) async {
        if (!hookFile.existsSync()) {
          await hookFile.create(recursive: true);
        }
        await hookFile.writeAsString(commonStr);
        if (!Platform.isWindows) {
          await Process.run('chmod', ['777', hookFile.path]).catchError((onError) {
            print(onError);
          });
        }
        return true;
      });
      if (!hookFile.existsSync()) {
        var exampleStr = userHooks;
        hookFile.createSync(recursive: true);
        hookFile.writeAsStringSync(exampleStr);
      }
      print('All files wrote successful!');
      progress.finish(showTiming: true);
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }
}
