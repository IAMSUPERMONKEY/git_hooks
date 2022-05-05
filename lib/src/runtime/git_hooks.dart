import 'dart:io';

import 'package:dart_git_hooks/dart_git_hooks.dart';

/// create files or call hooks functions
class GitHooks {
  /// ```dart
  /// Map<Git, UserBackFun> params = {
  ///   Git.commitMsg: commitMsg,
  ///   Git.preCommit: preCommit
  /// };
  /// GitHooks.call(arguments, params);
  /// ```
  /// [argument] is just passthrough from main methods. It may ['pre-commit','commit-msg'] from [hookList]
  void hookCall(List<String> argument, Map<Git, UserBackFun> params) async {
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
      print('git_hooks crashed when call $type,check your function');
    }
  }
}
