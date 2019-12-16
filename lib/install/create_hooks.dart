import "dart:io";
import "package:git_hooks/git_hooks.dart";
import "./hook_template.dart";
import 'package:path/path.dart';

class CreateHooks {
  Directory rootDir = Directory.current;
  Future<bool> copyFile({String realPath}) async {
    if (realPath == null) {
      realPath = './git_hooks.dart';
    } else {
      if (!realPath.endsWith(".dart")) {
        print("the file what you want to create is not a dart file");
        exit(1);
      }
    }
    Logger logger = new Logger.standard();
    try {
      String commonStr = commonHook;
      commonStr = createHeader() + commonStr;
      Directory gitDir = Directory(uri(rootDir.path + "/.git/"));
      String gitHookDir = uri(rootDir.path + "/.git/hooks/");
      if (!gitDir.existsSync()) {
        print(gitDir.path);
        throw new ArgumentError('.git is not exists in your project');
      }
      Progress progress = logger.progress('create files');
      for (var hook in hookList.values) {
        String path = gitHookDir + hook;
        var hookFile = new File(path);
        if (!hookFile.existsSync()) {
          await hookFile.create();
        }
        await hookFile.writeAsString(commonStr);
        if (!Platform.isWindows) {
          await Process.run('chmod', ['777', path])
              .catchError((onError) => print(onError));
        }
      }
      File hookFile = new File(uri(absolute(rootDir.path, realPath)));
      if (!hookFile.existsSync()) {
        String exampleStr = userHooks;
        await hookFile.createSync();
        await hookFile.writeAsStringSync(exampleStr);
      }
      print("All files wrote successful!");
      progress.finish(showTiming: true);
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }
}
