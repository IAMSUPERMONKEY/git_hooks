import 'dart:io';

import 'package:yaml/yaml.dart';

/// hooks template
String commonHook(String path) {
  var temp = '';
  if (Platform.isMacOS) {
    temp += 'source ~/.bash_profile\n';
  }
  temp += '''
hookName=`basename "\$0"`
gitParams="\$*"
program_exists() {
    local ret="0"
    command -v \$1 >/dev/null 2>&1 || { local ret="1"; }
    if [ "\$ret" -ne 0 ]; then
        return 1
    fi
    return 0
}
if program_exists dart; then
  dart $path \$hookName
  if [ "\$?" -ne "0" ];then
    exit 1
  fi
else
  echo "dart_git_hooks > \$hookName"
  echo "Cannot find dart in PATH"
fi
''';
  return temp;
}

/// dart code template
const userHooks = r'''
import 'dart:core';
import 'dart:io';

import 'package:git_hooks/git_hooks.dart';

void main(List<String> arguments) {
  // ignore: omit_local_variable_types
  Map<Git, UserBackFun> params = {Git.commitMsg: commitMsg, Git.preCommit: preCommit};
  //Git.commitMsg: commitMsg,
  GitHooks.call(arguments, params);
}

Future<bool> commitMsg() async {
  String commitMsg = Utils.getCommitEditMsg();
  print('commit message $commitMsg');
  if (commitMsg.startsWith('fix:') ||
      commitMsg.startsWith('feat:') ||
      commitMsg.startsWith('docs:') ||
      commitMsg.startsWith('style:') ||
      commitMsg.startsWith('refactor:') ||
      commitMsg.startsWith('test:') ||
      commitMsg.startsWith('chore:')) {
    return true; // you can return true let commit go
  } else {
    print(
      'commit message 格式： `fix:`, `feat:`, `docs:`, `style:`, `refactor:`, `test:`, `chore:`,'
      ' \n 参考地址：https://www.ruanyifeng.com/blog/2016/01/commit_message_change_log.html',
    );
    return false;
  }
  return true;
}

Future<bool> preCommit() async {
  try {
    print('dart analyze 开始分析... ${DateTime.now()}');
    //--options analysis_options.yaml lib
    ProcessResult result = await Process.run('dart', ['analyze']);
    print('dart analyze 分析中... ${result.stdout}');
    print("dart analyze 分析完成 - ${DateTime.now()} \t 返回码：${result.exitCode}");
    // print('dart analyze err: ${result.stderr}');
    if ('${result.stderr}'.isNotEmpty) return false;
  } catch (e) {
    print('错误：$e');
    return false;
  }
  return true;
}

''';

/// hooks header
String createHeader() {
  var rootDir = Directory.current;
  var f = File(rootDir.path + '/pubspec.yaml');
  var text = f.readAsStringSync();
  Map yaml = loadYaml(text);
  String name = yaml['name'] ?? '';
  String author = yaml['author'] ?? '';
  String version = yaml['version'] ?? '';
  String homepage = yaml['homepage'] ?? '';
  return '''
#!/bin/sh
# !!!don"t edit this file
# $name
# Hook created by $author
#   Version: $version
#   At: ${DateTime.now()}
#   See: $homepage#readme

# From
#   Homepage: $homepage#readme

''';
}
