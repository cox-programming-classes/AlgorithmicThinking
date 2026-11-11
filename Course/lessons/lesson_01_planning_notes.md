# Lesson 1 - Planning Notes

The dialogue the Lesson 1 plan gets built from.  Jason's words are quoted and
dated.  Claude's readings of them are marked as readings.  The plan itself
(`lesson_01_robot_object_model.md`) gets drafted from this file and reviewed
before anything is built from it.

## What's settled from the course notes

- Lesson 1 is mostly reading, and runs at least 4 class periods.
- It opens with an overview of the Robot Object Model, using concrete objects:
  is-a ("Billy *is a* Robot") and has-a ("Billy *has a* mecanum drive train").
  The abstract layer and the higher strategies stay out.
- The starter is the base bot:  a tank drive (`StandardTankDrive` or
  `OneStickTank`, which serve as the polymorphism review) and an `Arm` of one
  `DoublyLimitedMotor` and one `Claw`.  Every component hard-codes its own
  controls.
- Telemetry is accepted, never taught.
- The inciting incident (every instance reacts to the same button) waits for
  Lesson 2.

## 2026-11-10 - the cold open

> *"Day one cold open is a robot sitting on the table with a simple mech on top
> and  a question \"What the hell is this thing\"  and then ask the students to
> break it down into logical components.  with some prompting they should be
> able to understand that since there are two game controllers, there are at
> least two different jobs being done on the one robot.  we use the standard
> setup that gamepad1 is the drive-train and gamepad2 is the mech assembly.
> Then they look at another robot that has a different drive train and
> different mech assembly and have to play \"waht is the same?\" and \"what is
> different?\""*

- Day one starts with a physical robot, not code.  The question on the board:
  "What the hell is this thing?"
- Students break the robot into logical components.  The clue that cracks it:
  two game controllers means at least two jobs.  Gamepad 1 drives (the drive
  train).  Gamepad 2 runs the mechanism (the mech assembly).
- Then a second robot, with a different drive train and a different mech
  assembly.  The game:  what's the same, and what's different?

Claude's reading, to check:  the same/different list is where `Robot`,
`DriveTrain`, and `MechAssembly` come from.  What's the same across both
robots is the shape; what's different is which drive train and which
mechanism fills each slot.  That's is-a and has-a, discovered from hardware
before anyone opens a file.

## 2026-11-10 - the two robots, and no code yet

> *"which two robots doesn't matter, they might not even be FTC robots.  One
> should probably be a tank drive and one a mecanum drive train though since
> that's the most viusal and functionally stark example.  No code yet at all.
> Day 1 might not even see code at all.  We need a conceptual model before we
> subject these poor children to the horrors of Java"*

- Any two robots will do, FTC or not.  One tank drive and one mecanum drive,
  because that's the most visual and functionally stark difference.
- No code at the start.  Day 1 might see no code at all.  The conceptual model
  comes first.

> *"code will probably show up day 2"*

- Code probably arrives on day 2.

## 2026-11-10 - what day 1 has to leave them with

> *"Day 1 they need to have at least the visual object model and the
> undrstanding the things that exist on the robot physically also exist as
> concepual entities that are defined in certain places.  and the
> \"Configuration\" that is set up via the Driver Station defines labels that
> map directly to the physical hardware that is plugged into the Control Hub
> and Expansion Hub on the Robot itself.  (this physical-conceptual starter
> might actughtlly take 2 class periods... it's a lot and it is also essential
> understanding)"*

By the end of the physical-conceptual opening, students have:

1. **The visual object model:**  the robot drawn as its parts.
2. **Physical things are also conceptual things.**  Each part on the robot
   exists as a conceptual entity, defined in a specific place.
3. **The Configuration is the bridge.**  The configuration set up on the Driver
   Station gives labels to the hardware plugged into the Control Hub and the
   Expansion Hub.  Each label maps directly to one physical device.

This opening may take **two class periods**.  It's a lot, and it's essential.
That probably pushes code to day 3.

