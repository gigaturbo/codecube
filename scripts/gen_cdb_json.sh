#!/usr/bin/env bash
#
# Regenerate .cdb.json, embedding CONTENTDB.md as the ContentDB long description.
#
# WRITE CONTENTDB.md, NEVER .cdb.json. ContentDB reads long_description only from
# .cdb.json, and a JSON string cannot hold a newline, so the shipped field is one
# very long escaped line. That is the artefact, not the source: edit the Markdown
# and run this.
#
# It is deliberately NOT README.md. The two documents have different readers -
# the ContentDB reader is already on the package page - and ContentDB's own rules
# exclude most of what a README carries: a heading repeating the title, the short
# description restated, links to the repository or to the package's own page,
# licence text, API documentation, and images, which are not visible inside
# Luanti. The README was used here for the project's whole life (C20; the mod's
# counterpart is C19). https://content.luanti.org/help/appealing_page/
#
# So when adding to CONTENTDB.md: no badges, no screenshots, no title heading, no
# licence line, no links back to GitHub or to ContentDB. What belongs is what the
# game contains, what distinguishes it, and how to play it once installed. An
# image that carries meaning has to become words - the drone tool icons the
# README used inline in its instructions are why that rule has teeth here.
#
# CRLF is normalised to LF before escaping. Without that the output depends on
# the checkout's line endings: on Windows the file arrives as CRLF and the raw
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
}' "$(perl -0777 -pe 's|\r\n|\n|gs; s|\n|\\n|gs' CONTENTDB.md)" > .cdb.json
