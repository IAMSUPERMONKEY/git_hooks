import 'dart:io';

import 'package:dart_git_hooks/src/utils/type.dart';
import 'package:dart_git_hooks/src/utils/utils.dart';

/// hook 可执行文件
typedef HooksCommandFile = Future<bool> Function(File file);

/// 当前路径
String rootDir = Directory.current.path;

/// 创建 所有 hook 可执行文件
Future<void> hooksCommand(HooksCommandFile callBack) async {
  var gitDir = Directory(Utils.uri(rootDir + '/.git/'));
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
