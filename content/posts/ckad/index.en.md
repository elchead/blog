---
categories: ["Programming"]
title: "CKAD preparation - Tips for the Kubernetes exam"
date: 2021-09-07
resources:
- name: "featured-image"
  src: "ckad.png"
featuredImagePreview: "ckad.png"
# featuredImage: "featured-image"
---

Recently, I took the Certified Kubernetes Application Developer exam and would like to share some tips for the preparation. Be aware that at the end of September, an updated 2021 version will be released, so contents will change a bit.
Nevertheless, the exam contains 20 questions that need to be completed in 2 hours. So its crucial to be quick and comfortable with the `kubectl` CLI and formatting yaml files. But first things first:

## How to get started

In case you already have experience with Kubernetes for some time, you probably have most of the knowledge required. If you haven't used `vim` and unix tools before, you should get familiar with the very basics of them. 
I started learning about Kubernetes using the official documentation and reading [Kubernetes Up & Running by Brendan Burns](https://www.oreilly.com/library/view/kubernetes-up-and/9781492046523/). But if you are new to Kubernetes, then taking a course might also be a good idea. 

When I decided to take the exam, I did not quite know what to expect from it, so I took the [Udemy: Ultimate CKAD course](https://www.udemy.com/course/ultimate-ckad-certified-kubernetes-application-developer/learn/lecture/26777664?start=270) by Srinath Challa.
The course is very basic; so don't expect to learn much new stuff if you know the core topics. But in the end, it gave me more confidence for the exam because it covers all topics and has some preparation material (e.g. bookmarks) and tips.

## How to prepare

Once you decide to prepare for the exam, I would recommend signing up for the certificate to get early access to the exam simulator. You should definitely check the available coupons to get a discount on the quite high certificate price of $375! The price includes two coupons for exam simulators at [killer.sh](https://killer.sh/) (they have the same questions though) and I would take one once you feel comfortable with the topics, but before practicing for the exam. This way you get some feedback on where you are already and what you need to focus on. Be sure to know the "exam tips" beforehand to get a realistic feel of how you should do it in the real exam.

## Exam tips

The exam is done in a browser environment and you are allowed to have one additional tab (or separate window) for accessing the official documentation. You can use an external monitor for the documentation or separate windows on a large enough screen.

The time frame is short, so you might skip low percentage questions (2-3 %) and do them last. Moreover, shortcuts can help you save time:

1. Use the CLI as much as possible to get the boilerplate for the yaml files. `kubectl run / create` are your friends!
2. Configure your bashsrc:
	```
	vim ~/.bashsrc
	// add:
	alias k=kubectl
	alias kaf='k apply -f'
	alias kcn='kubectl config set-context --current --namespace'
	export d="--dry-run=client -o yaml"

	source <(kubectl completion bash)
	complete -F __start_kubectl k
	```
	This shortens the syntax and adds bash completion. To get the boilerplate for a pod manifest, you can then simply type `k run mypod --image myimage $do > pod.yaml` 
	Be careful, you might have to install bash-completion before:
	`sudo apt-get install bash-completion`
3. Configure vim:
	```
	Vim ~/.vimrc
	// add:
	set tabstop=2 // set tabbing to 2 spaces
	set shiftwidth=2 // apply tab on multiple lines
	set expandtab // use spaces for tabs
	```
	For debugging, it might also be useful to enable the line numbering: `:set number`
4. Optional: Tmux for multiple terminals

	I found the `kubectl explain` command quite convenient to quickly check the API, while I was writing the yaml file. For this it is however necessary two have 2 terminals. Tmux has different behavior (copying, scrolling ...), so be sure to be familiar with it if you want to use it in the exam.
	
	All commands inside tmux are prepended with `Ctrl+b`, so I omit that in the following.
	   
	    tmux
	    // inside tmux:
	    :set -g mouse on // scroll and click with mouse
	    “ // split terminal vertically 
	    % // or split horizontally
	

	For navigation, I used these commands:
	
	    ] // paste clipboard 
	    ; // toggle last used window
	    [ // activate scroll
	    x // kill current pane
	    & // kill session
	    d // detach
	    // in the terminal: tmux attach

Finally, as with most things, it is about practicing and you can find some practicing questions on Google, such as [these 150 questions](https://medium.com/bb-tutorials-and-thoughts/practice-enough-with-these-questions-for-the-ckad-exam-2f42d1228552). I hope you found some useful tips and good luck with the exam!


