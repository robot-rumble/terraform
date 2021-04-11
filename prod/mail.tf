# from:
# https://github.com/rafilkmp3/terraform-aws-ses-domain-cloudflare/blob/master/main.tf
# https://github.com/terraform-aws-modules/terraform-aws-iam/tree/master/examples/iam-user

#
# SES Domain Verification
#

resource "aws_ses_domain_identity" "main" {
  domain = var.domain
}

resource "cloudflare_record" "ses_verification" {
  name   = "_amazonses.${aws_ses_domain_identity.main.id}"
  type   = "TXT"
  value  = aws_ses_domain_identity.main.verification_token
  zone_id = var.cloudflare_zone_id
}

#
# SES DKIM Verification
#

resource "aws_ses_domain_dkim" "main" {
  domain = aws_ses_domain_identity.main.domain
}

resource "cloudflare_record" "dkim" {
  count  = 3
  name = format("%s._domainkey.%s", element(aws_ses_domain_dkim.main.dkim_tokens, count.index), var.domain)
  type  = "CNAME"
  value = "${element(aws_ses_domain_dkim.main.dkim_tokens, count.index)}.dkim.amazonses.com"
  zone_id = var.cloudflare_zone_id
}

resource "cloudflare_record" "spf_domain" {
  count  = 1
  name   = "@"
  type   = "TXT"
  value  = "v=spf1 include:amazonses.com -all"
  zone_id = var.cloudflare_zone_id
}

#
# USER
#

# IAM user without pgp_key (IAM access secret will be unencrypted)
module "iam_user" {
  source = "terraform-aws-modules/iam/aws//modules/iam-user"

  name = "hello"

  create_iam_user_login_profile = false
  create_iam_access_key         = true
}

resource "aws_iam_user_policy" "send_mail" {
  name = "send-mail"
  user = module.iam_user.this_iam_user_name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "ses:SendRawEmail",
            "Resource": "*"
        }
    ]
}
EOF
}

output "username" {
  value = module.iam_user.this_iam_access_key_id
}

output "password" {
  value = module.iam_user.this_iam_access_key_ses_smtp_password_v4
}
