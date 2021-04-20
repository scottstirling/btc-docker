# Bitcoin Docker Image / Container

Builds bitcoin core cloned from git source on an Ubuntu 20.04.2 LTS with:
### bitcoin:
- wallet disabled (see Dockerfile config for bitcoin)
- GUI disabled (see Dockerfile)
- debug symbols removed from bitcoin binaries
### docker:
- vol mounted to store/read blockchain data outside the container runtime
- bitcoin:bitcoin user and group created
- less and tiny-vim installed

## Requirements
 * DockerDesktop 3.3.1 (or newer) for OS X or Windows (or docker 20.10.6 on Linux)
 * Building the image from source project files requires the host running the build to have access to the Internet to pull down a base Ubuntu image and packages to install (see the Dockerfile for details).
 * To build and run, the docker and docker-compose command line tools (which are included with Docker Desktop) should show these minimum versions:

```
$ docker -v
Docker version 20.10.5, build 55c4c88

$ docker-compose -v
docker-compose version 1.29.0, build 07737305
```
 
## Building the image
To build the Docker image locally:

 * Download and install latest stable release of Docker Desktop for your OS (or just Docker if on Linux) from https://docs.docker.com/get-docker/
 * In a terminal (or PowerShell or Cygwin on Windows), cd into the project directory.

```
docker-compose build
```
or (with latest compose incorporated into docker cli):
```
docker compose build
```

[output will update to console for 40 - 90 minutes to build the image, depending on network and host resources]

Let the build run until completed (hopefully no errors). If errors occur please report them.

Now the image will have been built locally to your docker environment/installation and can be run in a container or saved to a tar file (see below for steps to run containers and optionally save an image).  Note: the built image does not appear as output in the project, but rather will be stored in docker's internal, layered file system, which you can insepct via commands such as:

```
docker image ls
```

After the image has been built (or loaded, see below) docker tools should show a newly added image in addition to any others you may have, as shown below:

```
$ docker image ls
REPOSITORY   TAG       IMAGE ID       CREATED             SIZE
btc-docker   latest    627e5b5c8133   About an hour ago   1.74GB
```

## Running a container with the image
Whether the image was built or loaded, it can be run the same way, either via command line or wrapper scripts for the command line.

To run the Docker built image in a local container from the command line in the background use the -d arg after the up command:

```
$ docker-compose up -d
```
The output of a successful startup should look something like below with a unique ID for your local CONTAINER ID instance:

```
$ docker compose up -d
[+] Running 1/1
 ⠿ Container btc-docker_btc-docker_1  Started                                   3.0s
```

Check the process is up via the command line:

```
$ docker compose ps
NAME                      SERVICE             STATUS              PORTS
btc-docker_btc-docker_1   btc-docker          running             0.0.0.0:8333->8333/tcp, 8332/tcp
```

or 

```
$ docker compose ls
NAME                STATUS
btc-docker          running(1)
```

Check the log output:
```
$ docker compose logs
btc-docker_1  | Environment info:
btc-docker_1  | hostname: 647d2c17a604
btc-docker_1  | ip address: 172.21.0.2
btc-docker_1  | TZ: America/New_York
btc-docker_1  | date: Mon Apr 19 21:32:25 EDT 2021
btc-docker_1  | operating system: Ubuntu 20.04.2 LTS \n \l
btc-docker_1  | kernel: Linux 647d2c17a604 5.10.25-linuxkit #1 SMP Tue Mar 23 09:27:39 UTC 2021 x86_64 x86_64 x86_64 GNU/Linux
btc-docker_1  | bitcoind version: Bitcoin Core version v21.99.0-13d27b452d4b
btc-docker_1  | Hello, from bitcoind-docker container
```

From the host outside of the container one can also use the docker exec command to start an interactive ssh session between the host and the root user on the running container.  Note: any changes made to a running container will be lost when it is shut down, unless the container itself is exported and saved (which can be done but is not described here; please see docker help for more info if interested).

Using docker exec to obtain a bash shell into the container locally:
```
$ docker exec -it btc-docker_btc-docker_1 bash
root@647d2c17a604:/tmp#
```

### VPN Note
The docker container has access to the same network as its host, including VPN or IPSEC tunnels.
No separate VPN setup or install is needed in the container.  VPN must be connected on the host when the container starts, 
otherwise the container will not be able to connect to VPN endpoints.  If you start a new VPN connection after starting the container, 
the container must be restarted to use it.

### Note for Windows 10 users running the container
Use Windows PowerShell to run the commands and scripts on Windows docker hosts.

## Loading a pre-built image from a saved image
Docker can load an image from a tar file instead of building it dynamically.

Most docker projects provide an image build for loading directly, and a separate project with assets to build the image or customize it.  It is possible to save to a tgz and then load your own pre-built image from the project as described above.

If loading a saved version of the image rather than building it, use docker's load command to read in the image from a gzipped tar file and its image tag like so:

```
$ docker load < /path/to/<name of image file>_2021-04-18.tar.gz
```
NOTE: the expanded image size is about 1.8 GB, but reduces to around 650 MB when compressed by zip or gzip.

Once loaded, you can use the project docker-compose.yml and docker-compose.override.yml files to "docker-compose up -d" the pre-built image. 

## Using and testing the container

The test user logins are:

* bitcoin
* bitcointester

Their test passwords will come out set the same and are exposed in the Dockerfile build commands and test-users.sh script: b1tc01n

## Description of files in this docker project:

1. Dockerfile - specifies how to build the image and some custom tasks to setup users and configuration. See code and comments in Dockerfile for more details.

2. docker-compose.yml - main entry-point to build the image and run the container via docker-compose command line.

3. docker-compose.override.yml - example, customizable docker-compose override settings, such as the host port, data volumes or default container time zone.

2. scripts/start.sh - included in the image. echoes some debug lines and (optionally) starts the bitcoind service in the container and tails /dev/null (a Docker hack / convention used to keep the container running indefinitely). This file is executable 755, copied into the built image under /sbin.

4. docker-run.sh - example wrapper script to run the container locally and set additional variables to modify runtime.  This script is a wrapper to the docker-compose command for local use..

5. docker-save.sh - example wrapper script to run the docker save command and output a gzipped and time-stamped tar file of the image, which can be backed up or transported elsewhere to load without going through the build process. 

9. README.md - markdown formatted source of this README.
