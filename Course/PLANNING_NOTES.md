# Planning Notes

The running record of how this course plan got made:  what was decided, what
was turned down, and what's still open.  Newest entries go at the bottom of each
section, with a date.  `HANDOFF.md` is where this started, and it stays as it
was written.

*Approved:*  marks a decision Jason made.  *Under review:*  marks a question or a
proposal still waiting on him.

## Goal

Plan *Algorithmic Thinking for Functional Programming*, the spring-semester
follow-up to the OODP C# course, using the robot code in this repository as the
course material.  The course gets the same layout as `OODP_Lessons/Course/`:
course plan, textbook, Flint prompts, and Canvas pages.

## Decisions

### 2026-11-10 - kickoff

- *Approved:*  The course follows OODP in the spring semester, at 4 meetings per
  cycle, from mid-January through the end of May 2027.
- *Approved:*  The paradigm is functional programming, taught in Java.  Jason:
  *"I am fully aware of the irony of trying to do Functional Programming in Java
  =P  that's half the joke for my snarky commentary, and also why the OODP class
  is taught in C#."*
- *Approved:*  The audience is OODP graduates, some on the FTC team and some
  not.  Game-specific content is tangential, and it is never expected
  pre-knowledge.
- *Approved:*  `TeamCode/` is editable.  It's where student code lives, and the
  code already in it came out of this class in earlier years, so it is course
  content as well as course material.  **This reverses the handoff**, which had
  the robot code left alone so it would merge cleanly with the team repository.
- *Approved:*  `doc/FlintLessons/` targets the FTC team.  It may serve as
  reference, and the course assumes nobody has read it.  The course's own tutor
  prompts get written new, in `Course/flint/`.
- *Approved:*  Students have several working robots, some of which the code
  already describes, plus the current season's robot once it exists.  Exemplar
  robots can be built for specific course goals.
- *Approved:*  Pacing is planned by unit, never by meeting.  About 45 meetings
  is the working estimate.
- Today's piece:  course goals and a scope and sequence, drafted in
  `Course/README.md`.  `GUIDING_PRINCIPLES.md`, lessons, chapters, and tooling
  come after that draft is approved.

### 2026-11-10 - found in the code, and carried into the draft

- **The language level is Java 8.**  `build.common.gradle` sets
  `sourceCompatibility JavaVersion.VERSION_1_8`, which is what the FTC SDK
  supports.  Lambdas, method references, `java.util.function`, `Optional`, and
  streams are all available (streams need Android API 24, and `minSdkVersion` is
  24).  Records, sealed types, `var`, and switch expressions are not.  The draft
  plans for Java 8 as it stands.
- **Nothing runs off the robot yet.**  `TeamCode/src/` has `main/` and no
  `test/`.  The draft makes a laptop-side test setup the hinge of Unit 2,
  because "pure code can be tested without the robot" is the claim that sells
  purity to these students.
