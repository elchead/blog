---
title: Building with SvelteKit and LLMs in 2024
taxonomies:
  tags:
    - "Tech"
date: 2024-01-21
---
In the past weeks, I was building [Nutri](https://nutri.adrianstobbe.com/), a tool to generate food recommendation based on a nutritional analysis of grocery receipts.
The idea arose from personal interest, to get a better understanding of the diversity of vitamins and minerals in my diet.
Impressed by the capabilities of LLMs, I wanted to experiment how suitable they are for this kind of problem.
In this post, I want to share my learning journey and stack for building a side-project web app in 2024.

## Proof of concept
I started with a simple Python script to detect the items using OCR from the [Google Vision API](https://cloud.google.com/vision/docs/ocr). While the API detected the receipt text reliably, cropping out only the relevant items was trickier. Soon after facing this difficulty, the [OpenAI vision API](https://platform.openai.com/docs/guides/vision) was released. This made the problem a lot easier, because I could let OpenAI recognize the items and then perform the nutritional analysis.
The food item recognition and the filtering of non-food or unclear item descriptions on the receipt worked really well. 
Next was the nutritional analysis. I had a list of interesting vitamins and minerals that are prone to deficiency from [here](https://macrofactorapp.com/micronutrients-worth-monitoring/). After some prompt experimentation, I found a good one to classify the nutrient content of all food items for each vitamin of interest.
I fact-checked some samples and was surprised about the accuracy. Filtering the structured data from the prompt result was another hurdle, because the format initially varied across executions. The proper prompt wording also stabilized that and allowed me to write a parser for the data. Later, I learned about [JSON mode](https://platform.openai.com/docs/guides/text-generation/json-mode), but quickly found out that the GPT4 model was not yet supported. At the time of writing, the GPT4 now also seems to be supported. The API moves fast! 

## Stack
**TLDR: SvelteKit + Bootstrap + Cloudfare**

Next, I wanted to build a web app. As a backend engineer by heart, I love the simplicity of Svelte and chose [SvelteKit](https://kit.svelte.dev/) and [Bootstrap](https://getbootstrap.com/). I initially build a simple Python API with [flask](https://flask.palletsprojects.com/en/3.0.x/), but at the time of deployment I decided to scrap that.

I wanted a good free tier for hosting and fast startup times. In my ventures with hosting a Python backend in a prior project ([Mealwheel](https://github.com/elchead/mealwheel)), I had used Herokus now removed free tier of its container service. But I was unhappy with the coldstarts.
That's where serverless comes into play. Shortly before, I read about [SvelteKit's support for API routes](https://kit.svelte.dev/docs/routing#server). This basically makes a separate backend server unnecessary.

Next, I had to choose a hosting provider. SvelteKit provides adapters for all big players: Netlify, Vercel and Cloudfare. I tried them in that order, only to find that the first two limit the API call duration to 10s in the free tier.
However, my complex OpenAI queries take up to 30s.
Cloudfare came as the savior, because they only limit CPU time and not I/O time.

Going all-in on SvelteKit, meant that I had to rewrite the existing Python backend in Javascript. This was actually more painful than I hoped, because JS libraries vary from their runtime. NodeJS has a great set of libraries, but they are [mostly not available](https://developers.cloudflare.com/workers/runtime-apis/nodejs/) in Cloudfares serverless environment. So things like converting an image to base64, just become a little more tedious. And even simple things like HTTP requests were a little more fiddly with `fetch` compared to the `axios` client.
So this was my biggest learning when developing for serverless JS. Be aware of the runtime differences when developing your solution. Overall, I found the DX of being mostly restricted to the web API noticeably worse compared to NodeJS.
Consequently, I would only choose it for very simple backend tasks, such as dispatching requests and formatting data.

Another interesting hurdle were browser differences, of course. On iOS (Safari WebKit), my receipt images did not load. It turned out that the free image compression service (resmush) doesn't serve HTTPS resources, and that the browser prohibits mixed content. The simplest solution was to serve the images through a reverse proxy. But of course, storing the images in a bucket service like [Cloudfare R2](https://developers.cloudflare.com/r2/) would be the way to go.

### Observability
Lastly, I wanted to understand the usage of my app. For general page visit statistics, the [web analytics dashboard](https://developers.cloudflare.com/analytics/web-analytics/) on Cloudfare is sufficient. You just need to add a little JS snippet on your site.
To understand, which features (endpoints) are used, I wanted to store logging information. On Cloudfare, [logs can be streamed](https://developers.cloudflare.com/workers/observability/log-from-workers/) for debugging, but persisting logs is reserved for [LogPush](https://developers.cloudflare.com/workers/observability/logpush/) - an enterprise feature. Of course, I could have used more sophisticated tools like DataDog or InfluxDB for log collection, but I just wanted the bare minimum, so I looked for the free service available at Cloudfare. I ended up pushing logs about the user context and called endpoint to their Key-Value storage [KV](https://developers.cloudflare.com/kv/). To find out how to use it within SvelteKit, refer to the [Cloudfare adapter docs](https://kit.svelte.dev/docs/adapter-cloudflare#bindings). I spend a lot of time trying to make it work refering to just the Cloudfare docs - it works differently in Svelte.

## Final words
In the end, this project turned out to be more frontend heavy than expected. The powerful OpenAI API really sped up the backend development, and after the PoC I spent almost 80% of the time on improving the UX and adding smaller features. Pareto rules! Overall, I'm happy with the outcome and learned a fair bit about building for the web in 2024. Hope you could take some useful tip away and happy building!