Claude's reading, to check:  the configuration labels are what code reaches
for later.  `hardwareMap.get(DcMotor.class, "leftTread")` in
`StandardTankDrive` asks for the device labeled `leftTread`.  So when code
arrives, the first link students can make is between a string in the code and
a label they set up, or looked at, on the Driver Station.

## 2026-11-10 - the working config, then breaking it

> *"I will prepare a starter config so they can see one working and executing
> correctly, then change something in the config and see it fail.  (the
> failure mode for a mis-spelled label in the Config is a Crash with a
> NullReferenceException on Init in the driver station app.)"*

- Jason prepares a starter configuration.  Students see it work and run
  correctly.
- Then a label gets changed in the configuration, and students watch it fail.
  The failure shows up on Init, in the Driver Station app.

**Checked against the SDK, 2026-11-10 (Claude):**  in FTC SDK 12.0.0,
`hardwareMap.get(DcMotor.class, "leftTread")` with no device by that name
throws an `IllegalArgumentException` (the strings in `RobotCore`'s
`HardwareMap.class` are `Unable to find a hardware device with name "%s" and
type %s`).  So a misspelled label in the base bot should stop Init with:

```
Unable to find a hardware device with name "leftTread" and type DcMotor
```

A `NullPointerException` (Java's name for C#'s `NullReferenceException`)
would come from code that gets back `null` instead, such as
`hardwareMap.tryGet(...)`.  The base bot uses `get`.  *Under review:*  confirm
on the robot what the Driver Station actually shows, and quote that exact text
in the lesson, the chapter, and the Flint prompt.

## 2026-11-10 - where code starts

> *"when code arrives, we will start at the OpMode level and the HardwareMap is
> the Java side of the Robot Config"*

- Code starts at the OpMode.
- `HardwareMap` is the Java side of the robot configuration.

Claude's reading of the starter, to check:  in `BaseBotStandardTankTeleOp`,
`hardwareMap` is a field the OpMode inherits from `LinearOpMode`, already
filled in from the active configuration.  The OpMode hands it to `BaseBot` and
to `new StandardTankDrive(hardwareMap)`.  `BaseBot` hands it to `Arm`, and
`Arm` hands it to `DoublyLimitedMotor` and `Claw`.  At the bottom, each one
calls `hardwareMap.get(...)` with a label from the configuration.  Following
`hardwareMap` from the OpMode down to each `get` walks the whole object model,
one layer at a time.

## 2026-11-10 - the layers of abstraction

