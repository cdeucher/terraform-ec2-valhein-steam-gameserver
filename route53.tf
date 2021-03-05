/*resource "aws_route53_zone" "cabd-public-zone" {
  name     = "zone-cabd.link"
  comment  = "cabd public zone"
  provider = aws
}*/

data "aws_route53_zone" "cabd-public-zone" {
  name     = "cabd.link"
}

output "aws_route53_zone" {
  value = data.aws_route53_zone.cabd-public-zone.zone_id
}

resource "aws_route53_record" "cabd-record" {
  zone_id = data.aws_route53_zone.cabd-public-zone.zone_id
  name    = "cabd.link"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.web-server-instance.public_ip]
}