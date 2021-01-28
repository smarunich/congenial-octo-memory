provider "aws" {
  profile = coalesce(var.aws_profile, "")
  region  = var.aws_region
}

module "aws_utilities" {
  source = "./modules/aws/util"
}
module "aws_ansible_inventory" {
  source = "./modules/aws/ansible_inventory"
  name_prefix = var.name_prefix
  octo_cluster_uuid = module.aws_utilities.random_uuid
  aws_region = var.aws_region
  aws_profile = var.aws_profile
  inventory_ip_address_type = var.inventory_ip_address_type
}

module "aws_key_pair" {
  count = var.aws_key_pair_reuse == false ? 1:0  
  source = "./modules/aws/key"
  key_name = "${var.name_prefix}-generated-key"
}

module "aws_iam" {
  count = var.iam_reuse == false ? 1:0  
  source = "./modules/aws/iam"
  name_prefix = var.name_prefix
}

module "aws_vpc" {
  count = var.vpc_reuse == false ? 1:0    
  source = "./modules/aws/vpc"
  vpc_cidr = var.cidr
  min_az_count = local.defender_infra.min_az_count
  max_az_count = local.defender_infra.max_az_count
  name_prefix = var.name_prefix
  aws_tags = merge( var.aws_tags, {"octo_cluster_uuid": module.aws_utilities.random_uuid })
}


module "aws_vpc_lookup" {
  count = var.vpc_reuse == true ? 1:0
  source = "./modules/aws/vpc_lookup"
  vpc_name = var.vpc_name
  subnet_names = var.subnet_names
}

module "aws_security_groups" {
  count = var.security_group_reuse == false ? 1:0    
  source = "./modules/aws/security_groups"
  vpc_id = var.vpc_reuse == false ? module.aws_vpc.0.id:module.aws_vpc_lookup.0.id
  name_prefix = var.name_prefix
  aws_tags = merge( var.aws_tags, {"octo_cluster_uuid": module.aws_utilities.random_uuid })
}

data "aws_security_group" "security_group_lookup" {
  count = var.security_group_reuse == true ? 1:0    
  id = var.security_group_id
}

module "aws_octomaster" {
  source = "./modules/aws/host"
  for_each = local.octomaster
  instance_count = each.value.count
  instance_name = each.key
  instance_flavour = each.value.aws.flavour
  ami_id = coalesce(var.ami_id, module.aws_utilities.latest_centos_ami)
  enable_placement_groups = var.enable_placement_groups
  key_name =  var.aws_key_pair_reuse == true ? var.aws_key_pair_name: module.aws_key_pair.0.key_name
  public_key = var.aws_key_pair_reuse == true ? var.aws_key_pair_public_key: module.aws_key_pair.0.public_key
  iam_instance_profile = var.iam_reuse == true ? var.iam_instance_profile_name: module.aws_iam.0.iam_instance_profile_name
  subnet_id = var.vpc_reuse == false ? module.aws_vpc.0.subnet_ids.0:module.aws_vpc_lookup.0.subnet_ids.0
  security_group_ids = var.security_group_reuse == false ? [module.aws_security_groups.0.internal_id, module.aws_security_groups.0.ingress_id]:[data.aws_security_group.security_group_lookup.0.id]
  disks = each.value.disk
  associate_public_ip_address = var.associate_public_ip_address
  delete_on_termination = var.delete_on_termination
  groups = join(":", each.value.groups)
  name_prefix = var.name_prefix
  octo_cluster_uuid = module.aws_utilities.random_uuid
  aws_tags = merge( var.aws_tags, {"octo_cluster_uuid": module.aws_utilities.random_uuid })
}

