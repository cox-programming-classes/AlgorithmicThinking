# Chapter 1 - The Robot Object Model

*"What the hell is this thing?"*

---

Last semester you built a game in C#, one type at a time.  This semester the
thing you're programming already exists, and it's sitting on the table.  It has
motors, wires, a battery, and a code base that students before you have been
writing for years.

So this chapter starts with the robot, and the code waits.  For the first two
meetings there's no Java at all.  You'll take a robot apart in your head, find
the pieces every robot shares, and see where the physical robot and the code
meet.  The code comes in Part Three, once you have a picture of what it's
describing.

| Part | Meeting | What you do |
|---|---|---|
| One | 1 | break a robot into its parts, and draw them |
| Two | 2 | follow the parts into the configuration, and break one |
| Three | 3 | follow the configuration into the code, down the layers and back up |
| Four | 4 | look back over the layers, and bring your questions |

---

# Part One - What is this thing?

## 1.1  Two controllers, two jobs

There's a robot on the table.  Before anyone tells you what it is, work it out.
What does it do?  What are its parts?  Which parts work together?

Look at how it's driven.  There are two game controllers.  Two controllers means
at least two jobs, done by two people, on one robot.

The standard setup:

| Controller | Its job |
|---|---|
| gamepad 1 | drives the robot around:  the **drive train** |
| gamepad 2 | runs the mechanism on top:  the **mech assembly** |

> **Answer in your notes.**  Draw the robot on the table.  Circle the drive
> train in one color and the mech assembly in another.  Then find every motor
> and servo you can, and say which job each one belongs to.

## 1.2  What's the same, and what's different

Now a second robot, with a different drive train and a different mechanism.  One
of the two robots drives on treads or plain wheels, a **tank drive**.  The other
has **mecanum** wheels, with rollers set at an angle, so it can slide sideways
without turning.

Play the game:  what's the same, and what's different?

> **Answer in your notes.**  Make two columns, *Same* and *Different*.  Fill
> them in for these two robots.

Look at what ended up in each column.  The *Same* column is the shape every robot
shares:  a drive train, run from gamepad 1, and usually a mechanism, run from
gamepad 2.  The *Different* column is what fills those slots on this particular
robot.  A tank drive and a mecanum drive are both drive trains.  An arm and a
launcher are both mechanisms.

## 1.3  The model, drawn

Here is that shape as a diagram.  Each box is a kind of thing, and each arrow
means "has":

```
            +---------+
            |  Robot  |
            +---------+
             |       |
          has 1   has 0 or 1
             v       v
  +------------+   +--------------+
  | DriveTrain |   | MechAssembly |
  +------------+   +--------------+
                          |
                       has some
                          v
                  +---------------+
                  | MechComponent |
                  +---------------+
```

A **component** is the smallest part that does one thing:  a single motor, a
servo, a motor with the switches that stop it.  A **mech assembly** is a group
of components that work together.  A robot has exactly one drive train, and it
may or may not have a mech assembly.

You'll see this diagram again, often.

> **Answer in your notes.**  Draw the diagram for each of the two robots, with
> the real parts filled in:  what kind of drive train, and which components are
> in each mech assembly.

---

# Part Two - The configuration

## 1.4  Physical things are conceptual things

Every part on the robot is a physical thing you can point at.  Each one also
exists as an idea:  *the left tread motor*, *the claw*, *the switch at the top
of the lift*.  The robot's code works with the ideas.  So somewhere there has
to be a list that connects each idea to the physical part it means.

## 1.5  The configuration

Every motor, servo, and sensor plugs into a port on one of two boxes on the
robot:  the **Control Hub** or the **Expansion Hub**.  The **Driver Station**,
the app the drivers hold, keeps a **configuration**:  a list that gives every
plugged-in device a **label**.

The configuration for this chapter's base bot uses six labels:

| Label | What it's plugged into |
|---|---|
| `leftTread` | the left drive motor |
| `rightTread` | the right drive motor |
| `cascadeMotor` | the motor that runs the arm's lift |
| `topLiftLimit` | the switch at the top of the lift |
| `bottomLiftLimit` | the switch at the bottom of the lift |
| `claw` | the claw's servo |

Each label maps to exactly one device, in one port.

> **Check.**  With the starter configuration active, choose **Base Bot
> (Standard Tank)** on the Driver Station, press Init, then Start.  Gamepad 1's
> sticks drive the two treads.  Gamepad 2's left stick runs the lift, which
> stops at each switch, and its bumpers open and close the claw.

## 1.6  Break one

Now change one label in the configuration.  Misspell `leftTread`, save, and
press Init again.

> **Answer in your notes.**  What does the Driver Station show?  Copy the
> message exactly.  Which label did it name?

The robot couldn't find a device it was told to look for.  Hold on to that.  The
label is the name the code asks for, and Part Three finds where it asks.

---

# Part Three - Down the layers, and back up

## 1.7  Start at the OpMode

