---
title: Unix cheatsheet - Beyond the basics
taxonomies:
  tags:
    - "Programming"
date: 2021-11-08
updated: 2021-12-12
---

We developers use the terminal a lot and there are a lot of tricks that can ease our work. So it's worth looking beyond the essentials of getting stuff done in the shell! The quickest way to find what you need is probably to use [`tldr`](https://tldr.sh/). But the frequently used hacks are best learned once to know about all the good stuff and work effectively. I recently found the great [The Linux Command Handbook](https://www.freecodecamp.org/news/the-linux-commands-handbook/#the-linux-ls-command) from Freecodecamp and went over it to extract the useful bites that I didn't know.

So, here they are:

## Files

### cp

`-v`: verbose

### mkdir

`-p`: create multiple nested folders

### rmdir

delete empty dir. Saver than (`rm -rf`). But best to use [`trash`](https://hasseg.org/trash/)

### ls

`-h`: human readable file sizes (M,K...)

### ln

the default is a hard link.

Hard link: points to content linked at time of linkage (does copy)

Soft link: pointer to the original file. Breaks when original is moved.

`-s original symlink`: soft link

### gzip

compress SINGLE file. By default the original file is removed.

`-k`: keep original file
`-d`: unzip or `gunzip`
`-v`: verbose info on saved storage percentage

### tar

gather multiple files (uncompressed)

`-cf archive.tar FILES...`: create archive

`-czf archive.tar.gz`: tar and zip

`-xf archive.tar.gz -C directory`: extract (potentially zipped) archive to specified directory.

`-tf archive.tar`: show files without extracting

### xargs

take output and turn into arguments for other command.
This is especially useful for commands that don't accept `stdin` (e.g. `touch`,`rm`,`ls`)

Example:

```bash
cat listFiles.txt | xargs rm
```

For `find` use `-print0 | xargs -0` to properly split the matching files

`-p`: print conformation prompt

`sh -c "command1 && command2 | command3"`: run multiple commands

`-I _ command _ optional_extra_arguments`: put output into `_` placeholder

## View

### cat

concatenate / print intput

`-n`: see line number

```bash
cat file1 file2 >> file3
```

### tail

open the file at the end

`-f`: (follow) watch for changes

`-n 10`: print last 10 lines

### less

view file inside interactive UI

`space`: navigate down one page

`b`: navigate up one page

navigation similar to vim

`v`: open in default system editor (vim)

`F`: follow mode (see changes live)

`:n`: open next file (for multiple input files)

`:p`: open previous file

### nano

`ctrl+s`: save

`ctrl+x`: quit

for all the rest, use `vim` 😛

## Extract

### tr

translate / delete character in a file:

`tr find_character replace_character < filename`
`-d`: delete occurences of character

### cut

cut given character from file

`-c 5-10`: cut character nbr 5 to 10 from each line
`-d "," -f 2,6`: extract the second and sixth `,` delimited field from each line

### grep

extract information (supports regex)

`-n`: show line numbers

`-C 2`: show 2 lines before and after match

`-i`: ignore case

`-v`: invert search (exclude all matches)

Example:

```bash
grep -n document.getElementById index.md
```

### find

find files relative to directory

`. -name '*.js'`: find js files relative to current directory

`-type`: type can be `f` (file), `l`(link),`d`(dir)

`-mtime -1`: match all files modified within 1 day

`find folder1 folder2`: can provide mutiple search directories

`-or`: or condition

`-delete`: deletes matches

`-exec`: execute command on each result

### wc

`-l`: just count lines

`-w`: just count words

### uniq

output unique lines

`-c`: count occurences

often used with sort (`sort -u` also filters unique elements):

```bash
sort <input> | uniq
```

### diff

compare two files

`-y`: compare next to each other, line by line

`-u`: show differences like in Git

`-r`: (recursively)

### basename

get last segment of provided path:

```bash
basename /Users/adria/test.txt
```

returns `test.txt`

### dirname

provides dirname of path (conjugate of basename)

## Process

### kill

kill signals (alternative after `/`) from softest:

`-TERM / -15`: terminate

`-HUP / -1`: (hang up) process before terminating

`-KILL / -9`: abruptly terminate

### killall

`killall NAME`
kill all processes matching NAME

### jobs

find all running jobs (including suspended ones)

### fg

`ctrl+z`: suspend process

If only 1 process is suspended, its enough to run `fg`, otherwise do:

`fg 2`: bring job 2 to foreground (get id from `jobs`)

### bg

run job in background (like appended `&` to command). API is same as `fg`

### ps

`ax`: `a` also shows processes of other users. `x` shows processes not linked to terminal

`axww`: to prevent cutting of command path

### top

display real-time info on resource usage (CPU, memory...)

`-o mem`: sort by memory usage

### nohup

let long-lived process run even after disconnect / logout

`nohup <command>`

### env

run command with variable without setting it in the outer environment (current shell)

```bash
env USER=adria node app.js
```

`-i`: clear variables from outer environment

`-u`: clear specified variable from command environment

## Privileges

### su / sudo

`su - <user>`: login to other user's home directory

`sudo -i`: start shell as root

`sudo -u <user>`: run command as other user

### chown

change file ownership

`chown -R <owner> <dir>`: recursively change permissions of all subdirectories

`chown <owner>:<group>`: change group as weell

`chgrp <group> <file>`: change group

### chmod

change read, write, execute permissions

`-r`: apply recursively

**Symbolic usage**

- `a` stands for _all_
- `u` stands for _user_
- `g` stands for _group_
- `o` stands for _others_

````bash
chmod a+rw filename #everyone can now read and write
chmod og-r filename #other and group can't read any more
```
````

**Numerical usage**

- `1` if has execution permission
- `2` if has write permission
- `4` if has read permission
  This gives us 4 combinations:

- `0` no permissions
- `1` can execute
- `2` can write
- `3` can write, execute
- `4` can read
- `5` can read, execute
- `6` can read, write
- `7` can read, write and execute

## Single vs double quotes

`""`: resolved at definition time

`''`: resolved at invocation time
An example makes it clearer:

```bash
alias lsstatic="ls $PWD"
alias lscurrent='ls $PWD'
```

`lscurrent` depends on the current directory, whereas static doesn't.

---

Sources:
[Freecodecamp: The Linux Command Handbook](https://www.freecodecamp.org/news/the-linux-commands-handbook/#the-linux-ls-command), [Unix Tutorial](https://www.softwaretestinghelp.com/unix-tutorials/)
