# Algorithmic Thinking for Functional Programming

Course materials for the spring elective that follows the fall C# course
(`OODP_Lessons`).  The course is taught from robot code written by students in
earlier runs of it.

## Getting it onto a computer

**On Windows, first, once per computer.**  Some FTC SDK file paths are long
enough to pass Windows' 260-character limit, and the clone fails with
`Filename too long`.  This lifts the limit for git:

```
git config --global core.longpaths true
```

The lesson starters are git submodules, so clone with them included:

```
git clone --recurse-submodules https://github.com/cox-programming-classes/AlgorithmicThinking.git
```

If it was already cloned without that flag and the lesson folders are empty,
run this from inside the repository:

```
git submodule update --init --recursive
```

Pulling later, making a new lesson starter, and fixing the usual submodule
problems are all in [`Course/SUBMODULES.md`](Course/SUBMODULES.md).

## What's here

| Folder | What it is |
|---|---|
| [`Course/`](Course/) | the course plan, the decisions behind it, and how-tos |
| [`ReferenceCopy/`](ReferenceCopy/) | a snapshot of the robot code from 2026-11-10, with the team's documents |
| `Lesson01_RobotObjectModel/` | the Lesson 1 starter (a submodule) |

Each code folder is its own Android Studio project.  Open them one at a time.

## License

The course materials in this repository and its lesson starters are licensed
under [Creative Commons Attribution-NonCommercial-ShareAlike 4.0
International](https://creativecommons.org/licenses/by-nc-sa/4.0/) (CC BY-NC-SA
4.0).  The full text is in [`LICENSE`](LICENSE).

The FTC SDK keeps its own license from *FIRST*:  `FtcRobotController/`, the
Gradle build, and the libraries that come with them.  That license is in
[`ReferenceCopy/LICENSE`](ReferenceCopy/LICENSE), and in `LICENSE-FIRST` in each
lesson starter.  Material under `ReferenceCopy/doc/` from *FIRST*, LEGO, and
other publishers keeps its own terms.
