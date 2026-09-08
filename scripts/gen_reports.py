#!/usr/bin/env python3
"""Render ROADMAP.md, AUDIT.md and PLAYTEST.md into .reports/*.html.

    python scripts/gen_reports.py            # all three, into .reports/
    python scripts/gen_reports.py --check    # regenerate and report drift, write nothing

Dev tooling. It never ships (`scripts` carries a wholesale `export-ignore` line
in `.gitattributes`) and no gate reads it: `check_game.sh` does not know about it
and luacheck does not read Python.

Four constraints, each of which a plausible edit would break silently:

* **No external fonts, scripts or stylesheets, and no third-party module.**
  The files are opened over `file://`, so everything is inline and the standard
  library is all that is available. That is why the Markdown subset below is
  hand-written rather than imported.
* **The renderings hold no fact the Markdown does not.** Structure, anchors,
  filters and colour are presentation; counts are a tabulation of the entries
  found in the source. Nothing is added, nothing is commented on, and there is
  no next-step panel — the document's own first section already says what is
  outstanding.
* **Deterministic.** Two runs over an unchanged tree produce byte-identical
  files, so a diff is worth reading. Nothing takes the wall clock: the footer
  dates the commit it describes, not the render.
* **Escape before you emit.** These documents quote Lua and shell containing
  `<`, `>` and `&`.

The parser handles the Markdown these three files use and no more: ATX
headings, paragraphs, bullet and ordered lists with indented continuations,
task-list items, fenced code, blockquotes, pipe tables, horizontal rules, and
inline code, bold, italic, links and autolinks. A `###` line inside a fence is
not a heading — `PLAYTEST.md` has one, in the block that documents the shape of
a check.
"""

import argparse
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT_DIR = os.path.join(ROOT, ".reports")

# ---------------------------------------------------------------- inline markup

_ESCAPES = (("&", "&amp;"), ("<", "&lt;"), (">", "&gt;"))


def esc(text):
    for raw, ref in _ESCAPES:
        text = text.replace(raw, ref)
    return text


_CODE = re.compile(r"(`+)(.+?)\1", re.S)
_STRONG = re.compile(r"\*\*(?=\S)(.+?)(?<=\S)\*\*", re.S)
_EM = re.compile(r"(?<![\w*])\*(?=\S)(.+?)(?<=\S)\*(?!\w)", re.S)
_LINK = re.compile(r"\[([^\]]+)\]\((\S+?)\)")
_AUTOLINK = re.compile(r"&lt;(https?://[^\s&]+)&gt;")


def inline(text):
    """Render inline Markdown.

    Code spans come out first, into placeholders no other rule can match, so
    `**` inside a span stays literal *and* a bold span that contains a code
    span still pairs up. These documents are full of the second shape —
    ``**`B50` is resolved**`` — and handling the two in the wrong order drops
    the emphasis and leaks the asterisks."""
    spans = []

    def stash(m):
        body = m.group(2)
        if body.startswith(" ") and body.endswith(" ") and body.strip():
            body = body[1:-1]
        spans.append(body)
        return "\x00%d\x01" % (len(spans) - 1)

    text = _emphasis(_CODE.sub(stash, text))
    return re.sub(r"\x00(\d+)\x01",
                  lambda m: "<code>%s</code>" % esc(spans[int(m.group(1))]),
                  text)


def _emphasis(text):
    text = esc(text)
    text = _STRONG.sub(lambda m: "<strong>%s</strong>" % m.group(1), text)
    text = _EM.sub(lambda m: "<em>%s</em>" % m.group(1), text)
    text = _LINK.sub(
        lambda m: '<a href="%s">%s</a>' % (m.group(2), m.group(1)), text)
    text = _AUTOLINK.sub(
        lambda m: '<a href="%s">%s</a>' % (m.group(1), m.group(1)), text)
    return text


def plain(text):
    """The same text with the markup taken off, for a title attribute."""
    text = _CODE.sub(lambda m: m.group(2), text)
    text = _STRONG.sub(lambda m: m.group(1), text)
    text = _EM.sub(lambda m: m.group(1), text)
    return text


# ----------------------------------------------------------------- block parser

FENCE = re.compile(r"^(```+|~~~+)\s*(\S*)\s*$")
HEADING = re.compile(r"^(#{1,6})\s+(.*)$")
BULLET = re.compile(r"^([-*])\s+(.*)$")
ORDERED = re.compile(r"^(\d+)\.\s+(.*)$")
TASK = re.compile(r"^\[([ xX])\]\s+(.*)$")
TABLE_DELIM = re.compile(r"^\|[\s:|-]+\|$")
HRULE = re.compile(r"^(-{3,}|\*{3,}|_{3,})$")


def parse_blocks(lines):
    """A list of blocks, each a dict with a 'k' kind key."""
    blocks = []
    i = 0
    n = len(lines)
    while i < n:
        line = lines[i]
        if not line.strip():
            i += 1
            continue

        fence = FENCE.match(line)
        if fence:
            marker, lang = fence.group(1), fence.group(2)
            body = []
            i += 1
            while i < n and not lines[i].startswith(marker[0] * 3):
                body.append(lines[i])
                i += 1
            i += 1  # closing fence
            blocks.append({"k": "code", "lang": lang, "text": "\n".join(body)})
            continue

        head = HEADING.match(line)
        if head:
            blocks.append({"k": "heading",
                           "level": len(head.group(1)),
                           "text": head.group(2).strip()})
            i += 1
            continue

        if HRULE.match(line.strip()):
            blocks.append({"k": "hr"})
            i += 1
            continue

        if line.startswith(">"):
            quoted = []
            while i < n and (lines[i].startswith(">") or not lines[i].strip()):
                if not lines[i].strip():
                    if i + 1 >= n or not lines[i + 1].startswith(">"):
                        break
                    quoted.append("")
                else:
                    quoted.append(re.sub(r"^>\s?", "", lines[i]))
                i += 1
            blocks.append({"k": "quote", "blocks": parse_blocks(quoted)})
            continue

        if line.startswith("|"):
            rows = []
            while i < n and lines[i].startswith("|"):
                rows.append(lines[i])
                i += 1
            if len(rows) >= 2 and TABLE_DELIM.match(rows[1].strip()):
                blocks.append(_table(rows))
                continue
            blocks.append({"k": "para", "text": " ".join(r.strip() for r in rows)})
            continue

        if BULLET.match(line) or ORDERED.match(line):
            block, i = _list(lines, i)
            blocks.append(block)
            continue

        para = []
        while i < n and lines[i].strip():
            if para and (HEADING.match(lines[i]) or FENCE.match(lines[i])
                         or lines[i].startswith(("|", ">"))
                         or BULLET.match(lines[i]) or ORDERED.match(lines[i])
                         or HRULE.match(lines[i].strip())):
                break
            para.append(lines[i].strip())
            i += 1
        blocks.append({"k": "para", "text": " ".join(para)})
    return blocks


def _table(rows):
    def cells(row):
        return [c.strip() for c in row.strip().strip("|").split("|")]

    align = []
    for spec in cells(rows[1]):
        left, right = spec.startswith(":"), spec.endswith(":")
        align.append("center" if left and right else
                     "right" if right else "left" if left else "")
    return {"k": "table",
            "head": cells(rows[0]),
            "align": align,
            "rows": [cells(r) for r in rows[2:]]}


