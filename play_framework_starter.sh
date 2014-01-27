# Here's what I've figured out so far, this comes from gliffy-testvm01 and gliffy-testvm02
 
# Installing the play framework for Gliffy
echo "export PATH=$PATH:/opt/play/current" >> /etc/profile
mkdir -p /opt/play ; cd /opt/play
wget http://downloads.typesafe.com/play/2.2.1/play-2.2.1.zip
ln -s play-2.2.1 current
 
useradd j2ee-play
usermod -aG j2ee-play kerryliu
usermod -aG j2ee-play han
usermod -aG j2ee-play keith
 
chown -R j2ee-play:j2ee-play current/
find current/ -type d -exec chmod 0775 {} \;
find current/ -type d -exec chmod ug+s {} \;
find current/ -type f -perm 744 -exec chmod 774 {} \;
find current/ -type f -perm 644 -exec chmod 664 {} \;
