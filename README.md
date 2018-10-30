# r2-docker

r2 docker build
- ubuntu
- nodejs
- python pip
- r2
- r2pipe
- r2frida
- r2dec

Takes your custom config file (.radare2rc) from the current directory
Copies contents of ./data to /home/r2/data
A sample binary was included inside ./data for testing purposes

Build docker image with:
> docker build -t r2-docker:latest .

Open binary with frida:
> r2 frida:/home/r2/data/sample
