resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow Web traffic"
  vpc_id      = aws_vpc.main.id

   ingress {
        description = "HTTPS"
        from_port   = 2456
        to_port     = 2456
        protocol    = "udp"
        cidr_blocks = ["0.0.0.0/0"]
   }
   ingress {
        description = "HTTP"
        from_port   = 2456
        to_port     = 2456
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
   }
   ingress {
        description = "HTTPS"
        from_port   = 2457
        to_port     = 2457
        protocol    = "udp"
        cidr_blocks = ["0.0.0.0/0"]
   }
   ingress {
        description = "HTTP"
        from_port   = 2457
        to_port     = 2457
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
   }   
   ingress {
        description = "SSH"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
   }
  egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
  }
}