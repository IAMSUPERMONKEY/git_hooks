import 'package:dart_git_hooks/src/main_command.dart';

void main(List<String> arguments) {
  final command = MainCommand();
  command.run(arguments);
}
