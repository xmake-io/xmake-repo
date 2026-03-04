# Templates

This directory contains the official xmake project templates.

## Structure

The directory structure is organized by language and project type:

```
templates/
  - language/ (e.g. c, c++, rust, ...)
    - category/ (e.g. console, static, shared, ...)
      - name/ (e.g. simple, qt, ...)
        - xmake.lua
```

## Usage

You can use these templates when creating a new project via `xmake create`:

```bash
xmake create -l c++ -t console myproject
```

## Contribution

We only accept general-purpose, lightweight, and basic project templates. Templates that are specific to a particular business logic or project type will be rejected.
