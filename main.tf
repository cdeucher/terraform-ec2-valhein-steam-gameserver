resource "aws_network_interface" "web-server-io" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]

}

resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.web-server-io.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.gw, aws_network_interface.web-server-io]  
}


resource "aws_instance" "web-server-instance" {
  ami               = "ami-02fe94dee086c0c37"
  instance_type     = "t2.medium"
  availability_zone = "us-east-1a"
  key_name          = "Ansible_local" 
  # This EC2 Instance has a public IP and will be accessible directly from the public Internet
  #associate_public_ip_address = true

  network_interface{
      device_index = 0
      network_interface_id = aws_network_interface.web-server-io.id
  }

  tags = {
      Name = "Production-instance"
  }
}

resource "null_resource" "bash_remote" {
  connection {
      private_key = file("MyKeyPair.pem")
      user        = "ubuntu"
      host        = aws_instance.web-server-instance.public_ip
  }

  provisioner "remote-exec" {
    inline = ["echo 'connected!'"]
  }
  provisioner "remote-exec" {
    inline = [
                "sudo apt-get -qq -y update"
                ,"sudo dpkg --add-architecture i386" 
                ,"sudo apt-get -qq -y update"  
                ,"sudo mkdir /data" 
                ,"sudo chmod -R 777 /data" 
                ,"sudo apt install -y curl wget file tar bzip2 gzip unzip bsdmainutils python util-linux ca-certificates binutils bc jq tmux netcat lib32gcc1 lib32stdc++6"  
                ,"sudo apt-get -qq -y install libsdl2-2.0-0:i386"
                ,"sudo mount /dev/xvdd /data"
                ,"mkdir -p ~/.config/unity3d/IronGate/Valheim/worlds"
                ,"sudo rsync -avuz /data/world_dir/* ~/.config/unity3d/IronGate/Valheim/worlds/"
                ,"sudo cat '*/5 * * * * /data/save_worlds.sh' > /etc/cron.d/custom"
                ,"sudo sudo /etc/init.d/cron restart"
                #,"sudo apt-get -qq -y install steamcmd"
                #,"cd /data && ./vhserver start"                                
    ]
  }   
                 
  /*
  provisioner "local-exec" {
    command = <<-EOF
                #
                # SETUP VOLUME (only new volumes)

                # vi save_worlds.sh
                # #!/bin/bash
                # rsync -avuz ~/.config/unity3d/IronGate/Valheim/worlds /data/world_dir 
                
                #ls -la ~/.config/unity3d/IronGate/Valheim/worlds/
                #5 * * * * /data/save_worlds.sh > /dev/null 2>&1
                #sudo mkfs -t xfs /dev/xvdd
                #sudo mkdir -p /data/lgsm/data
                #sudo apt -y install steamcmd
                #sudo wget -O linuxgsm.sh https://linuxgsm.sh
                #sudo chmod -R 777 /data
                #bash linuxgsm.sh vhserver
                #./vhserver install
                #./vhserver start
                EOF
  } 
  */
  depends_on  = [aws_instance.web-server-instance, aws_volume_attachment.ebs_att]    
}


output "base_ip" {
  value = aws_instance.web-server-instance.public_ip
}
