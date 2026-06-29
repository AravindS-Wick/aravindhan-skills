/* app.js — aravindhan-skills GitHub Pages
   Handles: data loading, Fuse.js search, category filters, skill cards, modal, copy */

(function () {
  'use strict';

  let allSkills = [];
  let categories = {};
  let fuse = null;
  let activeCategory = 'all';
  let currentSkill = null;

  // ── DOM refs ──────────────────────────────────────────────
  const grid       = document.getElementById('skills-grid');
  const searchInput= document.getElementById('search-input');
  const searchCount= document.getElementById('search-count');
  const filtersEl  = document.querySelector('.filters');
  const noResults  = document.getElementById('no-results');
  const modal      = document.getElementById('modal-overlay');
  const modalClose = document.getElementById('modal-close');
  const statCore   = document.getElementById('stat-core');

  // ── Load data ─────────────────────────────────────────────
  fetch('js/skills.json')
    .then(r => r.json())
    .then(data => {
      allSkills  = data.skills;
      categories = data.categories;
      if (statCore) statCore.textContent = data.meta.total;
      buildFilters();
      buildFuse();
      render(allSkills);
    })
    .catch(err => {
      console.error('Failed to load skills.json', err);
      grid.innerHTML = '<p style="color:#ef4444;grid-column:1/-1;text-align:center">Failed to load skills. Please refresh.</p>';
    });

  // ── Build category filter buttons ─────────────────────────
  function buildFilters() {
    // count per category
    const counts = {};
    allSkills.forEach(s => { counts[s.category] = (counts[s.category] || 0) + 1; });

    Object.entries(categories).forEach(([key, meta]) => {
      const btn = document.createElement('button');
      btn.className = 'filter-btn';
      btn.dataset.cat = key;
      btn.id = 'filter-' + key;
      btn.setAttribute('aria-label', `Filter: ${meta.label} (${counts[key] || 0})`);
      btn.innerHTML = `${meta.icon} ${meta.label} <span style="opacity:.5;margin-left:4px">${counts[key] || 0}</span>`;
      btn.addEventListener('click', () => setCategory(key));
      filtersEl.appendChild(btn);
    });

    // wire up "All" button
    document.getElementById('filter-all').addEventListener('click', () => setCategory('all'));
    updateFilterActive();
  }

  // ── Fuse.js fuzzy search ──────────────────────────────────
  function buildFuse() {
    fuse = new Fuse(allSkills, {
      keys: [
        { name: 'name',        weight: 0.4 },
        { name: 'description', weight: 0.35 },
        { name: 'keywords',    weight: 0.25 },
      ],
      threshold: 0.35,
      includeScore: true,
      ignoreLocation: true,
    });
  }

  // ── Search input handler ──────────────────────────────────
  let searchTimer = null;
  searchInput.addEventListener('input', () => {
    clearTimeout(searchTimer);
    searchTimer = setTimeout(doSearch, 80);
  });

  function doSearch() {
    const q = searchInput.value.trim();
    let results = allSkills;

    if (q) {
      results = fuse.search(q).map(r => r.item);
    }

    // apply category filter on top of search
    if (activeCategory !== 'all') {
      results = results.filter(s => s.category === activeCategory);
    }

    render(results);
    searchCount.textContent = q || activeCategory !== 'all'
      ? `${results.length} result${results.length !== 1 ? 's' : ''}`
      : '';
  }

  // ── Category filter ───────────────────────────────────────
  function setCategory(cat) {
    activeCategory = cat;
    updateFilterActive();
    doSearch();
  }

  function updateFilterActive() {
    document.querySelectorAll('.filter-btn').forEach(btn => {
      btn.classList.toggle('active', btn.dataset.cat === activeCategory);
    });
  }

  // ── Render skill cards ────────────────────────────────────
  function render(skills) {
    grid.innerHTML = '';
    noResults.hidden = skills.length > 0;

    skills.forEach((skill, i) => {
      const cat = categories[skill.category] || { label: skill.category, icon: '🛠️', color: '#6366f1' };
      const card = document.createElement('article');
      card.className = 'skill-card';
      card.setAttribute('role', 'listitem');
      card.setAttribute('tabindex', '0');
      card.setAttribute('aria-label', `${skill.name} — ${skill.description}`);
      card.style.animationDelay = `${Math.min(i * 0.03, 0.4)}s`;

      const topKws = (skill.keywords || []).slice(0, 3);

      card.innerHTML = `
        <div class="skill-card-header">
          <span class="skill-cat-pill" style="color:${cat.color};border-color:${cat.color}33;background:${cat.color}18">
            ${cat.icon} ${cat.label}
          </span>
          <span class="skill-card-arrow" aria-hidden="true">→</span>
        </div>
        <div class="skill-name">${escHtml(skill.name)}</div>
        <div class="skill-description">${escHtml(skill.description)}</div>
        ${topKws.length ? `<div class="skill-keywords">${topKws.map(k => `<span class="skill-keyword">${escHtml(k)}</span>`).join('')}</div>` : ''}
      `;

      card.addEventListener('click', () => openModal(skill));
      card.addEventListener('keydown', e => {
        if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); openModal(skill); }
      });
      grid.appendChild(card);
    });
  }

  // ── Modal ─────────────────────────────────────────────────
  function openModal(skill) {
    currentSkill = skill;
    const cat = categories[skill.category] || { label: skill.category, icon: '🛠️' };

    document.getElementById('modal-category').textContent = `${cat.icon} ${cat.label}`;
    document.getElementById('modal-title').textContent = skill.name;
    document.getElementById('modal-description').textContent = skill.description;

    const kwEl = document.getElementById('modal-keywords');
    kwEl.innerHTML = (skill.keywords || [])
      .map(k => `<span class="modal-keyword">${escHtml(k)}</span>`).join('');

    document.getElementById('modal-code').textContent =
      `# 1. Install\ngit clone https://github.com/AravindS-Wick/aravindhan-skills ~/personal/aravindhan-skills\ncd ~/personal/aravindhan-skills && ./install.sh\n\n# 2. Use in Claude\nTell Claude: "use the ${skill.name} skill"\n# or just describe what you want — skills auto-trigger`;

    const ghLink = document.getElementById('modal-github');
    ghLink.href = skill.github_url;

    modal.hidden = false;
    document.body.style.overflow = 'hidden';
    modalClose.focus();
    document.addEventListener('keydown', handleModalKey);
  }

  function closeModal() {
    modal.hidden = true;
    document.body.style.overflow = '';
    document.removeEventListener('keydown', handleModalKey);
  }

  function handleModalKey(e) {
    if (e.key === 'Escape') closeModal();
  }

  modalClose.addEventListener('click', closeModal);
  modal.addEventListener('click', e => { if (e.target === modal) closeModal(); });

  // ── Copy helpers ──────────────────────────────────────────
  window.copyInstall = function () {
    const code = document.getElementById('install-code').textContent;
    navigator.clipboard.writeText(code).then(() => {
      const btn = document.getElementById('copy-install');
      btn.textContent = 'Copied!';
      btn.classList.add('copied');
      setTimeout(() => { btn.textContent = 'Copy'; btn.classList.remove('copied'); }, 2000);
    });
  };

  window.copyModalInstall = function () {
    const code = document.getElementById('modal-code').textContent;
    navigator.clipboard.writeText(code).then(() => {
      const btn = document.getElementById('modal-copy');
      btn.textContent = 'Copied!';
      setTimeout(() => { btn.textContent = 'Copy Install'; }, 2000);
    });
  };

  // ── Escape HTML ───────────────────────────────────────────
  function escHtml(str) {
    return String(str)
      .replace(/&/g, '&amp;').replace(/</g, '&lt;')
      .replace(/>/g, '&gt;').replace(/"/g, '&quot;');
  }

})();
