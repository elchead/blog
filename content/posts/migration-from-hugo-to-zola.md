---
title: Migrating my blog from Hugo to Zola
taxonomies:
  tags:
    - "Programming"
date: 2023-09-13
---

I started my blog almost 3 years ago and recently released the 3rd version of it.
After Jekyll and Hugo, I switched to [Zola](https://www.getzola.org/) as static site generator (SSG).
A [Rustacean friend](https://fassbender.dev/)  recently built his blog, using a Rust-based SSG of course, and drew my attention to Zola.
I was unhappy with my Hugo blog workflow for quite some time and even build a small [CLI](https://github.com/elchead/blog-cli) in 2021 to ease publishing posts. But fiddling with the CLI was still less than ideal.
I like to write in Obsidian and publish from there. However, my old Hugo theme had a very inconvenient file structure for posts, which made publishing more cumbersome than necessary.
Then, another [blogger friend](https://lieu.gg/) told me how he manages his blog inside his Obsidian vault to have a single source of truth.

So, I decided to look for a blog with simple file structure, where a post is just a file. I looked for simpler designs on Hugo first, but nothing caught me.
Then, I found [mrkaran.dev/](https://mrkaran.dev/posts/migrating-to-zola/) and immediately liked the lean design and liked how he shared the same SSG iteration journey. So, I took his word that Zola had to be the best choice.

## Migrating posts
My biggest concern was that I didn't want to have too much work migrating my existing posts.

### YAML frontmatter
Specifically, the SSG should support my current YAML frontmatter. Zola concerned me at first, since I only saw TOML frontmatters and read that the author is opinionated about what is proper. Luckily, YAML is supported, even though the doc recommends TOML. Check!

### Links
The second thing that concerned me were links.
Zola has its [own opinionated way](https://www.getzola.org/documentation/content/linking/) of linking using `@/...` including file extension (e.g. `.md`).
Luckily, Zola also supports plain links like `[link](/posts/2022)`. Check again!

### Images
The next nice-to-have was image linking. Since I like to write my posts in Obsidian, I'd also like to place the images there. So hopefully, the path that Zola requires for image assets isn't to different from how I would refer to them in Obsidian. Luckily again, even links to images work very similarly. The only difference is that Zola requires an absolute link (leading `/`) whereas Obsidian resolves the image correctly as a relative link (without leading `/`).
So I just have to prepend a `/` to the path before publishing - that's fair enough for now.

## Experience with Zola
So far, Zola was very easy and smooth to use. It's well documented and designed with simplicity in mind. The basic blog only consists of 3 folders: `content`, `static`, `templates` and a `config.toml` file - great.
Due to the simple design, it's been very simple to adjust the design to my needs. Very different from my complex blog themes before!

The deployment was the only thing that caused a little more hiccups, since Zola is a bit more exotic than Jekyll and Hugo.
I tried to deploy with Vercel first and it didn't work. All looked good locally with `zola serve`, but the build failed online.
I found out that Vercel still uses an old version and that while more recent versions can be manually configured, the [installation fails due to lacking libraries in the build container](https://github.com/getzola/zola/issues/1713).
Luckily, everything worked smoothly on Netlify afterwards.

## Conclusion
I'm happy about the outcome, and the blog migration effort was less than expected (a few hours after the initial research). I'm also grateful for folks like [Karan](https://mrkaran.dev) who share their learnings and code publicly.
If you are not sure about a design yet, I can also recommend [taby](https://github.com/welpo/tabi) made by [Oscar](https://osc.garden/).
You can also find the source of my website on [GitHub](https://github.com/elchead/blog).

Happy blogging!
