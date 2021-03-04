
resource "aws_ebs_volume" "ebs_gs" {
  availability_zone = "us-east-1a"
  size              = 40
  #type = "gp2" #"st1"
  
  #lifecycle = {
  #  prevent_destroy = true
  #}

  tags = {
    Name = "GS"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdd"
  volume_id   = aws_ebs_volume.ebs_gs.id
  instance_id = aws_instance.web-server-instance.id

  skip_destroy = true

  depends_on  = [aws_ebs_volume.ebs_gs, aws_instance.web-server-instance, aws_eip.one]
}
