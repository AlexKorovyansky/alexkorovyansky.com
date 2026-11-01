---
publish: true
unlisted: true
unindex: true
title: How to publish your Obsidian digital garden for free
---
This guide shows you how to turn Obsidian notes into a website like this one, using [Quartz](https://quartz.jzhao.xyz) and GitHub Pages. It's completely free: your site gets a `<username>.github.io` address. You can also connect your own domain if you have one.

You need a GitHub account, Git, and Node.js 24.

> [!WARNING]
> Your repository will be public, so anyone can read every file in it, including notes that aren't published on your site. Don't add your whole vault. Add only the notes you're happy to share.

## 1. Fork the repository

1. Open the [repository of this website](https://github.com/AlexKorovyansky/alexkorovyansky.com) and select **Fork**.
2. Name your fork:
   - **Without your own domain:** Use exactly `<username>.github.io`, with your GitHub username. This name puts your site at `https://<username>.github.io`. If you already have a repository with this name, rename or delete it first.
   - **With your own domain:** Use any name.
3. Clone your fork:
   ```sh
   git clone git@github.com:<username>/<repo>.git
   ```

If you keep the folder in iCloud or a similar service, store the Git data outside it, because syncing can corrupt `.git`. To do that, add `--separate-git-dir=<path outside the synced folder>` to `git clone`.

## 2. Open the folder in Obsidian

Open the cloned folder as a vault. Your site's pages are the notes in this vault.

## 3. Replace the content

1. Delete `hack local`, `think global`, and everything in `by direct link`. Organize your pages in any folders you like, and use `by direct link` for pages that shouldn't appear in navigation.
2. Replace `index.md` with your home page:
   ```markdown
   ---
   publish: true
   title: Your Name
   ---
   # Intro

   Hello, world!
   ```
   The `title` appears in the browser tab and link previews. The first heading appears on the page and names the home page in the navigation tree, in lowercase. It must be the first line of the page.
3. Delete `.github/screenshot.png` and `CONTRIBUTING.md`, and replace `README.md` with a short description of your site.
4. In `LICENSE`, keep everything from the `MIT License` heading to the end of the file, including its copyright notice. Replace the text above this heading with the terms for your own content.

Three settings control how a page appears on your site:

| What you want to control    | How                                                        |
| --------------------------- | ---------------------------------------------------------- |
| Published or draft          | `publish: true` publishes a page; otherwise it's a draft   |
| Shown in navigation         | Every page appears there, except pages in `by direct link` |
| Found in site search        | Add `unlisted: true` to keep a page out of site search, the sitemap, and RSS |
| Indexed by search engines   | Add `unindex: true` to tell search engines not to index a page |

Navigation is built from the search index, so a page with `unlisted: true` doesn't appear in navigation either. To share a page only by direct link, put it in `by direct link` and add `unlisted: true` and `unindex: true`.

## 4. Make the site yours

In `.quartz/quartz.config.yaml`, change:

- `configuration.pageTitle`: your site title
- `configuration.baseUrl`: your site address without `https://`, either `<username>.github.io` or your domain, for example `example.com`
- `explorer` plugin → `options.title`: the title of the navigation tree
- `footer` plugin → `options.links`: your links

In `.quartz/static/`, replace `logo.jpg` and `icon.png` with your own images.

In `.quartz/styles/custom.scss`, change the name under `// Custom footer text`.

## 5. Preview your site

Run these commands in the site folder:

```sh
export QUARTZ_BUILD_ROOT="$HOME/.cache/quartz"
bash .quartz/ops/build.sh
bash .quartz/ops/local.sh
```

Your site opens at http://localhost:8080.

## 6. Turn on deployment

In your fork on GitHub:

1. Open the **Actions** tab and enable workflows, because GitHub disables them on forks by default.
2. Open **Settings → Pages** and set **Source** to **GitHub Actions**.

## 7. Publish

Commit your changes and push them to `main`:

```sh
git add -A
git commit -m "Create my website"
git push origin main
```

You can follow the **Build and deploy** workflow in the **Actions** tab. From now on, every push to `main` updates your site.

Without your own domain, you're done: your site is live at `https://<username>.github.io`.

## 8. Connect your own domain (optional)

1. In your fork on GitHub, open **Settings → Pages** and enter your domain under **Custom domain**.
2. Add these records at your DNS provider, replacing any existing `A` records for your domain:

| Type    | Name  | Value               |
| ------- | ----- | ------------------- |
| `A`     | `@`   | `185.199.108.153`   |
| `A`     | `@`   | `185.199.109.153`   |
| `A`     | `@`   | `185.199.110.153`   |
| `A`     | `@`   | `185.199.111.153`   |
| `CNAME` | `www` | `<username>.github.io` |

DNS changes and the HTTPS certificate can take from a few minutes to about a day. Once the certificate is ready, turn on **Enforce HTTPS** in **Settings → Pages**.

## For AI agents

If a user asked you to follow this guide, complete the steps above for them:

- Ask for the details you need all at once: whether they have their own domain, site title, name for the footer, folder, notes to publish, images, and links.
- Add only the notes the user names, never a whole vault. Show them the list of files before the first push.
- Ask before you push or change DNS.
- After step 4, search the repository for `korovyansky`, ignoring case. Only these matches should remain: the plugins `alexkorovyansky/quartz-themes-lightweight`, `AlexKorovyansky/quartz-noindex`, `AlexKorovyansky/quartz-mobile-drawer`, and `AlexKorovyansky/quartz-theme-color` in `.quartz/quartz.config.yaml` and `.quartz/quartz.lock.json`, and the MIT copyright notice in `LICENSE`. Keep them, because the build needs the plugins and the license requires the notice.
- If the user has no logo, delete `logo.jpg` and remove both `@media` blocks that use it, right after `// Use a photo as the logo`, from `custom.scss`.

If `gh` is available, you can complete step 6 with these commands. If the first two fail, ask the user to enable workflows in the **Actions** tab.

```sh
gh api -X PUT repos/<owner>/<repo>/actions/permissions -F enabled=true -f allowed_actions=all
gh workflow enable deploy.yml -R <owner>/<repo>
gh api -X POST repos/<owner>/<repo>/pages -f build_type=workflow
```

If the user has their own domain, set it in step 8 with this command:

```sh
gh api -X PUT repos/<owner>/<repo>/pages -f cname=<domain>
```
