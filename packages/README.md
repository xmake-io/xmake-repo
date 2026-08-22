# Packages

This directory contains the official xmake package recipes.

## Structure

The directory structure is organized by the first letter of the package name:

```
packages/
  - x/
    - xmake/
      - xmake.lua
  - z/
    - zlib/
      - xmake.lua
```

## Usage

You can integrate these packages into your project by adding `add_requires` to your `xmake.lua` file:

```lua
add_requires("zlib", "libpng")

target("test")
    set_kind("binary")
    add_files("src/*.c")
    add_packages("zlib", "libpng")
```

## Contribution

Please refer to [CONTRIBUTING.md](../CONTRIBUTING.md) for details on how to submit a new package.
