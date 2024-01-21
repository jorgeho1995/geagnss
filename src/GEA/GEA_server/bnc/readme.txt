sudo apt install xvfb

mkdir -R /home/ubuntu/.config/BKG

cp /home/ubuntu/GEA/GEA_server/bnc/BNC.bnc /home/ubuntu/.config/BKG

# As root
cp /home/ubuntu/GEA/GEA_server/bnc/bnc.service /lib/systemd/system
systemctl start bnc
systemctl enable bnc
