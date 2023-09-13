# Blog
This is the code for [my website](https://www.adrianstobbe.com).

It's the 3rd generation. The main reason for the redesign being a much simpler setup and being able to manage the blog content as git repo in my Obsidian-vault inside a subfolder.
Even links to images work very similar in Zola and Obsidian. The only difference is that Zola requires an absolute link (leading `/`) whereas Obsidian resolves the image correctly as a relative link (without leading `/`).

The enhancement also makes the [blog-cli](https://github.com/elchead/blog-cli) obsolete.

You can find the old Hugo (v2) and Jekyll (v1) blog in the branch list.
## Stack
- Framework: [Zola](https://www.getzola.org/)
- Theme: adopted from [@mr-karan](https://github.com/mr-karan/website) with some custom styles:
  - table of contents (static for mobile and button on desktop)
	  - dynamic button display adopted from [@welpo](https://github.com/welpo/tabi)
  - show last updated time
- Deployment: Netlify (Vercel is currently broken)
