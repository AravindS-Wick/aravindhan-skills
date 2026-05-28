const { chromium } = require('playwright');

const stories = [
  { name: 'with-adornments', url: 'http://localhost:6008/?path=/story/inputs-textfield--with-adornments' },
  { name: 'password-fields', url: 'http://localhost:6008/?path=/story/inputs-textfield--password-fields' },
  { name: 'number-stepper', url: 'http://localhost:6008/?path=/story/inputs-textfield--number-stepper' },
  { name: 'number-controls', url: 'http://localhost:6008/?path=/story/inputs-textfield--number-controls' },
  { name: 'masked-inputs', url: 'http://localhost:6008/?path=/story/inputs-textfield--masked-inputs' },
  { name: 'combobox-select', url: 'http://localhost:6008/?path=/story/inputs-select--combobox-select' },
  { name: 'paper-variants', url: 'http://localhost:6008/?path=/story/layout-card--paper-variants' },
  { name: 'datatable-plain', url: 'http://localhost:6008/?path=/story/data-display-datatable--plain' },
  { name: 'list-empty-states', url: 'http://localhost:6008/?path=/story/data-display-list--empty-states' },
];

(async () => {
  const browser = await chromium.launch({ headless: true });
  const results = [];

  for (const story of stories) {
    const page = await browser.newPage();
    const consoleErrors = [];

    page.on('console', msg => {
      if (msg.type() === 'error') {
        consoleErrors.push(msg.text());
      }
    });

    page.on('pageerror', err => {
      consoleErrors.push(`PAGE ERROR: ${err.message}`);
    });

    try {
      await page.goto(story.url, { waitUntil: 'networkidle', timeout: 30000 });

      // Wait for iframe to be available
      await page.waitForSelector('#storybook-preview-iframe', { timeout: 15000 });

      const frame = page.frame({ name: 'storybook-preview-iframe' }) ||
                    page.frames().find(f => f.url().includes('iframe.html'));

      let hasContent = false;
      let hasErrorOverlay = false;
      let frameConsoleErrors = [];

      if (frame) {
        frame.on('console', msg => {
          if (msg.type() === 'error') {
            frameConsoleErrors.push(msg.text());
          }
        });

        // Wait for story root or docs story to appear
        try {
          await frame.waitForSelector('#storybook-root, .docs-story, [data-testid="storybook-story"]', {
            timeout: 15000,
            state: 'visible'
          });
        } catch (e) {
          // Try waiting a bit more
          await page.waitForTimeout(3000);
        }

        // Check for error overlay
        const errorOverlay = await frame.$('.sb-errordisplay, #error-stack, .sb-storybook-error');
        if (errorOverlay) {
          const isVisible = await errorOverlay.isVisible();
          hasErrorOverlay = isVisible;
        }

        // Check for content in story root
        const storyRoot = await frame.$('#storybook-root');
        if (storyRoot) {
          const innerHTML = await storyRoot.innerHTML();
          hasContent = innerHTML.trim().length > 0;
        }

        // Also check docs-story
        if (!hasContent) {
          const docsStory = await frame.$('.docs-story');
          if (docsStory) {
            const innerHTML = await docsStory.innerHTML();
            hasContent = innerHTML.trim().length > 0;
          }
        }
      }

      // Take screenshot of the full page
      await page.screenshot({ path: `/tmp/verify_${story.name}.png`, fullPage: true });

      const allErrors = [...consoleErrors, ...frameConsoleErrors].filter(e =>
        !e.includes('favicon') &&
        !e.includes('net::ERR_') &&
        !e.includes('Warning:') &&
        !e.toLowerCase().includes('deprecated')
      );

      let status;
      if (hasErrorOverlay) {
        status = 'FAIL (error overlay visible)';
      } else if (!hasContent) {
        status = 'FAIL (no content in story root)';
      } else if (allErrors.length > 0) {
        status = `FAIL (console errors: ${allErrors.slice(0, 2).join(' | ')})`;
      } else {
        status = 'PASS';
      }

      results.push({ name: story.name, url: story.url, status, errors: allErrors, hasContent, hasErrorOverlay });
      console.log(`[${status.startsWith('PASS') ? 'PASS' : 'FAIL'}] ${story.name}`);
      if (!status.startsWith('PASS') && allErrors.length > 0) {
        console.log(`  Errors: ${allErrors.slice(0, 3).join('\n  ')}`);
      }

    } catch (err) {
      await page.screenshot({ path: `/tmp/verify_${story.name}.png` }).catch(() => {});
      results.push({ name: story.name, url: story.url, status: `FAIL (exception: ${err.message})`, errors: [err.message] });
      console.log(`[FAIL] ${story.name} — ${err.message}`);
    } finally {
      await page.close();
    }
  }

  await browser.close();

  console.log('\n=== SUMMARY ===');
  for (const r of results) {
    console.log(`${r.status.startsWith('PASS') ? 'PASS' : 'FAIL'} | ${r.name} | ${r.status}`);
  }
})();
