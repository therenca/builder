import 'package:dcli/dcli.dart';
import 'package:leo/leo.dart' as leo;
import 'package:yaml/yaml.dart' as yaml;

class Build {	
	static void mkdir(String folder){
		try {
			'mkdir $folder'.run;
			'mkdir $folder/conf/'.run;
		} catch(e){
			leo.pretifyOutput('[BUILDER | $folder] unable to run mkdir', color: leo.Color.red);
		}
	}

	static void aot(yaml.YamlList toBuild, String targetFolder){
		
		toBuild.forEach((build) {
			var isMove = false;
			var buildParts = build.split(',');
			var toBuild = buildParts[0] as String;
			var builtTo = buildParts[1] as String;
			
			late String programName;
			var _folder = targetFolder;
			if(builtTo.contains('/') == true){
				var temp = builtTo.split('/');		
				programName = temp.removeAt(temp.length - 1);
				for(var _dir in temp){
					_folder += '/$_dir';
				}
				'mkdir -p $_folder'.run;
			} else {
				programName = builtTo;
			}
			
			try {
				'dart compile exe $toBuild -o $programName'.run;
				isMove = true;
			} catch(e){
				leo.pretifyOutput('[BUILDER | aot] unable to build $programName', color: leo.Color.red);
			}

			if(isMove){
				try {
					'mv -v $programName $_folder/'.run;
				} catch(e){
					leo.pretifyOutput('[BUILDER | move] unable to move $programName to $_folder', color: leo.Color.red);
				}
			}
		});
	}

	static void copy(yaml.YamlList confFolders, String targetFolder){
		confFolders.forEach((conf) {
			try {
				'cp -rvf $conf $targetFolder/'.run;
			} catch(e){
				leo.pretifyOutput('[BUILDER | copy | $conf] unable to run copy', color: leo.Color.red);
			}
		});
	}

	static rsync(String ip, String user, String path, String targetFolder){
		try {
			"rsync -rvz -e 'ssh' --progress $targetFolder $user@$ip:$path".run;
		} catch(e){
			leo.pretifyOutput('[BUILDER | sync] unable to sync with $ip', color: leo.Color.red);
		}
	}
	
	static execute(String ip, String user, yaml.YamlList commands){
		for(var command in commands){
			try {
				"ssh $user@$ip $command".run;
			} catch(e){
				leo.pretifyOutput('[BUILDER | execute] unable to run $command', color: leo.Color.red);
			}
		}
	}

	static rm(String path){
		"rm -rvf $path".run;
	}
}