def _list(lines, i):
    """One list. Items own every following line indented by at least one space,
    which is how a multi-paragraph item is written in these documents."""
    n = len(lines)
    ordered = bool(ORDERED.match(lines[i]))
    start = int(ORDERED.match(lines[i]).group(1)) if ordered else 1
    items = []
    while i < n:
        m = ORDERED.match(lines[i]) if ordered else BULLET.match(lines[i])
        if not m:
            break
        raw = [m.group(2)]
        i += 1
        while i < n:
            if not lines[i].strip():
                # A blank line continues the item only if indented text follows.
                if (i + 1 < n and lines[i + 1].startswith(" ")
                        and lines[i + 1].strip()):
                    raw.append("")
                    i += 1
                    continue
                break
            if not lines[i].startswith(" "):
                break
            raw.append(lines[i])
            i += 1
        items.append({"task": None, "blocks": parse_blocks(_dedent(raw))})
        task = TASK.match(items[-1]["blocks"][0]["text"]) if items[-1]["blocks"] \
            and items[-1]["blocks"][0]["k"] == "para" else None
        if task:
            items[-1]["task"] = task.group(1).lower() == "x"
            items[-1]["blocks"][0]["text"] = task.group(2)
    return {"k": "list", "ordered": ordered, "start": start, "items": items}, i


def _dedent(raw):
    indents = [len(l) - len(l.lstrip(" ")) for l in raw[1:] if l.strip()]
    cut = min(indents) if indents else 0
    return [raw[0]] + [l[cut:] if l.strip() else "" for l in raw[1:]]


# --------------------------------------------------------------- document model
#
# Every document is a title, a preamble, and a list of sections; a section is
# free blocks plus entries. An entry is a finding, a check or a milestone: the
# unit the sidebar lists, the filter hides and the reader collapses.

SEVERITIES = ("critical", "high", "medium", "low")

# State keyword -> (css state class, label kept as the document writes it).
AUDIT_STATES = (("won't fix", "wontfix"), ("withdrawn", "idle"),
                ("resolved", "ok"), ("open", "open"))
CHECK_STATES = ("pass", "partial", "fail", "unchecked")

AUDIT_ID = re.compile(r"^([BSCA]\d+)$")
CHECK_ID = re.compile(r"^([WLRP]\d+)$")
MILESTONE = re.compile(r"^(G\d+)\.\s+(.*)$")
BULLET_ENTRY = re.compile(r"^\*\*([BSCA]\d+) · ([a-z]+) · ([^*]+)\*\*\s*—\s*(.*)$",
                          re.S)
RESULT = re.compile(r"^(Result:|Previously\b)", re.S)


class Entry(object):
    def __init__(self, kind, eid, title, blocks, sev="", state="", state_cls="",
                 refs="", lead=False):
        self.kind = kind          # 'finding' | 'check' | 'milestone' | 'part'
        self.id = eid             # 'B50', 'W4', 'G6', or '' for an untitled part
        self.title = title
        self.blocks = blocks
        self.sev = sev
        self.state = state        # the document's own words
        self.state_cls = state_cls   # ok | open | warn | idle | wontfix
        self.refs = refs          # '[B50]' on a check
        self.lead = lead          # title is the item's own first paragraph
        self.filter_value = state_cls    # what the state chips match on
        self.slug = ""
        self.group = ""


class Section(object):
    def __init__(self, title, level):
        self.title = title
        self.level = level
        self.blocks = []
        self.entries = []
        self.slug = ""


def split_sections(blocks):
    title = ""
    preamble = []
    sections = []
    cur = None
    for b in blocks:
        if b["k"] == "heading" and b["level"] == 1 and not title:
            title = b["text"]
            continue
        if b["k"] == "heading" and b["level"] == 2:
            cur = Section(b["text"], 2)
            sections.append(cur)
            continue
        (cur.blocks if cur else preamble).append(b)
    return title, preamble, sections


def split_entries(section, make_entry):
    """Turn each level-3 heading in a section into an entry, and hoist a list
    whose every item is an entry of its own (`AUDIT.md` writes its short
    resolved findings that way)."""
    free = []
    entries = []
    pending = None
    for b in section.blocks:
        if b["k"] == "heading" and b["level"] == 3:
            pending = make_entry(b["text"])
            entries.append(pending)
            continue
        target = pending.blocks if pending else free
        if b["k"] == "list" and not b["ordered"] and _all_bullet_entries(b):
            for item in b["items"]:
                entries.append(_bullet_entry(item))
            pending = None
            continue
        target.append(b)
    section.blocks = free
    section.entries = entries


def _all_bullet_entries(block):
    for item in block["items"]:
        first = item["blocks"][0] if item["blocks"] else None
        if not first or first["k"] != "para" or not BULLET_ENTRY.match(first["text"]):
            return False
    return bool(block["items"])


def _bullet_entry(item):
    m = BULLET_ENTRY.match(item["blocks"][0]["text"])
    eid, sev, state, rest = (g.strip() for g in m.groups())
    return Entry("finding", eid, rest, item["blocks"][1:], sev=sev, state=state,
                 state_cls=audit_state_cls(state), lead=True)


def audit_state_cls(state):
    low = state.lower()
    for keyword, cls in AUDIT_STATES:
        if keyword in low:
            return cls
    return "idle"


def finding_entry(heading):
    """`B50 · medium · resolved, `W4`–`W9` all pass — a player could fall out`"""
    head, _, title = heading.partition(" — ")
    parts = [p.strip() for p in head.split(" · ")]
    if len(parts) < 3 or not AUDIT_ID.match(parts[0]):
        return Entry("part", "", heading, [])
    sev = parts[1] if parts[1] in SEVERITIES else ""
    state = " · ".join(parts[2:])
    return Entry("finding", parts[0], title or head, [], sev=sev, state=state,
                 state_cls=audit_state_cls(state))


def check_entry(heading):
    """`W4 · The floor is there and you cannot fall through it [B50]`"""
    eid, _, title = heading.partition(" · ")
    if not CHECK_ID.match(eid.strip()):
        return Entry("part", "", heading, [])
    refs = ""
    m = re.search(r"\s*(\[[^\]]+\])$", title)
    if m:
        refs, title = m.group(1), title[:m.start()]
    return Entry("check", eid.strip(), title.strip(), [], refs=refs)


def milestone_entry(heading):
    """`G6. Bound the world — done: 5/5 written at `60259dd`, 6/6 checked`"""
    m = MILESTONE.match(heading)
    if not m:
        return Entry("part", "", heading, [])
    title, _, state = m.group(2).partition(" — ")
    low = state.lower()
    cls = ("ok" if low.startswith("done") else
           "idle" if low.startswith("not started") else "warn")
    return Entry("milestone", m.group(1), title.strip(), [], state=state.strip(),
                 state_cls=cls)


