#### Builder

Compiles dart code to an AOT bundle, also syncs config files accordingly
An example of a yaml with the relevant info would look like this:

```yaml
folder: production # folder the builds and confs will be dumped to
conf:
  # path to conf folders / files
  - ~/projects/project-name/lib/conf/conf1
  - ~/projects/project-name/lib/conf/conf2

build:
  # path to dart files to compile
  - ~/projects/project-name/bin/main.dart, program-name # on the remote side will reflec as production/program-name
  - ~/projects/project-name/bin/main.dart, /path/to/program-name # on the remote side will reflect as production/path/to/program-name

rsync:
  # assumes you are accessing the remote machine using ssh key, if not, this will fail
  user: user
  ip: ip address
  path: /path/to/folder/ # where to dump the builds and config files

commands:
  # these commands will run after everything has been synced to the remote server
  - mkdir -p /path/to/folder
  - kill 21322
  - systemctl restart service
```

The builder takes two arguments. The first parameter tells the builder what to do. Either sync the config to the server or build the binaries for the server, or both. The second parameter is the location of the yaml file as follows:

```bash
./builder all /path/to/yaml/file
./builder config /path/to/yaml/file
./builder build /path/to/yaml/file
```

> check releases for the builder binaries