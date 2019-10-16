import 'package:git_hooks/runtime/run.dart' as m;
import './install/CreateHooks.dart';
import "package:yaml/yaml.dart";
import "dart:io";

main(List<String> arguments) {
  if (arguments != null && arguments.length > 0) {
    String str = arguments[0];
    if (arguments?.length == 1) {
      if (str == 'create') {
        //安装的时候创建文件
        CreateHooks().copyFile();
      } else if (str == '-h' || str == '-help') {
        help();
      } else if (str == '-v' || str == '--version') {
        Directory rootDir = Directory.current;
        File f = new File(rootDir.path + "/pubspec.yaml");
        String text = f.readAsStringSync();
        Map yaml = loadYaml(text);
        String version = yaml['version'];
        print("v" + version);
      } else {
        print("'${str}' is not a git_hooks command,see follow");
        print('');
        help();
      }
    } else if (str == 'run') {
      //运行的时候执行
      m.run(arguments);
    } else {
      print(
          "Too many positional arguments: 1 expected, but ${arguments.length} found");
      print('');
      help();
    }
  } else {
    print("please Enter the command");
    print('');
    help();
  }
}

void help() {
  print("Common commands:");
  print("");
  print(" git_hooks create");
  print("   Create hooks files in '.git/hooks'");
  print("");
}
