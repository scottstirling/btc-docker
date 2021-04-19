# Bitcoin Docker Image / Container

## Requirements
 * DockerDesktop 2.5.0.1 (or newer) for OS X or Windows (or docker 19.03.14 on Linux)
 * Building the image from source project files requires the host running the build to have access to the Internet to pull down a base Ubuntu image and packages to install for Flash and Firefox (see the Dockerfile for details).
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
 * In a terminal (or PowerShell or Cygwin on Windows), cd into the flash-docker-rdp project directory.

```
export DOCKER_BUILDKIT=1 COMPOSE_DOCKER_CLI_BUILD=1

docker-compose build
```
[output will update to console for 8 - 20 minutes to build the image, depending on network and host resources]

Let the build run until completed (hopefully no errors). If errors occur please report them.

Now the image will have been built locally to your docker environment/installation and can be run in a container or saved to a tar file (see below for steps to run containers and optionally save an image).  Note: the built image does not appear as output in the project, but rather will be stored in docker's internal, layered file system, which you can insepct via commands such as:

```
docker-compose images
```
or 

```
docker image ls
```

After the image has been built (or loaded, see below) docker tools should show a newly added image in addition to any others you may have, as shown below:

```
$ docker-compose images
              Container                      Repository         Tag       Image Id       Size
-----------------------------------------------------------------------------------------------
btc_docker_1                                        btc-docker   latest  e26c93965306  6.01GB
```
or:

```
$ docker image ls
REPOSITORY            TAG          IMAGE ID       CREATED       SIZE
btc-docker           latest    e26c93965306   7 minutes ago   6.01GB
```

## Running a container with the image
Whether the image was built or loaded, it can be run the same way, either via command line or wrapper scripts for the command line.

To run the Docker built image in a local container from the command line:

```
$ docker-compose up -d
```
The output of a successful startup should look something like below with a unique hash for your local CONTAINER ID instance:

```
$ docker-compose up -d
Creating network "btc-docker_local" with the default driver
Creating btc-docker_1 ... done
```
Check the process is up via the command line:

```
$ docker-compose ps
                 Name                       Command       State           Ports
----------------------------------------------------------------------------------------
btc_docker_1                             /sbin/start.sh   Up      0.0.0.0:3390->3390/tcp
```
Now that the container is running you can use any Remote Desktop client to connect to the host where the container is running, and the port that the container has mapped to the host to listen for RDP clients. Set the RDP Client "PC Name" to localhost:3390. 

When logging in via RDP you will be prompted for login credentials.  Use the test credentials described below, e.g., btcadmin  w/password b1tc01n. 

From the host outside of the container one can also use the docker exec command to start an interactive ssh session between the host and the root user on the running container.  Note: any changes made to a running container will be lost when it is shut down, unless the container itself is exported and saved (which can be done but is not described here; please see docker help for more info if interested).


### VPN Note
The docker container has access to the same network as its host, including VPN or IPSEC tunnels.
No separate VPN setup or install is needed in the container.  VPN must be connected on the host when the container starts, 
otherwise the container will not be able to connect to VPN endpoints.  If you start a new VPN connection after starting the container, 
the container must be restarted to use it.

### Note for Windows 10 users running the container
Use Windows PowerShell to run the commands and scripts on Windows docker hosts.

## Loading a pre-built image from a saved image
Docker can load an image from a tar file instead of building it dynamically.

Most docker projects provide an image build for loading directly, and a separate project with assets to build the image or customize it.  Flash licensing and security requirements in most organizations have led us to recommend building the image yourself locally for license compliance and transparency. You can save and then load your own pre-built image from the project as described above.

If loading a saved version of the image rather than building it, use docker's load command to read in the image from a gzipped tar file and its image tag like so:

```
$ docker load < /path/to/flash-docker-rdp/dist/<name of image file>_2021-04-18.tar.gz
```
NOTE: the expanded image size is about 1.8 GB, but reduces to around 650 MB when compressed by zip or gzip.

Once loaded, you can use the project docker-compose.yml and docker-compose.override.yml files to "docker-compose up -d" the pre-built image. 

## Using and testing the container

The test user logins are:

* btcadmin
* scott
* mallesh

Their test passwords are all the same and are exposed in the Dockerfile build commands: p1v0tr33

The test users are all in a Linux group called "TBD" in the docker container. These are for demo purposes.  The authentication can be tied into LDAP or other identity management solutions.

## Description of files in this docker project:

1. Dockerfile - specifies how to build the image and some custom tasks to setup users and configuration. See code and comments in Dockerfile for more details.

2. docker-compose.yml - main entry-point to build the image and run the container via docker-compose command line; replaces previous release's docker-build.sh and docker-run.sh.

3. docker-compose.override.yml - example, customizable docker-compose override settings, such as the host port or default container time zone.

2. scripts/start.sh - included in the image. echoes some debug lines and starts the xrdp service in the container and tails /dev/null (a Docker hack / convention used to keep the container running indefinitely). This file is executable 755, copied into the built image under /sbin.

4. docker-run.sh - example wrapper script to run the container locally and set additional variables to modify runtime.  This script formerly wrapped the docker command but now wraps the docker-compose command.

5. docker-save.sh - example wrapper script to run the docker save command and output a gzipped and time-stamped tar file of the image, which can be backed up or transported elsewhere to load without going through the build process. 

9. README.md and README.pdf - markdown formatted source and PDF rendering of this README.