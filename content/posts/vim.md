---
title: VIM - Why geeks love it and you will too
taxonomies:
  tags:
    - "Programming"
resources:
- name: "featured-image"
  src: "keyboard.jpg"
featuredImagePreview: "keyboard.jpg"
date: 2021-06-01
updated: 2022-03-26
---
<div style="text-align:center;">
<img src="/images/keyboard.jpg" height="400">
</div>
VIM is more than just a text editor for geeks and the cool kids! If you aren't convinced or haven't heard about it - stick with me to see how it's magic might also improve your typing experience.

Also, VIM is absolutely worth learning if you don't intend to use the terminal program! Because of its vibrant community, VIM features are also supported in popular IDEs like Visual Studio Code (the best of both worlds imho) or even your Browser. Yes, even your surfing experience can benefit from VIM!

## VIM in a nutshell
In short, VIM is a terminal based text editor for Unix which has been around for almost 30 years now. It's most well known among programmers for its powerful features to navigate and edit code. VIM users belief that it's much smoother to just use the keyboard instead of navigating with a mouse. But besides speed, it is also more ergonomic to rely on the keyboard (you probably heard of the mouse arm, or at least german folks say so)!

At the same time it's maybe also the most frustrating text editor for first time users - yes, the most frequent google searches are "How to edit / exit vim?".
Being said that the learning curve is rather steep, the reward is deferred until you perform your first edit magic with a few keystrokes!

Short disclaimer, I will not show you the basics (which the linked resources below do much better than I could), but I will show you some examples that demonstrate its power and elegance.

The only thing you need to know is that VIM has a `normal` mode and an `insert` mode. The insert mode is for adding content and the normal mode is for editing and navigating code - what we actually spend most time on. Therefore, it's also the default mode when you open VIM. This is where newbies get confused when they type and apparently nothing happens 😤⌨️ . What is not clear is that their input are VIM commands which most likely do nothing in an empty document. With this in mind, we can now dive into the examples.

## How VIM is great

### Cursor navigation
VIM won't make you type faster, but it can help you move your cursor faster.

With VIM motions, you can easily move the cursor:

- **`0`**: move to the beginning of the line
- **`$`**: move to the end of the line
- **`^`**: move to the first non-blank character in the line
- **`t"`**: jump to right before the next quotes
- **`f"`**: jump and land on the next quotes

Moving by word is also easy:

- **`w`**: move forward one word
- **`b`**: move back one word
- **`e`**: move to the end of your word

One of my favorites is also `gi` which jumps you to the last insert position.

Better than fiddling with the mouse, isn't it?

Ok, that was simple. How about something super related to Javascript, C++ programmers - the missing braces. In VIM, you can jump to the matching bracket with `%`.

Fair enough, that is probably also something your IDE supports.

### Incrementing all indices of an array

But how about something that's usually super repetitive such as changing the values of an array?

Let's say, you want to change the values of an array to increasing numbers (1, 2, 3... 10) - without for loops.

The classical approach would probably be typing the first statement `my_array[0] = 1;`, copying the line with the mouse, pasting it a couple of times, and then clicking on each index and value to change it  — Puuh, this will take you around a minute I guess.

In VIM, you only type the first line. Then you type `yy10Pww^v10jg^a` (`^` - Ctrl-key). This looks like madness written out, but trust me - there is logic behind this 🤓

You don't need to follow this right now, but in case you are curious: `yy` copies the entire line, `10P` pastes the line ten times above the cursor, `ww` jumps the cursor two words ahead, `^v` goes into block-wise visual mode (similar to how you select with the mouse), `10j` selects the next 10 lines `g^a` increases the selection as desired.

These few strokes then result in this:

```markdown
my_array[1] = 1;
my_array[2] = 1;
my_array[3] = 1;
my_array[4] = 1;
my_array[5] = 1;
my_array[6] = 1;
my_array[7] = 1;
my_array[8] = 1;
my_array[9] = 1;
my_array[10] = 1;
my_array[11] = 1;
```

, and with very few more keystrokes, we can also increase all the 1s without ever touching the mouse. This of course, also works for similar scenarios where you want to increment all selected numbers by a desired step size, decrement etc.

It's probably not a situation you need to deal with daily, but I think it serves to show that you can also do sophisticated actions with VIM.

And it's very configurable. Most VIMers adjust the profiles to what is useful to them and share their config on the internet.

### Changing capitalization

Doing it the conventional way, changing the variable names to upper letters can be tedious if it is more than just a couple. Whereas it is convention in some languages (ABAP, Fortran), capitalization changes the meaning in others (Golang). Fortunately, it is easy to switch cases with  `g~`. You can apply this command to characters, words, entire lines, paragraphs, you name it:

```
 ~    : Invert case of current character

 g~w  : Invert case of current word

 g~~  : Invert case of entire line

 g~ip : Invert case of current paragraph
```



### Replacing text

Changing the content of a word (`cw`), an entire line (`cc`) or the rest of the line (`C`) is also very easy. You can even define to replace text within brackets, e.g. to change a function signature or replace the whole function definition. The `c` command becomes especially useful when combined with search. With `/{pattern}` , you can find the next instance of the pattern. You can then apply the replacement command on the matching instances by navigating through them. Simply type `cgn` after defining the search pattern, and rename the instance. With the repeat operator `.`  you can apply this action to the next instance with one keystroke.

Another cool thing is selecting other matches from your current cursor position and inserting cursors at the selected matches (props go [here](https://github.com/VSCodeVim/Vim/issues/3369)):
![](https://user-images.githubusercontent.com/13447232/53299785-59259b80-3865-11e9-93db-7eeaa4b7a81c.gif)

### Surroundings

Surroundings allow you to easily wrap characters around a text selection. This becomes handy when you want to add double quotes around a text to assign it to a string. In VIM, you can add a surrounding with `ys` and then you simple add the context, let's say the whole paragraph ( `ap` ) and the desired character (`"`).  With the cursor on our paragraph we then simply type `ysap"` - voila. Deleting them is even shorter: `ds"` . Of course you can also replace surroundings, i.e. `"` for `'`  with `cs"'`. Be aware that this is not a default feature and needs an extra plugin. But it is included for example in the VS Code vim extension.

## Further hacks
`+/-`: go to beginning of next / previous line

`m[letter]`: bookmark position on letter

`[letter]: go to bookmark

`Ctrl/Cmd+Shift+l`: Select all occurences

## How to get started

There is much more that I find useful, but I will leave that to you to explore! Below you can find a few resources that I found particularly helpful.

### Learning resources


- `vimtutor` - simply type it in your unix terminal (it is even available in Bavarian 🥨 `vimtutor bar` )

- [Learn Vim - VS Extension](https://marketplace.visualstudio.com/items?itemName=vintharas.learn-vim)

- [Great VS Code Vim Cheat Sheet](https://www.akosradler.dev/VimCheatSheet/)

- [Cheatsheet](http://www.viemu.com/a_vi_vim_graphical_cheat_sheet_tutorial.html):
<img src="/images/vi-vim-tutorial-1.gif" height=70% width=90% >

- [Comprehensive overview with advanced features](https://danielmiessler.com/study/vim/)

Before letting you go, I want to recommend the awesome browser extension I mentioned initially. It is called [Vimium](https://vimium.github.io/) for Chrome, but derivatives are also available for Firefox and Safari.

Keep in mind that it takes some time to get used to the VIM style. Start slowly and adapt trick by trick. I recommend to activate it as an extension in your IDE (e.g. VS Code) where you can still fallback to the conventional way when you are stuck on how to do it with VIM.

Happy VIMing :)
