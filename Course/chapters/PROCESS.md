# The Chapter Process

How a lesson becomes a textbook chapter.  Adapted 2026-11-10 from
`OODP_Lessons/Course/chapters/PROCESS.md`, which worked it out backward from
that course's Chapter 6.  What changed for this course:  Java instead of C#,
the robot instead of the console, and a reading-first Lesson 1 with almost no
class work to rebuild.

Read this file first.  Then the lesson's plan and planning notes in
`Course/lessons/`, then its chapter.  Feedback on a plan is worth more than
feedback on a chapter, because a plan error repeats in every chapter it
touches.

---

## The inputs, and the rule

| Input | Where it is | What it gives the chapter |
|---|---|---|
| The lesson plan | `Course/lessons/lesson_NN_*.md` | the idea, the order, the discoveries, the meeting count, the homework |
| The planning notes | `Course/lessons/lesson_NN_planning_notes.md` | Jason's words for each decision, and what's still open |
| The starter | the lesson's repo (`LessonNN_*/`), branch `main` | the code students open |
| The class work | the lesson's repo, `main` to `Teacher` | the Steps:  what got built, in what order.  Lesson 1 has none yet |

**The rule:  every line of code in a chapter is real.**  It is copied from the
starter, or it is a student's **Your turn** that the plan says the student
writes.  Every compiler error a chapter quotes was produced by building the
code, and every runtime message was seen on a robot.  What can't be checked
yet is marked unverified in the planning notes, and the chapter doesn't quote
it until it has been.

---

## The steps

### 1.  Inventory

Read the lesson plan, its planning notes, the starter's `README.md`, and any
Flint prompt or Canvas page for the lesson.  Read the chapter before and the
chapter after, so this one opens where the last left off and closes on what
comes next.

### 2.  Read the diff

Diff the starter against the class work, file by file.  Skip `build/`,
`.gradle/`, `.idea/`, and `FtcRobotController/`.  Sort every change into three
piles:  **built in class** (a Step), **a Your turn** (the student's), and
**teacher scaffolding** (quoted or skipped).

A reading lesson, like Lesson 1, has no diff.  Its chapter reads the starter
and follows the plan's story.

### 3.  Find the order

Order the changes by dependency, then by the plan's story.  Each Step has to
compile at its end.  Where the two disagree, the code has to compile, and the
story bends.

### 4.  Find the discoveries

Every plan has things students are meant to *find*.  The chapter sets each one
up, names it, and holds back the answer.  The answers go in the planning notes,
for Jason and for the Flint prompt.

### 5.  Verify the code

Export the starter into a scratch folder with `git archive`, which leaves the
lesson repo untouched.  Build it with Android Studio's JDK (on Jason's Windows
computer, `JAVA_HOME="/c/Program Files/Android/Android Studio/jbr"`):

```
./gradlew :TeamCode:compileDebugJavaWithJavac
```

For every **Check** that predicts a compiler error, make that exact edit in the
scratch copy, build, and copy the message.  A **Check** that predicts what the
robot or the Driver Station does can't be verified on a laptop.  Mark it
unverified in the planning notes until Jason has seen it on a robot.

### 6.  Split into meetings

The meeting count comes from the lesson plan.  Each meeting becomes one Word
file and one Canvas page, cut at a `# Part` heading.  The `CHAPTERS` table in
`Course/reference/build_chapter.lua` records which headings start which
meeting.

