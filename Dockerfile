# set base os
FROM ubuntu:12.04
ENV DEBIAN_FRONTEND noninteractive
# Set correct environment variables
ENV HOME /root
# Configure user nobody to match unRAID's settings
RUN \
usermod -u 99 nobody && \
usermod -g 100 nobody && \
usermod -d /home nobody && \
chown -R nobody:users /home && \

# Install Dependencies ,add startup files and patchfile
mkdir -p build-area/taglib-1.8 && \
mkdir -p /root/advancestore
ADD src/kodi.sh /root/start.sh
ADD src/advancedsettings.xml /advancestore/
ADD src/taglib-1.8 build-area/taglib-1.8/
RUN chmod +x /root/start.sh  && \
apt-get update && \
apt-get install -y supervisor software-properties-common python-software-properties && \
add-apt-repository ppa:team-xbmc/ppa && \
apt-get update && \
apt-get install -y kodi-eventclients-xbmc-send && \
apt-get build-dep kodi -y && \
cd build-area/taglib-1.8 && \
cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_RELEASE_TYPE=Release . && \
make && \
make install && \

# Download XBMC, pick version from github
cd .. && \
git clone https://github.com/topfs2/xbmc.git && \
cd xbmc && \
git checkout helix_headless  && \

# Configure, make, clean.
 ./bootstrap && \
./configure \
--prefix=/opt/kodi-server && \
make && \
make install && \
cd / && \
rm -rf  build-area && \
apt-get clean && \
rm -rf /var/lib/apt/lists /usr/share/man /usr/share/doc
ADD src/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
# set ports
EXPOSE 9777/udp 8080/tcp
ENTRYPOINT ["/root/start.sh"]