def check_state(entry):
    """A check's state is its most recent `Result:` line — the document lists
    results newest first inside an entry. `Previously` lines are the results it
    superseded."""
    prior = False
    state = "unchecked"
    seen = False
    for b in entry.blocks:
        if b["k"] != "para":
            continue
        if b["text"].startswith("Result:"):
            if seen:
                prior = True
                continue
            seen = True
            word = re.split(r"[,—]", b["text"][len("Result:"):].strip(), maxsplit=1)[0]
            word = word.strip().strip("*").lower()
            state = word if word in CHECK_STATES else "unchecked"
        elif b["text"].startswith("Previously"):
            prior = True
    return state, prior


CHECK_STATE_CLS = {"pass": "ok", "partial": "warn", "fail": "open",
                   "unchecked": "idle"}


# ------------------------------------------------------------------- rendering


def slugify(text, used):
    base = re.sub(r"-+", "-", re.sub(r"[^a-z0-9]+", "-", plain(text).lower())).strip("-")
    base = base or "s"
    slug = base
    k = 2
    while slug in used:
        slug = "%s-%d" % (base, k)
        k += 1
    used.add(slug)
    return slug


def anchor(slug):
    return ('<a class="hlink" href="#%s" aria-label="Link to this section">'
            '#</a>' % slug)


def render_blocks(blocks, out, level_shift=0):
    for b in blocks:
        kind = b["k"]
        if kind == "para":
            out.append(_para(b["text"]))
        elif kind == "heading":
            lvl = min(6, b["level"] + level_shift)
            slug = b.get("slug")
            out.append('<h%d%s>%s%s</h%d>'
                       % (lvl, ' id="%s"' % slug if slug else "",
                          inline(b["text"]), anchor(slug) if slug else "", lvl))
        elif kind == "code":
            cls = ' data-lang="%s"' % esc(b["lang"]) if b["lang"] else ""
            out.append("<pre%s><code>%s</code></pre>" % (cls, esc(b["text"])))
        elif kind == "quote":
            out.append("<blockquote>")
            render_blocks(b["blocks"], out, level_shift)
            out.append("</blockquote>")
        elif kind == "hr":
            out.append("<hr>")
        elif kind == "table":
            out.append(_table_html(b))
        elif kind == "list":
            _list_html(b, out, level_shift)


PARA_CLASS = (("Result:", "result"), ("Previously", "result prior"),
              ("**Pass:**", "passline"), ("**Keep", "keep"))


def _para(text):
    cls = ""
    for prefix, name in PARA_CLASS:
        if text.startswith(prefix):
            cls = name
            break
    if cls == "result":
        word = re.split(r"[,—]", text[len("Result:"):].strip(), maxsplit=1)[0]
        cls += " r-" + CHECK_STATE_CLS.get(word.strip().strip("*").lower(), "idle")
    attr = ' class="%s"' % cls if cls else ""
    return "<p%s>%s</p>" % (attr, inline(text))


def _table_html(b):
    out = ['<div class="tablewrap"><table><thead><tr>']
    for i, cell in enumerate(b["head"]):
        out.append("<th%s>%s</th>" % (_align(b, i), inline(cell)))
    out.append("</tr></thead><tbody>")
    for row in b["rows"]:
        out.append("<tr>")
        for i, cell in enumerate(row):
            out.append("<td%s>%s</td>" % (_align(b, i), inline(cell)))
        out.append("</tr>")
    out.append("</tbody></table></div>")
    return "".join(out)


def _align(b, i):
    a = b["align"][i] if i < len(b["align"]) else ""
    return ' style="text-align:%s"' % a if a else ""


def _list_html(b, out, level_shift):
    tag = "ol" if b["ordered"] else "ul"
    tasks = any(item["task"] is not None for item in b["items"])
    attrs = ' class="tasks"' if tasks else ""
    if b["ordered"] and b["start"] != 1:
        attrs += ' start="%d"' % b["start"]
    out.append("<%s%s>" % (tag, attrs))
    for item in b["items"]:
        if item["task"] is None:
            out.append("<li>")
        else:
            done = "done" if item["task"] else "todo"
            out.append('<li class="task %s"><span class="tick" aria-hidden="true">'
                       "%s</span>" % (done, "&#10003;" if item["task"] else "&#183;"))
        render_blocks(item["blocks"], out, level_shift)
        out.append("</li>")
    out.append("</%s>" % tag)


def render_entry(entry, open_default):
    out = []
    cls = "entry st-%s" % (entry.state_cls or "none")
    if entry.sev:
        cls += " sev-%s" % entry.sev
    # data-state is the value the state chips match on, and nothing else reads
    # it: the colour comes from the class. An entry the document gives no state
    # — a roadmap section that is not a milestone — carries an empty one, which
    # no chip can match, so the chips never hide it.
    data = ['data-state="%s"' % entry.filter_value]
    if entry.group:
        data.append('data-group="%s"' % entry.group)
    if entry.kind == "check" and entry.prior:
        data.append('data-prior="1"')
    out.append('<details class="%s" id="%s" %s%s>' %
               (cls, entry.slug, " ".join(data), " open" if open_default else ""))
    out.append("<summary>")
    if entry.id:
        out.append('<span class="eid">%s</span>' % esc(entry.id))
    title_cls = "etitle lead" if entry.lead else "etitle"
    out.append('<span class="%s">%s</span>' % (title_cls, inline(entry.title)))
    if entry.refs:
        out.append('<span class="erefs">%s</span>' % inline(entry.refs))
    out.append('<span class="chips">')
    if entry.sev:
        out.append('<span class="chip sev">%s</span>' % esc(entry.sev))
    if entry.kind == "check":
        out.append('<span class="chip state">%s</span>' % esc(entry.result))
        if entry.prior:
            out.append('<span class="chip prior">prior result</span>')
    elif entry.state:
        out.append('<span class="chip state">%s</span>' % inline(entry.state))
    out.append("</span>")
    out.append(anchor(entry.slug))
    out.append("</summary>")
    out.append('<div class="ebody">')
    # A body heading sits under the summary, which is not a heading element, so
    # it is pulled up one level to land directly under the section's h2 rather
    # than skipping a level.
    render_blocks(entry.blocks, out, level_shift=-1)
    out.append("</div></details>")
    return "".join(out)


# ------------------------------------------------------------------ page chrome

CSS_LIGHT = """
  --bg:#fbfbf9; --panel:#ffffff; --sunk:#f2f2ef; --code-bg:#f0f0ec;
  --fg:#1b1e23; --dim:#535963; --faint:#666d78;
  --rule:#e2e2dc; --rule-2:#c8c8c1;
  --link:#1f4f9c; --focus:#1f4f9c; --tint:#e8eefa;
  --sh:0 1px 2px rgba(24,26,30,.07);
  --ok-fg:#12613c; --ok-bg:#e2f2e8; --ok-line:#2c9160;
  --warn-fg:#7a4d00; --warn-bg:#fbeed4; --warn-line:#c3861a;
  --open-fg:#9e2118; --open-bg:#fbe7e4; --open-line:#cb4034;
  --idle-fg:#4a505b; --idle-bg:#eaecef; --idle-line:#98a0ac;
  --wontfix-fg:#4a3d6b; --wontfix-bg:#eceaf6; --wontfix-line:#8878b8;
"""

