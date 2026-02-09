from pathlib import Path
p = Path("/home/ubuntu/openedx-eks-assessment/infra/terraform/envs/prod/terraform.tfvars")
text = p.read_text().splitlines()
replacements = {
    "lms_domain": "lms_domain                  = \"lms.alnafi-openedx.ddnsfree.com\"",
    "ingress_alb_dns_name": "ingress_alb_dns_name        = \"<ALB_DNS_NAME>\"",
    "acm_certificate_arn_us_east_1": "acm_certificate_arn_us_east_1 = \"arn:aws:acm:us-east-1:648955502889:certificate/576f72f2-2cbd-4f44-a609-af4868da69d7\"",
    "enable_cloudfront": "enable_cloudfront           = true",
}
new_lines = []
for line in text:
    key = line.split('=')[0].strip() if '=' in line else None
    if key in replacements:
        new_lines.append(replacements[key])
    else:
        new_lines.append(line)
p.write_text("\n".join(new_lines) + "\n")