module "aws_defender" { 
  source = "./modules/aws/defender"
  instance_count = var.defender_mode_scalegroup == true ? 1:local.defenders.min_count
  instance_name = "defender"
  instance_flavour = local.defenders.aws.flavour
  ami_id = coalesce(var.ami_id, module.aws_utilities.latest_centos_ami)
  enable_placement_groups = var.enable_placement_groups
  key_name =  var.aws_key_pair_reuse == true ? var.aws_key_pair_name: module.aws_key_pair.0.key_name
  public_key = var.aws_key_pair_reuse == true ? var.aws_key_pair_public_key: module.aws_key_pair.0.public_key
  iam_instance_profile = var.iam_reuse == true ? var.iam_instance_profile_name: module.aws_iam.0.iam_instance_profile_name
  subnet_ids = var.vpc_reuse == false ? module.aws_vpc.0.subnet_ids:module.aws_vpc_lookup.0.subnet_ids
  security_group_ids = var.security_group_reuse == false ? [module.aws_security_groups.0.internal_id, module.aws_security_groups.0.ingress_id]:[data.aws_security_group.security_group_lookup.0.id]
  disks = local.defenders.disk
  associate_public_ip_address = var.associate_public_ip_address
  groups = join(":", local.defenders.groups)
  name_prefix = var.name_prefix
  octo_cluster_uuid = module.aws_utilities.random_uuid
  aws_tags = merge( var.aws_tags, {"octo_cluster_uuid": module.aws_utilities.random_uuid })
}

module "aws_defender_scalegroup" {
  count = var.defender_mode_scalegroup == true ? 1:0    
  source = "./modules/aws/defender_scalegroup"
  instance_count = local.defenders.min_count
  min_count = local.defenders.min_count
  max_count = local.defenders.max_count
  instance_name = "defender-asg"
  instance_flavour = local.defenders.aws.flavour
  ami_id = coalesce(var.defender_asg_ami_id, module.aws_utilities.latest_centos_ami)
  enable_placement_groups = var.enable_placement_groups
  key_name =  var.aws_key_pair_reuse == true ? var.aws_key_pair_name: module.aws_key_pair.0.key_name
  public_key = var.aws_key_pair_reuse == true ? var.aws_key_pair_public_key: module.aws_key_pair.0.public_key
  iam_instance_profile = var.iam_reuse == true ? var.iam_instance_profile_name: module.aws_iam.0.iam_instance_profile_name
  vpc_id = var.vpc_reuse == false ? module.aws_vpc.0.id:module.aws_vpc_lookup.0.id
  subnet_ids = var.vpc_reuse == false ? module.aws_vpc.0.subnet_ids:module.aws_vpc_lookup.0.subnet_ids
  security_group_ids = var.security_group_reuse == false ? [module.aws_security_groups.0.internal_id, module.aws_security_groups.0.ingress_id]:[data.aws_security_group.security_group_lookup.0.id]
  disks = local.defenders.disk
  associate_public_ip_address = var.associate_public_ip_address
  groups = join(":", local.defenders.groups)
  name_prefix = var.name_prefix
  octo_cluster_uuid = module.aws_utilities.random_uuid
  aws_tags = merge( var.aws_tags, {"octo_cluster_uuid": module.aws_utilities.random_uuid })
  defender_tg_http_arn = module.aws_defender_nlb.defender_tg_http_arn
  defender_tg_https_arn = module.aws_defender_nlb.defender_tg_https_arn
  health_check_type = var.defender_scalegroup_health_check_type
}

module "aws_defender_nlb" {  
  source = "./modules/aws/defender_nlb"
  vpc_id = var.vpc_reuse == false ? module.aws_vpc.0.id:module.aws_vpc_lookup.0.id
  subnet_ids = var.vpc_reuse == false ? module.aws_vpc.0.subnet_ids:module.aws_vpc_lookup.0.subnet_ids
  instance_ids = var.defender_mode_scalegroup == true ? []:module.aws_defender.defender_ids
  name_prefix = var.name_prefix
  aws_tags = merge( var.aws_tags, {"octo_cluster_uuid": module.aws_utilities.random_uuid })
}

