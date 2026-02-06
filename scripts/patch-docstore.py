from pathlib import Path

mongocfg = """DOC_STORE_CONFIG:
  default:
    ENGINE: \"xmodule.modulestore.mongo.MongoKeyValueStore\"
    HOST: \"10.10.10.189\"
    PORT: 27017
    USER: \"openedx\"
    PASSWORD: \"OpenedxMongo2026!\"
    DB: \"openedx\"
    COLLECTION: \"modulestore\"
    AUTH_SOURCE: \"admin\"
"""

paths = [
    Path('/home/ubuntu/.local/share/tutor/env/apps/openedx/config/lms.env.yml'),
    Path('/home/ubuntu/.local/share/tutor/env/apps/openedx/config/cms.env.yml'),
]

for file in paths:
    text = file.read_text()
    if 'DOC_STORE_CONFIG: null' in text:
        text = text.replace('DOC_STORE_CONFIG: null\n', mongocfg)
    else:
        lines = text.splitlines()
        out = []
        i = 0
        while i < len(lines):
            line = lines[i]
            if line.startswith('DOC_STORE_CONFIG:'):
                out.append(mongocfg.rstrip('\n'))
                i += 1
                while i < len(lines) and (lines[i].startswith(' ') or lines[i].startswith('\t')):
                    i += 1
                continue
            out.append(line)
            i += 1
        text = '\n'.join(out) + '\n'
    file.write_text(text)