CSS_DARK = """
  --bg:#15171a; --panel:#1c1f24; --sunk:#101216; --code-bg:#23272d;
  --fg:#e3e6ea; --dim:#a6acb7; --faint:#848b96;
  --rule:#2b2f36; --rule-2:#3d434c;
  --link:#8fb5ff; --focus:#8fb5ff; --tint:#1d2739;
  --sh:0 1px 2px rgba(0,0,0,.4);
  --ok-fg:#82dba7; --ok-bg:#16301f; --ok-line:#44a86e;
  --warn-fg:#f5c977; --warn-bg:#382c14; --warn-line:#c9902a;
  --open-fg:#ff9e93; --open-bg:#3a1f1c; --open-line:#df6a5e;
  --idle-fg:#adb4bf; --idle-bg:#262a31; --idle-line:#6c7480;
  --wontfix-fg:#c4b6f0; --wontfix-bg:#272346; --wontfix-line:#8b7ac4;
"""

CSS_BODY = """
*,*::before,*::after{box-sizing:border-box}
html{-webkit-text-size-adjust:100%}
body{margin:0;background:var(--bg);color:var(--fg);
  font:16px/1.65 var(--serif);}
:root{--sans:system-ui,-apple-system,"Segoe UI",Roboto,"Helvetica Neue",Arial,sans-serif;
  --serif:Charter,"Bitstream Charter","Iowan Old Style","Palatino Linotype",Palatino,
    "Book Antiqua",Georgia,"Times New Roman",serif;
  --mono:ui-monospace,SFMono-Regular,"Cascadia Mono","Consolas","Liberation Mono",Menlo,monospace;
  /* --barh and --chrome are measured by the script once the bars are laid out;
     these are the fallbacks, and they only have to be close. */
  --topbar:3.25rem; --barh:3.25rem; --chrome:5.9rem;}
a{color:var(--link)}
a:focus-visible,button:focus-visible,input:focus-visible,summary:focus-visible{
  outline:2px solid var(--focus);outline-offset:2px;border-radius:3px}
code{font-family:var(--mono);font-size:.86em;background:var(--code-bg);
  padding:.08em .3em;border-radius:3px;overflow-wrap:break-word}
pre{background:var(--sunk);border:1px solid var(--rule);border-radius:6px;
  padding:.8rem 1rem;overflow-x:auto;font-size:.86rem;line-height:1.5}
pre code{background:none;padding:0;font-size:1em}
hr{border:0;border-top:1px solid var(--rule);margin:2rem 0}
blockquote{margin:1.2rem 0;padding:.2rem 0 .2rem 1rem;border-left:3px solid var(--rule-2);
  color:var(--dim)}
blockquote>:first-child{margin-top:0}blockquote>:last-child{margin-bottom:0}

/* chrome */
.skip{position:absolute;left:-9999px;top:0;background:var(--panel);padding:.5rem .8rem;z-index:60}
.skip:focus{left:.5rem;top:.5rem}
.topbar{position:sticky;top:0;z-index:40;display:flex;align-items:center;gap:.75rem;
  min-height:var(--topbar);padding:.4rem .9rem;background:var(--panel);
  border-bottom:1px solid var(--rule);box-shadow:var(--sh);
  font-family:var(--sans);flex-wrap:wrap}
.topbar .doc{font-weight:650;letter-spacing:-.015em;font-size:1rem;white-space:nowrap;
  font-family:var(--sans);margin:0}
.topbar .tally{color:var(--dim);font-size:.82rem;letter-spacing:.005em}
.topbar .tally b{color:var(--fg);font-weight:650}
.spacer{flex:1 1 auto}
#filter{font:inherit;font-size:.86rem;padding:.32rem .55rem;min-width:11rem;
  color:var(--fg);background:var(--bg);border:1px solid var(--rule-2);border-radius:5px}
#showing{font-size:.78rem;color:var(--dim);white-space:nowrap;min-width:6.5rem}
.btn{font:inherit;font-size:.78rem;padding:.3rem .55rem;cursor:pointer;
  color:var(--dim);background:var(--bg);border:1px solid var(--rule-2);border-radius:5px}
.btn:hover{color:var(--fg);border-color:var(--rule-2);background:var(--sunk)}
#navtoggle{display:none}

.filters{display:flex;gap:.4rem;flex-wrap:wrap;align-items:center;
  padding:.5rem .9rem;background:var(--panel);border-bottom:1px solid var(--rule);
  position:sticky;top:var(--barh);z-index:35;font-family:var(--sans)}
.filters .lbl{font-size:.72rem;text-transform:uppercase;letter-spacing:.06em;
  color:var(--faint);margin-right:.15rem}
.toggle{font:inherit;font-size:.76rem;cursor:pointer;padding:.2rem .5rem;
  border:1px solid var(--rule-2);border-radius:999px;background:var(--bg);color:var(--dim)}
.toggle .n{opacity:.65;margin-left:.3rem;font-variant-numeric:tabular-nums}
.toggle[aria-pressed="true"]{color:var(--fg);border-color:currentColor}
.toggle[aria-pressed="true"].t-ok{color:var(--ok-fg);background:var(--ok-bg)}
.toggle[aria-pressed="true"].t-warn{color:var(--warn-fg);background:var(--warn-bg)}
.toggle[aria-pressed="true"].t-open{color:var(--open-fg);background:var(--open-bg)}
.toggle[aria-pressed="true"].t-idle{color:var(--idle-fg);background:var(--idle-bg)}
.toggle[aria-pressed="true"].t-wontfix{color:var(--wontfix-fg);background:var(--wontfix-bg)}
.toggle.t-prior[aria-pressed="true"]{border-style:dashed;color:var(--dim)}
.toggle[aria-pressed="false"]{opacity:.55;text-decoration:line-through}
.sep{width:1px;align-self:stretch;background:var(--rule);margin:0 .3rem}

/* layout */
.layout{display:grid;grid-template-columns:16.5rem minmax(0,1fr);gap:2.5rem;
  max-width:80rem;margin:0 auto;padding:0 1.1rem}
.side{position:sticky;top:calc(var(--chrome) + .4rem);align-self:start;
  max-height:calc(100vh - var(--chrome) - 1rem);overflow-y:auto;overscroll-behavior:contain;
  padding:1.1rem .2rem 2rem 0;font-family:var(--sans);font-size:.82rem}
.side h2{font-size:.7rem;text-transform:uppercase;letter-spacing:.08em;color:var(--faint);
  margin:0 0 .5rem}
.side ul{list-style:none;margin:0;padding:0}
.side .s-link{display:block;padding:.24rem .45rem;border-radius:4px;color:var(--fg);
  text-decoration:none;font-weight:600;letter-spacing:-.005em}
.side .s-link:hover{background:var(--sunk)}
.side li.here>.s-link{background:var(--tint);color:var(--link)}
.side .kids{margin:.1rem 0 .5rem .15rem;border-left:1px solid var(--rule);padding-left:.35rem}
.side .e-link{display:flex;align-items:baseline;gap:.4rem;padding:.16rem .4rem;
  border-radius:4px;color:var(--dim);text-decoration:none}
.side .e-link:hover{background:var(--sunk);color:var(--fg)}
.side .dot{flex:0 0 auto;width:.5rem;height:.5rem;border-radius:50%;
  background:var(--idle-line);transform:translateY(-.05rem)}
.side .e-id{font-weight:600;font-variant-numeric:tabular-nums}
.side .e-meta{margin-left:auto;font-size:.68rem;color:var(--faint);
  text-transform:uppercase;letter-spacing:.04em}
.side .e-name{overflow:hidden;text-overflow:ellipsis;white-space:nowrap;flex:1 1 auto}
.st-ok .dot,.dot.d-ok{background:var(--ok-line)}
.st-warn .dot,.dot.d-warn{background:var(--warn-line)}
.st-open .dot,.dot.d-open{background:var(--open-line)}
.dot.d-idle{background:var(--idle-line)}
.dot.d-wontfix{background:var(--wontfix-line)}
main{min-width:0;padding:1.6rem 0 5rem}
main>.intro{margin-bottom:1rem}

/* prose measure */
main p,main ul,main ol,main blockquote,.ebody p,.ebody ul,.ebody ol{max-width:72ch}
main h2,main h3,main h4{font-family:var(--sans);letter-spacing:-.02em;line-height:1.25;
  max-width:60ch}
main h2{font-size:1.32rem;margin:2.4rem 0 .8rem;padding-bottom:.35rem;
  border-bottom:1px solid var(--rule)}
main h3{font-size:1.05rem;margin:1.8rem 0 .6rem}
main h4{font-size:.95rem;margin:1.4rem 0 .5rem;color:var(--dim)}
section{scroll-margin-top:calc(var(--chrome) + .6rem)}
.hlink{margin-left:.45rem;color:var(--faint);text-decoration:none;font-family:var(--sans);
  font-size:.8em;opacity:0;transition:opacity .12s}
h2:hover .hlink,h3:hover .hlink,h4:hover .hlink,summary:hover .hlink,.hlink:focus{opacity:1}

/* tables */
.tablewrap{overflow-x:auto;margin:1.1rem 0;border:1px solid var(--rule);border-radius:6px;
  background:var(--panel)}
table{border-collapse:collapse;width:100%;font-family:var(--sans);font-size:.84rem;
  line-height:1.5}
th,td{text-align:left;padding:.45rem .7rem;border-bottom:1px solid var(--rule);
  vertical-align:top}
thead th{background:var(--sunk);font-weight:650;white-space:nowrap;
  position:sticky;top:0}
tbody tr:last-child td{border-bottom:0}
tbody tr:hover{background:var(--sunk)}

/* entries */
.entry{margin:.55rem 0;background:var(--panel);border:1px solid var(--rule);
  border-left:4px solid var(--idle-line);border-radius:6px;box-shadow:var(--sh)}
.entry.st-ok{border-left-color:var(--ok-line)}
.entry.st-warn{border-left-color:var(--warn-line)}
.entry.st-open{border-left-color:var(--open-line)}
.entry.st-wontfix{border-left-color:var(--wontfix-line)}
.entry>summary{cursor:pointer;list-style:none;display:flex;align-items:baseline;
  gap:.5rem;flex-wrap:wrap;padding:.6rem .8rem;font-family:var(--sans)}
.entry>summary::-webkit-details-marker{display:none}
.entry>summary::before{content:"\\25B8";color:var(--faint);font-size:.8em;
  transform:translateY(-.05em)}
.entry[open]>summary::before{content:"\\25BE"}
.entry[open]>summary{border-bottom:1px solid var(--rule)}
.eid{font-weight:700;letter-spacing:-.01em;font-variant-numeric:tabular-nums}
.etitle{font-weight:500;letter-spacing:-.01em;flex:1 1 18rem;min-width:0}
.etitle.lead{white-space:nowrap;overflow:hidden;text-overflow:ellipsis;
  font-weight:400;color:var(--dim);font-family:var(--serif)}
.entry[open] .etitle.lead{white-space:normal;overflow:visible;color:var(--fg)}
.erefs{font-size:.78rem;color:var(--faint);font-variant-numeric:tabular-nums}
.chips{display:flex;gap:.3rem;flex-wrap:wrap;margin-left:auto}
.chip{font-size:.7rem;letter-spacing:.03em;text-transform:uppercase;
  padding:.12rem .42rem;border-radius:999px;white-space:nowrap;
  background:var(--idle-bg);color:var(--idle-fg)}
.chip.state,.chip.sev{max-width:26rem;overflow:hidden;text-overflow:ellipsis}
/* a state is a clause in these documents, not a word: uppercase would shout */
.chip.state{text-transform:none;letter-spacing:0;font-size:.74rem}
.st-ok .chip.state{background:var(--ok-bg);color:var(--ok-fg)}
.st-warn .chip.state{background:var(--warn-bg);color:var(--warn-fg)}
.st-open .chip.state{background:var(--open-bg);color:var(--open-fg)}
.st-wontfix .chip.state{background:var(--wontfix-bg);color:var(--wontfix-fg)}
.sev-critical .chip.sev,.sev-high .chip.sev{background:var(--open-bg);color:var(--open-fg)}
.sev-medium .chip.sev{background:var(--warn-bg);color:var(--warn-fg)}
.chip.state code,.chip.sev code{background:none;padding:0;font-size:1em}
.ebody{padding:.2rem 1rem 1rem}
.ebody>:first-child{margin-top:.9rem}
.ebody>:last-child{margin-bottom:0}
.entry:target,section:target>h2{scroll-margin-top:calc(var(--chrome) + .6rem)}
.entry:target{border-color:var(--focus);box-shadow:0 0 0 3px var(--tint)}
.entry:target>summary{background:var(--tint)}
h2:target,h3:target,h4:target{background:var(--tint);border-radius:4px;
  box-shadow:-.4rem 0 0 var(--tint),.4rem 0 0 var(--tint)}

/* marked paragraphs, all from markers the Markdown already carries */
.keep{border-left:3px solid var(--rule-2);background:var(--sunk);padding:.6rem .85rem;
  border-radius:0 4px 4px 0}
.passline{background:var(--sunk);padding:.55rem .85rem;border-radius:4px}
.result{font-family:var(--sans);font-size:.85rem;padding:.55rem .85rem;
  border-left:3px solid var(--idle-line);background:var(--sunk);border-radius:0 4px 4px 0}
.result.r-ok{border-left-color:var(--ok-line)}
.result.r-warn{border-left-color:var(--warn-line)}
.result.r-open{border-left-color:var(--open-line)}
.result.prior{color:var(--dim);font-size:.8rem;opacity:.9}
ul.tasks{list-style:none;padding-left:0}
ul.tasks>li.task{display:grid;grid-template-columns:1.3rem 1fr;align-items:start}
li.task .tick{font-family:var(--sans);color:var(--ok-fg);font-weight:700}
li.task.todo .tick{color:var(--faint)}
li.task.todo>p:first-of-type{color:var(--dim)}
li>p{margin:.35rem 0}
li{margin:.4rem 0}

.empty{display:none;color:var(--dim);font-family:var(--sans);padding:2rem .2rem}
body.nomatch .empty{display:block}
[hidden]{display:none !important}

footer{font-family:var(--sans);font-size:.8rem;color:var(--dim);
  border-top:1px solid var(--rule);margin-top:3rem;padding:1.2rem 0 0;max-width:72ch}
footer p{margin:.4rem 0;max-width:72ch}

@media (max-width:64rem){
  .layout{display:block;padding:0 1rem}
  #navtoggle{display:inline-block}
  .side{position:fixed;left:0;right:0;top:var(--chrome);z-index:38;
    max-height:70vh;margin:0;padding:1rem 1.2rem 1.4rem;background:var(--panel);
    border-bottom:1px solid var(--rule-2);box-shadow:0 8px 24px rgba(0,0,0,.18);
    transform:translateY(-115%);transition:transform .18s ease;visibility:hidden}
  body.navopen .side{transform:none;visibility:visible}
  main{padding-top:1rem}
}
@media (prefers-reduced-motion:reduce){*{transition:none !important}}
@media print{.topbar,.filters,.side{display:none}.entry{break-inside:avoid}}
"""

