# Docker Technologies For DevOps and Developers
## Hypervisor-based Virtualization

VMware and Virtualbox are hypervisor providers.

* allows one to divide a machine into multiple VMs. Each VM uses only its own CPU, Memory and storage resources.
* Each virtual machine installs a fully functional guest operating system with its own kernel, memory management, device routers, daemons etc…
* to just set up and run an application we have to go through a lot in recreating a fully functional guest operating system.
* portability is not guaranteed 
* virtualization happens at the hardware level

## Container-based

Container Engine (example: Docker Daemon)

* each guest instance is called a container. within each container we install the application and all the libraries the application depends on 
* only one kernel
* containers share the same kernel — the container engine.
* virtualization happens at the operating system level 
* containers share the host’s OS
* no guest operating system required
* the container only contains the required components for the application
* containers consume less CPU, RAM and storage space than VMs.
* we can have more containers running on one physical machine than VMs.
* containers contain the minimum requirements for running the application
* containers are entirely self sufficient bundles 


## Docker Software’s Client-Server Architecture
* docker daemon, docker server, docker engine — all the same
* the user does not directly interact with the daemon (docker server).
* the user uses the docker client to interact with the docker server (daemon)
* The daemon
	* builds containers
	* runs containers
	* distributes containers
* docker daemon, client and containers run on the same host.
* you can connect a docker client to a remote docker daemon
* docker daemon cannot run natively on Mac OS or windows because docker daemon uses Linux specific kernel features
* docker daemon runs inside a docker machine — a lightweight Linux VM — for Mac OS or Windows.

## Images
* read only templates use to create containers.
* images are created with docker build command
* images can be composed of other images because they can become large
* images are stored in a docker registry like docker hub
* images are tagged for versioning

## Containers
* If an image is a class, then a container is an instance of a class — a runtime object.
* containers are lightweight and portable encapsulations of an environment in which to run applications
* containers are created from images. inside a container, it has all the binaries and dependencies needed to run the application

## Registries and Repositories
* A registry is where we store our images.
* docker hub is a public registry
* images are stored in repositories
* docker repository is a collection of different docker images with the same  name, that have different tags, each tag usually represents a different version of the image

## Running first container
* `docker run busybox:1.24 echo "hello world"` containers must be run from an image and its version
* every execution of  `docker run image:tagged-version`  spins up a new container

## Deep dive in containers
* containers running in the foreground are attached to the console from which they are executed
* containers running in the background are not attached to a particular shell. This is called running containers in detached mode. In short, when running a container in detached mode we can run the container in a shell and still use that very same shell for other commands. 
* docker inspect shows low level information about a container or image

## Docker Port Mapping and Docker Logs Command
* The host that is referred to is the linux virtual machine running docker if you are running docker in Windows or MacOS
* Docker can expose a port inside the container: `docker run -it --rm -p 8888:8080 tomcat:8.0` — in this case `8888` is localhost port, the port of the linux virtual machine running docker. `8080` is the port the apache process, tomcat, runs on. The format is as follows `-p host_port:container_port`. This exposes the container port to the host port

## Docker Image Layers
* read only layers that represent file system differences
* images are made by the file system layers, differences in this file system are considered layers.
* images are stacked on top of each other to form a base for container’s file system
* Image layer example:
	1. bootfs (kernel)
	2. Debian (Base Image)
	3. add emacs  (Image)
	4. add apache (Image)
	5. writable (container)
* when we create a new container a new thin writable layer on top of the underlying stack. this is called the writable container layer. All changes made to the running container such as writing new files, modifying existing files and deleting existing files are written to this this writable container layer. 
* the main difference between the container and the image is the top writable layer.
* when the container is deleted, the writable layer is also deleted, but the underlying image remains unchanged.
* multiple containers can share access to the same underlying image — only diffing in the writable layer.

## Build Docker Images - Committing changes made in a container
* docker commit command will save the changes we made to the Docker container’s file system to a new image. `docker commit container_ID repository_name:tag`

## Build Docker Images - Writing a Dockerfile
* A Dockerfile is a text document that contains all the instructions users provide to assemble an image 
* What is an instruction? an instruction can be, installing a program, adding some source code or specifying the command to run after the container starts up and so on
* docker can build images automatically by reading instructions from a Dockerfile. Each instruction will create a new image layer to the image
* Instructions specifying what to do when creating an image.
* FROM, instruction specifies the base image.
* Docker build command (`docker build -t robskrob/delian .`)

### Docker Build Context
* Docker build command takes the path to the build context as an argument.
* Docker build builds the image using the instructions in the Dockerfile.
* The path specifies where  to find the files for the context of the build on the docker daemon. For example, if we want to copy some source code from local disk to the container those files must exist in the build context path.
* The docker daemon could be running on a remote machine. No parsing of the docker file happens on the client side 
* When the build process starts, docker client would pack all the files in the build context into a tarball then transfer the tarball file to the docker daemon
* By default, docker would search for the Dockerfile in the root directory of the build context path.
* If your Dockerfile does not live in the build context path that’s ok. You can tell docker to search for a different file by providing a `-f` option.
* The `docker build` process:
	1. `Sending build context to Docker daemon`. On `docker build` the docker client is transferring all the files inside the build context which is my current folder from my local machine to the docker daemon.
	2. `Step 1 FROM`. Docker is going through the instructions in the docker file
	3. `Step 2 RUN`. Docker starts a new container from the base Debian image
