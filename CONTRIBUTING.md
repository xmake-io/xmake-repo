# Contributing

If you discover issues or want to contribute a new package, please report them to the
[issue tracker][1] of the repository or submit a pull request. Please,
try to follow these guidelines when you do so.

## Issue reporting

* Check that the issue has not already been reported.
* Check that the issue has not already been fixed in the latest code
  (a.k.a. `master`).
* Be clear, concise and precise in your description of the problem.
* Open an issue with a descriptive title and a summary in grammatically correct,
  complete sentences.
* Include any relevant code to the issue summary.

## Pull requests

* Use a topic branch to easily amend a pull request later, if necessary.
* Write good commit messages.
* Use the same coding conventions as the rest of the project.
* Ensure your edited codes with four spaces instead of TAB.
* About how to make a package, please see [Create and Submit packages to the official repository](https://xmake.io/#/package/remote_package?id=submit-packages-to-the-official-repository)

# Package maintainers

## Work to be done

Review the pull requests submitted by contributors
 - Check for commits to dev branches, master branches are not allowed to be directly committed and merged
 - Check that the code conforms to the specification
 - Check that the on_test script is added and that the ci test passes
 - Help contributors with difficult ci testing issues where possible
 - Check that the code is lean and remind contributors to remove redundant code and keep the on_test script as lean as possible and not too long
Merge pull requests on dev branches that pass the tests

## Other points to note

1. don't have any commits to the master branch
2. ci will periodically sync commits from the dev branch to the master branch and other mirror repositories every hour
3. packages must be merged using `Squash and merge` mode to avoid overly redundant commit records

## How do I become a package maintainer?

First you need to meet the following requirements:

- Have committed at least 10 packages that have been successfully merged into the xmake-repo repository
- Have helped review at least 3 other contributors' commits and provided valuable input
- Submitted packages that are recognised by existing package maintainers for their quality
- Have sufficient free time and energy and be passionate about xmake package maintenance
- Be familiar with the use of xmake and the full process of creating xmake packages

If you feel you meet the above requirements, you can apply to become a package maintainer by emailing waruqi@gmail.com.

# 贡献代码

如果你发现一些问题或者想贡献一个新的包
那么你可以在[issues][1]上提交反馈，或者发起一个提交代码的请求(pull request).

## 问题反馈

* 确认这个问题没有被反馈过
* 确认这个问题最近还没有被修复，请先检查下 `master` 的最新提交
* 请清晰详细地描述你的问题
* 如果发现某些代码存在问题，请在issue上引用相关代码

## 提交代码

* 请先更新你的本地分支到最新，再进行提交代码请求，确保没有合并冲突
* 编写友好可读的提交信息
* 请使用与工程代码相同的代码规范
* 确保提交的代码缩进是四个空格，而不是tab
* 为了规范化提交日志的格式，commit消息，不要用中文，请用英文描述
* 关于如何制作包，请参看文档：[制作和提交到官方仓库](https://xmake.io/#/zh-cn/package/remote_package?id=%e6%b7%bb%e5%8a%a0%e5%8c%85%e5%88%b0%e4%bb%93%e5%ba%93)

[1]: https://github.com/xmake-io/xmake-repo/issues

# 包维护者

## 需要做的工作

1. Review 贡献者提交的 pull request
 - 检查是否提交到 dev 分支，master 分支是不允许被直接提交和合并的
 - 检查代码所以是否符合规范
 - 检查是否添加 on_test 脚本，并且 ci 测试是否通过
 - 尽可能帮助贡献者解决 ci 测试过程中遇到的一些疑难问题
 - 检查代码是否精简，提醒贡献者去除冗余代码，on_test 脚本尽可能保持精简，不要太长
2. 合并 dev 分支上通过测试的 pull request

## 其他注意点

1. 不要有任何到 master 分支的提交
2. ci 每个小时会定期将 dev 分支的提交同步到 master 分支以及其他镜像仓库
3. 必须使用 `Squash and merge` 模式合并包，避免过于冗余的提交记录

## 如何成为包维护者？

首先你需要满足以下要求：

- 至少提交过 10 个包，并成功合并入 xmake-repo 仓库
- 至少帮助 Review 过 3 个其他贡献者提交的包，并提出有价值的意见
- 提交的包质量得到现有包维护者的认可
- 有足够的空闲时间和精力，对 xmake 包维护充满热情
- 熟悉 xmake 的使用，以及 xmake 包的完整制作过程

如果你觉得满足上述要求，可以发送邮件到 waruqi@gmail.com 去申请成为包维护者。