JS = r"""
(function(){
  var root=document.documentElement, KEY='codecube-report-theme';
  // The two sticky bars wrap at narrow widths, so their height is measured
  // rather than assumed: everything that has to clear them reads --chrome.
  function measure(){
    var bar=document.querySelector('.topbar').offsetHeight;
    root.style.setProperty('--barh',bar+'px');
    root.style.setProperty('--chrome',
      (bar+document.querySelector('.filters').offsetHeight)+'px');
  }
  window.addEventListener('resize',measure);
  measure();
  var tbtn=document.getElementById('theme'), modes=['auto','light','dark'];
  function setMode(m){
    if(m==='auto'){root.removeAttribute('data-theme');}else{root.setAttribute('data-theme',m);}
    tbtn.textContent='Theme: '+m; tbtn.setAttribute('aria-label','Colour theme: '+m);
    try{m==='auto'?localStorage.removeItem(KEY):localStorage.setItem(KEY,m);}catch(e){}
  }
  var stored=null; try{stored=localStorage.getItem(KEY);}catch(e){}
  setMode(modes.indexOf(stored)>0?stored:'auto');
  tbtn.addEventListener('click',function(){
    var cur=root.getAttribute('data-theme')||'auto';
    setMode(modes[(modes.indexOf(cur)+1)%modes.length]);
  });

  var entries=Array.prototype.slice.call(document.querySelectorAll('.entry'));
  var sections=Array.prototype.slice.call(document.querySelectorAll('main section'));
  var navFor={};
  Array.prototype.forEach.call(document.querySelectorAll('.e-link'),function(a){
    navFor[a.getAttribute('href').slice(1)]=a.parentNode;
  });
  var navSec={};
  Array.prototype.forEach.call(document.querySelectorAll('.s-link'),function(a){
    navSec[a.getAttribute('href').slice(1)]=a.parentNode;
  });
  entries.forEach(function(e){e._t=(e.textContent||'').toLowerCase();});
  sections.forEach(function(s){s._t=(s.textContent||'').toLowerCase();
    s._entries=Array.prototype.slice.call(s.querySelectorAll('.entry'));});

  var filter=document.getElementById('filter');
  var showing=document.getElementById('showing');
  var toggles=Array.prototype.slice.call(document.querySelectorAll('.toggle'));
  function offSet(kind){
    var off={};
    toggles.forEach(function(t){
      if(t.dataset.kind===kind && t.getAttribute('aria-pressed')==='false'){
        off[t.dataset.value]=1;
      }
    });
    return off;
  }
  function run(){
    var q=filter.value.trim().toLowerCase();
    var offState=offSet('state'), offGroup=offSet('group');
    var shown=0;
    entries.forEach(function(e){
      var hide=(e.dataset.state in offState)||(e.dataset.group in offGroup)
        ||(e.dataset.prior&&('prior' in offState))
        ||(q&&e._t.indexOf(q)<0);
      e.hidden=!!hide;
      if(!hide){shown++;}
      var n=navFor[e.id]; if(n){n.hidden=!!hide;}
    });
    sections.forEach(function(s){
      var hide;
      if(s._entries.length){hide=s._entries.every(function(e){return e.hidden;});}
      else{hide=!!q&&s._t.indexOf(q)<0;}
      s.hidden=hide;
      var n=navSec[s.id]; if(n){n.hidden=hide;}
    });
    showing.textContent=shown===entries.length
      ? entries.length+' '+showing.dataset.noun
      : shown+' of '+entries.length+' showing';
    document.body.classList.toggle('nomatch',shown===0);
  }
  filter.addEventListener('input',run);
  toggles.forEach(function(t){
    t.addEventListener('click',function(){
      t.setAttribute('aria-pressed',t.getAttribute('aria-pressed')==='true'?'false':'true');
      run();
    });
  });
  document.getElementById('expand').addEventListener('click',function(){
    entries.forEach(function(e){if(!e.hidden){e.open=true;}});
  });
  document.getElementById('collapse').addEventListener('click',function(){
    entries.forEach(function(e){e.open=false;});
  });
  document.getElementById('navtoggle').addEventListener('click',function(){
    document.body.classList.toggle('navopen');
  });
  document.addEventListener('keydown',function(ev){
    if(ev.key==='/'&&ev.target!==filter&&!ev.metaKey&&!ev.ctrlKey){
      ev.preventDefault();filter.focus();filter.select();
    }else if(ev.key==='Escape'){
      if(document.body.classList.contains('navopen')){document.body.classList.remove('navopen');}
      else if(ev.target===filter&&filter.value){filter.value='';run();}
    }
  });

  function reveal(){
    var id=decodeURIComponent(location.hash.slice(1));
    if(!id){return;}
    var el=document.getElementById(id);
    if(el&&el.tagName==='DETAILS'){el.open=true;}
    if(el&&el.hidden){filter.value='';toggles.forEach(function(t){
      t.setAttribute('aria-pressed','true');});run();
      el.scrollIntoView();}
  }
  window.addEventListener('hashchange',reveal);
  reveal();

  if('IntersectionObserver' in window){
    var live={};
    var io=new IntersectionObserver(function(recs){
      recs.forEach(function(r){
        if(r.isIntersecting){live[r.target.id]=1;}else{delete live[r.target.id];}
      });
      var top=null;
      sections.forEach(function(s){if(top===null&&live[s.id]){top=s.id;}});
      Object.keys(navSec).forEach(function(id){
        navSec[id].classList.toggle('here',id===top);
      });
    },{rootMargin:'-'+(parseFloat(getComputedStyle(root).getPropertyValue('--chrome'))+8)
        +'px 0px -65% 0px'});
    sections.forEach(function(s){io.observe(s);});
  }
  run();
})();
"""


