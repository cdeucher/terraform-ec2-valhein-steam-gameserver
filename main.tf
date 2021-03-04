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
  instance_type     = "t2.small"
  availability_zone = "us-east-1a"
  key_name          = "private_key" 
  # This EC2 Instance has a public IP and will be accessible directly from the public Internet
  #associate_public_ip_address = true

  network_interface{
      device_index = 0
      network_interface_id = aws_network_interface.web-server-io.id
  }

  /*connection {
        # The default username for our AMI
        user = "ubuntu"
        host = aws_instance.web-server-instance.public_ip
        type = "ssh"
        private_key = "${file("private_key.pem")}"
  }

  provisioner "remote-exec" {
    inline = [
          "sudo apt update -y",
          "sudo dpkg --add-architecture i386",
          "sudo apt -y update",
          "sudo mkdir -p /data/lgsm/data",
          "sudo chmod -R 777 /data",
          "sudo apt install -y curl wget file tar bzip2 gzip unzip bsdmainutils python util-linux ca-certificates binutils bc jq tmux netcat lib32gcc1 lib32stdc++6",
          "sudo apt install -y libsdl2-2.0-0:i386"
    ]
  }*/
   
  //user_data = "${file("data/index.php")}"
  user_data  = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo dpkg --add-architecture i386
                sudo apt -y update
                sudo mkdir -p /data/lgsm/data
                sudo chmod -R 777 /data
                sudo apt install -y curl wget file tar bzip2 gzip unzip bsdmainutils python util-linux ca-certificates binutils bc jq tmux netcat lib32gcc1 lib32stdc++6 
                sudo apt install -y libsdl2-2.0-0:i386

                sudo mkfs -t xfs /dev/xvdd
                sudo mount /dev/xvdd /data
                
                cd /data && ./vhserver start
                
                #sudo apt -y install steamcmd
                #sudo wget -O linuxgsm.sh https://linuxgsm.sh
                #sudo chmod -R 777 /data
                #bash linuxgsm.sh vhserver
                #./vhserver install
                #./vhserver start
    
                EOF

  tags = {
      Name = "Production-instance"
  }
}
output "base_ip" {
  value = aws_instance.web-server-instance.public_ip
}
