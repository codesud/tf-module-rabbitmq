resource "aws_route53_record" "rabbitmq-record" {
    # I'd need the zone details, which we have given in the vpc module, so we need to fetch the zone id from there. We are can read remote state from their outputs
  zone_id = data.terraform_remote_state.vpc.outputs.HOSTEDZONE_PRIVATE_ID
  name    = "rabbitmq-${var.ENV}.${data.terraform_remote_state.vpc.outputs.HOSTEDZONE_PRIVATE_ZONE}"
  type    = "A"
  ttl     = 10
  records = [aws_spot_instance_request.rabbitmq.private_ip]
  depends_on = [aws_spot_instance_request.rabbitmq]
}