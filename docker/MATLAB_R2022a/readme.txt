sudo DOCKER_BUILDKIT=1 docker build --tag=fire_matlab_ismrmrd_server .
docker run --rm -it --name aa --mac-address 02:42:ac:11:00:06 -v /var/run/docker.sock:/var/run/docker.sock -v /C//Users/pan21/Desktop/DockerOut:/tmp/share pany3/fire-matlab-server:debug
docker run --rm -p 9095:9095 --name bb -v /C//Users/pan21/Desktop/DockerOut:/tmp/share fire-matlab-server 9095
docker run -it --rm --entrypoint=/bin/bash fire-matlab-server

UPDATE MATLAB CODE
cd /opt/code
apt-get update && apt-get install -y git
rm -r matlab-ismrmrd-server-master
git clone https://github.com/panyue3/matlab-ismrmrd-server-master.git
cd matlab-ismrmrd-server-master
matlab -r buildDocker

BUILD CHROOT
docker create --name tmpimage fire-matlab-server:latest
docker export tmpimage > fire-matlab-prompt.tar
docker rm tmpimage
docker run -it --rm --privileged=true -v /C//Users/pan21/Desktop/DockerOut:/tmp ubuntu /bin/bash
dd if=/dev/zero of=/tmp/fire-matlab-prompt.img bs=1M count=
mke2fs -F -t ext3 /tmp/fire-matlab-prompt.img
mkdir /mnt/chroot
mount -o loop /tmp/fire-matlab-prompt.img /mnt/chroot
tar -xvf /tmp/fire-matlab-prompt.tar --directory=/mnt/chroot
umount /mnt/chroot
exit

PLACE CHROOT IMAGE IN C:\Medcom\MriCustomer\ice\fire\chroot

\usr\bin\mlrtapp\fire_matlab_ismrmrd_server\fsroot\fire_matlab_\

