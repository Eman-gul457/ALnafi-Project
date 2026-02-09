from pathlib import Path

# MongoDB configuration (SENSITIVE VALUES REMOVED)
# Actual values should be provided via environment variables or a secure secrets manager
mongocfg = """DOC_STORE_CONFIG:
  default:
    ENGINE: "xmodule.modulestore.mongo.MongoKeyValueStore"
    HOST: "${MONGO_HOST}"          # e.g. 10.10.10.189
    PORT: ${MONGO_PORT}            # e.g. 27017
    USER: "${MONGO_USER}"          # e.g. openedx
    PASSWORD: "${MONGO_PASSWORD}"  # DO NOT hard-code passwords
    DB: "${MONGO_DB}"              # e.g. openedx
    COLLECTION: "modulestore"
    AUTH_SOURCE: "admin"
"""

paths = [
    Path('/home/ubuntu/.local/share/tutor/env/apps/openedx/config/lms.env.yml'),
    Path('/home/ubuntu/.local/share/tutor/env/apps/openedx/config/cms.env.yml'),
]

for file in paths:
    text = file.read_text()

    # Case 1: DOC_STORE_CONFIG is explicitly set to null
    if 'DOC_STORE_CONFIG: null' in text:
        text = text.replace('DOC_STORE_CONFIG: null\n', mongocfg)

    # Case 2: DOC_STORE_CONFIG already exists and must be replaced
    else:
        lines = text.splitlines()
        out = []
        i = 0

        while i < len(lines):
            line = lines[i]

            if line.startswith('DOC_STORE_CONFIG:'):
                out.append(mongocfg.rstrip('\n'))
                i += 1

                # Skip existing indented config block
                while i < len(lines) and (
                    lines[i].startswith(' ') or lines[i].startswith('\t')
                ):
                    i += 1
                continue

            out.append(line)
            i += 1

        text = '\n'.join(out) + '\n'

    file.write_text(text)
