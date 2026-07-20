#!/usr/bin/env bash
set -e errexit

echo "Installing extensions on Antigravity"
agy plugin install ./plugins/programming-skills/
agy plugin install ./plugins/java/
agy plugin install ./plugins/python/
agy plugin install ./plugins/node/
agy plugin install ./plugins/frontend/
agy plugin install ./plugins/devops/
agy plugin install ./plugins/docs/
agy plugin install ./plugins/architecture/
agy plugin install ./plugins/workflow/
