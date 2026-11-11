# Lesson 1 - The Robot Object Model

*"What the hell is this thing?"*

**Five meetings.**  Starter:
[`Lesson01_RobotObjectModel/`](../../Lesson01_RobotObjectModel/), branch
`main`.

**Drafted 2026-11-10, before class,** from
[`lesson_01_planning_notes.md`](lesson_01_planning_notes.md), where Jason's
words for every decision here are quoted.  Anything marked **[For Jason]** is
a gap he hasn't filled yet, or a reading of Claude's that he hasn't confirmed.

The plan is meant to bend.  Nothing said in class gets recorded, so when a
meeting goes differently, the plan changes to match what Jason brings back.

---

## Where we are

The first lesson of the course.  Students arrive from the fall C# course with
objects, interfaces, composition, and enough polymorphism for "Billy *is a*
Robot" and "Billy *has a* mecanum drive train."  Some are on the robotics team
and some aren't, so nothing here assumes the game, the hardware, or the team's
code.

Java shows up for the first time in Meeting 3, and only after the model is in
place without it.

---

## The One New Idea

**The parts on a robot exist as conceptual entities too, arranged in layers
from the most general (the Robot) to the most concrete (the components), and
the configuration is where the physical and the conceptual meet.**
---

## Learning Goals

Students will be able to:

1. Break a robot into its drive train and its mech assembly, and the assembly
   into its components, from the hardware alone.
2. Explain how the configuration on the Driver Station labels the hardware
   plugged into the Control Hub and the Expansion Hub, and predict what happens
   when a label is misspelled.
3. Follow `hardwareMap` from the OpMode down to every `hardwareMap.get(...)`,
   and match each one to a configuration label.
4. Name the four layers of the model, and the abstract job of each.
5. Tell an abstract class from a concrete one:  a `DriveTrain` *must* drive; a
   `StandardTankDrive` has two motors and knows how to use them.
6. (Meeting 5)  Explain why swapping `StandardTankDrive` for `OneStickTank` is
   one line of code, what that line depends on, and what the choice between
   the two drive trains trades.  (It's a flavor, a driver's preference.)

Meeting 5 is hazy on purpose for now.

---

## New Vocabulary

| Term | Meaning, the way this lesson uses it |
|---|---|
| Driver Station | the app the drivers hold, with the gamepads plugged in |
| Control Hub, Expansion Hub | the boxes on the robot the motors, servos, and sensors plug into |
| Configuration | the list on the Driver Station that gives each plugged-in device a label |
| `HardwareMap` | the Java side of the configuration:  code asks it for a device by its label |
| OpMode | the program the Driver Station runs; where the code starts |
| layer of abstraction | one level of the model, from the most general to the most concrete |
| `Robot`, `DriveTrain`, `MechAssembly`, `MechComponent` | the four layers |
| abstract class | says what something *must* do, and leaves the how to a concrete class |
| concrete class | an actual thing that does it |
| polymorphism | (Meeting 5) one slot, many things that fit it |

**Held back on purpose:**  `IControlStrategy` and the Strategy pattern (Lesson
2), autonomous code, and state machines.  Telemetry is in every file.
Students accept it and move on:  it's this course's `Console.WriteLine`.

---

## What's in the starter

A tank-drive base bot with a one-joint arm.  Every component defines its own
controls.

