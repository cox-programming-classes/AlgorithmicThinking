# Handoff:  Algorithmic Thinking for Functional Programming

Made 2026-11-10.  This is where the semester elective that follows the C# course
(`../OODP_Lessons`) gets planned.  The robot code is the course material.

## Where this came from

A copy of the team repository `WinsorRobotics26-27`, taken from its `textbook`
branch at commit `5a3da3c`, with the git history kept.  One thing was taken out:

- **`doc/FieldGuide/` stays with the team.**  It is the robotics team's reference
  book, and it lives on in the team repository.  This course doesn't use it.
  One code comment still points at it
  (`TeamCode/.../RobotModel/Robots/Robot.java`, line 75).  It was left alone so
  the robot code matches the team's and merges cleanly.

Everything else came over as it was:  `TeamCode/`, the FTC SDK, `doc/FlintLessons/`
(the team's tutor prompts), `doc/CanvasFrontPage.html`, and the hardware and
game-manual references.

## Remotes

This repository has **no remote**.  Publish it from GitHub Desktop.  After that,
add these two if they're needed:

```
git remote add robotics https://github.com/the-winsor-school/WinsorRobotics26-27.git
git remote add upstream https://github.com/FIRST-Tech-Challenge/FtcRobotController.git
```

Because the history is shared, `git pull robotics master` brings the team's
later robot code into this repo.

## The standard format

Lay the course out the way `OODP_Lessons/Course/` is laid out, and copy its
tooling rather than rewriting it:

```
Course/
  README.md                 pacing, structure, how to run things
  GUIDING_PRINCIPLES.md     why each decision was made
  lessons/                  the lesson plans
  chapters/                 the textbook, one chapter per lesson
    PROCESS.md, planning/, book/ (title-page openings)
  reference/                the book build, and the Word and PDF it makes
  canvas/                   chapters as Canvas pages, plus the upload tooling
  flint/                    the tutor prompts
```

| Piece | Copy from |
|---|---|
| Course plan | `OODP_Lessons/Course/README.md`, `GUIDING_PRINCIPLES.md`, `lessons/` |
| Textbook build | `OODP_Lessons/Course/reference/` (`build_chapter.lua`, `book-reference.docx`) and `chapters/PROCESS.md`.  The Field Guide's newer scripts (`check_chapters.ps1`, `finish_book.ps1`, `preview_pages.ps1`, `make_art.ps1`, `make_cover.ps1`) are in the team repo under `doc/FieldGuide/reference/` |
| Flint helpers | `OODP_Lessons/Course/flint/`, `meta/FLINT_PROMPT_GUIDE.md`.  Flint takes `.docx` (memory note `flint-wants-word`) |
| Canvas | `OODP_Lessons/Course/canvas/` (`build_manifest.py`, `import_canvas.ps1`, `README.md`) and the Canvas tasks in `OODP_Lessons/.vscode/tasks.json`.  This course needs its own Canvas course ID |
| Voice and design | `OODP_Lessons/meta/` (`LESSON_DESIGN_FRAMEWORK.md`, `CS_GUIDING_PRINCIPLES.md`, `teaching_philosophy.md`, style guides) |

## Claude memory

The memory notes Claude keeps between sessions are in
`OODP_Lessons/meta/claude-memory/`.  Read its `README.md` before writing any new
notes.  Open Claude Code in this folder once, then install the notes from there.

## Still open

- Whether the course runs.  As of 2026-11-10, sign-ups are short.
- The Canvas course ID.  There isn't one yet, and there won't be unless the
  course runs.  Leave the Canvas tooling unconfigured until then.
- Which parts of the robot code the course teaches from, and in what order.
- Whether `doc/FlintLessons/` stays here as reference material or gets trimmed.