A meeting with no record (Lesson 1's Meeting 4) still gets a page, holding what
students take into it, never what was said in it.

### 7.  Write

```
# Chapter N - Title
*tagline, from the lesson plan*
---
Opening:  where the last chapter left us, and the problem it left behind.
---
# Part One - ...                reading:  ## N.1, N.2 ... sections
# Part Two - ...                building:  ## Step 1 - ..., ## Step 2 - ...
...
## Chapter summary
### New syntax in this chapter  table, with where each was met
### Vocabulary                  alphabetical, each with its section
### Check your understanding    numbered questions
## What's next
```

The markers, which the build turns into boxes, and nothing else:

| Marker | Written as | Means |
|---|---|---|
| **Build it.** | bold, at the start of a paragraph | type this into the project |
| **Your turn.** | bold, at the start of a paragraph | the student writes this, unguided |
| **Optional** | bold, inside a Your turn | nothing later depends on it |
| Aside | `> **Aside:  topic**` | a piece of Java explained the first time it appears |
| Check | `> **Check.**  ...` | stop, run, and here is what you should see |
| Tonight | `> **Tonight.**  ...` | the homework, only where the plan sends work home |
| Answer in your notes | `> **Answer in your notes.**  ...` | a written question, kept |
| Argue it | `> **Argue it.**  ...` | a question with no settled answer, for class |

**Each chapter teaches what it needs, at the point it needs it.**  Students
arrive knowing C# from the fall.  An Aside covers a piece of Java the first
time it appears, and says how it differs from the C# they know.

### 8.  Check the prose

The voice rules are in `ClaudeWritingProject/style-guide/`, a sibling of the
`Robotics` folder:  `APPALACHIAN_ACADEMIC_STYLE.md` and
`WRITING_COMMON_ERRORS.md`.  Every drafter reads both in full.  The mechanical
checks, from the top of this repository:

| Rule | Find it |
|---|---|
| two spaces after every sentence, and after a colon | `grep -nE '[a-z)][.?!:] ["A-Z]'` |
| no typographic dashes;  `--` with a space each side | `grep -n '—\|–'` |
| no paired `-- ... --` brackets | `grep -nE ' -- [^.]{5,120} -- '` |
| headings take a single hyphen | `grep -nE '^#{1,6} .* -- '` |
| no definition by negation | read for `not`, `never`, `nothing`, `without`, `rather than`, `instead of` doing setup-and-knockdown work |
| no abstract "stays", "holds", "lives" | `grep -niwE 'stays?\|holds?\|lives'`, and ask whether you could point at it |
| no comma before a trailing adverb, in Claude's drafts | `grep -nE ',\s+[a-z]+ly[.:;)"]'` |
| no commentary lines | read every paragraph's last sentence:  does it add a fact, or tell the reader what to think of the ones before it? |

Jason's own words, quoted from the planning notes, are left exactly as he wrote
them.

### 9.  Build

```
pandoc lua Course/reference/build_chapter.lua 01
```

An appendix builds the same way, by its key:  `A1` is Appendix 1, the FTC SDK
reference (`appendix_1_ftc_sdk.md`), one piece, for students and teachers.
Its rule matches the chapters':  every signature was read from the SDK jars
with `javap`, and every behavior from `javap -c`.

Needs only pandoc 3.  It writes one Word file per meeting to
`Course/chapters/build/word/` (for Flint, which takes `.docx`) and one Canvas
page per meeting to `Course/chapters/build/canvas/`, with every style inline,
because Canvas strips `<style>` blocks.  It keeps every double space.

**The print version** is two more steps, on Windows with Microsoft Word:

```
pandoc lua Course/reference/build_chapter.lua book
powershell -ExecutionPolicy Bypass -File Course/reference/finish_book.ps1
```

The first puts every chapter in the `BOOK` list into one Word file,
`Course/chapters/build/book/Book_Draft.docx`, with a title page and a table of
contents, and writes `meetings.tsv`.  The second has Word lay it out for
double-sided printing, fill in the contents and page numbers, and export
`Book_Draft.pdf`.  Then it cuts one PDF per meeting into
`Course/chapters/build/pdf/`, so each handout matches the book page for page.
Close any of those PDFs before running it; the script stops if one is open.

Build the book after any change to a chapter, and read the PDFs it cuts.

**Figures and art.**  Run these before the book build when they change:

```
py Course/reference/make_figures.py
powershell -ExecutionPolicy Bypass -File Course/reference/make_art.ps1
powershell -ExecutionPolicy Bypass -File Course/reference/make_cover.ps1
```

- `make_figures.py` draws the chapters' UML diagrams as SVG, and exports PNGs
  with Inkscape (`C:\Program Files\Inkscape`), into `Course/chapters/figures/`.
  Those files are committed, since chapters embed them.
- `make_art.ps1` and `make_cover.ps1` are recycled from the Field Guide.  They
  draw each chapter's title picture, the spot pictures `finish_book.ps1` drops
  into large gaps, and the cover, all into `build/book/`.  The book builds
  without any of them.

Not set up yet:  the one-line chapter openings in `Course/chapters/book/`.

To look at the finished pages on this computer, render the PDF to images:
`powershell -ExecutionPolicy Bypass -File Course/reference/preview_pages.ps1`.

---

## What this process can't know

- **What happened in the room.**  Nothing said in class is recorded.  The
  chapter follows the plan, and the plan changes when Jason says the room went
  differently.
- **What the robot does.**  A laptop can compile the code.  Only a robot can
  confirm a Driver Station message or a motor's direction.
- **Jason's call on what's a discovery.**  Where the plan is silent, the drafter
  guessed, and the planning notes say so.
