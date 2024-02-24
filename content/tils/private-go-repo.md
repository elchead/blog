---
title: Go get private modules
taxonomies:
  tags:
    - "TIL"
date: 2024-01-24
---
When using a private repository in a Go project, you need to provide authentication.
This is straightforward and documented](<https://go.dev/doc/faq#git_https>).

On Mac, other than using an `netrc` file you can use the OSX toolchain.

```bash
git config --global credential.helper osxkeychain
```

Moreover, and this was not clearly documented for me, you also need to tell `go get` that it is working with a private module, so that it doesn't try to check against the public checksum database at [sum.golang.org](https://sum.golang.org/):

```bash
go env -w GOPRIVATE={private_repo}
```

Source: <https://play-with-go.dev/working-with-private-modules_go119_en/>
