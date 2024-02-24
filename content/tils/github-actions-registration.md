---
title: GitHub actions need to be registered
taxonomies:
  tags:
    - "TIL"
date: 2023-10-13
---

In order to run a new workflow on a dev-branch, it's not enough to have a `workflow_dispatch` and do `gh workflow run FILE.yml -r BRANCH`

For the workflow to be registered, you need to specify initally:

```yaml
on:  push:    branches:       - "BRANCH"
```

I always do this in a separate debug commit, so that I can easily delete this commit after triggering the workflow once.