The Driver Station runs **OpModes**.  The one you chose in 1.5 is this file, in
`TeamCode/src/main/java/org/firstinspires/ftc/teamcode/OpModes/`:

```java
@TeleOp(name = "Base Bot (Standard Tank)", group = "Base Bot")
public class BaseBotStandardTankTeleOp extends LinearOpMode
{
    Robot robot;

    @Override
    public void runOpMode() throws InterruptedException
    {
        robot = new BaseBot(hardwareMap, telemetry, new StandardTankDrive(hardwareMap));

        telemetry.addLine("initialized");
        telemetry.update();

        waitForStart();

        // run until the end of the match (driver presses STOP)
        while (opModeIsActive())
        {
            robot.update(gamepad1, gamepad2);
            robot.updateTelemetry();
        }
    }
}
```

Everything before `waitForStart()` happens when you press Init.  The loop runs
after Start, until Stop.

> **Aside:  Java, as a C# reader sees it**
>
> - `extends LinearOpMode` is C#'s `: LinearOpMode`.  Java says `extends` for a
>   class and `implements` for an interface.
> - `@TeleOp(...)` is an **annotation**, Java's version of a C# attribute like
>   `[TeleOp(...)]`.  It's how the Driver Station finds this OpMode and the name
>   it shows.
> - C# makes you write the `override` keyword.  Java's `@Override` is an
>   optional annotation:  it asks the compiler to check that the method really
>   does override one.
> - `throws InterruptedException` declares an exception this method can let
>   escape.  C# has no equivalent.  Leave it in.

`hardwareMap`, `telemetry`, `gamepad1`, and `gamepad2` are never declared in
this file.  `LinearOpMode` hands them down, already filled in.

**`hardwareMap` is the Java side of the configuration.**  When you press Init,
the SDK reads the active configuration and builds `hardwareMap` from it, label
by label.

> **Aside:  telemetry**
>
> `telemetry` sends text to the Driver Station's screen.
> It's in nearly every file, and it does what C#'s `Console.WriteLine` did for
> you last semester.  Accept it and move on.

## 1.8  Follow `hardwareMap` down

The OpMode hands `hardwareMap` to two constructors.  Follow it.

**Into the drive train.**  `RobotModel/DriveTrain/Tank/StandardTankDrive.java`:

```java
public StandardTankDrive(HardwareMap hardwareMap)
{
    left = hardwareMap.get(DcMotor.class, "leftTread");
    right = hardwareMap.get(DcMotor.class, "rightTread");
    right.setDirection(DcMotorSimple.Direction.REVERSE);
}
```

There are the first two labels from the configuration.

> **Aside:  `DcMotor.class`**
>
> `DcMotor.class` is C#'s `typeof(DcMotor)`.  `hardwareMap.get`
> takes the kind of device and its label, and hands back that device.

**Into the robot.**  `RobotModel/Robots/BaseBot.java`:

```java
public BaseBot(HardwareMap hardwareMap, Telemetry telemetry, DriveTrain driveTrain)
{
    super(telemetry, driveTrain);
    mechAssembly = new Arm(hardwareMap);
    initializeSubsystems();
}
```

`BaseBot` passes it on to its mech assembly.  `RobotModel/Mechs/Assemblies/Arm.java`:

```java
public Arm(HardwareMap hardwareMap)
{
    lift = new DoublyLimitedMotor(
            hardwareMap,
            "cascadeMotor",
            "topLiftLimit",
            "bottomLiftLimit");
    claw = new Claw(hardwareMap, "claw");
}
```

And `Arm` passes it to its components, along with their labels.  At the bottom,
in `DoublyLimitedMotor`:

```java
motor = hardwareMap.get(DcMotor.class, motorName);
forwardSensor = hardwareMap.get(TouchSensor.class, forwardSensorName);
reverseSensor = hardwareMap.get(TouchSensor.class, reverseSensorName);
```

and in `Claw`:

```java
servo = hardwareMap.get(CRServo.class, servoName);
```

Every `hardwareMap.get` asks for one label from the configuration.  In 1.6 you
misspelled one, and the `get` that asked for it found nothing.

> **Answer in your notes.**  Draw the path `hardwareMap` takes, from the OpMode
> to every `get`.  Write the label beside each `get`.  Check that all six labels
> from 1.5 are there.

## 1.9  Back up:  name the layers

The path you just drew has levels to it.  Going down, each level is more
specific than the one above it.  Coming back up, name each one, and what it's
for.

| Layer | What it's for |
|---|---|
| `MechComponent` | the lowest layer, where commands actually go to hardware |
| `MechAssembly` | has components, or smaller assemblies.  It can get as complex as the mechanism needs |
| `DriveTrain` | beside the assemblies:  a special kind of component that never belongs to an assembly |
| `Robot` | the most general layer.  It has one drive train, and maybe a mech assembly, and doesn't care what either one is |

These are the **layers of abstraction**, and they're the diagram from 1.3.  The
code's classes are named for the boxes.

Here's the top layer doing its whole job, in `Robot.java`:

