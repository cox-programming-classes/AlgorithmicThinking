# Algorithmic Thinking for Functional Programming

The spring follow-up to the fall C# course (`OODP_Lessons`).  It meets four
times a cycle, from mid-January to the end of May.  It builds on the fall
course and goes deeper, and it's taught in Java, because that's what
the robots run.

The course title is older than the course.  "Algorithmic thinking" is the vibe:
thinking about processes, and how to translate them into the common language of
humans and robots.  "Functional Programming" is still in the title because a
course title can only change a little with each re-proposal.  The title doesn't
set the syllabus.

The material is the robot code, written over several years by students in this
course.  `ReferenceCopy/` is a snapshot of it, taken on 2026-11-10.  The first
half of the course works in lesson starter repos beside it, each one stripped to
what its lesson needs.  After the midterm (a point in the content, not a date),
students work in the full code.  Some students are on the FTC team and some
aren't, so nothing in the course assumes knowledge of the game, the robot, or
the team.

The decisions behind this page, with Jason's words for each, are in
[`PLANNING_NOTES.md`](PLANNING_NOTES.md).

## Where the course ends

Students build a presentation championing the Robot Object Model:  the many
ways it makes programming the robot better.  They give it to the FTC community
at the season Kickoff the following fall.  For this run, that's fall 2027.

The secret goal:  *"yes it is more complex, but the trade offs are worth it."*

Ideally the whole class presents, and that can't be guaranteed.  Seniors will
have graduated by Kickoff, and some students drift off.  The presentation has to
work for whoever is there.

## The big themes

| Pattern | What the course does with it | Where it is in the code |
|---|---|---|
| **Strategy** | the deep dive | `IControlStrategy` and the per-component strategy interfaces, then up through the layers |
| **State** | revisited from the fall, and taken down the rabbit hole | `IState`, `StateMachine` |
| **Facade** | beheld | the nested `Autonomous...` classes at each major layer of the model:  `AutonomousRobot`, `AutonomousDriving`, `AutonomousMechBehaviors`, `AutonomousComponentBehaviors` |
| **Extensions** | revisited from C#, more deeply, with opinions about Java's version; a Decorator with extra steps | `Extensions/` |

Possible side tangents:

- Simulating multithreaded operation inside the FTC OpMode loop.
- The monad the Limelight code is handed:  `LimelightExtensions` gets an
  `Optional` from a stream and drops it straight to a null.  That's what the
  fall course taught, and Java has no nullable `?` on a type.

## Sequence

The plan grows as the course does, the way the fall course's did.  This page
records what's settled, and leaves the rest open on purpose.

### Settled

1. **An overview of the Robot Object Model, using concrete objects.**  Students
   arrive with enough polymorphism for "Billy *is a* Robot" and "Billy *has a*
   mecanum drive train."  The abstract layer and the higher-level strategies are
   left out at the start.  This part takes a while.
2. **Dumb components.**  A component that defines its move commands in its own
   class means every instance of it reacts when the driver presses "A."
3. **`IControlStrategy`.**  The Strategy pattern answers *how does this
   component get its commands from a gamepad?*, separately for each instance.
   The canonical example:  `DoublyLimitedMotor` in `CascadeArm`, where two
   instances of one class run the cascade on the left stick and the drawbridge
   on the right, and differ only in the strategy each is handed.

### And then...

Not yet written.  It gets written as the course develops.

## Staying on the rails

As the rest of the sequence gets written, each new piece gets checked against
what's already settled:

- **Does it move toward the presentation?**  Every topic should leave students
  more able to explain why the model is worth its complexity.
- **Concrete first.**  A layer of the model shows up as concrete objects before
  its abstract version, and a lower layer comes before the strategies above it.
- **Each solution hands over the next problem.**  The dumb component makes the
  case for `IControlStrategy`.  Later topics should arrive the same way.
- **Build on the fall course, don't repeat it.**  Strategy, State, and
  extensions were all met in C#.  This course goes deeper.
- **No FTC knowledge assumed.**  The game is color.  `ReferenceCopy/doc/FlintLessons/` was
  written for the team, and the course doesn't assume anyone has read it.

## Pacing

About 45 meetings, four per cycle.  Pacing is planned by unit, never by
meeting.

```
Course/
  README.md                 this file:  where the course ends, the themes, the sequence so far
  PLANNING_NOTES.md         decisions with sources, open questions, what's next
  HANDOFF.md                how this repository started
  SUBMODULES.md             cloning with the lesson repos, making and publishing a new one
  sessions/                 one note per working session:  how the course got made
  lessons/                  each lesson's plan, and the dialogue it was built from
ReferenceCopy/              a snapshot of the robot code (2026-11-10), with the team's doc/
Lesson01_RobotObjectModel/  the Lesson 1 starter:  the base bot, with dumb components
```

Each Gradle project sits one level below the root, and none is inside another.
Open each one in Android Studio on its own.

The rest of the OODP layout (`GUIDING_PRINCIPLES.md`, `lessons/`, `chapters/`,
`reference/`, `canvas/`, `flint/`) gets added as each piece is needed.
