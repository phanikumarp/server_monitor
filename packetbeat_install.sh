sudo apt-get install -y libpcap0.8
curl -L -O https://download.elastic.co/beats/packetbeat/packetbeat_1.2.2_amd64.deb
sudo dpkg -i packetbeat_1.2.2_amd64.deb
sudo wget -q -O /etc/packetbeat/packetbeat.yml https://raw.githubusercontent.com/basivireddy/server_monitor/master/packetbeat.yml
sudo wget -q -O /etc/rc.local https://raw.githubusercontent.com/basivireddy/server_monitor/master/rc.local
i=`curl http://169.254.169.254/latest/meta-data/ami-id`
sed -i "s/shipper_name/$i/g" /etc/packetbeat/packetbeat.yml
