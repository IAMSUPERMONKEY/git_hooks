import 'dart:io';

import 'package:dart_git_hooks/dart_git_hooks.dart';
import 'package:dart_git_hooks/utils/logging.dart';
import 'package:path/path.dart';

import './hook_template.dart';

typedef _HooksCommandFile = Future<bool> Function(File file);
String _rootDir = Directory.current.path;

/// install hooks
class CreateHooks {
  /// Create files to `.git/hooks` and [targetPath]
  static Future<bool> copyFile({String? targetPath}) async {
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
      await _hooksCommand((File hookFile) async {
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

  /// 仅复制hook文件
  static Future<bool> copyHookFile({required String targetPath}) async {
    // var relativePath = '$_rootDir/$targetPath';
    var logger = Logger.standard();
    print('targetPath = $targetPath');

    try {
      // 判断 git_hook.dart 是否存在，不存在创建一个
      var relativePath = '$_rootDir/$targetPath';
      var gitHookDart = File(Utils.uri(absolute(_rootDir, relativePath)));
      if (!gitHookDart.existsSync()) {
        print('$relativePath 不存在，创建 git_hook.dart');
        var exampleStr = userHooks;
        gitHookDart.createSync(recursive: true);
        gitHookDart.writeAsStringSync(exampleStr);
      }

      var commonStr = commonHook(Utils.uri(targetPath));
      commonStr = createHeader() + commonStr;

      var progress = logger.progress('create files for `.git/hooks`');
      await _hooksCommand((File hookFile) async {
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

  /// get target file path.
  /// returns the path that the git hooks points to.
  static Future<String?> getTargetFilePath() async {
    String? commandPath = '';
    await _hooksCommand((File hookFile) async {
      var hookTemplate = hookFile.readAsStringSync();
      var match = RegExp(r'dart\s(\S+)\s\$hookName').firstMatch(hookTemplate);
      if (match is RegExpMatch) {
        commandPath = match.group(1)!;
        return false;
      }
      return true;
    });
    return commandPath;
  }

  static Future<void> _hooksCommand(_HooksCommandFile callBack) async {
    var gitDir = Directory(Utils.uri(_rootDir + '/.git/'));
    var gitHookDir = Utils.gitHookFolder;
    if (!gitDir.existsSync()) {
      throw ArgumentError('.git is not exists in your project');
    }
    for (var hook in hookList.values) {
      var path = gitHookDir + hook;
      var hookFile = File(path);
      if (!await callBack(hookFile)) {
        return;
      }
    }
  }
}
