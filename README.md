# kinrose.co

A plain static site (one `index.html`, no build step, no Node/npm) + Supabase, migrated from Squarespace.

## What's here

- `index.html` — the whole site (home, projects, videos, merch) — vanilla JS, no framework, no build step
- `config.js` — your two Supabase keys go here
- `supabase/schema.sql`, `supabase/seed.sql` — the database, and the content migrated from the live site
- `images/` — cover art and photos downloaded from the old Squarespace CDN
- `CNAME` — tells GitHub Pages this site should answer at `kinrose.co`
- `supabase/admin_schema.sql` — adds your admin login, a site-wide theme (colors/fonts/corners), and
  freeform content blocks (text/image/card) you can add to any page

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

### 2b. Set up your admin login (so you can edit the live site yourself)
This is optional, but it's what gives you the Squarespace-style "edit anything while logged in" experience.

1. **SQL Editor → New query** → paste and run [`supabase/admin_schema.sql`](supabase/admin_schema.sql).
2. **Authentication → Users → Add user** → enter your email + a password you'll remember (leave "Auto Confirm
   User" checked, so you don't need to verify by email). Copy the new user's **User UID**.
3. **SQL Editor → New query** → run (with your real UID pasted in):
   ```sql
   insert into admins (user_id) values ('paste-the-uid-here');
   ```
   That row is what makes that one login an admin. Nobody else can ever sign up through the site itself —
   you create every admin by hand, the same way.
4. **Storage → New bucket** → name it exactly `site-images` → toggle **Public bucket: ON** → create it.
   (This is where images you upload through the admin panel get stored.)
5. Back in **SQL Editor**, scroll to the bottom of `admin_schema.sql` and re-run just the four `storage.objects`
   policies if they didn't take the first time (they only work once the bucket above actually exists).

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

## Using the admin panel

Once you've done step 2b, click **admin** in the site's nav bar and log in with the email/password you
created. While logged in:

- **theme** (nav link) opens a panel to change the background color, text color, muted-text color, card
  background color, corner roundness, and heading/body fonts — site-wide, applied instantly, no redeploy.
- On every page, you'll see **+ Text / + Image / + Card** buttons. These add new content blocks right on
  that page — a text block (plain paragraphs), an image (paste a URL or upload a file from your computer),
  or a card (image + title + text, styled like the project cards). Each existing block gets **Edit**,
  **Delete**, and **↑ / ↓** (reorder) controls.
- Blocks you add to a specific project's page only show on that project; blocks added on the home, projects,
  or videos pages show there respectively.
- **logout** signs you out — visitors never see any of these controls or buttons, and even if someone found
  a way to fake being logged in, the database itself (Row Level Security) refuses any write that isn't from
  your actual admin account.

Everything here is powered by [Tailwind](https://tailwindcss.com) (loaded from a CDN, no build step) for the
admin UI's layout, and plain CSS variables for the parts you can recolor from the theme panel.

## Making changes later

- **Theme/content** (colors, fonts, text/image/card blocks): use the admin panel above — no file edits or
  redeploys needed.
- **Original migrated content** (release info, tracklists, videos): edit the rows directly in
  **Supabase → Table Editor**. Changes show up immediately.
- **Code/layout itself**: edit `index.html` on github.com (click the pencil icon) or re-upload a new version
  the same way as step 5.

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
