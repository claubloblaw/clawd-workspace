# Scraper Status

## 2026-02-24: BLOCKED by Imperva CAPTCHA

All 3 scheduled runs (8am, 2pm, 8pm) returned 0 listings.

**Root cause:** realtor.ca is serving an Imperva/Incapsula bot detection CAPTCHA page. Both browser navigation and direct API calls are blocked.

**To fix:**
1. Open realtor.ca manually in the OpenClaw browser and solve the CAPTCHA — this should set cookies that allow the scraper to work for a while
2. Or: rewrite scraper to use realtor.ca's mobile API endpoint which may have lighter bot protection
3. Or: add proxy rotation

**Action needed from Marcel:** Quick manual CAPTCHA solve, or approve rewrite approach.