def page(doc, meta):
    """Assemble one rendering. `doc` carries the parsed document, `meta` the
    git provenance for the footer."""
    out = ['<!DOCTYPE html>', '<html lang="en">', "<head>",
           '<meta charset="utf-8">',
           '<meta name="viewport" content="width=device-width,initial-scale=1">',
           '<meta name="color-scheme" content="light dark">',
           "<title>%s</title>" % esc(plain(doc.title)),
           "<style>",
           ":root{%s}" % CSS_LIGHT,
           '@media (prefers-color-scheme:dark){:root:not([data-theme="light"]){%s}}'
           % CSS_DARK,
           ':root[data-theme="dark"]{%s}' % CSS_DARK,
           CSS_BODY, "</style>", "</head>", "<body>",
           '<a class="skip" href="#main">Skip to content</a>']

    # header
    out.append('<header class="topbar">')
    out.append('<button class="btn" id="navtoggle" aria-label="Show the section '
               'index">Sections</button>')
    out.append('<h1 class="doc">%s</h1>' % inline(doc.title))
    out.append('<span class="tally">%s</span>' % doc.tally)
    out.append('<span class="spacer"></span>')
    out.append('<label class="skip" for="filter">Filter</label>')
    out.append('<input id="filter" type="search" placeholder="Filter %s '
               '(press /)" autocomplete="off" spellcheck="false">' % doc.noun)
    out.append('<span id="showing" data-noun="%s">%d %s</span>'
               % (doc.noun, len(doc.entries), doc.noun))
    out.append('<button class="btn" id="theme" type="button">Theme: auto</button>')
    out.append("</header>")

    # filter chips
    out.append('<div class="filters">')
    out.append('<span class="lbl">%s</span>' % doc.state_label)
    for value, label, cls, count in doc.state_filters:
        out.append('<button class="toggle t-%s" type="button" data-kind="state" '
                   'data-value="%s" aria-pressed="true">%s<span class="n">%d</span>'
                   "</button>" % (cls, value, esc(label), count))
    if doc.group_filters:
        out.append('<span class="sep"></span><span class="lbl">%s</span>'
                   % doc.group_label)
        for value, label, count in doc.group_filters:
            out.append('<button class="toggle" type="button" data-kind="group" '
                       'data-value="%s" aria-pressed="true">%s<span class="n">%d</span>'
                       "</button>" % (value, esc(label), count))
    out.append('<span class="spacer"></span>')
    out.append('<button class="btn" id="expand" type="button">Expand all</button>')
    out.append('<button class="btn" id="collapse" type="button">Collapse all</button>')
    out.append("</div>")

    out.append('<div class="layout">')

    # sidebar
    out.append('<nav class="side" aria-label="Document index"><h2>%s</h2><ul>'
               % esc(doc.nav_label))
    for sec in doc.sections:
        out.append("<li>")
        out.append('<a class="s-link" href="#%s">%s</a>' % (sec.slug, inline(sec.title)))
        if sec.entries:
            out.append('<ul class="kids">')
            for e in sec.entries:
                dot = e.result_cls if e.kind == "check" else (e.state_cls or "idle")
                out.append("<li>")
                out.append('<a class="e-link" href="#%s" title="%s">' %
                           (e.slug, esc(plain(e.nav_title))))
                out.append('<span class="dot d-%s"></span>' % dot)
                if e.id:
                    out.append('<span class="e-id">%s</span>' % esc(e.id))
                out.append('<span class="e-name">%s</span>' % esc(plain(e.nav_title)))
                if e.nav_meta:
                    out.append('<span class="e-meta">%s</span>' % esc(e.nav_meta))
                out.append("</a></li>")
            out.append("</ul>")
        out.append("</li>")
    out.append("</ul></nav>")

    # body
    out.append('<main id="main">')
    if doc.preamble:
        out.append('<div class="intro">')
        render_blocks(doc.preamble, out)
        out.append("</div>")
    for sec in doc.sections:
        out.append('<section id="%s">' % sec.slug)
        out.append("<h2>%s%s</h2>" % (inline(sec.title), anchor(sec.slug)))
        render_blocks(sec.blocks, out)
        for e in sec.entries:
            out.append(render_entry(e, e.open_default))
        out.append("</section>")
    out.append('<p class="empty">Nothing matches the filter.</p>')

    out.append("<footer>")
    for line in meta:
        out.append("<p>%s</p>" % line)
    out.append('<p>Presentation only, generated by <code>scripts/gen_reports.py</code> '
               'from <code>%s</code>. Every fact here is in that file; '
               '<code>.reports/</code> is gitignored and costs nothing to lose.</p>'
               % esc(doc.source))
    out.append("</footer></main></div>")
    out.append("<script>%s</script>" % JS)
    out.append("</body></html>")
    return "\n".join(out) + "\n"


