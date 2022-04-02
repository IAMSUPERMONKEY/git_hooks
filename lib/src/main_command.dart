import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dart_git_hooks/src/command/create_command.dart';
import 'package:dart_git_hooks/src/utils/hook_utils.dart';
import 'package:dart_git_hooks/src/utils/type.dart';
import 'package:dart_git_hooks/src/utils/utils.dart';

import 'command/init_command.dart';
import 'command/remove_command.dart';
import 'command/version_command.dart';

/// dart 运行命令 入口
class MainCommand extends CommandRunner<void> {
  /// 初始化
  MainCommand() : super('dart_git_hooks', 'A command line for create git hooks') {
    // argParser.addFlag('-version', abbr: 'v');
    // 增加其他子命令
    addCommand(CreateCommand());
    addCommand(InitCommand());
    addCommand(RemoveCommand());
    addCommand(VersionCommand());
  }
}

/// 测试用，直接调用某个 hook
/// ```dart
/// Map<Git, UserBackFun> params = {
///   Git.commitMsg: commitMsg,
///   Git.preCommit: preCommit
/// };
/// GitHooks.call(arguments, params);
/// ```
/// [argument] is just passthrough from main methods. It may ['pre-commit','commit-msg'] from [hookList]
void call(List<String> argument, Map<Git, UserBackFun> params) async {
  var type = argument[0];
  try {
    params.forEach((userType, function) async {
      if (hookList[userType.toString().split('.')[1]] == type) {
        if (!await params[userType]!()) {
          exit(1);
        }
      }
    });
  } catch (e) {
    print(e);
    print('dart_git_hooks crashed when call $type,check your function');
  }
}

/// 测试
/// get target file path.
/// returns the path that the git hooks points to.
Future<String?> getTargetFilePath() async {
  String? commandPath = '';
  await hooksCommand((File hookFile) async {
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
