#!/usr/bin/env bash
set -e errexit

echo "Installing extensions on Gemini"
gemini extensions link ./plugins/programming-skills/
gemini extensions link ./plugins/devops/
gemini extensions link ./plugins/docs/
gemini extensions link ./plugins/frontend/
gemini extensions link ./plugins/java/
gemini extensions link ./plugins/node/
gemini extensions link ./plugins/python/
gemini extensions link ./plugins/workflow/