# ------------------------------------------------------------------- git facts


def git(*args):
    try:
        res = subprocess.run(("git",) + args, cwd=ROOT, capture_output=True,
                             text=True, encoding="utf-8", errors="replace")
    except OSError:
        return ""
    return res.stdout.strip() if res.returncode == 0 else ""


def provenance(source):
    """Footer lines. Deterministic on an unchanged tree: nothing here reads the
    clock, and the date is the commit's, not the render's."""
    head = git("rev-parse", "--short", "HEAD")
    if not head:
        return ["<strong>No git metadata available</strong> — this rendering "
                "names no commit."]
    branch = git("rev-parse", "--abbrev-ref", "HEAD")
    subject = git("log", "-1", "--format=%s")
    date = git("log", "-1", "--format=%ad", "--date=short")
    doc_sha = git("log", "-1", "--format=%h", "--", source)
    doc_date = git("log", "-1", "--format=%ad", "--date=short", "--", source)
    dirty_doc = bool(git("status", "--porcelain", "--", source))
    lines = []
    if dirty_doc:
        lines.append("Rendered from <code>%s</code> as it stands in the working "
                     "tree, with uncommitted changes over <code>%s</code> (%s)."
                     % (esc(source), esc(doc_sha or "?"), esc(doc_date or "?")))
    else:
        lines.append("Rendered from <code>%s</code> as committed at <code>%s</code>"
                     ", %s." % (esc(source), esc(doc_sha or "?"), esc(doc_date or "?")))
    ahead = git("rev-list", "--count", "origin/main..HEAD")
    tail = ""
    if ahead and ahead != "0":
        tail = " %s commit%s ahead of <code>origin/main</code>." % (
            esc(ahead), "" if ahead == "1" else "s")
    lines.append("Repository at <code>%s</code> on <code>%s</code>, %s — %s.%s"
                 % (esc(head), esc(branch), esc(date), esc(subject), tail))
    # The adopted release is the pointer recorded in the superproject's tree,
    # not whatever `mods/codeblock` happens to be checked out at: an unstaged
    # submodule is this repository's normal resting state.
    ptr = git("rev-parse", "HEAD:mods/codeblock")
    if ptr:
        tag = git("-C", "mods/codeblock", "describe", "--tags", "--exact-match", ptr)
        lines.append("Adopted codeblock <code>%s</code>%s."
                     % (esc(ptr[:7]), " — <code>%s</code>" % esc(tag) if tag
                        else ", an untagged commit"))
    return lines


# ------------------------------------------------------------ the three reports


