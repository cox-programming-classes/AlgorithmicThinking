# Session Notes

One file per working session between Jason and Claude, named
`YYYY-MM-DD.md` (add `-b`, `-c` for a second session the same day).  They
record how the course got made:  the dialogue, the turns it took, and where it
went wrong.

The three records split the work this way:

| File | What it records | Read it to find out |
|---|---|---|
| `Course/PLANNING_NOTES.md` | course-wide decisions, by topic, with Jason's words | *what* was decided, and why |
| `Course/lessons/lesson_NN_planning_notes.md` | one lesson's dialogue, with Jason's words | what a lesson is built from |
| `Course/sessions/YYYY-MM-DD.md` | one session, start to finish | *how* the work went, including the mistakes |

Session notes point at the other two and don't repeat them.  A decision gets
quoted once, in the file that records it as a decision.

## The structure

Every session note uses these sections, in this order.  Leave a section in
with "None" when it's empty, so sessions can be compared section by section.

```
# Session YYYY-MM-DD - <what it was mostly about>

**Who:**  Jason, Claude (<model>).  **Where:**  <computer, and how Jason was connected>.

## Where we started
What was already true when the session opened, and what Jason asked for first.

## How it went
The arc, in order.  A numbered list of the turns that changed direction, each
one or two sentences, quoting Jason at the turning points.

## Where Claude got it wrong
Each mistake:  what happened, how it was caught (by Jason, by a test, by a
check), and what changed so it won't recur (a memory note, a rule, a file).

## What we learned about the process
Things about *how* to do this work that should carry forward.  Not course
decisions; those go in PLANNING_NOTES.

## Decisions
Pointers to the PLANNING_NOTES and lesson-notes entries made this session.

## What got built
Files and commits, by repository.

## Open threads
What's waiting, and on whom.

## Next session starts here
The first thing to do, in one or two lines.
```
