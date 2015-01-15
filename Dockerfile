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
apt-get install supervisor software-properties-common python-software-properties ffmpeg automake autopoint bison build-essential ccache cmake curl cvs default-jre fp-compiler gawk gdc gettext git-core gperf libasound2-dev libass-dev libavcodec-dev libavfilter-dev libavformat-dev libavutil-dev libbluetooth-dev  libboost-dev libboost-thread-dev libbz2-dev libcap-dev libcdio-dev libcec-dev libcec1 libcrystalhd-dev libcrystalhd3 libcurl3 libcurl4-gnutls-dev libcwiid-dev libcwiid1 libdbus-1-dev libenca-dev libflac-dev libfontconfig-dev libfreetype6-dev libfribidi-dev libglew-dev libiso9660-dev libjasper-dev libjpeg-dev libltdl-dev liblzo2-dev libmad0-dev libmicrohttpd-dev libmodplug-dev libmp3lame-dev libmpeg2-4-dev libmpeg3-dev libmysqlclient-dev libnfs-dev libogg-dev libpcre3-dev libplist-dev libpng-dev libpostproc-dev libpulse-dev libsamplerate-dev libsdl-dev libsdl-gfx1.2-dev libsdl-image1.2-dev libsdl-mixer1.2-dev libshairport-dev libsmbclient-dev libsqlite3-dev libssh-dev libssl-dev libswscale-dev libtiff-dev libtinyxml-dev libtool libudev-dev libusb-dev libva-dev libva-egl1 libva-tpi1 libvdpau-dev libvorbisenc2 libxml2-dev libxmu-dev libxrandr-dev libxrender-dev libxslt1-dev libxt-dev libyajl-dev mesa-utils nasm pmount python-dev python-imaging python-sqlite swig unzip yasm zip zlib1g-dev -y curl wget unzip && \
add-apt-repository ppa:team-xbmc/ppa && \
apt-get update && \
apt-get install -y libtag-dev libbluray-dev libbluray1 kodi-eventclients-xbmc-send && \
add-apt-repository --remove ppa:team-xbmc/ppa && \
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
chown -R nobody:users /opt/kodi-server && \
cd / && \
rm -rf  build-area && \
apt-get clean && \
rm -rf /var/lib/apt/lists /usr/share/man /usr/share/doc
ADD src/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
# set ports
EXPOSE 9777/udp 8080/tcp
ENTRYPOINT ["/root/start.sh"]
