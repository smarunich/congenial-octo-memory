output "dns_name" {
    value = aws_lb.defender_nlb.dns_name
}

output "private_ips" {
    value = aws_eip.nlb_eip.*.private_ip
}

output "public_ips" {
    value = aws_eip.nlb_eip.*.public_ip
}

output "defender_tg_http_arn" {
    value = aws_lb_target_group.defender_tg_http.arn
}

output "defender_tg_https_arn" {
    value = aws_lb_target_group.defender_tg_https.arn
}