
output "tier" {
    value = var.tier
}

output "octomaster_ips" {                                 
    value = [ for i in module.aws_octomaster : i.private_ips ]
}                                                 
                                                  
output "octomaster_names" {                             
    value = [ for i in module.aws_octomaster : i.hostnames ]
}                                                                    
                                                

output "defender-nlb-ips" {
    value = module.aws_defender_nlb.public_ips
}

output "defender-nlb-name" {
    value = module.aws_defender_nlb.dns_name
}