* Docker daemons runs each instruction inside a contain. A Container is a writable process that will write file system change to an image. In our case it installs a program.  Once docker has written changes to the image and committed that image, Docker removes the container. For an instruction docker creates a new container, runs the instruction, commits a new layer to the image and removes the container. Containers are ephemeral. In the build process we just use a container to write image layers and once they are finished we get rid of them. 
* After docker commits the container as a new image, it starts a new container from the recently committed image for the next instruction. 
* Docker starts a new container for each instruction in the image
* In short, the process is while building a docker file to create a container to `RUN` each instruction which makes changes to the container’s file system, commit container’s new changes — the container itself is committed — as a new image (layer to the image) and then remove the container.  Spin up a new container from the image docker committed in the previous instruction for the next instruction in `RUN`.
* The Docker daemon — not the docker client — builds the image.
* Images are persistent and read only.

## Dockerfile In Depth
* Each `RUN` command will execute the command on the top writable layer of the container, then commit the container as a new image.
* The new image is used for the next step in the Dockerfile. So each `RUN` instruction will create a new image layer.
* It is recommended to chain the `RUN` instructions in the Dockerfile to reduce the number of image layers it creates.

### Sort Multi-line Arguments Alphanumerically
* This will help you avoid duplication of packages and make the list much easier to update.

### CMD Instructions
* CMD instructions specifies what command you want to run when the container starts up.
* If we don’t specify CMD instruction in the Dockerfile, Docerk will use the default command defined in the base image. In our case the base image is `debian:jessie` and the default command is `sh`, bash.
* The CMD instruction doesn’t run when building the image, it only runs when the container starts up.
* You can specify the command in either exec for which is preferred or in shell form.

### Docker cache
* Each time Docker executes an instruction it builds a new image layer.
* The next time, if the instruction doesn’t change, Docker will simply reuse the existing layer.
* In order to not use the cache, change the instruction of `RUN`

### COPY Instruction
* The COPY instruction copies new files or directories from build context and adds them to the file system of the container.

### ADD Instruction
* ADD instruction can not only copy files but also allow you to download a file from the internet and copy to the container.
* ADD instruction also has the ability to automatically unpack compressed files.
* The rule is: use COPY for the sake of transparency, unless you’re absolutely sure you need ADD.
* COPY only supports the basic copying of local files into the container. COPY is just a stripped down version of ADD.

## Push Docker Images to Docker Hub

### Latest Tag
* Docker will use latest as a default tag when no tag is provided.
* A lot of repositories use it to tag the most up to date stable image. However, this is still only a convention and is entirely not being enforced.
* Images which are tagged latest will not be updated automatically when a newer version of the image is pushed to the repository.
* Avoid using latest tag.

## Containerize a Simple Hello World Web Application
* Dockerfile is used to build the docker container for the web app
* The Dockerfile’s instructions:
	* Base image already has python installed. In this file specifically it is just specifying the version of python.
	* Install Flask
	* Adding a user `RUN useradd -ms /bin/bash admin`. the `ms` option creates a default home directory for  the `admin` user. The default shell of the `admin` user is `bash`.
	* `USER admin` makes sure that the app will be run as `admin`, which has an appropriate set of permissions.
		* the `USER` instruction, which runs the app process, should always be set to a non privileged user within the containers. Otherwise, the app process will be run as `root` within the container.
		* If an attacker breaks into the container he will have `root` access in the host machine because the `uid`s are the same. In theory a `root` user within a docker container cannot escalate to be a `root` user in the host machine, but some people believe that it could be possible to do so.
		* We also want to have the minimum amount of privileges for our OS user that runs the app so that the application’s files’ permissions do not change to `root`s permission level. This will create painful havoc for our app because permissions in its files may conflict with each other and with the app’s process’s user privileges.
* `WORKDIR` (“the working directory”) — sets the working directory for any run `CMD`, enter point, `COPY` or `ADD` instructions that follow this instruction in the docker file.
* `COPY app` , copy the app directory from local host to the container.
* `CMD ["python", "app.py"]` — because the working directory has been defined to `/app` we can just use the relative path to the `app.py` file.
* The build context is the current directory because the Dockerfile sits in the current directory.
* The build context is wherever the Dockerfile sits.
* `docker exec` allows you to run a command in a running container. 

## Docker Container Links
* the goal is to link the redis container and our python app container which will allow them to talk to each other without having to expose any network ports.
* container links allow containers to discover each other and securely transfer information about one container to another container.
* When a link is make a conduit is set up between the source container and the recipient container. The recipient container can then access select data about the source container.
* In our case, Redis would be the source container and the `dockerapp` container would be the recipient container.
* the name of the link for the container — redis — can serve as the name for the host address. Instead of using a network address string, we can use the name of the container as the docker container link.

### How do container links work behind the scenes?
	* when a linux machine gets started it will need to know the mapping of some hostnames of the ip addresses before DNS can be referenced. this mapping is kept in the `/etc/hosts`  file
	* host name `redis` will be resolved as the `ip` address of 172.17.0.2
	* the `ip` is the `ip` address of the `redis` container

### Benefits of Docker Container Links
	* The main use for docker container links is when we build an application with micro service architecture, we are able to run many independent components in  different containers.
	* Docker creates a secure tunnel between the containers that doesn’t need to expose any port externally on the container.

## Automate Current Workflow with Docker Compose
* Manual linking containers and configuring services become impractical when the number of containers grow.
* the build instruction of the docker compose file defines the path to the Dockerfile which will be used to build the dockerapp image.
* docker can either run containers from existing images or docker can build an image from a docker file and then run it.
* All services need either an image or a build instruction

### Docker Compose
* Docker compose is a very handy tool to quickly get docker environment up and running.
* Docker compose uses yams files to store the configuration of all the containers, which removes the burden to maintain our scripts for docker orchestration.

