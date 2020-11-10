---
layout: post
categories: Programming
title: "Design Patterns: How to write better code"
excerpt_separator: <!--more-->
# summary: |
---

Learning to write proper code is hard. Who doesn't know it, after having an initial spark on how to solve a problem, it is tentative to immediately start coding. I guess most of us did so initially and almost always ended up on dead-end roads. Taking the time to think a design through before writing the first line is indispensable for larger projects but even makes things easier for smaller undertakings.
<!--more-->
Object-oriented programming is a very common and powerful paradigm to write code. The patterns I refer to are based on this principle and give guidelines on how to design classes and interfaces.
The main motivation for these patterns is **code reusability** and easier **maintenance**. Code shouldn't break after adjusting a single line. Also, extending the functionality shouldn't need a big refactor.

## Why bother learning patterns?
- **Don't try to reinvent the wheel**:
  
  Design patterns are tested and tried solutions, so they are probably useful for you too.
- **It's a universal toolkit**: 

    They are motivated by general principles and allow you to think and frame problems in new ways. They help to see the bigger picture by abstracting the problem specifics.

- **Understand other code more easily**:
    
    The recognition of patterns can help read other code. Patterns encipher intent, so it might reveal why code was designed that way.

- **A way to communicate design ideas concisely.**:

    Using a common language can simplify communication among developers. This is what lingo should be used for: precise communication of complex ideas.

## The book
I found [Dive Into Design Patterns](https://refactoring.guru/design-patterns/book) by Alexander Shvets to be a great resource to learn about this topic. It initially lays out general principles to guide design and briefly introduces UML diagrams. The main focus is then on explaining the 22 classical design patterns from the ["Gang of Four"](https://www.goodreads.com/book/show/85009.Design_Patterns).

### What I especially like about the book
I found the writing style fluent and concise. It doesn't remain abstract but instead tries to relate it to practice. I found the real-world analogies to the patterns sometimes quite amusing. Moreover, the book has a clear structure for each design. It starts with a problem that the pattern addresses. The pattern structure is explained (with UML diagram), and pseudo-code is given.
Moreover, the book comes with source code for solutions in several common languages (Python, C++, Go, Java, Swift...). It not only mentions when to use it but also when to not use it. Finally, the relationship with other patterns is laid out. This is useful to distinguish patterns with a similar structure, but it also mentions how they might be combined. I find it very didactic to connect the newly learned content.

## How I learned

I went through the book rather quickly because it was such a good read. Each day, I read about two to three patterns. I then went through a source-code implementation to understand the language's specifics and make the constructs more relatable. I focused on Python but always glimpsed at the Go solution to learn about its language specialties. Also, the author of the Go solutions was a bit more creative with the hypothetical problems :)
After that, I thought about a problem by myself and how I could apply the pattern. I then implemented a sketchy solution in Python. This was definitely the most time-intensive part, but I believe that it is crucial for learning.

> Tell me and I forget,  
> teach me and I remember,  
> involve me and I learn.

Sidenote: *If you want to learn more about the origin of this Confucian wisdom, check [here](https://quoteinvestigator.com/2019/02/27/tell/).*

## Where to get started
Finally, most of the book's content is available for free on [Refactoring Guru](https://refactoring.guru/design-patterns/)! So you can check out if it serves you at no cost. I bought the book for a better reading experience, to take notes, and to practice with the source code solutions. It's also a good way to appreciate the author's work, into which clearly a lot of thought and love went (there are so many nice drawings!).

