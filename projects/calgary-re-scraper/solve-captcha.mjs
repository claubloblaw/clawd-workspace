import { chromium } from 'playwright';

const CDP_URL = 'http://127.0.0.1:18800';

async function main() {
  const browser = await chromium.connectOverCDP(CDP_URL);
  const contexts = browser.contexts();
  const context = contexts[0] || await browser.newContext();
  
  // Find the page with realtor.ca
  let page = null;
  for (const p of context.pages()) {
    if (p.url().includes('realtor.ca')) { page = p; break; }
  }
  if (!page) {
    page = await context.newPage();
    await page.goto('https://www.realtor.ca/map#ZoomLevel=11&Center=50.962500%2C-114.107500&LatitudeMax=51.04500&LongitudeMax=-113.90000&LatitudeMin=50.88000&LongitudeMin=-114.31500&Sort=6-D&GeoName=Calgary%2C%20AB&PropertyTypeGroupID=1&TransactionTypeId=2&PriceMin=500000&PriceMax=1200000&BuildingTypeId=1&BedRange=3-0&BathRange=2-0&StoreyRange=1-2&Currency=CAD', { waitUntil: 'networkidle', timeout: 30000 });
    await page.waitForTimeout(3000);
  }
  
  console.log('Page URL:', page.url());
  
  // Try to find and interact with the iframe
  const frames = page.frames();
  console.log('Frames:', frames.length);
  for (const f of frames) {
    console.log('  Frame:', f.url().substring(0, 100));
  }
  
  // Use CDP to click at specific coordinates (bypassing iframe boundaries)
  const cdp = await page.context().newCDPSession(page);
  
  // Click the trumpet icon (approximately at 310, 225 in viewport)
  console.log('Clicking trumpet...');
  await cdp.send('Input.dispatchMouseEvent', { type: 'mousePressed', x: 310, y: 225, button: 'left', clickCount: 1 });
  await cdp.send('Input.dispatchMouseEvent', { type: 'mouseReleased', x: 310, y: 225, button: 'left', clickCount: 1 });
  
  await page.waitForTimeout(1500);
  
  // Take screenshot to see result
  const buf = await page.screenshot();
  const { writeFileSync } = await import('fs');
  writeFileSync('/Users/claub/workspace/projects/calgary-re-scraper/data/captcha-after-trumpet.png', buf);
  console.log('Screenshot saved after trumpet click');
  
  await browser.close();
}

main().catch(e => { console.error(e); process.exit(1); });
