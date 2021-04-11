resource "cloudflare_record" "main" {
  type            = "CNAME"
  name            = var.domain
  value           = var.boxfuse_domain
  zone_id         = var.cloudflare_zone_id
  proxied         = true
}

resource "cloudflare_record" "www" {
  type            = "CNAME"
  name            = "www"
  value           = var.boxfuse_domain
  zone_id         = var.cloudflare_zone_id
  proxied         = true
}
