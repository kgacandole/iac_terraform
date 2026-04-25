module "frontend" {
    source              = "./modules/frontend"
    site_bucket_name    = var.site_bucket_name
}

module "backend" {
    source              = "./modules/backend"
    prefix              = var.prefix
    package_build_path  = var.package_build_path
}