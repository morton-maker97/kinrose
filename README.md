# kinrose.co

A plain static site (one `index.html`, no build step, no Node/npm) + Supabase, migrated from Squarespace.

## What's here

- `index.html` — the whole site (home, projects, videos, merch) — vanilla JS, no framework, no build step
- `config.js` — your two Supabase keys go here
- `supabase/schema.sql`, `supabase/seed.sql` — the database, and the content migrated from the live site
- `images/` — cover art and photos downloaded from the old Squarespace CDN
- `CNAME` — tells GitHub Pages this site should answer at `kinrose.co`

## One-time setup (everything in a browser — no installs)

### 1. Create a Supabase project
Go to [supabase.com](https://supabase.com), sign up, and create a new project. Give it a database password
(store it somewhere safe — you won't need it again for this site).

### 2. Load the database
In your Supabase project: **SQL Editor → New query** → paste the entire contents of
[`supabase/schema.sql`](supabase/schema.sql) → **Run**. Then click **New query** again (a fresh, blank
box — don't just edit the same one) and do the same with [`supabase/seed.sql`](supabase/seed.sql) — that
loads in all 5 releases (tracklists, credits, bonus photos), and the 10 videos.

If the projects or videos pages look empty once the site is live, it's almost always one of: `seed.sql`
hasn't been run yet, or `config.js` still has the placeholder `YOUR-PROJECT-REF` values instead of your
real Supabase URL/key. Open the browser's console (right-click → Inspect → Console) on the page for the
actual error.

### 3. Get your API keys
**Project Settings → API**. Copy the **Project URL** and the **anon public** key (never the `service_role` key).

### 4. Fill in config.js
Open [`config.js`](config.js) on your computer in any text editor (even TextEdit) and paste your two values in:
```js
const SUPABASE_URL = 'https://your-project-ref.supabase.co';
const SUPABASE_ANON_KEY = 'your-anon-public-key';
```
Save the file.

### 5. Upload to GitHub
**If you already have a `kinrose` repo from an earlier attempt, delete it first** (Settings → scroll to
bottom → Delete this repository) and create a fresh one. Earlier upload attempts left behind files from a
different version of this site (`layouts/`, `pages/`, `videos/index.astro`, etc.) that will break the build
if they're still there alongside the new files — a clean repo avoids that entirely.

1. On [github.com](https://github.com): **New repository** → name it (e.g. `kinrose`) → leave it empty → **Create repository**.
2. On the new repo's page, click **uploading an existing file**.
3. Show hidden files in Finder first (`Cmd+Shift+.`) so `.nojekyll` is visible, then drag in everything from
   the `kinrose-site` folder: `index.html`, `config.js`, `CNAME`, `favicon.ico`, `.nojekyll`, `README.md`, the
   `images` folder, and the `supabase` folder. (Everything here is only one folder level deep, so drag-and-drop
   won't scramble it the way deeply nested folders did last time.)
4. **Commit changes**.

`.nojekyll` is important: GitHub Pages normally runs every file through Jekyll (a different site builder)
before publishing. This site doesn't need that — `.nojekyll` tells GitHub Pages to just serve the files as-is.

### 6. Turn on GitHub Pages
**Settings → Pages → Source: Deploy from a branch → Branch: `main` / `(root)` → Save.**
No build step, no Actions, no secrets to configure. After a minute or two, your site is live at
`https://<your-username>.github.io/<repo-name>/`.

### 7. Point kinrose.co at it
Once the `github.io` URL looks right, go to your domain registrar and update kinrose.co's DNS to point at
GitHub Pages ([GitHub's guide](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site)).
Then in the repo's **Settings → Pages**, add `kinrose.co` as the custom domain and enable **Enforce HTTPS**
once it's verified.

## Making changes later

- **Content** (release info, tracklists, videos): edit the rows directly in **Supabase → Table Editor**. Changes
  show up immediately — no redeploy needed, since the page reads from Supabase live.
- **Design/layout**: edit `index.html` on github.com (click the pencil icon) or re-upload a new version the same
  way as step 5.

## Connecting merch (Shopify)

The merch page/nav link is hidden for now (there's nothing to show yet). Once you have a Shopify store, the simplest no-backend way
to sell from it is:
1. Shopify Admin → Settings → Apps and sales channels → Develop apps → create an app with **Storefront API** access.
2. Fetch products client-side with `fetch()` against `https://your-store.myshopify.com/api/2024-10/graphql.json`
   using that app's Storefront access token, and link each product's variant to Shopify's hosted checkout
   (`https://your-store.myshopify.com/cart/<variant-id>:1`) — no backend required.

Ask me when you're ready to wire this in and I'll add the code to `index.html`.

## Content not carried over automatically

I only had access to the public site, not your Squarespace admin, so this covers everything visible on
kinrose.co today (home, 5 project posts, 10 videos, the logo/cover images). If there are draft posts, unlisted
pages, or higher-resolution originals sitting in your Squarespace media library, download those and add them
the same way (drop the image into `images/`, add a row in Supabase's Table Editor).
