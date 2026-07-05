#!/usr/bin/env bash
set -e errexit

echo "Adding marketplace on Claude"
claude plugin marketplace add ./

echo "Installing plugins on Claude"
claude plugin install programming-skills@software-engineering-skills
claude plugin install docs@software-engineering-skills
claude plugin install java@software-engineering-skills
claude plugin install node@software-engineering-skills
claude plugin install python@software-engineering-skills
claude plugin install frontend@software-engineering-skills
claude plugin install devops@software-engineering-skills
claude plugin install workflow@software-engineering-skills