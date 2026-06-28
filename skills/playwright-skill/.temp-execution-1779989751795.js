const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();
  
  try {
    await page.goto('http://localhost:3000', { waitUntil: 'networkidle', timeout: 10000 });
    
    const buttonCardDetails = await page.evaluate(() => {
      const cards = Array.from(document.querySelectorAll('.preview-card'));
      const card = cards.find(c => c.querySelector('.preview-card-header span').textContent.includes('Button'));
      if (!card) return null;
      
      const body = card.querySelector('.preview-card-body');
      const buttons = Array.from(body.querySelectorAll('button'));
      
      return {
        cardHtml: card.outerHTML,
        bodyStyle: {
          display: window.getComputedStyle(body).display,
          width: body.getBoundingClientRect().width,
          height: body.getBoundingClientRect().height
        },
        buttons: buttons.map((btn, i) => {
          const rect = btn.getBoundingClientRect();
          const style = window.getComputedStyle(btn);
          return {
            index: i,
            html: btn.outerHTML,
            rect: { x: rect.x, y: rect.y, width: rect.width, height: rect.height },
            color: style.color,
            bgColor: style.backgroundColor,
            display: style.display,
            visibility: style.visibility,
            opacity: style.opacity
          };
        })
      };
    });
    
    console.log(JSON.stringify(buttonCardDetails, null, 2));
    
  } catch (err) {
    console.error('Error:', err.message);
  } finally {
    await browser.close();
  }
})();