> *"once we have the hardwareMap and have demonstrated what happens when you
> mislabel a component, we'll start looking into the Robot Model in code.
> introduce the Layers of Abstraction.  The Robot is the most general layer.
> It has a Drive Train and a Mech Assembly, but it doesn't actually care what
> either of those are concretely.  similarly a mech assembly has components
> (or possibly sub-assemblies).  Components are the lowest layer where you
> actually give commands to hardware.  In parallel, the drive train is
> basically a special case of a Component that cannot be a member of an
> Assembly.  (A robot has exactly one drive train; A robot may or may not have
> a mech assembly, and a mech assembly can be wildly complex within the
> boundaries of the robot model.   This is also an opportunity to talk in
> deeper detail about the philosophical difference between an Abstract class
> and a concrete implementation of that class.   A DriveTrain *must* drive
> (abstract behavior).  A StandardTankDrive has 2 motors and knows how to use
> them."*

After `hardwareMap` and the mislabeled-component demo, the Robot Model in
code, as **layers of abstraction**:

| Layer | What it is |
|---|---|
| `Robot` | the most general layer.  It has a drive train and a mech assembly, and doesn't care what either one is concretely. |
| `MechAssembly` | has components, or possibly sub-assemblies.  It can be wildly complex, within the boundaries of the model. |
| `MechComponent` | the lowest layer:  where commands actually go to hardware. |
| `DriveTrain` | in parallel:  basically a special case of a component that can't belong to an assembly. |

The rules:  a robot has **exactly one** drive train.  A robot **may or may
not** have a mech assembly.

And the deeper point:  **abstract class against concrete implementation.**
A `DriveTrain` *must* drive:  that's abstract behavior.  A `StandardTankDrive`
has two motors and knows how to use them.

Claude's observation, to check:  the starter's `Robot` doesn't enforce
"exactly one" drive train.  `update()` checks `if (driveTrain != null)` the
same way it checks `mechAssembly`, so a robot with no drive train compiles and
runs.  Either the code changes to match the rule (for example, `Robot`'s
constructor requires a `DriveTrain`), or the gap becomes something students
find.

## 2026-11-10 - meetings 3 and 4

> *"\"Layers of Abstraction\" will be a recurring theme, it's a real onion and
> we'll keep peeling back the layers...... not the same layers as the layers of
> abstraction... maybe they are the same?....   in meeting 3 we will trace the
> hardwareMap down the layers of the concrete implementation and then on our
> way back up we'll name the layers and their abstract meaning.   Day 4, lets
> plan to review that concept cause it is a real brain melter. and then give
> the class a chance for their input into the process.  Day 4 should also
> anticipate a fair amount of confusion with the difference between the
> abstract robot model and the concrete implementations.  And this should be a
> free form discussion that will have no script and no record."*

- **Meeting 3:**  trace `hardwareMap` *down* through the layers of the concrete
  implementation.  On the way back *up*, name each layer and its abstract
  meaning.
- **Meeting 4:**  review the layers, because it's a brain melter.  Then give
  the class a chance to add their input to the process.  Expect a lot of
  confusion between the abstract robot model and its concrete implementations.
  A free-form discussion:  **no script, and no record.**
- "Layers of abstraction" is a recurring theme for the course.  Jason, on
  whether the onion's layers and the abstraction layers are the same thing:
  *"not the same layers as the layers of abstraction... maybe they are the
  same?...."*  Left open on purpose.

## 2026-11-10 - polymorphism waits, the drive train is required, no record

> *"1) lets save the polymorphism in code for later.  Don't want to melt too
> many brains too fast.  Swaping the drive train is one line of code so it is
> very easy to do without thinking.  we should think about it deeply in day 5.*
> *2) Robot should not allow a null drivetrain, that is an outstanding problem
> in the main distro that is probably solvably by a single added keyword.  In
> C# I would just sneak in a `required` but I don't think that exists in
> filthy Java*
> *3)  \"No Record\" means I'm not recording nor taking notes on what we talk
> about in real time in class.  There is just no way to do that ethically in
> the classroom.  We just have to accept that.  It is why our lesson plans here
> are fluid and have to be adaptable when things go differently in the
> classroom on that day."*

- **Polymorphism in code waits for day 5.**  Swapping the drive train is one
  line, so it's easy to do without thinking.  Day 5 is for thinking about it
  deeply.
- **`Robot` must not allow a null drive train.**  Fixed in the starter
  (see below).  It's also an outstanding problem in the team's code.
- **"No record" means nothing said in class gets recorded or written down in
  real time.**  There's no ethical way to do that in a classroom.  That's why
  these plans stay fluid, and have to adapt when the day goes differently.
  Meeting 4 still gets its place in the plan:  what it's for, and the
  confusions to expect.

**The fix, 2026-11-10 (Claude).**  Java has no `required`.  The nearest single
keyword is `final`:  a `final` field must be assigned exactly once, in the
constructor, or the class doesn't compile.  So `Robot` now takes the drive
train as a constructor argument into a `final` field.  `final` still lets a
caller pass `null`, so the constructor also calls
`Objects.requireNonNull(driveTrain, ...)`, which stops a null at construction
with a clear message instead of a crash later.  The `driveTrain != null`
checks are gone.  `mechAssembly` stays optional.

## 2026-11-10 - Jason's comments on the first draft

Written into the draft plan, then moved here word for word.

On the one new idea:

> *"^^ Good sentence.  Remind me to have other props for \"components\"  I
> should have at least a loose motor or dis-embodied jointed component
> assembly"*

On the learning goals:

