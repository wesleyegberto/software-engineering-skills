#!/usr/bin/env bash
set -e errexit

echo "Installing extensions on Antigravity"
agy plugin install ./software-engineering-skills/plugins/programming-skills/
agy plugin install ./software-engineering-skills/plugins/java/
agy plugin install ./software-engineering-skills/plugins/python/
agy plugin install ./software-engineering-skills/plugins/node/
agy plugin install ./software-engineering-skills/plugins/frontend/
agy plugin install ./software-engineering-skills/plugins/devops/
agy plugin install ./software-engineering-skills/plugins/docs/
agy plugin install ./software-engineering-skills/plugins/architecture/
agy plugin install ./software-engineering-skills/plugins/workflow/
