
import 'dart:io';
import 'package:leo/leo.dart'as leo;
import 'package:yaml/yaml.dart' as yaml;
import 'package:builder/builder/build.dart';

void main(List<String> args) async {

	if(args.isNotEmpty && args.length == 2){

		var _getFileHelper = () async {
			var yamlFile = File(args.last);
			return await yamlFile.readAsString();
		};

		var future = _getFileHelper();
		var yamlBlob = await leo.tryCatch(future);

		if(yamlBlob != null){
			var yamlDoc = yaml.loadYaml(yamlBlob);

			var targetFolder = yamlDoc['folder'];
			var confFiles = yamlDoc['conf'];
			var toBuild = yamlDoc['build'];
			var commands = yamlDoc['commands'];

			var ip;
			var user;
			var remotePath;
			var syncInfo = yamlDoc['rsync'];
			if(syncInfo != null){
				ip = syncInfo['ip'];
				user = syncInfo['user'];
				remotePath = syncInfo['path'];
			}

			targetFolder ??= 'production';
			confFiles ??= <yaml.YamlList>[];
			toBuild ??= <yaml.YamlList>[];
			commands ??= <yaml.YamlList>[];

			switch(args.first){
				case 'config': {
					Build.mkdir(targetFolder);
					Build.copy(confFiles, targetFolder);
					Build.rsync(ip, user, remotePath, targetFolder);
					Build.execute(ip, user, commands);
					Build.rm(targetFolder);

					break;
				}

				case 'build': {
					Build.mkdir(targetFolder);
					Build.aot(toBuild, targetFolder);
					Build.rsync(ip, user, remotePath, targetFolder);
					Build.execute(ip, user, commands);
					Build.rm(targetFolder);

					break;
				}

				case 'all': {
					Build.mkdir(targetFolder);
					Build.aot(toBuild, targetFolder);
					Build.copy(confFiles, targetFolder);
					Build.rsync(ip, user, remotePath, targetFolder);
					Build.execute(ip, user, commands);
					Build.rm(targetFolder);

					break;
				}

				default: {
					leo.pretifyOutput('[BUILDER] expected values are action "config" or "build" or "all"', color: leo.Color.red);

					break;
				}
			}
		} else {
			leo.pretifyOutput('[BUILDER] yaml file: ${args[1]} does not exist', color: leo.Color.red);
		}
	} else {
		leo.pretifyOutput('[BUILDER] only one action needed, either action "config" or "build" or "all", also specify the path to the yaml file. EG: ./builder config /path/to/yaml', color: leo.Color.red);
	}
}