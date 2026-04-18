1) generate a pub file (https://vast.ai/docs/instance-setup/ssh)
	- ssh-keygen -t rsa
	- ssh-add; ssh-add -l
	- mv ~/.ssh/id_rsa.pub ~/.ssh/`whatever-name`.pub
	- mv ~/.ssh/id_rsa ~/.ssh/`whatever-name`
	- cat ~/.ssh/id_rsa.pub
	- past it into the server's 'Add/Remove SSH Keys' section

side note: 
	- to disable the auto tmux session, `touch ~/.no_auto_tmux`
	- if you get an issue with opencv, try `apt-get update && apt-get install libgl1`
	- if you forget you ghp password, just run on your local machine `getGhp` itll copy it to your clipboard

TensorFlow stuff:
	- `error: libdevice not found at ./libdevice.10.bc`
		* first thing install neofetch to get the system info needed
			- Architecture: [x86_64, aarch64, ppc64le, s390x, ...]
			- Distribution: [Ubuntu, Debian, Fedora, CentOS, ...]
			- Version: [20.04, 22.04, ...]
		* Second thing go to `https://developer.nvidia.com/cuda-12-2-0-download-archive`
			- fill in everything
			- select `deb (network)`
			- run the commands
		* finally launch a new instances with the right docker image cuz there is no hope in this world
