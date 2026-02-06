import os
import django
os.environ.setdefault("DJANGO_SETTINGS_MODULE","lms.envs.tutor.production")
django.setup()
from django.contrib.sites.models import Site
Site.objects.update_or_create(id=1, defaults={"domain":"lms.blackmode.io","name":"lms.blackmode.io"})
