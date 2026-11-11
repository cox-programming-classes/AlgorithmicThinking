# Prologue - How This Book Works

*The common language of humans and robots.*

---

This course follows the one you took in the fall.  In the fall you wrote your
own game in C#.  This semester you work in code that students before you have
been writing for years, the code that runs the team's FIRST Tech Challenge
robots.  You'll read it, take it apart, and add to it.  By the end of the
course you'll be able to explain why it's built the way it is.

This is a course in design patterns.  It's built around four of them:

- **Strategy**, the deepest dive:  how a part of the robot gets its commands.
- **State**, and the rabbit hole that goes with it.
- **Facade**, in the nested classes behind the major pieces of the robot's
  code.
- **Decorator**, by way of extensions, which you met in C#.  Java's version
  is worse.

You meet each pattern when the robot's code runs into the problem that pattern
solves.

Every design choice in this book is a trade-off.  The robot's code is organized
around the **Robot Object Model**, and the model is more complex than a single
file of code that drives one robot.  What that complexity buys, and whether it's
worth it, is the question the whole course is about.

The course ends with a presentation.  The class builds a case for the Robot
Object Model, and the students who are here next fall present it to the FTC
community at Kickoff, the event that opens each season.

You know C# from the fall.  Java is new, and the book teaches it as the code
needs it, with an Aside each time a piece of Java first appears.  You don't
need to be on the robotics team.  The game, the hardware, and the team's code
get explained as they come up.

## Where this came from

"Algorithmic Thinking" is a title I made up many years ago, to name the vibe of
the course.  You should be thinking about processes, and how to translate them
into the common language of humans and robots.  On these robots, unfortunately,
that language is Java.

Java, at least the version these robots run, doesn't have a good way to
represent a lot of the ideas we'd want, first-class functions for a start.
Even its extensions are done sideways.

The code in this book is the result of student work in this class over the past
several years, and it runs the robots you'll use.

**[For Jason:  anything more about where the course came from:  when it
started, the team, the robots, and how the Robot Object Model got its shape.
Nothing here is filled in until you say it.]**

### How the chapters got written

The chapters come after the lessons.  Each lesson has a plan, and code to start
from:  a copy of the team's code, cut down to what that lesson needs.  Each
chapter gets written from those two things.

So the code in every chapter is real.  It's copied from the lesson's starter,
or it's code the chapter asks you to write yourself.  When a chapter shows a
compiler error, that's the error the compiler printed, word for word.  When a
chapter says what the robot does, someone has watched a robot do it, or the
chapter says it still needs checking.

I wrote this book with a writing assistant:  Claude, an AI model made by
Anthropic.  Claude helped me turn each lesson plan and its code into the
chapter you're reading.  This book could not exist without that help.  I've
taught this course for years, and this is the first time it's been written
down.

It's also a record of one run of the course, at one point in time.  Nothing
said in class gets recorded, so the plan changes to fit what happens in the
room, and the book follows the plan.  It will change the next time the class
runs.

## How a chapter runs

One chapter covers one lesson, and a lesson takes several class meetings.
Chapter 1 takes five.  On Canvas, and in the files for Flint, each meeting gets
its own document, cut at a Part heading, with the meeting named at the top.
The printed book keeps each chapter whole.

### The starters, and the live code

For the first half of the course, each lesson opens its own **starter**:  a
fresh copy of the team's code with everything the lesson doesn't need taken
out.  Chapter 1's robot is a tank drive with a one-joint arm, and every part of
it is as simple as it can be.  Each lesson after that adds pieces back as it
needs them.

After the midterm, you work in the team's live code.  The midterm here is a
point in the material:  it comes when the class gets there.  By then you'll
know your way around the code.

The course repository's `README.md` says how to download every starter at
once, from the command line.

### The robots

The class has several working robots, and the current season's robot joins
them once it's built.  Some chapters ask you to run code on one.

**[For Jason:  homework.  Whether there is any, and the cap.  OODP's was
fifteen minutes a night.]**

**[For Jason:  the Flint helper.  Its name, if it has one, and what it will and
won't do for students in this course.]**

### The chapters so far

| Chapter | Meetings | What it's about |
|---|---|---|
| 1 - The Robot Object Model | 5 | the layers of a robot, from the hardware to the code |

The chapters after this one get written as the course runs.  The book ends with
two appendices, for students and teachers both.  **Appendix 1** is a reference
to the FTC SDK, the library under the team's code:  every class and method the
course uses, what each one does, and the rough edges found in them.  It also
covers the sensors, cameras, and other devices the SDK supports that the
course hasn't used yet, so you know what's there when a robot needs one.
**Appendix 2** is the Limelight 3A, a camera with a computer of its own, which
needs an appendix to itself.

## How to read a chapter

### The shape

Every chapter has the same parts, in the same order.

- **An opening** that says where the last chapter left you, and what problem is
  still standing.
- **Part One** reads the starter.  Its sections are numbered by chapter, 1.1,
  1.2, 1.3, and each one takes apart one piece of the code.
- **Part Two and after** build.  The building comes in numbered Steps, and each
  Step changes one or two things.  Chapter 1 is a reading chapter, so its Parts
  read and talk, and the building starts in Chapter 2.
- **The end of the chapter** gathers it up:  a summary, a table of new syntax
  and where you met it, the vocabulary, a few questions to check your
  understanding, and a look at what comes next.

### The marks

**Build it** marks code to type into the project.  Type it by hand.  Your
fingers learn the syntax faster than your eyes do.

**Your turn** marks code you write yourself.  The chapter says what it has to
do, and leaves the how to you.

**Optional** marks a **Your turn** that nothing later depends on.  Skip it if
you're short on time, and the steps after it still work.

The rest come in boxes, and each kind has its own color.

> **Aside:  what an Aside is**
>
> An Aside explains a piece of Java the first time it appears in the book, and
> says how it differs from the C# you know.  Most Asides are new spellings for
> things you've already used.  If you already know one, skim the box and keep
> going.

> **Check.**  A Check marks a place to stop and make sure the code does what
> the chapter says.  Some Checks build the project and quote the compiler.
> Some run it on a robot.  If yours is different, fix that before you go on,
> because the next step builds on this one.

> **Tonight.**  A Tonight box is homework, and it says how long to spend.

> **Answer in your notes.**  A question to answer in writing, in a sentence or
> two.  Keep your notes, because class picks up from them.

> **Argue it.**  A question with more than one good answer.  Pick one, and be
> ready to defend it.  The room won't agree, and that's the point.
