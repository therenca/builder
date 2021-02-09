import 'package:dcli/dcli.dart';
import 'package:leo/leo.dart' as leo;
import 'package:yaml/yaml.dart' as yaml;

class Build {	
	static void mkdir(String folder){
		try {
			'mkdir $folder'.run;
			'mkdir $folder/conf/'.run;
		} catch(e){
			leo.pretifyOutput('[BUILDER | $folder] unable to run mkdir', color: 'red');
		}
	}

	static void aot(yaml.YamlList toBuild, String targetFolder){
		toBuild.forEach((build) {
			var isMove = false;
			var buildParts = build.split(',');
			var toBuild = buildParts[0];
			var builtTo = buildParts[1];
			
			try {
				'dart2native $toBuild -o $builtTo'.run;
				isMove = true;
			} catch(e){
				leo.pretifyOutput('[BUILDER | aot] unable to build $toBuild', color: 'red');
			}

			if(isMove){
				try {
					'mv -v $builtTo $targetFolder/'.run;
				} catch(e){
					leo.pretifyOutput('[BUILDER | move] unable to move $builtTo to $targetFolder', color: 'red');
				}
			}
		});
	}

	static void copy(yaml.YamlList confFolders, String targetFolder){
		confFolders.forEach((conf) {
			try {
				'cp -rvf $conf $targetFolder/'.run;
			} catch(e){
				leo.pretifyOutput('[BUILDER | copy | $conf] unable to run copy', color: 'red');
			}
		});
	}

	static rsync(String ip, String user, String path, String targetFolder){
		try {
			"rsync -rvz -e 'ssh' --progress $targetFolder $user@$ip:path".run;
		} catch(e){
			leo.pretifyOutput('[BUILDER | sync] unable to sync with $ip', color: 'red');
		}
	}

	static rm(String path){
		"rm -rvf $path".run;
	}
}