| File | What it is |
|---|---|
| `OpModes/BaseBotStandardTankTeleOp.java` | builds a `BaseBot` with a `StandardTankDrive`, then loops |
| `OpModes/BaseBotOneStickTeleOp.java` | the same, with a `OneStickTank`.  Held back for Meeting 5 |
| `RobotModel/Robots/Robot.java` | the most general layer.  Exactly one drive train (`final`, never null); maybe a mech assembly |
| `RobotModel/Robots/BaseBot.java` | a `Robot` with an `Arm` |
| `RobotModel/DriveTrain/DriveTrain.java` | abstract:  must `drive(gamepad)` |
| `RobotModel/DriveTrain/Tank/StandardTankDrive.java` | two motors, one stick each |
| `RobotModel/DriveTrain/Tank/OneStickTank.java` | two motors, one stick for both |
| `RobotModel/Mechs/Assemblies/MechAssembly.java` | abstract:  must pass instructions to its components |
| `RobotModel/Mechs/Assemblies/Arm.java` | one `DoublyLimitedMotor` (the lift) and one `Claw` |
| `RobotModel/Mechs/Components/MechComponent.java` | abstract:  must `move(gamepad)` |
| `RobotModel/Mechs/Components/DoublyLimitedMotor.java` | a motor between two limit switches; left stick |
| `RobotModel/Mechs/Components/Claw.java` | a continuous servo; the bumpers |
| `Extensions/GamepadExtensions.java` | dead zones, and the flipped y-axis |

Configuration labels the starter asks for:  `leftTread`, `rightTread`,
`cascadeMotor`, `topLiftLimit`, `bottomLiftLimit`, `claw`.

`MechComponent` declares an empty `IControlStrategy`, and nothing uses it.
Leave it alone until Lesson 2.

---

## Meeting 1 - What is this thing?

No code today.  Meetings 1 and 2 are one long opening, and the split between
them falls wherever the room gets to.

### The cold open

A robot on the table, with a simple mechanism on top.  On the board:

> **What the hell is this thing?**

Students break it into logical components.  The clue that cracks it, with
some prompting:  **two game controllers means at least two jobs.**  The
standard setup:  gamepad 1 drives the robot (the drive train), and gamepad 2
runs the mechanism (the mech assembly).

### What's the same?  What's different?

A second robot, with a different drive train and a different mech assembly.
One tank drive and one mecanum drive, because that's the most visual,
functionally stark difference.  Any two robots work, FTC or not.

The game:  **what's the same, and what's different?**

The same column is the model's shape:  every robot has a drive train, and
maybe a mechanism.  The different column is what fills each slot.

### The visual object model

Draw the robot as its parts.  Jason draws it from scratch on the board.  The
form is a simplified UML diagram:  boxes and arrows, with no properties and no
behaviors.  A version already exists and can be regenerated, for handouts and
the chapter.  It comes back every lesson, until students see it in their
dreams.

**[For Jason:  where the existing diagram lives, or how you regenerate it.]**

---

## Meeting 2 - The configuration

Still no code.

### Physical things are conceptual things

Each part on the robot also exists as a conceptual entity, and each one is
defined in a specific place.

### The configuration is the bridge

The configuration, set up on the Driver Station, gives a label to each piece
of hardware plugged into the Control Hub and the Expansion Hub.  Every label
maps directly to one physical device.

1. **It works.**  Jason's starter configuration, loaded and running.  The
   robot drives, and the arm moves.
2. **It breaks.**  Change one label in the configuration and Init again.  It
   fails on Init, in the Driver Station app.

**[For Jason:  confirm the exact message on the robot.  In SDK 12.0.0,
`hardwareMap.get(...)` throws an `IllegalArgumentException` that reads
`Unable to find a hardware device with name "leftTread" and type DcMotor`.
Quote whatever the Driver Station actually shows.]**

### Where this leaves them

The label is the name that code will ask for.  That's the door into Meeting 3.

**[For Jason:  how Meeting 2 ends, and anything they carry into Meeting 3.]**

---

## Meeting 3 - Down the layers, and back up

Code starts here, at the OpMode.

### `hardwareMap` is the Java side of the configuration

Open `BaseBotStandardTankTeleOp`.  `hardwareMap` is already there, inherited
from `LinearOpMode` and filled in from the configuration that's running.

### Down:  follow `hardwareMap`

Trace it through the concrete implementation, one constructor at a time:

```
BaseBotStandardTankTeleOp
  -> new StandardTankDrive(hardwareMap)    get "leftTread", "rightTread"
  -> new BaseBot(hardwareMap, ...)
       -> new Arm(hardwareMap)
            -> new DoublyLimitedMotor(...)  get "cascadeMotor", "topLiftLimit", "bottomLiftLimit"
            -> new Claw(...)                get "claw"
```

