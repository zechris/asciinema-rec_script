# asciinema-rec_script
[![Conventional Commits][conventional-commits-image]][conventional-commits-url]

Record 💭 comments and ❯ commands from from shell scripts in addition to their output.

This is done by building a version of the original script that surfaces all the comments and commands by *also* echoing them to the screen.

Then passing that augmented script to asciinema's [rec --command](https://github.com/asciinema/asciinema#rec-filename) command.


## Motivation

The [asciinema](https://asciinema.org) tool is an awesome terminal session recorder.

And it has a [rec [filename]](https://github.com/asciinema/asciinema#rec-filename) command with a `-c --command=<command>` option.

This specifies a `command` to record (other than the default of `$SHELL`)

So given an (executable) script [screencasts/demo-date_maths](https://github.com/zechris/asciinema-rec_script/blob/main/screencasts/demo-date_maths):
```bash
#!/usr/bin/env bash
## Date maths

# The `date` command can be used to retrieve the:
#  * *day of the week* using the `%l` option
day_of_the_week=$(date +%l)

#  * *hour of the day* using the `%u` option
hour=$(date +%u)


# Now, can you guess what we're going to do with those two numbers?
# 🤔...
sleep 3

# We're going to add them together!
echo $((day_of_the_week + hour))
```

We can use asciinema's `rec` to make a recording:
```
asciinema rec --command screencasts/demo-date_maths
```


However that recording is going to lose a bunch of context from the script and end up looking something like this:
<img width="808" alt="Screen Shot 2021-10-17 at 19 49 14" src="https://user-images.githubusercontent.com/49626717/137619503-05ec8492-f2df-4bc3-a410-ad3300223b8f.png">

If, however we instead used this command:
```
asciinema-rec_script screencasts/demo-date_maths
```

Without *any* effort we can end up with a recording like this:
[![demo-date_maths.cast](screencasts/demo-date_maths.gif)](https://asciinema.org/a/gOhB2rxL8LTl3PL6kpC4YPCID)


## Getting Started
### Installation:
Place `asciinema-rec_script` somewhere in your $PATH.


#### Requirements:
 * [asciinema](https://asciinema.org) ([installation](https://github.com/asciinema/asciinema#installation))
 * bash
 * (optional) [bat](https://github.com/sharkdp/bat) ([installation](https://github.com/sharkdp/bat#installation))
   * _A `cat` clone to provide syntax highlighting_


### Example Usages:
 * `asciinema-rec_script ./screencasts/demo-date_maths`
   * _When called with no extra arguments, the tool will pass `asciinema rec` a filename of `./screencasts/demo-date_maths.cast` to place the recording in_
   * _(Nb. the filename is derived from the source script by attaching a `.cast` extension.)_
 * `./screencasts/demo-date_maths.asc`
   * _Will take advantage of the shebang line [#!/usr/bin/env asciinema-rec_script](https://github.com/zechris/asciinema-rec_script/blob/main/screencasts/demo-bash_functions.asc#L1) in the `.asc` script_
   * _(ie. allowing the input script to be run as its own command, without having to pass it as an argument to `asciinema-rec_script`)_
 * `./screencasts/demo-date_maths.asc --`
   * _When called with `--` the tool will allow `asciinema rec` to receive no additional arguments_
   * _(ie. allowing it to maintain its default behaviour of uploading screencasts to https://asciinema.org)_
 * `./screencasts/demo-date_maths.asc --help`
   * _Will also pass any additional arguments it gets to `asciinema rec`_
   * _(so eg. `--help` will show all the [asciinema rec [options]](https://github.com/asciinema/asciinema#rec-filename))_
 * `SLEEP=0 ./screencasts/demo-bash_functions.asc`
   * _(env vars can be passed into the script in the regular way)_
   * _(to eg set `PROMPT="$ "`, `PROMPT_PAUSE=5`)_
 * `bash ./screencasts/demo-date_maths.asc`
   * _Nb. It should also be possibe to execute the `.asc` script in your $SHELL as a regular bash script_
   * _(Maintaining this compatability means that the `.asc` file won't require any special commands that a regular shell script wouldn't already have in it.  Which hopefully results in regular shell scripts resulting in half-decent looking recordings.)_

(Nb. the `.asc` extension (_"ASCiinema"_) is not strictly necessary, but gives some uniformity.)


### How it works
`asciinema-rec_script` (written in bash) reads from the file passed to it one line at a time and will detect:
 * ❯ _lines of code_ (syntax highlighting them as bash code)
 * 💭 _comments_ (syntax highlighting them as markdown)
 * _blank lines_ (preserving whitespace)
 * 💬 and some other _special lines_

It uses meta-programming to build an augmented version of itself from each of these lines storing them in a temporary `augmented_script` file.

And finally it passes that file (and any other arguments specified on the command line) to `asciinema run --command <augmented_script>` for it to make a recording.

Nb. although the `.asc` scripts are used to produced asciinema recordings its expected that these files can also be run in bash/zsh

eg.
```
❯ source screencasts/demo-bash_functions.asc
a='a 0', b='b 0', c=''
-> f1(a='a 0', b='b 0', c='')
-> f1(a='a 0', b='b 0', c='')
BEFORE: a='a 0', b='b 0', c=''
-> f1(a='a 1', b='b 1', c='c 1')
AFTER : a='a 1', b='b 1', c='c 1'
BEFORE: a='a 0', b='b 0', c=''
-> f1(a='a 1', b='b 1', c='c 1')
AFTER : a='a 0', b='b 0', c=''
-> f1(a='a 1', b='b 2', c='c 2')
-> f1(a='a 1', b='b 0', c='c 2')
Sun Oct 17 20:56:56 AEDT 2021
-> f1(a='a 1', b='b 0', c='Sun Oct 17 20:56:56 AEDT 2021')
BEFORE: a='a 0', b='b 0', c=''
-> f1(a='a 1', b='b 3', c='c 3')
AFTER : a='a 0', b='b 0', c=''
-> f2(a='a 4', b='b 4', c='Sun Oct 17 20:56:56 AEDT 2021')
-> f2(a='a 4', b='b 4', c='Sun Oct 17 20:56:56 AEDT 2021')
-> f2(a='a 4', b='b 4', c='c 4')
```

#### Limitations
As the `.asc` is read in one line at a time, making it difficult (if not impossible) to execute multi-line commands in these shell scripts.

The two workarounds I could think of were:
1. making every multi-line command fit on one line
  * So this:
    ```bash
    f1() {
      echo "-> f1(a='$a', b='$b', c='$c')"
    }
    ```
  * would have to be manually edited in the `.asc` file to this:
    ```bash
    f1() { echo "-> f1(a='$a', b='$b', c='$c')"; }
    ```
2. inline the multi-line code from a `source` command:
  * So something like this:
    ```bash
    source "${script%.asc}/f1.1"
    ```
  * could be used (eg. [here](https://github.com/zechris/asciinema-rec_script/blob/4d7b6e6768a1a9d7af97af72afeaf415be0fc647/screencasts/demo-bash_functions.asc#L7)) to source [this file](https://github.com/zechris/asciinema-rec_script/blob/4d7b6e6768a1a9d7af97af72afeaf415be0fc647/screencasts/demo-bash_functions/f1.1#L1-L3) but be seemlessly displayed in the [recording](https://asciinema.org/a/2Vvvu1UoiUI1GU6kBYDCRx9Vp?t=2) as:
    ```bash
    f1() {
      echo "-> f1(a='$a', b='$b', c='$c')"
    }
    ```



## Also included
### [asciinema-gh](https://github.com/zechris/asciinema-rec_script/blob/main/bin/asciinema-gh)
This tool provides a command line playack menu of screencasts which it pulls from github repos.

It works with both public & private github repos.

(Nb. The recordings that appear in the menu don't necessarily have to be made using `asciinema-rec_script`,
but the menu will filter out all the `.asc` files from that directory.)

#### Requirements:
 * [asciinema](https://asciinema.org)
 * [gh](https://github.com/cli/cli)
 * [jq](https://stedolan.github.io/jq)


#### Example Usages:
 * `asciinema-gh zechris/asciinema-rec_script`
   * _search for .cast files in https://github.com/zechris/asciinema-rec_script/tree/master/screencasts_
 * `REF=v0.9.0 asciinema-gh zechris/asciinema-rec_script` 
   * _(which can be used with a github `REF`s like release tags eg. [v0.9.0](https://github.com/zechris/asciinema-rec_script/releases/tag/v0.9.0))_
 * `REF=first_pr asciinema-gh zechris/asciinema-rec_script` 
   * _(or branch names eg. [first_pr](https://github.com/zechris/asciinema-rec_script/tree/first_pr))_
 * `asciinema-gh spectreconsole/spectre.console docs/input/assets/casts`
   * _(NB. a path can also be specified if the screencasts aren't found in the default `./screencasts`)_
 * `echo 26 | screencast_dir=docs/input/assets/casts asciinema-gh spectreconsole/spectre.console`
   * _(to pre-select number `26` from the menu)_

[![asciicast](https://asciinema.org/a/uiqC0yZrCP9UPGqWaX5Wnf7wF.svg)](https://asciinema.org/a/uiqC0yZrCP9UPGqWaX5Wnf7wF)

[conventional-commits-image]: https://img.shields.io/badge/Conventional%20Commits-1.0.0-yellow.svg
[conventional-commits-url]: https://conventionalcommits.org
