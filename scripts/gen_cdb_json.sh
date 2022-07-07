#!/usr/bin/env bash

printf \
'{
    "type": "GAME",
    "title": "Codecube",
    "name": "codecube",
    "short_description": "A game where the player can construct by programming",
    "long_description": "%s",
    "dev_state": "BETA",
    "tags": [
        "education"
    ],
    "license": "AGPL-3.0-only",
    "repo": "https://github.com/gigaturbo/codecube.git",
    "issue_tracker": "https://github.com/gigaturbo/codecube/issues"
}' "$(perl -0777 -pe 's|\n|\\n|gs' README.md)" > .cdb.json