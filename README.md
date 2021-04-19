<div align="center">
  <a href="https://xmake.io">
    <img width="160" heigth="160" src="https://tboox.org/static/img/xmake/logo256c.png">
  </a>  

  <h1>xmake-repo</h1>

  <div>
    <a href="https://github.com/xmake-io/xmake-repo/actions?query=workflow%3AWindows">
      <img src="https://img.shields.io/github/workflow/status/xmake-io/xmake-repo/Windows/dev.svg?style=flat-square&logo=windows" alt="github-ci" />
    </a>
    <a href="https://github.com/xmake-io/xmake-repo/actions?query=workflow%3ALinux">
      <img src="https://img.shields.io/github/workflow/status/xmake-io/xmake-repo/Linux/dev.svg?style=flat-square&logo=linux" alt="github-ci" />
    </a>
    <a href="https://github.com/xmake-io/xmake-repo/actions?query=workflow%3AmacOS">
      <img src="https://img.shields.io/github/workflow/status/xmake-io/xmake-repo/macOS/dev.svg?style=flat-square&logo=apple" alt="github-ci" />
    </a>
    <a href="https://github.com/xmake-io/xmake-repo/actions?query=workflow%3AAndroid">
      <img src="https://img.shields.io/github/workflow/status/xmake-io/xmake-repo/Android/dev.svg?style=flat-square&logo=android" alt="github-ci" />
    </a>
  </div>
  <div>
    <a href="https://www.reddit.com/r/tboox/">
      <img src="https://img.shields.io/badge/chat-on%20reddit-ff3f34.svg?style=flat-square" alt="Reddit" />
    </a>
    <a href="https://gitter.im/tboox/tboox?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge">
      <img src="https://img.shields.io/gitter/room/tboox/tboox.svg?style=flat-square&colorB=96c312" alt="Gitter" />
    </a>
    <a href="https://t.me/tbooxorg">
      <img src="https://img.shields.io/badge/chat-on%20telegram-blue.svg?style=flat-square" alt="Telegram" />
    </a>
    <a href="https://jq.qq.com/?_wv=1027&k=5hpwWFv">
      <img src="https://img.shields.io/badge/chat-on%20QQ-ff69b4.svg?style=flat-square" alt="QQ" />
    </a>
    <a href="https://discord.gg/XXRp26A4Gr">
      <img src="https://img.shields.io/badge/chat-on%20discord-7289da.svg?style=flat-square" alt="Discord" />
    </a>
    <a href="https://github.com/xmake-io/xmake-repo/blob/master/LICENSE.md">
      <img src="https://img.shields.io/github/license/xmake-io/xmake-repo.svg?colorB=f48041&style=flat-square" alt="license" />
    </a>
    <a href="http://xmake.io/pages/donation.html#donate">
      <img src="https://img.shields.io/badge/donate-us-orange.svg?style=flat-square" alt="Donate" />
    </a>
  </div>

  <p>An official xmake package repository</p>
</div>

## Supporting the project

Support this project by becoming a sponsor. Your logo will show up here with a link to your website. 🙏 [[Become a sponsor](https://xmake.io/#/about/sponsor)]

<a href="https://opencollective.com/xmake#backers" target="_blank"><img src="https://opencollective.com/xmake/backers.svg?width=890"></a>

## Introduction ([中文](/README_zh.md))

xmake-repo is an official xmake package repository. 

## Package dependences

<img src="https://xmake.io/assets/img/index/add_require.png" width="70%" />

## Package management

<img src="https://xmake.io/assets/img/index/package_manage.png" width="80%" />

If you want to know more, please refer to the xmake documentation:

* [Documents](https://xmake.io/#/package/remote_package)
* [Github](https://github.com/xmake-io/xmake)
* [HomePage](https://xmake.io)

## Xrepo

xrepo is a cross-platform C/C++ package manager based on [Xmake](https://github.com/xmake-io/xmake).

It is based on the runtime provided by xmake, but it is a complete and independent package management program. Compared with package managers such as vcpkg/homebrew, xrepo can provide C/C++ packages for more platforms and architectures at the same time.

If you want to know more, please refer to the xrepo documentation: 

* [Documents](https://xrepo.xmake.io/#/getting_started) 
* [Github](https://github.com/xmake-io/xrepo) 
* [Gitee](https://gitee.com/tboox/xrepo)

![](https://xrepo.xmake.io/assets/img/xrepo.gif)

## Submit package to repository

Write a xmake.lua of new package in `packages/x/xxx/xmake.lua` and push a pull-request to the dev branch.

For example, [packages/z/zlib/xmake.lua](https://github.com/xmake-io/xmake-repo/blob/dev/packages/z/zlib/xmake.lua):

If you want to known more, please see: [Create and Submit packages to the official repository](https://xmake.io/#/package/remote_package?id=submit-packages-to-the-official-repository)


