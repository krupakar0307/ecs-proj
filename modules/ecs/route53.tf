
# SSL Certificate
resource "aws_acm_certificate" "service_cert" {
    domain_name       = var.service_domain
    validation_method = "DNS"

    tags = {
        Name = "${var.service}-ssl-cert"
    }
}

# Route53 Record for DNS Validation
resource "aws_route53_record" "service_cert_validation" {
    for_each = {
        for dvo in aws_acm_certificate.service_cert.domain_validation_options : dvo.domain_name => {
            name   = dvo.resource_record_name
            type   = dvo.resource_record_type
            value  = dvo.resource_record_value
        }
    }

    zone_id = var.zone_id # Replace with your Route53 Zone ID
    name    = each.value.name
    type    = each.value.type
    records = [each.value.value]
    ttl     = 60
}

# Wait for Certificate Validation
resource "aws_acm_certificate_validation" "service_cert_validation" {
    certificate_arn         = aws_acm_certificate.service_cert.arn
    validation_record_fqdns = [for record in aws_route53_record.service_cert_validation : record.fqdn]
}

    
# Route53 Record for ALB
resource "aws_route53_record" "service_alb" {
    zone_id = var.zone_id # Replace with your Route53 Zone ID
    name    = var.service_domain
    type    = "A"

    alias {
        name                   = aws_lb.service_alb.dns_name
        zone_id                = aws_lb.service_alb.zone_id
        evaluate_target_health = true
    }
}

