#!/usr/bin/env python3
"""Auto-regenerate docs/js/skills.json from skills/ folder.
Run: python3 scripts/generate_skills_json.py
"""
import os, re, json
from pathlib import Path

ROOT = Path(__file__).parent.parent
SKILLS_DIR = ROOT / "skills"
OUT_FILE   = ROOT / "docs" / "js" / "skills.json"

CATEGORY_META = {
    "agent":    {"label": "Agent & Orchestration", "icon": "🤖", "color": "#6366f1"},
    "security": {"label": "Security",               "icon": "🔒", "color": "#ef4444"},
    "web":      {"label": "Web & Browser",          "icon": "🌐", "color": "#0ea5e9"},
    "design":   {"label": "Design & UI",            "icon": "🎨", "color": "#ec4899"},
    "mobile":   {"label": "Mobile",                 "icon": "📱", "color": "#f59e0b"},
    "backend":  {"label": "Backend & DevOps",       "icon": "⚙️",  "color": "#10b981"},
    "product":  {"label": "Product & Analytics",    "icon": "📊", "color": "#8b5cf6"},
    "workflow": {"label": "PR & Git Workflow",       "icon": "🔀", "color": "#14b8a6"},
    "research": {"label": "Research & Web",         "icon": "🔍", "color": "#f97316"},
    "devtools": {"label": "Dev Tools",              "icon": "🛠️",  "color": "#a855f7"},
}

def read_frontmatter(skill_md: Path):
    """Extract name, description, category, tags from SKILL.md frontmatter."""
    text = skill_md.read_text(errors='ignore')
    if not text.startswith('---'):
        return {}
    end = text.find('---', 3)
    if end == -1:
        return {}
    fm = text[3:end]
    result = {}
    for line in fm.splitlines():
        m = re.match(r'^(\w+):\s*(.+)$', line.strip())
        if m:
            key, val = m.group(1), m.group(2).strip().strip('"').strip("'")
            result[key] = val
    # tags
    tm = re.search(r'^tags:\s*\[(.+)\]', fm, re.MULTILINE)
    if tm:
        result['tags'] = [t.strip().strip('"') for t in tm.group(1).split(',')]
    return result

skills = []
skip = {'basic', 'library', 'dependent'}

for entry in sorted(SKILLS_DIR.iterdir()):
    if not entry.is_dir() or entry.name in skip:
        continue
    skill_md = entry / "SKILL.md"
    fm = read_frontmatter(skill_md) if skill_md.exists() else {}
    name = entry.name
    cat  = fm.get('category', 'devtools')
    desc = fm.get('description', f"{name} skill for Claude Code")
    tags = fm.get('tags', [])
    if isinstance(tags, str):
        tags = [t.strip() for t in tags.split(',')]
    skills.append({
        "name":        name,
        "category":    cat,
        "keywords":    tags,
        "description": desc,
        "tier":        fm.get('tier', 'core'),
        "github_url":  f"https://github.com/AravindS-Wick/aravindhan-skills/tree/main/skills/{name}"
    })

output = {
    "meta": {
        "total":     len(skills),
        "generated": "auto",
        "repo":      "https://github.com/AravindS-Wick/aravindhan-skills"
    },
    "categories": CATEGORY_META,
    "skills":     skills
}

OUT_FILE.parent.mkdir(parents=True, exist_ok=True)
OUT_FILE.write_text(json.dumps(output, indent=2, ensure_ascii=False))
print(f"✅ Generated {OUT_FILE} with {len(skills)} skills")