Every `get` at the bottom asks for a label from Meeting 2.

### Up:  name the layers

On the way back up, name each layer and its abstract meaning.

| Layer | Its abstract meaning |
|---|---|
| `MechComponent` | the lowest layer:  where commands go to hardware |
| `MechAssembly` | has components, or sub-assemblies.  Can be wildly complex, inside the model's boundaries |
| `DriveTrain` | in parallel:  a special case of a component that never belongs to an assembly |
| `Robot` | the most general layer.  Has exactly one drive train, maybe a mech assembly, and doesn't care what either one is concretely |

### Abstract and concrete

A `DriveTrain` *must* drive.  That's abstract behavior.  A `StandardTankDrive`
has two motors and knows how to use them.

"Exactly one drive train" is in the code, too.  `Robot` takes its drive train
in its constructor, stores it in a `final` field, and refuses `null`.  Java has
no `required`, so `final` plus `Objects.requireNonNull` is as close as it gets.

**Hold back:**  the one-line swap to `OneStickTank`.  It waits for Meeting 5.

---

## Meeting 4 - Review, and the class's turn

The layers are a brain melter, so this meeting goes back over them.  Then the
class gets a chance to add their input to the process.

A free-form discussion, with **no script and no record.**  Expect a lot of
confusion between the abstract robot model and its concrete implementations.
The likely forms of it are under Teacher Notes.

---

## Meeting 5 - One line

`BaseBotOneStickTeleOp` differs from `BaseBotStandardTankTeleOp` in one line:
the drive train it hands to `BaseBot`.  Swapping it is easy to do without
thinking.  This meeting is for thinking about it deeply.

**[For Jason:  the questions and the activity.]**

**[For Jason:  a decision before this meeting.  `StandardTankDrive` sets the
right motor to `REVERSE`, and `OneStickTank` doesn't set a direction at all.
On the same robot, the one-line swap drives one tread backward.  Fix
`OneStickTank` in the starter, or keep it as the discovery:  the swap compiles
and runs, and the robot spins.]**

---

## Homework

**[For Jason:  whether homework applies to this lesson, and the cap.  OODP's
rule was fifteen minutes a night, with every lesson opening fresh.  Not yet
confirmed for this course.]**

---

## Teacher Notes

### Pacing

Meetings 1 and 2 are one opening, and they may run long.  It's a lot, and it's
essential.  If the opening takes more than two meetings, push everything
else back:  code shouldn't start before the model is in place.

### Before Meeting 1

- Two robots:  one tank drive with a simple mechanism, one mecanum drive with
  a different mechanism.
- **Props for "components":**  at least a loose motor, or a disembodied
  jointed component assembly.  Something a student can hold that is one
  component and nothing else.
- A starter configuration on the Driver Station for the tank robot, with the
  labels the starter asks for.  **[For Jason:  if the tank robot isn't the
  base bot, Meeting 3's trace needs a robot whose labels match the code.]**

### Confusions to expect in Meeting 4

Claude's guesses, for Jason to keep, cut, or replace:

- "Where's the Robot's motor?"  `Robot` has no hardware of its own; everything
  it moves belongs to a layer below.
- "`DriveTrain` is a class, so why can't I make one?"  An abstract class says
  what something must do, and only a concrete one can be built.
- `BaseBot` against `Robot`:  which one is "the robot"?
- Why the drive train isn't part of the mech assembly, when both have motors.
- A label in the configuration against a variable name in Java:  which one
  has to match what?

### Errors you'll actually see

- A misspelled configuration label stops Init.  The message is still to be
  confirmed on the robot (see Meeting 2).

### Hold these back

- `IControlStrategy` and every strategy (Lesson 2).
- Two of the same component.  `Arm` has exactly one `DoublyLimitedMotor` on
  purpose.  Lesson 2 adds a second joint, making it the `CascadeArm`, and both
  lifts move on the same stick.  That's the inciting incident.
- The one-line drive train swap, until Meeting 5.
- Telemetry, as a topic.
