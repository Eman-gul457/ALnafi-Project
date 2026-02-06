from pathlib import Path
p = Path("/home/ubuntu/openedx-eks-assessment/infra/terraform/envs/prod/terraform.tfvars")
text = p.read_text().splitlines()
replacements = {
    "lms_domain": "lms_domain                  = \"lms.blackmode.io\"",
    "ingress_alb_dns_name": "ingress_alb_dns_name        = \"ab364486d519c4973b543fa56a874634-93f51c229db90e3d.elb.ap-south-1.amazonaws.com\"",
    "acm_certificate_arn_us_east_1": "acm_certificate_arn_us_east_1 = \"arn:aws:acm:us-east-1:648955502889:certificate/9cee78e5-e04e-4eee-9b89-5296609a744a\"",
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
