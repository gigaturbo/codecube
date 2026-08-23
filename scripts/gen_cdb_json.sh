#!/usr/bin/env bash
#
# Regenerate .cdb.json, embedding README.md as the ContentDB long description.
#
# CRLF is normalised to LF before escaping. Without that the output depends on
# the checkout's line endings: on Windows, README.md arrives as CRLF and the raw
# CR bytes survive into the JSON string, so the file differs from one generated
# on Linux and scripts/check_game.sh reports it as stale.

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
}' "$(perl -0777 -pe 's|\r\n|\n|gs; s|\n|\\n|gs' README.md)" > .cdb.json
