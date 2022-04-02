import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dart_git_hooks/src/utils/hook_utils.dart';
import 'package:dart_git_hooks/src/utils/logging.dart';
import 'package:dart_git_hooks/src/utils/utils.dart';
import 'package:path/path.dart';

import '../hook_template.dart';

/// 初始化 hook
class InitCommand extends Command {
  @override
  String get description => '根据已有的 bin/git_hook.dart，创建对应 hook 可执行脚本';

  @override
  String get name => 'init';

  @override
  Future<void> run() async {
    String? targetPath;
    try {
      targetPath = argResults?['init'];
      print('获取 init 的参数 $targetPath');
    } on RangeError {
      targetPath = null;
    }
    await copyHookFile(targetPath: targetPath ?? 'bin/git_hooks.dart');
  }

  /// 仅复制hook文件
  static Future<bool> copyHookFile({required String targetPath}) async {
    var logger = Logger.standard();
    print('targetPath = $targetPath');

    try {
      // 判断 git_hook.dart 是否存在，不存在创建一个
      var relativePath = '$rootDir/$targetPath';
      var gitHookDart = File(Utils.uri(absolute(rootDir, relativePath)));
      if (!gitHookDart.existsSync()) {
        print('$relativePath 不存在，创建 git_hook.dart');
        var exampleStr = userHooks;
        gitHookDart.createSync(recursive: true);
        gitHookDart.writeAsStringSync(exampleStr);
      }

      var commonStr = commonHook(Utils.uri(targetPath));
      commonStr = createHeader() + commonStr;

      var progress = logger.progress('create files for `.git/hooks`');
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
      print('All files wrote successful!');
      progress.finish(showTiming: true);
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }
}