> *"This is a good list.  Meeting 5 is hazy on purpose at this point and
> that's OK.  Ultimately that one should end with understanding the
> choice/tradeoff between the two drive trains (which really is just a flavor
> or preference.)"*

On the visual object model:

> *"The simplified UML diagram (no proproerties no behaviors, just boxes with
> arrows) exists, and can be re-generated easily.  I will also definitely draw
> it from scracth on the board, and after a few weeks the students should be
> seeing it in their dreams at night."*

And on what comes next:

> *"Ok, I've wrtten some comments along the way.  Lets work from this for now.
> And we'll come back to it once we have some hard copy lessons down."*

- *Approved:*  the one new idea, as drafted.
- *Approved:*  the learning goals.  Meeting 5 ends on the trade-off between
  the two drive trains, which is a flavor, a driver's preference.  It stays
  hazy for now, on purpose.
- *Approved:*  the visual model is the simplified UML diagram:  boxes and
  arrows, no properties, no behaviors.  Jason draws it from scratch on the
  board.  It recurs until students dream about it.
- Prep:  props for "components", at least a loose motor or a disembodied
  jointed component assembly.
- Next:  build the hard-copy lesson materials from this draft.  Come back to
  the plan once they exist.

## 2026-11-10 - Chapter 1, first draft (Claude)

`Course/chapters/chapter_01_robot_object_model.md`, built with
`pandoc lua Course/reference/build_chapter.lua 01` into four Word files and four
Canvas pages, one per meeting (Parts One to Four).  Meeting 5 has no part yet,
because the plan leaves it hazy.

Every code excerpt is copied from the starter at `7fd7854`.  Unverified, until
Jason sees it on a robot:

- **1.5's Check:**  what the base bot does under the starter configuration
  (sticks drive the treads, the lift stops at each switch, the bumpers run the
  claw).  It's read from the code.
- **1.6:**  the misspelled-label message.  The chapter asks students to copy
  whatever the Driver Station shows, and quotes nothing.

Choices for Jason to check:

- *Under review:*  **1.3's diagram is ASCII**, standing in for the simplified
  UML diagram Jason already has.  Swap in the real one once we know where it
  lives.
- *Under review:*  **Part Four** asks students to write down, before class, the
  one thing about the layers that still doesn't make sense.  That's homework
  of a kind, and homework is still open.
- *Under review:*  **The Asides compare Java to C#** at each first use:
  `extends`, annotations, `@Override`, `throws`, `.class`, `final`, and
  `Objects.requireNonNull` against `ArgumentNullException.ThrowIfNull`.
- *Under review:*  **1.10 explains "abstract" with an analogy**, buying "a
  vehicle" without buying a particular one.  It's Claude's.
- The tagline is Jason's cold-open line.

## The shape so far

| Meeting | What happens |
|---|---|
| 1-2 | A robot on the table:  "What the hell is this thing?"  Two controllers, two jobs.  A tank and a mecanum robot:  what's the same, what's different.  The visual object model.  Physical parts as conceptual entities.  The Configuration working, then broken by a misspelled label.  No code. |
| 3 | Code starts at the OpMode.  `hardwareMap` is the Java side of the configuration.  Trace it down through the concrete layers; name each layer and its abstract meaning on the way back up. |
| 4 | Review the layers.  The class's input into the process.  An open discussion, unscripted and unrecorded, ready for confusion between the abstract model and the concrete code. |
| 5 | Polymorphism in code, thought through deeply:  `StandardTankDrive` against `OneStickTank`, the one-line swap. |

## Open

- Where the Standard vs. One Stick swap goes (the polymorphism review):
  meeting 3, on the way back up, or somewhere else?
- `Robot` allows a null drive train, against "exactly one."  Fix the code, or
  leave it for students to find?
- Does meeting 4 get any student-facing page at all (a chapter section, a
  Canvas page, a Flint session), given "no record"?
- What does the conceptual model look like when students have it?  A drawing,
  a diagram on the board, a list, their own words?
- How does day 1 end, and what do students carry into the next meeting?
- When code does arrive, what's the first thing they look at?
