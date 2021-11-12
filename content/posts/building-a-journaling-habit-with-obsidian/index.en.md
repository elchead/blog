---
title: Building a Journaling habit with Obsidian
categories: [Second-brain]
resources:
  - name: "featured-image"
    src: "calendar.png"
featuredImagePreview: "calendar.png"
date: 2021-11-12
---

Journaling is one of the habits that many find desirable, yet few achieve to establish. I felt the same struggle, until I found a nice workflow in my notetaking app Obsidian that I want to share with you.

## The value of Journaling

I believe that people fail to journal regularly because it's never urgent. So it recedes from the urgent but not necessarily important tasks. Yet it's those that would probably most benefit from it. Journaling is about escaping the rush of day-to-day, reflecting on what is happening, and finding intention for the day. But it's not just beneficial for ourselves. By rewinding the small beautiful moments, we can also become more appreciative of our dearest and loved ones.

Journaling can take different forms, be it asking yourself a couple of simple questions or long streamlining of thoughts (brain dump). But to start a habit it's best to keep it simple. Honestly, it even took me some time to get valuable answers to simple questions like "What are you grateful for?" or "What would make today great?". I was just not used to asking this.

Yet, I believe it's very meaningful because it sets your intention for the day. We can become more appreciative about what we have, but maybe more importantly it can mentally prepare us for misfortune. Stoics call this negative visualization (also see [my book notes](/books/stoic-joy)).

## Journaling with Obsidian

When deciding to start journaling you have to decide on a medium. Some prefer paper, but I love the keyboard and the benefits of digital notes. I initially used Notion which is great functionality-wise, but I disliked the sluggishness. It's great that it also works on mobile, but the slowness just made for a bad user experience. Finally, I switched to Obsidian, because it's my general long-term note-taking app. The fewer tools, the better. Also, the notes are stored in markdown files locally, which also gives you more control over your data.

Besides, the community has built some awesome plugins!
The built-in daily note plugin already provides the most important functionality: a button to create a timestamped title with your template.

### Smart templating with the Calendar plugin

Later, I discovered the calendar plugin, which shows a nice calendar overview to open and create notes. But more crucially, it provides some templating features like linking notes with a tag like `[[{{yesterday}}]]` and referencing specific content like this `=[[{{yesterday}}]].want-to-improve`.
I find this convenient to quickly see my intentions from the day before.
The plugin can be easily installed inside Obsidian options under `Community plugins`.

### Tabular journal view with the Dataview plugin

One thing I liked in Notion was the tabular view of my journal. This allowed me to see the entries for each prompt at a glance. Luckily, there is the Dataview plugin that does exactly that! I enjoyed [this](https://input.sh/replicating-notions-tables-with-obsidian-plugins/) article to implement it, but you can also just [install it](https://github.com/blacksmithgu/obsidian-dataview) and take my code snippet :)

```dataview
table Weekday, Week as "Week", row["Storyworthy"] as "Storyworthy",row["Day Rating"] as "Rating"
from "Journal" where !contains(file.name, "1_DailyNotes") sort file.day desc
```

{{< image src="dataview.png" caption="The tabular view, of course without my data 😉" >}}

## My journaling flow

You can find my whole note template here: [daily_template.md](https://drive.google.com/file/d/1_G8ZHs38CRmg9Sq-BoR1oM1y4xO9M0jc/view?usp=sharing), which is mostly taken from [here](https://forum.obsidian.md/t/daily-and-weekly-reviews-dataview/17021).
The template pretty much speaks for itself. My morning journaling is fairly short. The visualization is maybe not so clear and also not heavily used by myself. I use it to write down my desired flow of the day and mention expected challenges.

In the evening, I take much more time to reflect on my actions. I start by first enumerating the most important happenings of the day under `Activities 👨‍💻🏋️‍♀️`.
I found that sometimes even crucial events get lost if I don't chronologically repass the day. Oh yes, my poor memory...
From this list, I find it easy to extract my learnings and positive and negative behaviors.
Recently, I'm also trying to be more mindful about my eating habits, which is why I also have a rating for my diet.

Finally, I try to extract one story-worthy moment (inspired by [this](/books/storyworthy) book). The idea is to be more aware of the mundane but beautiful moments. It's not the spectacular travel adventures that make for the best stories, but rather relatable moments. Moments that touch us emotionally, but that are difficult to see because we tend to look for the big and grandiose.

## Conclusion

I finally found a workflow to make journaling stick. It's snappy and nicely integrates into my note-taking app with all the features I like (btw, Obsidian even has a vim plugin 🤓 and is available on mobile). I can directly link to my journal entries and easily integrate them into my personal search engine because it's just plain files.

One final thought before you leave. For me, it made a remarkable difference to love the tool I am using. Honestly, featurewise not a lot has changed since I switched to Obsidian. But the few upper points just made it feel much more personal. So, find what you like. Lower the barrier to start writing. It all get's easier once you did it for a few weeks consistently.

I am curious to learn about your journaling flow and am happy to answer any questions!