- **The code is full of functional material.**  The draft's anchors:
  `IState` (a state is a function that returns the next state),
  `StateMachine.doAndWait` (a function that builds states, and reaches into a
  shared field to do it), `IAutonStrategy` (a `Runnable` by another name),
  `LimelightExtensions` (a stream that ends in `.orElse(null)`),
  `AngleExtensions` (pure math, and two algorithms worth comparing), and
  `MecanumDrive` (the same mixing math written twice, at lines 60 and 240, with
  the second copy's turn signs swapped).

### 2026-11-10 - the first draft of goals, rejected

The six goals and the scope and sequence drafted in `README.md` were turned
down.  Jason:  *"Please don't put words in my mouth ;)   Your 6 goals are way
off the mark right from the start.  I need to give you more context before you
start writing that.  This is the follow up to the OODP course, not re-writing
it but with ~JAVA~"*

What went wrong:  the draft was written before Jason had said what the course
is for, so it filled the gap with guesses.  Several units retaught what OODP
already covers (handed-in strategies, immutability, objects with a functional
bent), only in Java.  It also put framing into the course's mouth that was
never his.

- *Approved:*  This course builds on OODP and does not repeat it.
- Next step:  Jason supplies the course's context and purpose before any goals
  are drafted.  The rejected draft stays in `README.md`, marked as rejected, as
  a record until it's replaced.

### 2026-11-10 - what the course is about, in Jason's words

Given as a stream of consciousness, and kept verbatim.  Nothing has been
drafted from it yet.

> *"The biggest theme of the Algorithms course is a combination of diviing deep
> into the Strategy pattern, while revisiting and going down the rabit hole of
> the State pattern.  Along the way we also behold the beauty of the Facade
> pattern (in the form of the AbstractX nested classes within the major beats
> of the Robot Model).  We also revist (more deeply) the Extensions concept
> from C# and opine over how shitty the Java version is, and also remind folks
> that this is a Decorator with extra steps (or fewer steps if we were in C#
> [cough cough] lol).   The end goal is to prepare a presentation evangelizing
> the greatness of the Robot Object Model and explaining the many different
> ways that this makes programming the robot cooler and more awesomer (secret
> goal:  yes it is more complex, but the trade offs are worth it).  Side
> tangents might include the nature of simulating multi-threaded operation
> within the FTC OpMode construct; exploring the explicitly provided Monad
> structure in Limelight (you already saw it when you were looking at that
> Optional return that is immediately dropped down to a nullable-reference
> because that's what they learned in the OODP class and Java doesn't have the
> nullable `?` post-fix on Types."*

### 2026-11-10 - the course title is an appendix

> *"\"Algorithmic Thinking\" is a title I made up many years ago which is mean
> to embody the vibe of the course.  They should be thinking about processes
> and how to translate them into the common language of humans and robots
> (Unforutnately that means Java in this case).  Even though I wrote that
> course title it is still inherited because **the powers that be** won't let
> me change a course title wholesale so I have to slowly mutate it over years
> of re-proposals of the same course.... that is also why \"Functional
> Programming\" is in the course title... Yo're looking at the middle point of
> an evolutionary process where the Course Title is the equivalent of a
> biological appendix"*

- *Approved:*  The title doesn't set the syllabus.  "Algorithmic thinking" names
  the course's vibe:  thinking about processes, and translating them into the
  common language of humans and robots, which here is Java.  "Functional
  Programming" survives in the title because a title can only change a little
  with each re-proposal.  It is not the paradigm the course is built around.
- This supersedes the kickoff entry above that read "the paradigm is
  functional programming."  The quote there stands as said:  it answered which
  meaning of "functional" the title uses.

### 2026-11-10 - the final presentation's audience

> *"the audience is the FTC community.  The kids will give the presentation at
> Kickoff the following fall"*

- *Approved:*  Students present the Robot Object Model to the FTC community at
  the season Kickoff the fall after the course, so fall 2027 for this run.  The
  audience knows FTC well and doesn't know this codebase, which is the reverse
  of the class itself.

- Who presents:  *"ideally the whole class, but that cant be guaranteed.  if a
  senior takes the class they aren't around for the fall Kickoff event.  Some
  kids also just peace out and that is ~fine~  just unfortunate."*  The plan
  has to work for whoever shows up in the fall, and seniors will have
  graduated by then.

### 2026-11-10 - sequence, the opening

> *"start with an overview of the Robot Object model (this will take a bit, but
> they have the foundation to undrstand the concrete objecst and just enough
> polymorphism to understand that \"Billy *is a* Robot\" and \"Billy *has a*
> Mechanum dirve train\"  We should ignore the Abstract part and all of the
> higher level strategies from the get go.  We start with the dumb view of
> control defined at the Component level and immediately realize taht isnt
> good enough.  IControlStrategy is the entry point from there. and then...*
>
> *...*
>
> *we develop further, similar to the OODP class it should develop organically
> to some degree toward the ultimate goals.  And it'll be a living process.
> You won't be able to and shouldn't expect to write an entire course plan all
> at once right away."*

- *Approved:*  The course opens on an overview of the Robot Object Model, at
  the level of concrete objects:  is-a (Billy is a Robot) and has-a (Billy has
  a mecanum drive train).  The abstract layer and the higher-level strategies
  stay out at first.
- *Approved:*  First real topic:  the "dumb" view of control at the Component
  level, which turns out not to be good enough.  `IControlStrategy` is the way
  in from there.
- *Approved:*  The plan grows as the course does, the way OODP's did.  Write
  the next stretch, not the whole semester.

**The dumb component, and why Strategy fixes it.**

> *"dumb components directly define the move commands in the Component class
> themselves.  which means that **every** instance of that component reactvs
> when the driver presses \"A\" on the game pad.  the Strategy pattern which
> answers the question \"/How/ does this component get its commands from a
> Gamepad\" fixes that problem."*

- *Approved:*  The first problem the course solves:  a component that
  hard-codes its own buttons in `move(gamepad)` makes every instance of it
  answer the same button.  The Strategy pattern answers *how does this
  component get its commands from a gamepad*, one instance at a time.
- *Under review (Claude's observation, not yet Jason's call):*  `CascadeArm`
  (`RobotModel/Mechs/Assemblies/CascadeArm.java`, lines 45-75) is the payoff
  already in the code.  It builds two `DoublyLimitedMotor`s from the same
  class, the cascade on the left stick and the drawbridge on the right, and
  the only difference between them is the lambda each one is handed.  A dumb
  `DoublyLimitedMotor` would move both lifts on the same stick.
- *Approved, 2026-11-10:*  Jason:  *"Yes, DoublyLimitedMotor and its role in
  the CascadeArm is the canonical example of this problem."*

## Open questions

- **Pinned, 2026-11-10:**  how earlier runs of the course went, what worked,
  and what Jason would change.  *"Thats a whole conversation of its own we
  should put a pin in."*  Come back to it before writing lesson plans.
  *Superseded 2026-11-10:*  there are no written plans from earlier runs.
  What they taught comes out lesson by lesson, as each is planned.

- *Under review:*  **The laptop test setup.**  The proposal is a `src/test/java`
  folder in `TeamCode` with plain JUnit 4, as Android local unit tests that run
  on the laptop JVM.  It changes the build, so it waits for approval, and it
  needs a trial run on a school laptop before Unit 2 depends on it.
- *Under review:*  **Stay at Java 8?**  Raising the language level is possible
  in principle, but the FTC SDK supports 8.  Plan for 8.  The missing features
  become part of the commentary, the same way the C# course used what C# hands
  you.
- *Under review:*  **The course robot.**  Is there one exemplar robot every
  student can count on for Units 0-4, such as one of the tank drives, while the
  season robot is still being built?
- *Under review:*  **Where each student's code lives in `TeamCode/`.**  The
  options are a package per student, a branch per student, or a fork per
  student.
- *Under review:*  **Does `TeamCode/` still pull from the team repository?**  If
  student work lands here and team work lands there, `git pull robotics master`
  will start to conflict.  Decide whether this repo keeps tracking the team's
  code, or keeps its own fork of it from now on.
- *Under review:*  **The final project's AI policy.**  Last year's final project
  planning (`doc/PastProjects/2025-2026/`) had students write a plan, then refine
  it in dialogue with Codex under stated rules and checkpoints.  Does the
  project phase keep that shape?
- Open from the handoff:  whether the course runs (sign-ups are short), the
  Canvas course ID, and what happens to `doc/FlintLessons/`.

### 2026-11-10 - the rails

> *"after the and then is up in the air right now and we'll continue writing in
> the future.  We have enough context now to get started and lay our rails
> toward the big goals.  and also keep ourselves on the tracks as we develop
> that \"and then ...\" in the future."*

- `README.md` was rewritten from Jason's context, replacing the rejected draft.
  It holds where the course ends, the four patterns, the settled opening, an
  open "And then...", and a "Staying on the rails" checklist.  Each item on
  that checklist comes from a decision logged above.
- The rejected draft's laptop-test idea and its Java 8 notes stay in this file
  as findings.  Neither is in the new plan, since neither came from Jason.

### 2026-11-10 - lesson submodules

> *"Much like the OODP course, we'll keep it flexible in the class time.
> **we make the road by walking** after all ;)  Here's a structual
> instruction:  Much like the OODP course has a series of Submodules for the
> first half of the course to focus on instructive things with rolled-back
> versions of the live repo.  Let's do that here as well."*

- *Approved:*  The first half of the course runs on lesson submodules, the way
  OODP's does.  Each lesson is its own repository, holding a rolled-back version
  of the live robot code that is focused on what that lesson teaches.
- How OODP does it, for reference:  `OODP_Lessons/.gitmodules` registers
  `Lesson01_FirstObjects` through `Lesson08_Identity`, each a small repo under
  `cox-programming-classes` on GitHub, several with a `Teacher` branch.
- *Under review:*  how the lesson repos here get made.  The proposal was sent
  to Jason before any repo was created.

> *"Yes, for the first half of the course, the lesson starter code should come
> from a fresh starter code repo.  Post midterm (that is a content term not a
> date-time term) we should be up todate enough to be working in the live repo
> with confidence.  The overview lesson should get a simplified version o fthe
> repo that does not have any of the Autonomous nested classes and nothing that
> relies on those, no StateMachines, and no higher level Control Strategies.
> (though it should have the IControlStrategy in the MechComponent
> unimplemented in the inciting incident for that lesson which might not be
> lesson 1)"*

- *Approved:*  Lesson repos in the first half start with fresh history, from a
  starter, not a clone of the live repo.
- *Approved:*  "Midterm" is a point in the content, not a date.  After it,
  students work in the live repo.
- *Approved:*  The overview lesson's repo is simplified:  no `Autonomous...`
  nested classes and nothing that depends on them, no state machines, and no
  control strategies above the component level.

> *"Reading B is the correct interpretation.  and the inciting incident should
> come up in lesson 2.  Lesson 1 will be primarily reading and should include a
> basic robot that works in the Dumbest of dumb control setups."*

- *Approved:*  The Lesson 1 repo has dumb components.  Each one defines its own
  controls in `move(gamepad)`.  `MechComponent` declares `IControlStrategy`,
  and nothing implements it yet.
- *Approved:*  Lesson 1 is mostly reading, and includes a basic robot that
  works with the dumbest possible control setup.
- *Approved:*  The inciting incident (every instance reacts to "A") comes in
  Lesson 2.  Under Reading B it happens in the same starter code, so Lesson 2
  needs no new repo to set it up.

### 2026-11-10 - the Lesson 1 starter, first version

Built at `Lesson01_RobotObjectModel/`:  a fresh `git init` on `main` with no
remote, files staged and not yet committed, and not yet registered as a
submodule.  It compiles and `assembleDebug` builds the robot-controller APK.

What it holds:  `FtcRobotController/`, the Gradle files, `libs/`, and a
simplified `TeamCode/`.  `doc/`, `scripts/`, `.github/`, and `Course/` stay
out.

What was cut:  all of `AutonStrategies/`; `IState`, `AngleExtensions`,
`ThreadExtensions`, `TurnDirection`, `LimelightExtensions`; every
`Autonomous...` nested class and `getAutonomous...` method; `MacroManager`,
`IRobotStrategy`, `IAssistRobotStrategy`, `IAssemblyStrategy`, the Robot-level
`IControlStrategy`; the Limelight and IMU in `BillyRobot` and the IMU in
`MecanumDrive`; `OneStickTank`'s `LeroyState`; the auton OpMode.  The RED and
BLUE Billy TeleOps were the same apart from a tag ID, and became one `Billy`.

Choices Claude made that Jason should check:

- *Under review:*  **Which buttons each dumb component hard-codes.**  Each one
  took the lambda it had in the live code.  `DoublyLimitedMotor`:  left stick
  Y, so both of `CascadeArm`'s lifts ride the left stick.  `SpinnyIntake`:  A/B
  (from `ExampleIntakeAssembly`; Billy's used the d-pad).  `Claw`:  bumpers
  (from `ExampleIntakeAssembly`; `CascadeArm`'s used A/B), so the claw and
  intake on `OneStickTankRobot` don't collide.  `Turret`:  bumpers.
  `PusherServo`:  X.  `DoubleShooter`:  Y, with the d-pad trimming power.
  Billy's turret and the claw share the bumpers, but no robot has both.
- *Under review:*  **Telemetry strategies were cut too.**  They're strategies,
  so each component's `update()` now hard-codes its readout.
- *Under review:*  **All four robots stayed.**  `StandardTankRobot` is the
  dumbest-of-dumb robot.  `Wildbots2025` carries the Lesson 2 incident.
  `OneStickTankRobot` and Billy are reading material.
- *Under review:*  **Comments were trimmed, not rewritten.**  Susan Zuo's
  telemetry credits stay.  TODOs that pointed at cut code were shortened to
  what's still true:  `Claw`, `Turret`, and the mecanum sign bug.  The
  `RobotBuilder`, field-relative drive, IMU-ownership, and assembly-sensor
  TODOs were removed, because each depends on cut code.
- The lesson's `README.md` is a placeholder.  The lesson text is Jason's.

**Integration note, for building on this machine:**  `JAVA_HOME` points at a
Java 8 JRE, and Gradle needs 17+.  Build with Android Studio's bundled JDK:
`JAVA_HOME="/c/Program Files/Android/Android Studio/jbr"`.  An earlier report
in this session that the live repo compiled was wrong.  That build had failed
on the JDK, and the "exit 0" came from a trailing `echo`.  With the right JDK
the live repo compiles.

### 2026-11-10 - starters carry only what the lesson needs

> *"in the starter code lessons, we should strip out all the unnecesary code
> tthat isn't relevant to the lesson at hand.  That'll mean generating a new
> standard base-bot (for early lessons, let's use a TankDrive robot and use
> Standard vs OneStick as a way to re-view polymorphism)  That robot should
> have  very simple mech assembly with no duplicated components to hold off the
> Strategy problem.  For continuity it should probably be a single DLM and a
> claw.  That way when we add a second joint in lesson 2 to the arm
> (introducing the CascadeArm as the inciting incident and the Strategy problem
> as the solution"*

- *Approved:*  Each starter strips out all the code that isn't relevant to its
  lesson.  This replaces the first version above, which kept all four robots.
- *Approved:*  Early lessons use a new standard base bot with a tank drive.
  `StandardTankDrive` against `OneStickTank` reviews polymorphism.
- *Approved:*  The base bot's mech assembly is one `DoublyLimitedMotor` and one
  `Claw`.  With no duplicated components, the Strategy problem stays hidden.
- *Approved:*  Lesson 2 adds a second joint to the arm.  That makes it the
  `CascadeArm`, which is the inciting incident, and Strategy is the solution.

> *"Let's just let Telemetry live as a low level thing that we just accept and
> keep upgrading at each layer.  Telemetry is core.  And it is a thing folks
> just need to accept.  It is the equivalent of Console.WriteLine in C#"*

- *Approved:*  Telemetry is core plumbing, the course's `Console.WriteLine`.
  It isn't a topic.  Every layer has it, and it gets upgraded as layers are
  added.
- Applied in the starters:  telemetry strategies stay cut, and each
  component's `update()` writes its own readout.  The live code's long
  telemetry-refactor Javadocs (bug numbers, the two-phase-init rationale) are
  cut down to one-line comments in the starters, with Susan Zuo's
  `@author` credit kept on the base classes.  *Under review:*  whether that
  trim goes too far.

**The Lesson 1 starter, second version.**  Rebuilt to that spec, in the same
folder, still uncommitted and unregistered.  It assembles.  `TeamCode/` is now
13 Java files:  `Robot`, `DriveTrain`, `MechAssembly`, `MechComponent`;
`StandardTankDrive`, `OneStickTank`; `DoublyLimitedMotor`, `Claw`; the new
`Arm` and `BaseBot`; two OpModes; `GamepadExtensions`.  Every other robot,
drive train, assembly, and component was removed.

Choices Claude made that Jason should check:

- *Under review:*  **The drive train is handed in.**  `BaseBot(hardwareMap,
  telemetry, driveTrain)`.  The two OpModes, `Base Bot (Standard Tank)` and
  `Base Bot (One Stick)`, differ in one line, the drive train they pass.  The
  alternative was two Robot subclasses, the way the live code has
  `StandardTankRobot` and `OneStickTankRobot`.
- *Under review:*  **Names.**  `BaseBot` for the robot; `Arm` for the assembly,
  with its motor field called `lift`.
- *Under review:*  **Hardware names carry over from `CascadeArm`**
  (`cascadeMotor`, `topLiftLimit`, `bottomLiftLimit`), so the arm's first joint
  keeps its configuration when Lesson 2 adds the second.  The claw is `claw`.
- *Under review:*  **Controls.**  The lift is on gamepad 2's left stick and the
  claw on its bumpers.
- `MechComponent`'s TODO that listed the live components by category was cut,
  since none of them are here.  The rule above it stays.  `Claw`'s paragraph
  about the duplicate `Turret` was cut too.

### 2026-11-10 - the snapshot moves to `ReferenceCopy/`

> *"Lets move it to inside the Course folder since we have a copy of the
> current live code (it is not a live copy, just a snap shot from today and
> that's ok).  Or should we move the existing code that was pre-existing in
> this project to a \"Reference-Copy\" folder?  I don't want having gradle
> projects at different folder layers to get confusing."*

Claude recommended the reference folder, because the root was itself a Gradle
project, and anything placed under it, `Course/` included, would sit inside
that project.  Jason:  *"go for it"*.

- *Approved:*  The robot code in this repo is a snapshot from 2026-11-10, not a
  live copy.
- *Approved:*  `ReferenceCopy/` holds the snapshot:  `FtcRobotController/`,
  `TeamCode/`, the Gradle files and wrapper, `libs/`, the FTC `README.md`,
  `LICENSE`, the team's `doc/`, and `scripts/` (which updates
  `doc/game-manual/` and finds it relative to itself).  Moved with `git mv`, so
  history follows the files.  It compiles from its new place.
- The root now holds only siblings:  `Course/`, `ReferenceCopy/`, the lesson
  starter repos, `.github/`, and `.gitignore`.  No Gradle project is inside
  another.  This matches OODP, where `Course/`, the lessons, and the reference
  game sit side by side.
- `.github/workflows/check-competition-manual.yml` now points at
  `ReferenceCopy/scripts/` and `ReferenceCopy/doc/`.  It's team tooling, and
  it won't run until the repo is on GitHub.  *Under review:*  keep it, or
  delete it.
- `HANDOFF.md` still names the old paths.  It stays as written, as the record
  of how the repo started.
- This settles the open question about pulling from the team repository:  the
  path move means `git pull robotics master` will no longer merge cleanly, and
  that's fine for a snapshot.
- *Under review:*  where students work after the midterm.  Jason said *"we
  should be up todate enough to be working in the live repo with confidence"*.
  Is that `ReferenceCopy/`, a fresh copy of the team's code, or the team
  repository itself?

### 2026-11-10 - Lesson 1 registered as a submodule

> *"each time we build a new starter code, we should right away set it up as a
> submodule.  But (as we learned in the OODP projcet) you can't set the orgin
> manually ... I've had to ask you to clear the origin you set and let GitHub
> Desktop do that part.  But also down the road when I clone *this* repo, it
> has trouble pulling the sub modules... so if you left instructions for how to
> do that correctly from the command line, I'd appreciate that."*

- *Approved:*  Every new starter is registered as a submodule as soon as it
  exists.
- *Approved:*  No remote is ever set inside a lesson repo.  GitHub Desktop's
  Publish sets it.
- Done:  `Lesson01_RobotObjectModel` got its first commit (`544fe38`) and was
  registered with `git submodule add`, URL
  `https://github.com/cox-programming-classes/Lesson01_RobotObjectModel.git`.
  Checked afterward:  no remote inside the lesson repo, and it's on `main`.
- `Course/SUBMODULES.md` has the command-line steps for cloning with
  submodules, pulling later, making a new starter, publishing from GitHub
  Desktop in the right order, and a table of the usual failures.
- *Under review:*  the `cox-programming-classes` organization was assumed from
  OODP.  After publishing, check `.gitmodules` against where it actually went.

### 2026-11-10 - on GitHub, public, CC BY-NC-SA

> *"Yes, please create the parent repo.  These can be public though, my class
> materials are open source.  (please add a CC license that is non-comercial
> share alike)"*

- *Approved:*  The parent and the lesson repos are public, in
  `cox-programming-classes`.  Created with `gh repo create`.
- *Approved:*  Course materials are licensed CC BY-NC-SA 4.0.  `LICENSE` in
  each repo is the official legal text, downloaded from creativecommons.org.
- The FTC SDK keeps *FIRST*'s BSD license:  `ReferenceCopy/LICENSE` in the
  parent, and `LICENSE-FIRST` (moved there unchanged) in each lesson starter.
  Each README says which license applies to what.  Third-party files in
  `ReferenceCopy/doc/` (the game manual, LEGO's license) keep their own terms.
- The clone command is at the top of the root `README.md`, so it travels with
  the repository and shows on its GitHub page.
- *Under review:*  the robot code in `TeamCode/` was written by students.  The
  team repository it came from is public under BSD-3-Clause-Clear.  Whether
  the CC license covers their code, or only Jason's materials, is Jason's call
  and possibly the school's.

### 2026-11-10 - first round of lesson planning, and the pipeline

> *"both of those are fine.  I don't think the .github workflow is working
> correctly but I'm not interested in fixing that right now.  Let's start the
> first round of lesson planning and and build the pipeline for translating
> into Canvas+Flint+Textbook.  We'll practice on Lesson 1 (probably at least 4
> class periods) and review before we build Lesson 2"*

- *Approved:*  The student code stays under the CC license as is, and the
  workflow stays as it is for now.  Jason doesn't think it works, and isn't
  fixing it yet.
- *Approved:*  Build the pipeline from lesson plan to Canvas, Flint, and the
  textbook, practicing on Lesson 1.  Lesson 1 runs at least 4 class periods.
  Review it all before Lesson 2.
- On the pinned conversation about earlier runs:  *"I don't have written
  lesson plans from the previous iterations of this course. Sorry.  I am only
  able to write these things down effectively now with your help lol"*.  So
  what earlier runs taught lives in Jason's head and in the code.  It comes out
  lesson by lesson, as each one gets planned, and goes into that lesson's
  teacher notes.  This replaces the pin.
- A recurring course theme, from the Lesson 1 dialogue:  *"\"Layers of
  Abstraction\" will be a recurring theme, it's a real onion and we'll keep
  peeling back the layers...... not the same layers as the layers of
  abstraction... maybe they are the same?...."*  Whether the course's onion
  and the model's layers are the same thing is left open on purpose.  Lesson
  planning dialogue lives in `Course/lessons/lesson_NN_planning_notes.md`.
- Tools on this computer:  pandoc 3.13; Python 3.14 through the `py` launcher
  (`python` itself isn't on the path); Word; Windows PowerShell 5.1, no
  PowerShell 7.

### 2026-11-10 - the chapter pipeline, first piece

- `Course/chapters/PROCESS.md`, adapted from OODP's:  Java for C#, Gradle and
  the robot for the console, a reading-first Lesson 1, and the style guide in
  `ClaudeWritingProject/style-guide/`.
- `Course/reference/build_chapter.lua`, copied from OODP with only its
  configuration changed:  series and book title "Algorithmic Thinking",
  Chapter 1 split into four meetings, and a working book tagline from Jason's
  own words, *"We make the road by walking."*  His to change.
- Output goes to `Course/chapters/build/word/` and `build/canvas/`, which git
  ignores (`build/`).  Rebuild on any computer with pandoc 3.
- Still to come, after Chapter 1 is reviewed:  the Flint prompt, and the
  Canvas manifest.  The printed book waits for more chapters.

### 2026-11-11 - the book's subtitle

> "We make the road by walking" can't be the subtitle lol.  That's a whole
> different book ;)  Calling what we are doing "Functional Programming" is
> also a bit of a stretch though since Java (or at least the version we are
> stuck with) doesn't have a good way to represent a lot of the concepts we
> really want:  First Class Functions, etc.  even Extensions are done
> sideways.  Let's have the subtitle reference the FIRST Tech Challenge
> context of the course

- *Approved:*  the subtitle names FIRST Tech Challenge, and stays clear of
  "Functional Programming."
- *Under review:*  the wording.  Claude's working version is *Design Patterns
  for FIRST Tech Challenge Robots*, since the course is a patterns course.
- *Approved (2026-11-11):*  "excellent I like this subtitle."

### 2026-11-11 - Appendix 1, the FTC SDK

> Let's do a little work on a reference section.  In the Processing-Sprite
> course project also found in the GitHub folder, we have Apendixes built
> there with a Library reference.  We should provide a detailed reference for
> the FTC base code as one apendix, lets build that right now

- *Approved:*  scope is the FTC SDK (not the team's Robot Object Model), and
  the audience is *"everyone, teachers and students both need the
  reference"*, so it gets a Canvas page as well as a Word file.
- `Course/chapters/appendix_1_ftc_sdk.md`, modeled on Processing-Sprite's
  `reference_api.md`:  six parts, sections A1.1 to A1.15, ending in Known
  issues.  Covers every SDK class the starter and `ReferenceCopy/` use.
- Verified against the SDK 12.0.0 jars in the Gradle cache with `javap`
  (signatures) and `javap -c` (behaviors).  Findings worth carrying into
  lessons:  `...WasPressed()` is consumed by its first reader (Lesson 2's two
  components on one gamepad);  `Telemetry`'s `" : "` separator doubles the
  starter's trailing-colon captions;  `Limelight3A.getLatestResult()` returns
  an empty result, so the team's null check never fires;  `CRServo` extends
  `DcMotorSimple`;  `LinearOpMode` is a Template Method.
- *Under review:*  two items are marked to confirm on a robot:  how the Driver
  Station shows the `get` exception, and the doubled-colon display.

### 2026-11-11 - Appendix 1, the rest of the toolbox

> lets add documentation to the FTC SDK appendix for the other Objects even
> the ones we don't have used in the reference code.  Especially Sensors.
> Kids can't know how to add a tool if they don't know that it exists~

- *Approved:*  a new Part Six, "The rest of the toolbox" (A1.15 to A1.28):
  how to add a device, distance, color, digital, analog, and voltage sensors,
  odometry (Pinpoint, OTOS, OctoQuad), other IMUs, webcams and the
  VisionPortal (AprilTag, color blob, predominant color), HuskyLens, extended
  servos and the SPARK Mini, lights, the hubs and bulk reads, and the older
  Modern Robotics sensors.  Known issues moved to Part Seven (A1.29), with
  five new rows.
- Inventory from the SDK 12.0.0 jars;  signatures from `javap`, behaviors from
  `javap -c`.  Code lines quoted from FIRST's own sample OpModes in
  `ReferenceCopy/FtcRobotController/.../external/samples/`, which compile
  against this SDK, and each section names its sample.  One example (the
  potentiometer) is ours, and says so.
- New finds:  in 12.0.0, AprilTag detections split into single and cluster
  types, and only a single tag has an `id`;  the REV 2m distance sensor ignores
  `distanceOutOfRange`;  the REV touch sensor reads `false` when pressed as a
  `DigitalChannel`;  bulk caching is `OFF` by default.

### 2026-11-11 - Appendix 2, the Limelight 3A

> Limelight3A definitely needs a whole appendix of its own because it is a
> complicated onboard computer of its own

> we should update the documentation to the 12.0.0 version

- *Approved:*  `Course/chapters/appendix_2_limelight.md`, A2.1 to A2.18:  two
  computers (what runs where, setup, pipelines);  the driver (lifecycle,
  background polling, commands);  `LLResult` (validity checks, the main
  target, timing, the five target lists, finding one tag);  poses, MegaTag1
  and 2, field maps;  Python, status, calibration, snapshots;  known issues.
  Appendix 1's A1.11 points to it.
- Source:  the team's notes in `ReferenceCopy/doc/limelight3a/`, re-verified.
  The published 11.2.1 and 12.0.0 source archives were diffed:  every
  Limelight file, and `Pose3D`, `Position`, `YawPitchRollAngles`, and
  `Quaternion`, are identical.  Camera-side facts (setup, the web page,
  firmware keys) are from Limelight's documentation, and the appendix says so.
- The team's notes now say 12.0.0, with honest dates:  researched 2026-09-12
  against 11.2.1, re-verified 2026-11-11 against 12.0.0.  This changes
  `ReferenceCopy/`, which is a snapshot;  the competition repository's copy of
  those notes still says 11.2.1.
- The Aside on streams and `Optional` (A2.11) is factual only:  what the code
  does, and its C# equivalents.  Where the course takes `Optional` further is
  Jason's call, and the appendix leaves it there.

### 2026-11-11 - the Prologue

> Lets also build an intro section similar to the other books as well

- `Course/chapters/chapter_00_prologue.md`, on the frame of the OODP and
  Processing-Sprite prologues:  what the book is, where it came from, how a
  chapter runs, how to read one, the marks.
- Built from Jason's own words in this file and nothing else.  The tagline,
  *"The common language of humans and robots,"* is from his explanation of the
  title.  The "appendix" passage is his "biological appendix."  The secret
  goal stays out:  the prologue asks whether the complexity is worth it, and
  leaves the answer to the course.
- *Under review:*  three **[For Jason]** gaps:  the course's history, homework,
  and the Flint helper's name and rules.
- *Approved (2026-11-11):*  "We don't need to talk about the politics of
  course naming."  The first trim (keeping the appendix joke) was "still
  bad."  Now the paragraph is one plain line on Java, and the book doesn't
  mention "Functional Programming" at all.

### 2026-11-11 - `ReferenceCopy/` becomes the `TeamRepo/` submodule

> Can we swap out the ReferenceCopy snapshot with a sub-module link to the live
> competition repo?

This reverses the 2026-11-10 decision that the robot code here is a snapshot.
Jason, on the branch:  *"I've merged the textbook into master~"*.

- *Approved:*  `TeamRepo/` is a submodule of
  `the-winsor-school/WinsorRobotics26-27`, following `master`.  The folder
  name is Jason's choice, season-neutral, so next season only the URL changes.
- *Approved:*  the 12.0.0 Limelight notes were committed in the team repo
  (`1ace5a2`, on `master` and `textbook`), and `TeamRepo/` points at that
  commit.  Jason's uncommitted Field Guide edits there were left alone.
- `ReferenceCopy/` was removed;  its history stays in this repo's log.
- `.github/workflows/check-competition-manual.yml` was deleted, which settles
  its *Under review* from 2026-11-10.  It maintains the team's game-manual
  mirror, the team repo runs its own copy, and this repo can't commit inside a
  submodule.
- Repointed:  both `README.md` files, `SUBMODULES.md` (with a new section on
  moving `TeamRepo/` forward and swapping seasons), Appendix 1, and Appendix 2.
- *Under review:*  whether this answers the 2026-11-10 question of where
  students work after the midterm.
- Open:  the team's `master` is eight commits ahead of GitHub.  It has to be
  pushed before this repo is, or a clone can't fetch `TeamRepo/`.

### 2026-11-11 - Appendix 1, encoders

> We need another thing in the reference section:  How to use Encoders, both
> those attached to motors and using an encoder that is not built into the
> motor itself (i.e. an encoder attached to a shaft that is on the output end
> or a shaft driven by a servo as oopsed to the dcmotor spindle itself)

- *Approved (by request):*  a new Part Seven, Encoders, in Appendix 1:  A1.29
  the encoder in a motor (ticks per turn from the SDK's motor types, direction,
  resetting, ticks to inches), A1.30 `RUN_USING_ENCODER` and `RUN_TO_POSITION`,
  A1.31 encoders of their own (on a motor port's connector, on a servo-driven
  shaft with the loop in code, absolute encoders, the OctoQuad), A1.32 choosing
  one.  Known issues moved to Part Eight, A1.33, and its cross-references
  followed.  Six new known-issue rows.
- Checked in SDK 12.0.0's compiled code:  `REVERSE` negates position,
  velocity, and targets;  `RUN_TO_POSITION` uses the power's absolute value;
  setting power with no target throws `TargetPositionNotSetException`;
  `isBusy()` is `false` outside `RUN_TO_POSITION`;  the default tolerance is 5,
  sent with the next target;  `RUN_USING_ENCODER` scales power by the motor
  type's top speed;  the SDK resets no encoders between OpModes;  the goBILDA
  5202/3/4 type is one entry at 2786 ticks;  an unconfigured motor gets
  TETRIX's 1440;  four motor ports per hub.
- The team's code reads an encoder in one place (`SpinnyIntake`'s
  telemetry), so this part is toolbox, like Part Six.  Three examples are
  ours, with invented labels, and say so:  ticks per arm degree, reading an
  external encoder, and a proportional loop for a servo-driven shaft.
- That proportional loop is the course's first feedback controller, in an
  appendix.  Jason:  *"The servo example might come up as a lesson, I haven't
  planned that far, but it is one I want to do.  If we write a lesson on PID,
  it will go there."*
- *Under review:*  a lesson on PID, built from the servo-driven shaft in
  A1.31.  Wanted, not yet placed in the sequence.

## What's next

1. Jason reviews the new `README.md`.
2. Continue the sequence past `IControlStrategy`, in conversation.
3. The pinned conversation about earlier runs of the course, before any lesson
   plans get written.
4. `GUIDING_PRINCIPLES.md` comes later, from Jason's reasoning, once there is
   enough of it on record.