```java
public void update(Gamepad gamepad1, Gamepad gamepad2)
{
    driveTrain.drive(gamepad1);
    if (mechAssembly != null) mechAssembly.giveInstructions(gamepad2);
}
```

Two controllers, two jobs.  `Robot` hands gamepad 1 to whatever drive train it
has, and gamepad 2 to whatever mech assembly it has.

## 1.10  Abstract and concrete

Open `RobotModel/DriveTrain/DriveTrain.java`:

```java
public abstract class DriveTrain
{
    public abstract void drive(Gamepad gamepad);
```

A `DriveTrain` *must* drive.  That's all this class says about driving.  It
doesn't say how, because it can't:  driving a tank and driving a mecanum robot
are different jobs.

Now `StandardTankDrive`, from 1.8.  It has two motors, and it knows how to use
them:

```java
@Override
public void drive(Gamepad gamepad)
{
    float leftDrive = GamepadExtensions.GetLeftStickY(gamepad);
    float rightDrive = GamepadExtensions.GetRightStickY(gamepad);
    left.setPower(leftDrive);
    right.setPower(rightDrive);
}
```

`DriveTrain` is **abstract**:  it says what something must do.
`StandardTankDrive` is **concrete**:  it's an actual thing that does it.  You
can build a `StandardTankDrive`.  You can't build a `DriveTrain`, any more than
you can buy "a vehicle" without buying some particular one.

> **Aside:  `abstract`**
>
> `abstract` means the same thing in Java as in C#.

The rule "a robot has exactly one drive train" is in the code, too.  In
`Robot.java`:

```java
protected final DriveTrain driveTrain;
```

```java
protected Robot(Telemetry telemetry, DriveTrain driveTrain)
{
    this.telemetry = telemetry;
    this.driveTrain = Objects.requireNonNull(driveTrain, "A Robot must have a DriveTrain.");
}
```

> **Aside:  `final`, and the missing `required`**
>
> A `final` field must be
> given its value exactly once, in the constructor, or the class won't compile.
> It's close to C#'s `readonly`.  C# also has `required`, to make a caller
> supply a value.  Java has no such keyword, and `final` still lets a caller
> pass `null`.  So the constructor checks for `null` itself, with
> `Objects.requireNonNull`.

> **Argue it.**  `Robot`'s field is typed `DriveTrain`, the abstract class.
> What does `Robot` gain by not knowing which drive train it has?  What does it
> give up?

---

# Part Four - Looking back

Four layers, two of them abstract in a way you can't hold in your hand, and a
robot on the table that's concrete all the way down.  Expect this to take more
than one pass.  This meeting is for going back over it, together, and for your
questions.

> **Answer in your notes.**  Before class, write down the one thing about the
> layers that still doesn't make sense to you.  Bring it.

## Chapter summary

| You looked at | It's an example of |
|---|---|
| two controllers, two jobs | the drive train and the mech assembly, separated |
| the same/different columns | what every robot shares, and what fills each slot |
| the configuration's labels | the bridge between the physical robot and the code |
| `hardwareMap.get(DcMotor.class, "leftTread")` | code asking for a device by its label |
| `Robot`, `DriveTrain`, `MechAssembly`, `MechComponent` | layers of abstraction |
| `DriveTrain` against `StandardTankDrive` | an abstract class and a concrete one |
| `final` plus `requireNonNull` | a rule of the model, enforced in code |

### New syntax in this chapter

| Java | C# you already know | Met in |
|---|---|---|
| `class A extends B` | `class A : B` | 1.7 |
| `@TeleOp(...)` | an attribute, `[TeleOp(...)]` | 1.7 |
| `throws InterruptedException` | none | 1.7 |
| `DcMotor.class` | `typeof(DcMotor)` | 1.8 |
| `final` field | `readonly` field | 1.10 |
| `Objects.requireNonNull(x, "...")` | `ArgumentNullException.ThrowIfNull(x)` | 1.10 |

### Vocabulary

| Term | Section |
|---|---|
| abstract class | 1.10 |
| concrete class | 1.10 |
| configuration | 1.5 |
| Control Hub, Expansion Hub | 1.5 |
| drive train | 1.1 |
| Driver Station | 1.5 |
| `hardwareMap` | 1.7 |
| label | 1.5 |
| layers of abstraction | 1.9 |
| mech assembly | 1.1 |
| mech component | 1.3 |
| OpMode | 1.7 |

### Check your understanding

1. A robot has two controllers.  What does each one run?
2. Name something that's the same about every robot, and something that
   differs from robot to robot.
3. What is a configuration label, and where in the code is one used?
4. You misspell `claw` in the configuration.  Which line of code is the first
   to notice?
5. Put the four layers in order, from most general to most concrete, and say
   what each is for.
6. Why can't you build a `DriveTrain`?
7. Why is `Robot`'s `driveTrain` field `final`, and why does the constructor
   still check it for `null`?

## What's next

The base bot's arm has one joint.  In the next lesson it gets a second one, and
the code for the arm has to tell the two joints apart.