class Doc(object):
    """One rendering's parsed source plus the labels its chrome needs."""

    def __init__(self, source, blocks):
        self.source = source
        self.title, self.preamble, self.sections = split_sections(blocks)
        self.entries = []
        self.noun = "entries"
        self.tally = ""
        self.nav_label = "Contents"
        self.state_label = "State"
        self.group_label = "Series"
        self.state_filters = []
        self.group_filters = []

    def finish(self):
        """Allocate every anchor in one pass, so no two collide: sections,
        entries, then any heading left inside a body."""
        used = set()
        for sec in self.sections:
            sec.slug = slugify(sec.title, used)
            for e in sec.entries:
                e.slug = e.id if e.id else slugify(e.title, used)
                used.add(e.slug)
                self.entries.append(e)
        name_headings(self.preamble, used)
        for sec in self.sections:
            name_headings(sec.blocks, used)
            for e in sec.entries:
                name_headings(e.blocks, used)


def name_headings(blocks, used):
    for b in blocks:
        if b["k"] == "heading":
            b["slug"] = slugify(b["text"], used)
        elif b["k"] == "quote":
            name_headings(b["blocks"], used)
        elif b["k"] == "list":
            for item in b["items"]:
                name_headings(item["blocks"], used)


def counted(entries, key, order, labels=None, classes=None):
    """Filter buttons in a fixed order, dropping states the document does not
    use, so no chip is offered that can never match."""
    tally = {}
    for e in entries:
        tally[key(e)] = tally.get(key(e), 0) + 1
    out = []
    for value in order:
        if not tally.get(value):
            continue
        label = labels.get(value, value) if labels else value
        cls = classes.get(value, "idle") if classes else "idle"
        out.append((value, label, cls, tally[value]))
    return out


def build_audit(blocks):
    doc = Doc("AUDIT.md", blocks)
    for sec in doc.sections:
        split_entries(sec, finding_entry)
        for e in sec.entries:
            e.group = e.id[0] if e.id else ""
            e.filter_value = e.state_cls
            e.open_default = e.state_cls == "open"
            e.nav_title = e.title
            e.nav_meta = e.sev[:3] if e.sev else ""
    doc.finish()
    doc.noun = "findings"
    doc.nav_label = "Findings"
    doc.state_label = "State"
    doc.group_label = "Series"
    states = counted(doc.entries, lambda e: e.state_cls or "idle",
                     ("open", "ok", "wontfix", "idle"),
                     {"ok": "resolved", "open": "open", "wontfix": "won't fix",
                      "idle": "other"},
                     {"ok": "ok", "open": "open", "wontfix": "wontfix",
                      "idle": "idle"})
    doc.state_filters = states
    series = {"B": "B bugs", "S": "S sandbox", "C": "C compliance",
              "A": "A architecture"}
    doc.group_filters = [(v, series.get(v, v), n) for v, _l, _c, n in
                         counted(doc.entries, lambda e: e.group, ("B", "S", "C", "A"))]
    doc.tally = "<b>%d</b> findings &#183; %s" % (
        len(doc.entries),
        " &#183; ".join("<b>%d</b> %s" % (n, l) for _v, l, _c, n in states)
        or "none")
    return doc


def build_playtest(blocks):
    doc = Doc("PLAYTEST.md", blocks)
    for sec in doc.sections:
        split_entries(sec, check_entry)
        for e in sec.entries:
            e.group = e.id[0] if e.id else ""
            e.result, e.prior = check_state(e)
            e.result_cls = CHECK_STATE_CLS[e.result]
            e.state_cls = e.result_cls
            e.filter_value = e.result
            e.open_default = e.result != "pass"
            e.nav_title = e.title
            e.nav_meta = e.refs.strip("[]") if e.refs else ""
    doc.finish()
    doc.noun = "checks"
    doc.nav_label = "Checks"
    doc.state_label = "Result"
    doc.group_label = "Group"
    states = counted(doc.entries, lambda e: e.result,
                     ("fail", "unchecked", "partial", "pass"),
                     None,
                     {"pass": "ok", "partial": "warn", "fail": "open",
                      "unchecked": "idle"})
    prior = sum(1 for e in doc.entries if e.prior)
    if prior:
        states = states + [("prior", "prior result", "prior", prior)]
    doc.state_filters = states
    groups = {"W": "W world", "L": "L light", "R": "R restrictions",
              "P": "P packaging"}
    doc.group_filters = [(v, groups.get(v, v), n) for v, _l, _c, n in
                         counted(doc.entries, lambda e: e.group, ("W", "L", "R", "P"))]
    doc.tally = "<b>%d</b> checks &#183; %s" % (
        len(doc.entries),
        " &#183; ".join("<b>%d</b> %s" % (n, l) for v, l, _c, n in states
                        if v != "prior"))
    return doc


def build_roadmap(blocks):
    doc = Doc("ROADMAP.md", blocks)
    for sec in doc.sections:
        split_entries(sec, milestone_entry)
        for e in sec.entries:
            e.group = "milestone" if e.id else "note"
            e.filter_value = e.state_cls
            e.open_default = e.state_cls != "ok"
            e.nav_title = e.title
            e.nav_meta = ""
    doc.finish()
    doc.noun = "sections"
    doc.nav_label = "Milestones"
    doc.state_label = "Milestone"
    doc.group_label = "Kind"
    doc.state_filters = counted(
        doc.entries, lambda e: e.state_cls, ("warn", "idle", "ok"),
        {"ok": "done", "warn": "in flight", "idle": "not started"},
        {"ok": "ok", "warn": "warn", "idle": "idle"})
    doc.group_filters = [(v, l, n) for v, l, _c, n in
                         counted(doc.entries, lambda e: e.group,
                                 ("milestone", "note"),
                                 {"milestone": "milestones", "note": "other sections"})]
    milestones = [e for e in doc.entries if e.id]
    done = sum(1 for e in milestones if e.state_cls == "ok")
    doc.tally = "<b>%d</b> milestones &#183; <b>%d</b> done" % (len(milestones), done)
    return doc


REPORTS = (("ROADMAP.md", "roadmap.html", build_roadmap),
           ("AUDIT.md", "audit.html", build_audit),
           ("PLAYTEST.md", "playtest.html", build_playtest))


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--check", action="store_true",
                    help="report whether the output would change; write nothing")
    args = ap.parse_args()

    if not args.check:
        os.makedirs(OUT_DIR, exist_ok=True)
    drift = []
    for source, target, build in REPORTS:
        path = os.path.join(ROOT, source)
        with open(path, encoding="utf-8") as fh:
            text = fh.read()
        doc = build(parse_blocks(text.replace("\r\n", "\n").split("\n")))
        html = page(doc, provenance(source))
        out = os.path.join(OUT_DIR, target)
        if args.check:
            old = ""
            if os.path.exists(out):
                with open(out, encoding="utf-8", newline="") as fh:
                    old = fh.read()
            if old != html:
                drift.append(target)
            continue
        with open(out, "w", encoding="utf-8", newline="\n") as fh:
            fh.write(html)
        print("%-13s -> .reports/%-14s %3d entries, %d sections, %d KiB"
              % (source, target, len(doc.entries), len(doc.sections),
                 len(html.encode("utf-8")) // 1024))
    if args.check:
        if drift:
            print("stale: " + ", ".join(drift))
            return 1
        print("all three renderings are up to date")
    return 0


if __name__ == "__main__":
    sys.exit(main())
