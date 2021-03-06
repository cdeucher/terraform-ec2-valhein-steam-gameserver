
/* create a new volume
resource "aws_ebs_volume" "ebs_gs" {
  availability_zone = "us-east-1a"
  size              = 40
  #type = "gp2" #"st1"
  
  
  lifecycle {
  //    prevent_destroy = true
    ignore_changes = [kms_key_id, instance_id]
  }
  tags = {
    Name = "GS"
  }
}*/
/* use an old valume */
data "aws_ebs_volume" "ebs_gs" {
  most_recent = true

  filter {
    name   = "volume-type"
    values = ["gp2"]
  }
  filter {
    name   = "tag:gp2_volume_name"
    values = ["valhein_gs"]
  }
}

output "aws_ebs_volume_id" {
  value = data.aws_ebs_volume.ebs_gs.id
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdd"
  volume_id   = data.aws_ebs_volume.ebs_gs.id
  instance_id = aws_instance.web-server-instance.id

  skip_destroy = true

  depends_on  = [data.aws_ebs_volume.ebs_gs, aws_instance.web-server-instance, aws_eip.one]
}
