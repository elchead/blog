---
title: Fixing CSV parsing - First attribute not regonized (BOM)
categories: ["Programming"]
date: 2021-11-03
---

Today, I wanted to read a CSV file from Notion and stumbled on the issue that my first attribute was not properly read.
I validated my code on a another file before, but on this file it just didn't work. Turns out that I had the same issue with another npm library. What bothered me was that when printing the object, I could see the attribute, but it had single quotes around it and was printed in green. However, there was no way to access the attribute. Several other attributes with columns including spaces also had this issue. The latter is of course easy to fix by just removing the blank spaces. But what's going on with the first attribute?

## The solution

It dawned on me that somehow there were some weird characters at the beginning of the file that I couldn't see.
When parsing the file in python, I could indeed see that.
Indeed, the UTF-8 standard permits a prepended ByteOrderMark (BOM) which can confuse CSV parsers.
Some parsers provide a bom option to deal with this, but the simplest solution is to strip this away in the command line:

```
sed $'s/\xEF\xBB\xBF//g' file.csv > file.csv
```

The devil lies in the the details, but next time you and me will be aware that encoding can be subtle and is not easily visible in the editor.
