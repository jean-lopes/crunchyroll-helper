# Crunchyroll Helper

## Description
Helper for [Crunchyroll](http://www.crunchyroll.com/). It allows the download/stream of episodes. Once started, it will chain the next episodes.

## Dependencies
- [livestreamer](http://docs.livestreamer.io/index.html)
- [stack](http://docs.haskellstack.org/)

## Installation
- Install [stack](http://docs.haskellstack.org/)
- Download [livestreamer](http://docs.livestreamer.io/index.html) and add it to your PATH variable
- $ git clone https://github.com/jean-lopes/crunchyroll-helper.git
- $ cd crunchyroll-helper
- $ stack setup
- $ stack build
- $ stack exec crunchyroll-helper-exe <username> <password> <url> <episode> <download>

### Examples
Start downloading Berserk episode 1 and onward
$ stack exec crunchyroll-helper-exe teste 123 http://www.crunchyroll.com/berserk 1 True

Start streaming Berserk episode 1 and onward to your default midia player
$ stack exec crunchyroll-helper-exe teste 123 http://www.crunchyroll.com/berserk 1 False