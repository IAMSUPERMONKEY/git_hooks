import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dart_git_hooks/dart_git_hooks.dart';
import 'package:dart_git_hooks/src/utils/logging.dart';

/// 移除 .git/hooks 脚本
class RemoveCommand extends Command {
  @override
  String get description => '移除已有的 .git/hooks 脚本';

  @override
  String get name => 'remove';

  @override
  Future<void> run() async {
    await deleteFiles();
  }

  /// delete all file from `.git/hooks`
  Future<bool> deleteFiles() async {
    var rootDir = Directory.current;
    var logger = Logger.standard();

    var gitDir = Directory(Utils.uri(rootDir.path + '/.git/'));
    var gitHookDir = Utils.gitHookFolder;
    if (!gitDir.existsSync()) {
      print(gitDir.path);
      throw ArgumentError('.git is not exists in your project');
    }
    var progress = logger.progress('delete files');
    for (var hook in hookList.values) {
      var path = gitHookDir + hook;
      var hookFile = File(path);
      if (hookFile.existsSync()) {
        await hookFile.delete();
      }
    }
    // var hookFile = File(Utils.uri(rootDir.path + '/git_hooks.dart'));
    // if (hookFile.existsSync()) {
    //   await hookFile.delete();
    //   print('dart_git_hooks.dart deleted successfully!');
    // }
    progress.finish(showTiming: true);
    print('All in files `.git/hooks` deleted successfully!');
    // await Process.run('pub', ['global', 'deactivate', 'dart_git_hooks']).catchError((onError) {
    //   print(onError);
    // });
    // print('dart_git_hooks uninstalled successful!');
    return true;
  }
}
