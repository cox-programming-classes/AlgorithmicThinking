# Appendix 1 - The FTC SDK

*The library under every OpMode, as this course uses it.*

---

Every robot in this course runs on the FIRST Tech Challenge SDK, the library
FIRST publishes for the Control Hub.  Students' code sits in `TeamCode/`.  The
SDK is everything underneath it:  the `FtcRobotController` app, and the
libraries it pulls in when Gradle builds the project.  Parts One to Five
document every piece of the SDK that the course's code touches, in the starter
for each lesson and in the team's code in `TeamRepo/`.  Part Six covers
the rest of the toolbox:  the sensors, cameras, and other devices the SDK
supports that the course's code hasn't used yet.  You can't reach for a tool
until you know it exists.

It's for everyone.  Students can look up a method here when a chapter uses it
without stopping to explain it, or when a robot needs a sensor it doesn't have
yet.  Teachers get the inside of the box:  what each call actually does, and
the rough edges, in Part Eight.

**Version 12.0.0.**  Every signature below was read out of the SDK 12.0.0
libraries with `javap`, the tool that lists what a compiled Java class contains.
Every behavior described below was checked in the compiled code itself.  What
can only be confirmed on a robot is marked **to confirm on a robot**.  FIRST's
own documentation, for everything this appendix leaves out, is at
`ftc-docs.firstinspires.org`, and the full Javadoc is at
`javadoc.io/doc/org.firstinspires.ftc`.

This appendix has eight parts.

| Part | What it covers |
|---|---|
| One | **The shape of the SDK.**  Where it is, and the family tree of its devices. |
| Two | **OpModes.**  `LinearOpMode`, and the annotations that put an OpMode on the Driver Station. |
| Three | **`HardwareMap`.**  How code finds a device by its configuration label. |
| Four | **Devices.**  Motors, servos, the touch sensor, the IMU, and the Limelight camera. |
| Five | **The driver's side.**  `Gamepad`, `Telemetry`, and `ElapsedTime`. |
| Six | **The rest of the toolbox.**  Distance, color, analog, and voltage sensors, odometry, cameras, lights, extended servos, and the hubs themselves. |
| Seven | **Encoders.**  The encoder in a motor, letting the hub use it, and encoders on shafts of their own. |
| Eight | **Known issues.**  Every rough edge found, and what to do about it. |

---

# Part One - The shape of the SDK

## A1.1  Where it is

The SDK arrives in packages.  The course uses five of them.

| Package | What's in it |
|---|---|
| `com.qualcomm.robotcore.eventloop.opmode` | `LinearOpMode`, `OpMode`, and the annotations `@TeleOp`, `@Autonomous`, `@Disabled` |
| `com.qualcomm.robotcore.hardware` | `HardwareMap`, `Gamepad`, and the device interfaces:  `DcMotor`, `Servo`, `CRServo`, `TouchSensor`, `IMU`, and more |
| `com.qualcomm.robotcore.util` | `ElapsedTime`, and `Range` (clipping and scaling numbers) |
| `org.firstinspires.ftc.robotcore.external` | `Telemetry`, `Func`, and `navigation` (`AngleUnit`, `YawPitchRollAngles`) |
| `com.qualcomm.hardware` | the code for particular products:  `rev.RevHubOrientationOnRobot`, `limelightvision.Limelight3A` |

Every import at the top of a course file that starts with `com.qualcomm` or
`org.firstinspires.ftc.robotcore` comes from the SDK.  An import that starts
with `org.firstinspires.ftc.teamcode` is the course's own code.

The `FtcRobotController/` folder is the app itself.  Nobody in this course
edits it.

## A1.2  The family tree

The SDK describes every device with an **interface**, and the device types are
built on one another.

```
HardwareDevice      (every device a configuration can name)
 |
 +-- DcMotorSimple  (setPower, getPower, setDirection)
 |    |
 |    +-- DcMotor   (adds encoders, run modes, and braking)
 |    |    |
 |    |    +-- DcMotorEx  (adds velocity and current)
 |    |
 |    +-- CRServo   (a continuous servo, driven by power)
 |
 +-- Servo          (a position, from 0 to 1)
 +-- TouchSensor    (isPressed)
 +-- DigitalChannel (one true-or-false wire)
 +-- IMU            (the robot's heading)
 +-- DistanceSensor (how far away something is)
 +-- ColorSensor    (red, green, blue, as whole numbers)
 +-- NormalizedColorSensor  (red, green, blue, from 0 to 1)
 +-- VoltageSensor  (the battery)
 +-- AnalogInput    (a voltage on an analog port;  a class)
 +-- Limelight3A    (a camera;  a class)
```

A device can be more than one of these at once.  A color sensor that also
measures distance is a `ColorRangeSensor`, which is a `ColorSensor`, a
`NormalizedColorSensor`, and a `DistanceSensor` all together.  Part Six has the
devices this tree leaves out.

Two things in the tree come back throughout the course.

- **`CRServo` is a `DcMotorSimple`.**  A continuous servo and a motor take the
  same commands, `setPower` from -1 to 1, so the SDK gives them the same
  interface.  Code written against `DcMotorSimple` runs either one.
- **The code names only the interface.**  `hardwareMap.get(DcMotor.class,
  "leftTread")` returns an object of a class inside the SDK, chosen to match the
  hub the motor is plugged into.  `StandardTankDrive` stores it as a `DcMotor`
  and never learns the class.  The Robot Object Model makes the same move one
  layer up:  `Robot` stores a `DriveTrain` and never learns which one.

> **Aside:  `interface` in Java**
>
> A Java interface is a C# interface:  a list of methods a class promises to
> have.  Java says `implements` where C# says `:`, and an interface extends
> another with `extends`, as `DcMotor extends DcMotorSimple` does.  The SDK
> doesn't put an `I` in front of its interface names, so `DcMotor` is an
> interface even though it reads like a class.

---

# Part Two - OpModes

## A1.3  `LinearOpMode`

An OpMode is a program the Driver Station can run.  Every OpMode in this course
extends `LinearOpMode` and supplies one method, `runOpMode()`.

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

`runOpMode()` starts when the driver presses **INIT**.  Everything before
`waitForStart()` is setup, and everything after it is the match.

**What an OpMode inherits.**  Four fields, filled in by the SDK before
`runOpMode()` starts:

| Field | Type | What it is |
|---|---|---|
| `hardwareMap` | `HardwareMap` | the running configuration, for finding devices (Part Three) |
| `telemetry` | `Telemetry` | text for the Driver Station's screen (A1.13) |
| `gamepad1` | `Gamepad` | the first driver's controller (A1.12) |
| `gamepad2` | `Gamepad` | the second driver's controller |

**What it can call.**

| Method | What it does |
|---|---|
| `waitForStart()` | waits until the driver presses **START**, and returns.  If STOP comes first, it returns then. |
| `opModeIsActive()` | `true` after START and before STOP.  When it's `true`, it also gives the rest of the app a moment to run, so a `while (opModeIsActive())` loop never hogs the robot. |
| `isStarted()` | `true` once START has been pressed |
| `isStopRequested()` | `true` once STOP has been pressed |
| `opModeInInit()` | `true` between INIT and START |
| `sleep(long ms)` | pauses for that many milliseconds.  If STOP arrives during the pause, it returns early (A1.33). |
| `idle()` | gives the rest of the app a moment to run |
| `getRuntime()`, `resetRuntime()` | seconds on the OpMode's own clock, and a way to set it back to zero |

**The other kind of OpMode.**  `LinearOpMode` extends `OpMode`, which works
differently.  An `OpMode` supplies five methods, and the SDK calls them in
order:  `init()` once, `init_loop()` until START, `start()` once, `loop()` until
STOP, and `stop()` once.  `LinearOpMode` writes all five itself, marks each one
`final` so no subclass can change them, and hands its subclass `runOpMode()` in
their place.

That arrangement has a name:  the **Template Method** pattern.  A base class
fixes the order of the steps, and each subclass fills in the steps.

## A1.4  The annotations

An annotation puts an OpMode on the Driver Station's list.

| Annotation | What it does |
|---|---|
| `@TeleOp(name = "...", group = "...")` | lists the OpMode under TeleOp, for driver-controlled play |
| `@Autonomous(name = "...", group = "...", preselectTeleOp = "...")` | lists it under Autonomous.  `preselectTeleOp` names the TeleOp to queue up when this one ends. |
| `@Disabled` | takes it off the list, with the code left in place |

Every setting is optional, and each one defaults to `""`.  The team's code has
one `@Autonomous`:  `ExampleStateMachineAuton`.

> **Aside:  annotations and attributes**
>
> A Java annotation is a C# attribute:  `@TeleOp(name = "...")` in Java is
> `[TeleOp(Name = "...")]` in C#.  The SDK reads it when the app starts, and
> builds the Driver Station's list from every class that has one.

---

# Part Three - `HardwareMap`

## A1.5  Finding a device by its label

`hardwareMap` is the Java side of the configuration on the Driver Station.
Code asks it for a device by type and label.

```java
left = hardwareMap.get(DcMotor.class, "leftTread");
right = hardwareMap.get(DcMotor.class, "rightTread");
```

| Method | What it does |
|---|---|
| `get(Class<T> type, String name)` | the device with that label, as that type.  Throws if there isn't one. |
| `tryGet(Class<T> type, String name)` | the same, and returns `null` if there isn't one |
| `get(String name)` | the device with that label, as a plain `HardwareDevice` |
| `getAll(Class<T> type)` | every device of that type, as a `List` |
| `getAllNames(Class<?> type)` | every label for that type |

**What `get` does, step by step.**  It trims spaces off both ends of the name.
It calls `tryGet`.  If `tryGet` finds nothing, `get` throws an
`IllegalArgumentException` with this message:

```
Unable to find a hardware device with name "leftTread" and type DcMotor
```

Two different mistakes produce it.  The label in the code and the label in the
configuration can be spelled differently.  Or the label can be right and the
type wrong:  asking for `"claw"` as a `Servo`, when the configuration says it's
a continuous servo, fails the same way.

How the Driver Station shows the exception is **to confirm on a robot.**

**The older style.**  `HardwareMap` also has a public field for each kind of
device, so `hardwareMap.dcMotor.get("leftTread")` works.  The course uses
`get(DcMotor.class, ...)` everywhere, and most current examples do too.

> **Aside:  `DcMotor.class`**
>
> `DcMotor.class` is Java's version of C#'s `typeof(DcMotor)`:  an object that
> stands for the type itself.  `get` is a **generic method**, so handing it
> `DcMotor.class` makes it return a `DcMotor`, with no cast.

---

# Part Four - Devices

## A1.6  `DcMotorSimple` and `DcMotor`

A `DcMotor` is a motor on a motor port.  It has everything a `DcMotorSimple`
has, and more.

**From `DcMotorSimple`:**

| Method | What it does |
|---|---|
| `setPower(double power)` | -1 is full reverse, 0 is stopped, 1 is full forward.  On a REV hub, anything outside -1 to 1 is clipped to the nearest end. |
| `getPower()` | the power last set |
| `setDirection(Direction d)` | `Direction.FORWARD` or `Direction.REVERSE`.  `REVERSE` flips the sign of every power from here on. |
| `getDirection()` | the direction last set |

`StandardTankDrive` reverses the right motor, so both treads drive forward on a
positive power:

```java
right.setDirection(DcMotorSimple.Direction.REVERSE);
```

`Direction` belongs to `DcMotorSimple`, so it's written
`DcMotorSimple.Direction.REVERSE` even when the variable is a `DcMotor`.

**Added by `DcMotor`:**

| Method | What it does |
|---|---|
| `setZeroPowerBehavior(ZeroPowerBehavior b)` | what the motor does at power 0:  `BRAKE` resists turning, and `FLOAT` coasts |
| `getCurrentPosition()` | the encoder count, in ticks |
| `setMode(RunMode m)` | how the motor uses its encoder (below) |
| `setTargetPosition(int ticks)` | the target for `RUN_TO_POSITION` |
| `isBusy()` | `true` while `RUN_TO_POSITION` is still moving toward its target |

| `RunMode` | Meaning |
|---|---|
| `RUN_WITHOUT_ENCODER` | power goes straight to the motor |
| `RUN_USING_ENCODER` | the hub uses the encoder to hold a steady speed for a given power |
| `RUN_TO_POSITION` | the hub drives to `setTargetPosition`, at the power given |
| `STOP_AND_RESET_ENCODER` | stops the motor and sets the count to zero |

Three more `RunMode` names, `RUN_WITHOUT_ENCODERS`, `RUN_USING_ENCODERS`, and
`RESET_ENCODERS`, are marked deprecated.  They're old spellings.  Use the four
above.

Part Seven covers encoders in full:  ticks per turn, `RUN_TO_POSITION` step by
step, and encoders on shafts of their own.

**`DcMotorEx`** adds a motor's velocity (`setVelocity`, `getVelocity`), its
current draw (`getCurrent`), and tuning for the hub's speed control.  Ask for
one with `hardwareMap.get(DcMotorEx.class, ...)`.  The course's code doesn't use
it yet.

## A1.7  `CRServo`

A continuous-rotation servo spins like a small motor, and the SDK treats it as
one:  `CRServo` extends `DcMotorSimple`, so it has `setPower`, `getPower`, and
`setDirection`, and nothing about position.  Its power is clipped to -1 to 1.

`Claw` drives one from the bumpers:

```java
if(gamepad.left_bumper)
    servo.setPower(1);
else if(gamepad.right_bumper)
    servo.setPower(-1);
else
    servo.setPower(0);
```

A `CRServo` can't report where it is.  The comment at the top of `Claw.java`
lists two sensors that could answer that, and why.

## A1.8  `Servo`

A standard servo turns to a position and holds it.

| Member | What it does |
|---|---|
| `setPosition(double p)` | turns to `p`, from 0 to 1.  Anything outside is clipped. |
| `getPosition()` | the position last set.  The servo has no sensor, so this is the command, and the servo may still be getting there. |
| `scaleRange(double min, double max)` | narrows the range, so 0 to 1 now means `min` to `max` |
| `setDirection(Servo.Direction d)` | `REVERSE` flips the range end for end |
| `MIN_POSITION`, `MAX_POSITION` | 0.0 and 1.0 |

The team's `BillyMA` swings a servo between two positions:  `setPosition(0.8)` and
`setPosition(0.0)`.

## A1.9  `TouchSensor` and `DigitalChannel`

| Member | What it does |
|---|---|
| `TouchSensor.isPressed()` | `true` while the button is pressed |
| `TouchSensor.getValue()` | the same reading as a number |
| `DigitalChannel.getState()` | the raw signal on a digital port, `true` or `false` |
| `DigitalChannel.setMode(DigitalChannel.Mode m)` | `INPUT` to read the port, `OUTPUT` to drive it |

`DoublyLimitedMotor` reads two touch sensors, one at each end of the lift's
travel:

```java
public boolean canGoForward()
{
    return ! forwardSensor.isPressed();
}
```

Whether a touch sensor shows up as a `TouchSensor` or a `DigitalChannel`
depends on the device type chosen in the configuration.

## A1.10  `IMU`

The IMU is a sensor inside the Control Hub that measures how the robot is
turned.  The team's code reads it for the robot's heading.

```java
imu = hardwareMap.get(IMU.class, "imu");
```

| Member | What it does |
|---|---|
| `initialize(IMU.Parameters p)` | tells the IMU how the hub is mounted on the robot |
| `resetYaw()` | makes the current heading zero |
| `getRobotYawPitchRollAngles()` | the robot's yaw (heading), pitch, and roll, as a `YawPitchRollAngles` |
| `YawPitchRollAngles.getYaw()` | the heading, in degrees |
| `YawPitchRollAngles.getYaw(AngleUnit u)` | the heading in `AngleUnit.DEGREES` or `AngleUnit.RADIANS` |

**How the hub is mounted.**  The IMU measures the hub, and the hub can be
bolted on in any orientation.  `initialize` takes the mounting in two
directions:  which way the REV logo on the hub faces, and which way its USB
ports face.

```java
imu.initialize(new IMU.Parameters(new RevHubOrientationOnRobot(
        RevHubOrientationOnRobot.LogoFacingDirection.UP,
        RevHubOrientationOnRobot.UsbFacingDirection.FORWARD)));
```

That example is a hub lying flat, with its USB ports facing the front of the
robot.  The team's code doesn't call `initialize` yet (A1.33).

## A1.11  `Limelight3A`

The Limelight 3A is a camera with its own computer, which finds targets such as
AprilTags and reports what it sees.  This section is the short version.
**Appendix 2** covers the Limelight in full.

```java
limelight = hardwareMap.get(Limelight3A.class, "limelight");
limelight.start();
limelight.pipelineSwitch(0);
```

| Member | What it does |
|---|---|
| `start()`, `pause()`, `stop()` | starts and stops reading results from the camera |
| `pipelineSwitch(int index)` | chooses which of the camera's saved setups (pipelines) runs |
| `isConnected()` | `true` while the camera is talking to the hub |
| `getLatestResult()` | the most recent result, as an `LLResult` |
| `LLResult.isValid()` | `true` when the result has a target in it |
| `LLResult.getTx()`, `getTy()` | how far the target is from the center of the picture, sideways and up, in degrees |
| `LLResult.getTa()` | how much of the picture the target fills |
| `LLResult.getFiducialResults()` | every AprilTag found, as a `List` |
| `LLResult.getStaleness()` | how old the result is, in milliseconds |

**`getLatestResult()` and `null`.**  Before the camera has sent anything,
`getLatestResult()` builds an empty result and returns that, and its
`isValid()` is `false`.  So a `null` check alone can't tell whether the camera
saw anything.  `isValid()` can.

---

# Part Five - The driver's side

## A1.12  `Gamepad`

A `Gamepad` is a snapshot of one controller.  Its readings are public fields,
read directly, with no method call.

| Field | Type | Range |
|---|---|---|
| `left_stick_x`, `left_stick_y`, `right_stick_x`, `right_stick_y` | `float` | -1 to 1 |
| `left_trigger`, `right_trigger` | `float` | 0 to 1 |
| `a`, `b`, `x`, `y` | `boolean` | |
| `dpad_up`, `dpad_down`, `dpad_left`, `dpad_right` | `boolean` | |
| `left_bumper`, `right_bumper` | `boolean` | |
| `left_stick_button`, `right_stick_button` | `boolean` | pressing a stick down |
| `start`, `back`, `guide` | `boolean` | |
| `left_trigger_pressed`, `right_trigger_pressed` | `boolean` | the trigger pulled past 0.5 |

**Pushing a stick up gives a negative `y`.**  The starter's
`GamepadExtensions` flips the sign, so "up" is positive everywhere in the
course's code, and it treats any reading closer to zero than 0.05 as zero, so a
stick that doesn't quite center doesn't creep:

```java
public static float GetLeftStickY(Gamepad gamepad)
{
    if(gamepad == null)
        return 0f;
    // negative to account for inverted y on gamepads!
    return -ApplyDeadZone(gamepad.left_stick_y);
}
```

**PlayStation names.**  A PlayStation controller's buttons are in the same
`Gamepad`, under their own names:  `cross` is `a`, `circle` is `b`, `square` is
`x`, `triangle` is `y`, `share` is `back`, `options` is `start`, and `ps` is
`guide`.  The SDK copies each pair, so either name works on either controller.

**Pressed, once.**  Every button also has a pair of methods that report a
change:  `aWasPressed()` and `aWasReleased()`, `leftBumperWasPressed()`, and so
on.  `aWasPressed()` returns `true` once for each press, the first time it's
called after the press, and `false` after that until the next press.  A field
like `a` is `true` for as long as the button is held, so a loop that toggles
something on `a` toggles it on every pass.  `aWasPressed()` toggles it once.

Reading `aWasPressed()` uses the press up.  A second call in the same loop gets
`false` (A1.33).

**Making it rumble.**  `rumble(int ms)` shakes the controller, and
`setLedColor(r, g, b, ms)` sets a PlayStation controller's light.

## A1.13  `Telemetry`

`telemetry` sends lines of text to the Driver Station's screen.  It's this
course's `Console.WriteLine`.

| Method | What it does |
|---|---|
| `addData(String caption, Object value)` | adds a line:  the caption, then the value |
| `addData(String caption, String format, Object... args)` | the value built with `String.format`, as in `addData("yaw", "%.1f", yaw)` |
| `addData(String caption, Func<T> valueProducer)` | the value comes from a function, called when the message is built |
| `addLine(String text)` | adds a line of plain text |
| `update()` | sends everything added so far |
| `setAutoClear(boolean)` | whether `update()` clears the lines it sent |
| `setMsTransmissionInterval(int ms)` | the least time between two messages |

**Nothing appears until `update()`.**  `addData` adds a line to a message, and
`update()` sends the message.  Each robot class in the course adds its own lines
in `updateTelemetry()` or `update()`, and `Robot` calls `telemetry.update()`
once for the whole robot.

**The defaults, in 12.0.0.**

| Setting | Default | What it means |
|---|---|---|
| auto-clear | on | every `update()` starts the next message empty |
| transmission interval | 250 ms | `update()` sends at most four times a second.  Calls in between keep building the message, and return `false`. |
| caption separator | `" : "` | `addData("power", 0.5)` shows as `power : 0.5` |

> **Aside:  `Func<T>` and lambdas**
>
> `Func<T>` is the SDK's own interface, with one method, `T value()`.  Java
> lets a **lambda** stand in for any interface with exactly one method, so this
> works:
>
> `telemetry.addData("yaw", () -> imu.getRobotYawPitchRollAngles().getYaw());`
>
> C# has a `Func<T>` too, built into the language.  Java has no built-in
> function type, so each library declares its own one-method interface, and
> lambdas fit whichever one a method asks for.

## A1.14  `ElapsedTime`

`ElapsedTime` is a stopwatch.  It starts running the moment it's made.

| Member | What it does |
|---|---|
| `new ElapsedTime()` | a stopwatch, started now |
| `new ElapsedTime(ElapsedTime.Resolution r)` | the same, with `time()` in `SECONDS` or `MILLISECONDS` |
| `reset()` | starts it over from zero |
| `seconds()`, `milliseconds()` | the time since it started, in those units, whatever the resolution |
| `time()` | the time since it started, in the resolution's units:  seconds, unless told otherwise |

The team's `StateMachine` makes one with `Resolution.MILLISECONDS` and then
reads `milliseconds()`, which gives milliseconds with either resolution.

---

# Part Six - The rest of the toolbox

Everything in this part is in SDK 12.0.0 and works on the robots, and the
course's code hasn't used any of it yet.  It's here so that when a robot needs
to sense something, you know what's already built.

## A1.15  Adding a device the course hasn't used

Every device goes in the same way.

1. **Plug it in, and configure it.**  On the Driver Station, add the device to
   the configuration on the port it's plugged into, choose its type from the
   list, and give it a label.  Sensors that talk over **I2C**, a four-wire bus
   for sensors, go on one of the hub's I2C buses.  The type you choose decides
   which Java class the SDK builds for it.
2. **Ask for it.**  In the constructor of the class that owns it, call
   `hardwareMap.get(...)` with its type and label.
3. **Read it in telemetry first.**  Before any code depends on a sensor, put
   its reading on the Driver Station and watch the numbers change as you move
   things in front of it.

**Ask for the interface when one fits.**  A distance sensor can be asked for as
a `DistanceSensor`, whichever brand it is, and then the code works with any
distance sensor.  Ask for the brand's own class only when the device does
something no interface covers, as the goBILDA Pinpoint does.

**Start from FIRST's sample.**  The SDK comes with sample OpModes in
`FtcRobotController/src/main/java/org/firstinspires/ftc/robotcontroller/external/samples/`,
and nearly every device below has one.  Each section names its sample.  To
use one, copy it into `TeamCode/`, change the labels to match your
configuration, and delete its `@Disabled` line.  Every code line quoted in this
part comes from those samples, except one, which says so.

## A1.16  Distance sensors

A `DistanceSensor` reports how far away the nearest thing in front of it is.

| Member | What it does |
|---|---|
| `getDistance(DistanceUnit unit)` | the distance, in `DistanceUnit.MM`, `CM`, `METER`, or `INCH` |

```java
sensorDistance = hardwareMap.get(DistanceSensor.class, "sensor_distance");
```

```java
telemetry.addData("range", String.format("%.01f cm", sensorDistance.getDistance(DistanceUnit.CM)));
```

Devices that are `DistanceSensor`s:

| Device | Class | Notes |
|---|---|---|
| REV 2m Distance Sensor | `Rev2mDistanceSensor` | a laser time-of-flight sensor, for up to about two meters |
| AndyMark time-of-flight sensor | `AndyMarkTOF` | the same chip as the REV 2m |
| REV Color Sensor V3 | `RevColorSensorV3` | measures distance too, over a short range (A1.17) |

**When nothing is in range.**  The interface defines a constant for "out of
range," `DistanceSensor.distanceOutOfRange`, which is the largest number a
`double` can hold.  The REV 2m sensor's `getDistance` passes the chip's own
reading straight through, and that constant plays no part, so out of range is
a large number of millimeters.  Read the sensor in telemetry with nothing in
front of it, and write down what it says.

**The MaxBotix ultrasonic sensor** (`MaxSonarI2CXL`) measures with sound, and
it has its own methods in place of the interface:  `getDistanceSync(unit)`
waits for a fresh reading, and `getDistanceAsync(unit)` returns the last one.

Samples:  `SensorREV2mDistance`, `SensorAndyMarkTOF`.

## A1.17  Color sensors

There are two ways to read color, and most color sensors offer both.

| Interface | Member | What it does |
|---|---|---|
| `NormalizedColorSensor` | `getNormalizedColors()` | red, green, blue, and alpha (overall brightness), each from 0 to 1, as a `NormalizedRGBA` |
| | `setGain(float)` | multiplies the readings, for a dim sensor or a dark object |
| `ColorSensor` | `red()`, `green()`, `blue()`, `alpha()` | the same readings as raw whole numbers, with a range that depends on the sensor |
| `SwitchableLight` | `enableLight(boolean)` | turns the sensor's own light on or off |
| `DistanceSensor` | `getDistance(unit)` | on sensors that measure distance as well |

FIRST's sample reads the normalized colors, and reads distance from the same
sensor by treating it as a `DistanceSensor`:

```java
colorSensor = hardwareMap.get(NormalizedColorSensor.class, "sensor_color");
```

```java
NormalizedRGBA colors = colorSensor.getNormalizedColors();
```

```java
telemetry.addData("Distance (cm)", "%.3f", ((DistanceSensor) colorSensor).getDistance(DistanceUnit.CM));
```

That cast works because the REV Color Sensor V3 is a `ColorRangeSensor`:  one
object, with all three interfaces.  The AndyMark color sensor is one too.

Sample:  `SensorColor`.  A webcam can also act as a color sensor, over a
larger area (A1.23).

## A1.18  Switches, and other digital inputs

A digital port reads one wire, as `true` or `false`.  Anything that's simply on
or off plugs in there:  a touch sensor, a magnetic limit switch, a beam-break
sensor.

| Read it as | Member | What it gives |
|---|---|---|
| `TouchSensor` | `isPressed()` | `true` while pressed (A1.9) |
| `DigitalChannel` | `getState()` | the raw level on the wire |

```java
digitalTouch = hardwareMap.get(DigitalChannel.class, "digitalTouch");
```

```java
if (digitalTouch.getState() == false) {
```

In FIRST's `SensorDigitalTouch` sample, `getState()` is `false` while the
button is pressed:  the REV touch sensor's wire reads low when pushed.  Read as
a `TouchSensor` (`RevTouchSensor`), the same button gives `isPressed()`, which
is the right way up.  For any other switch, check which way it reads in
telemetry.

Samples:  `SensorTouch`, `SensorDigitalTouch`.

## A1.19  Analog inputs

An analog port reads a voltage.  A **potentiometer**, a knob that turns with a
joint, plugs in here and reports the joint's angle as a voltage.

| Member | What it does |
|---|---|
| `getVoltage()` | the voltage on the port |
| `getMaxVoltage()` | the most it can read:  3.3 volts on a REV hub |

```java
AnalogInput pot = hardwareMap.get(AnalogInput.class, "armPot");
double fraction = pot.getVoltage() / pot.getMaxVoltage();
```

That example is ours, with an invented label.  `fraction` runs from 0 to 1
across the knob's travel.

## A1.20  Battery voltage

Every hub measures the battery.  A motor at the same power moves slower on a
tired battery, so code that has to be consistent can scale its power by the
voltage.

| Member | What it does |
|---|---|
| `VoltageSensor.getVoltage()` | the battery's voltage |

Each hub registers its own `VoltageSensor`, with no configuration entry, so
code finds them by type:  `hardwareMap.getAll(VoltageSensor.class)`.  A hub
also reports it directly (A1.27).

## A1.21  Odometry:  where the robot is on the field

A drive train's own encoders lose track when wheels slip.  **Odometry** pods
are small unpowered wheels that roll on the field, with encoders, and a
computer that turns their counts into the robot's position.  The SDK supports
three.

**The goBILDA Pinpoint** reads two pods and its own IMU, and reports an x, a y,
and a heading.

| Member | What it does |
|---|---|
| `update()` | reads everything from the device.  Call it once each time through the loop. |
| `getPosition()` | the position as of the last `update()`, as a `Pose2D` |
| `Pose2D.getX(unit)`, `getY(unit)`, `getHeading(angleUnit)` | the parts of a position |
| `setOffsets(x, y, unit)` | where the pods are, measured from the robot's center |
| `setEncoderResolution(pods)` | which goBILDA pods are fitted:  `goBILDA_4_BAR_POD` or `goBILDA_SWINGARM_POD` |
| `setEncoderDirections(x, y)` | `FORWARD` or `REVERSED`, for each pod |
| `resetPosAndIMU()` | sets the position to zero, and recalibrates the IMU |

```java
pinpoint = hardwareMap.get(GoBildaPinpointDriver.class, "pinpoint");
```

```java
pinpoint.update();
Pose2D pose2D = pinpoint.getPosition();
```

**The SparkFun OTOS** (Optical Tracking Odometry Sensor) needs no pods.  It
watches the floor with an optical sensor, the way a computer mouse does.

| Member | What it does |
|---|---|
| `getPosition()` | the position, as a `SparkFunOTOS.Pose2D` with public fields `x`, `y`, and `h` (heading) |
| `setLinearUnit(unit)`, `setAngularUnit(unit)` | the units it reports in |
| `setOffset(pose)` | where the sensor is, measured from the robot's center |
| `calibrateImu()` | calibrates its IMU.  The robot has to sit still. |
| `resetTracking()` | sets the position to zero |

**The OctoQuad** reads up to eight encoders, for pods or anything else that
turns, and can work out a position from them as well.  `readSinglePosition(n)`
reads one encoder.  A1.31 covers it as an encoder reader.

Samples:  `SensorGoBildaPinpoint`, `SensorSparkFunOTOS`, `SensorOctoQuad`, and
`SensorOctoQuadLocalization`.

## A1.22  Other IMUs

The `IMU` interface in A1.10 covers more than the Control Hub's own sensor.
Each of these is an `IMU`, and takes the same calls:

| Device | Class |
|---|---|
| the IMU inside a Control Hub, older or newer | `LynxEmbeddedBNO055IMUNew`, `BHI260IMU` |
| the REV 9-Axis IMU, an external board | `Rev9AxisImu` |
| the AndyMark IMU | `AndyMarkIMU` |

An external IMU can be mounted anywhere, and the `ImuOrientationOnRobot`
passed to `initialize` describes how.  The **navX-Micro**
(`NavxMicroNavigationSensor`) is older, and has its own methods.

Samples:  `SensorIMUOrthogonal` (a hub mounted square to the robot) and
`SensorIMUNonOrthogonal` (mounted at an angle).

## A1.23  Webcams, and the VisionPortal

A USB webcam plugs into the Control Hub.  The **`VisionPortal`** runs it, and
hands each frame to one or more **processors**, which find things in the
picture.  The processors run on the Control Hub's own computer, where a
Limelight (A1.11) brings a computer of its own.

| Member | What it does |
|---|---|
| `VisionPortal.easyCreateWithDefaults(camera, processors...)` | builds a portal with default settings |
| `new VisionPortal.Builder()` | builds one with chosen settings:  `.setCamera(...)`, `.addProcessor(...)`, `.setCameraResolution(...)`, then `.build()` |
| `setProcessorEnabled(processor, boolean)` | turns one processor on or off, to save the hub's time |
| `stopStreaming()`, `resumeStreaming()` | pauses and restarts the camera |
| `close()` | shuts the camera down |

The webcam is a device in the configuration, and the code asks for it as a
`WebcamName`:

```java
aprilTag = AprilTagProcessor.easyCreateWithDefaults();
```

```java
visionPortal = VisionPortal.easyCreateWithDefaults(
    hardwareMap.get(WebcamName.class, "Webcam 1"), aprilTag);
```

Three processors come with the SDK.

**`AprilTagProcessor`** finds AprilTags, the square black-and-white markers on
the field, and works out where each one is.

| Member | What it does |
|---|---|
| `getDetections()` | every tag in the latest frame, as `AprilTagDetection`s |
| `AprilTagSingleDetection.id` | which tag it is |
| `AprilTagSingleDetection.metadata` | the tag's name and size, from the processor's tag library |
| `AprilTagDetection.ftcPose` | where the tag is from the camera:  `x`, `y`, `z`, `yaw`, `pitch`, `roll`, and `range`, `bearing`, `elevation` |

In SDK 12.0.0, `getDetections()` can return two kinds of detection:  a single
tag (`AprilTagSingleDetection`) or a cluster of tags that share one position
(`AprilTagClusterDetection`).  Only a single tag has an `id`, so FIRST's sample
checks which kind it has before it reads one:

```java
for (AprilTagDetection detection : currentDetections) {
    if (detection instanceof AprilTagSingleDetection) {
        AprilTagSingleDetection singleDet = (AprilTagSingleDetection) detection;
```

A tag missing from the processor's tag library still gets an `id`, and its
`metadata` and `ftcPose` are `null`.  The sample checks `metadata` before it
reads the pose.

> **Aside:  `instanceof`, and the cast**
>
> `detection instanceof AprilTagSingleDetection` is C#'s `detection is
> AprilTagSingleDetection`:  `true` when the object is that type, or a subclass
> of it.  The cast on the next line, `(AprilTagSingleDetection) detection`,
> looks the same in both languages.  C# can test and name it in one step, with
> `if (detection is AprilTagSingleDetection singleDet)`.  Java 8 takes two.

**`ColorBlobLocatorProcessor`** finds patches of one color, such as game pieces,
and reports each patch as a `Blob`.

| Member | What it does |
|---|---|
| `Builder.setTargetColorRange(range)` | the color to find:  `ColorRange.BLUE`, `RED`, `YELLOW`, `GREEN`, `ARTIFACT_GREEN`, `ARTIFACT_PURPLE`, or your own |
| `Builder.setRoi(region)` | the part of the picture to search, as an `ImageRegion` |
| `getBlobs()` | every patch found, as a `List<ColorBlobLocatorProcessor.Blob>` |
| `Blob.getContourArea()`, `getCircle()`, `getBoxFit()`, `getCircularity()` | each patch's size, the circle and rectangle that fit it, and how round it is |
| `addFilter(...)`, `setSort(...)` | drops patches outside a range, and orders the rest, by area, density, aspect ratio, arc length, or circularity |

```java
ColorBlobLocatorProcessor colorLocator = new ColorBlobLocatorProcessor.Builder()
        .setTargetColorRange(ColorRange.ARTIFACT_PURPLE)   // Use a predefined color match
```

Those are the first two lines of a longer builder in FIRST's sample, which sets
nine more options.

**`PredominantColorProcessor`** turns the camera into a color sensor.  It
looks at one region of the picture and reports which of a list of colors
(`Swatch`es) it's closest to.

```java
PredominantColorProcessor.Result result = colorSensor.getAnalysis();
```

`result.closestSwatch` is the answer, and `result.RGB` and `result.HSV` give the
measured color.

Samples:  `ConceptAprilTagEasy` and `ConceptAprilTag`, then
`RobotAutoDriveToAprilTagTank` for driving to a tag;
`ConceptVisionColorLocator_Circle` and `_Rectangle`;  `ConceptVisionColorSensor`.

## A1.24  HuskyLens

The DFRobot HuskyLens is a small camera with its own screen and its own
computer.  It's trained on the device itself, with its buttons, and then
reports what it finds over I2C.

| Member | What it does |
|---|---|
| `selectAlgorithm(algorithm)` | what to look for:  `TAG_RECOGNITION`, `COLOR_RECOGNITION`, `OBJECT_TRACKING`, `OBJECT_RECOGNITION`, `LINE_TRACKING`, `FACE_RECOGNITION`, `OBJECT_CLASSIFICATION` |
| `blocks()` | everything found, as `HuskyLens.Block`s |
| `Block.id`, `x`, `y`, `width`, `height` | which trained thing it is, and where it is in the picture |

```java
huskyLens.selectAlgorithm(HuskyLens.Algorithm.TAG_RECOGNITION);
```

```java
HuskyLens.Block[] blocks = huskyLens.blocks();
```

Sample:  `SensorHuskyLens`.

## A1.25  Servos, extended

**More travel.**  A servo's position is a pulse on its wire, and the SDK sends
pulses from 600 to 2400 microseconds by default.  Some servos turn further
than that range allows.  A `Servo` from a REV hub is also a `ServoImplEx`, which
has `PwmControl`:

| Member | What it does |
|---|---|
| `setPwmRange(new PwmControl.PwmRange(lower, upper))` | the pulses that positions 0 and 1 send, in microseconds |
| `setPwmDisable()` | stops sending pulses, so the servo goes limp |
| `setPwmEnable()` | starts again |

Ask for one with `hardwareMap.get(ServoImplEx.class, ...)`.  The servo's
datasheet gives its pulse range.  `CRServoImplEx` does the same for a
continuous servo.

**A motor on a servo port.**  The REV SPARK Mini is a motor controller that
plugs into a servo port, and takes a motor.  The SDK configures it as a
continuous servo, so it's a `DcMotorSimple` (A1.2):

```java
leftDrive  = hardwareMap.get(DcMotorSimple.class, "left_drive");
```

Samples:  `ConceptScanServo`, `ConceptRevSPARKMini`.

## A1.26  Lights

| Device | Class | How it works |
|---|---|---|
| REV Blinkin LED driver | `RevBlinkinLedDriver` | plugs into a servo port and runs an LED strip.  `setPattern(BlinkinPattern.X)` picks one of its 100 built-in patterns, such as `RAINBOW_RAINBOW_PALETTE` or `CONFETTI`. |
| an LED on a digital port | `LED` | `on()`, `off()`, and `isLightOn()` |
| SparkFun Qwiic LED Stick | `SparkFunLEDStick` | a strip of LEDs on I2C.  `setColor(color)`, `setColor(index, color)`, `setBrightness(n)`, `turnAllOff()`. |

Lights tell the drive team what the robot knows:  a piece is loaded, a target
is in sight, the end of the match is near.

Samples:  `SampleRevBlinkinLedDriver`, `ConceptRevLED`, `ConceptLEDStick`.

## A1.27  The hubs themselves

Each Control Hub and Expansion Hub is a `LynxModule`, and code can talk to the
hub directly.  Ask for every hub at once:

```java
List<LynxModule> allHubs = hardwareMap.getAll(LynxModule.class);
```

| Member | What it does |
|---|---|
| `setBulkCachingMode(mode)` | `OFF`, `AUTO`, or `MANUAL`, below |
| `clearBulkCache()` | in `MANUAL`, throws away the last bulk read.  Call it once per loop. |
| `getInputVoltage(VoltageUnit.VOLTS)` | the battery's voltage |
| `getCurrent(CurrentUnit.AMPS)` | how much current the hub is drawing |
| `setConstant(color)` | sets the color of the hub's own light |

**Bulk reads.**  Every sensor reading is a message to the hub and back, and
each one takes time.  With bulk caching on, the hub sends all of its motor
encoders, digital ports, and analog ports in one message, and repeated reads
come from that.  It's `OFF` by default.  `AUTO` takes a new bulk read
whenever code asks for a value it has already read.  `MANUAL` keeps the same
bulk read until the code calls `clearBulkCache()`.  FIRST's sample turns it on
for every hub:

```java
module.setBulkCachingMode(LynxModule.BulkCachingMode.AUTO);
```

Sample:  `ConceptMotorBulkRead`, which times all three modes.

## A1.28  Older sensors

The SDK keeps interfaces for sensors from before the REV hubs, mostly sold by
Modern Robotics.  They appear in old examples, and a few teams still have the
hardware.

| Interface | What it measured |
|---|---|
| `GyroSensor` | heading, before the `IMU` interface |
| `OpticalDistanceSensor`, `LightSensor` | how much light bounces back |
| `UltrasonicSensor` | distance, by sound |
| `IrSeekerSensor` | the direction of an infrared beacon |
| `CompassSensor` | magnetic north |
| `AccelerationSensor` | acceleration |

For new code, use `IMU`, `DistanceSensor`, and `NormalizedColorSensor`.

---

# Part Seven - Encoders

An **encoder** counts how far a shaft has turned.  It's how code knows where
an arm is, how far a wheel has rolled, or how fast a flywheel spins.  Most
motors come with one built in, and an encoder can also go on any shaft the code
cares about:  the output of a gearbox, an arm's pivot, or a shaft a servo
drives.

There are two kinds.

| Kind | What it reports | After the power goes off |
|---|---|---|
| **Relative**, or **quadrature** | ticks counted since the last reset, up for one direction and down for the other | the count starts again from zero, wherever the shaft is |
| **Absolute** | the shaft's angle within one turn | it reports the same angle, because the angle is read from the shaft itself |

A motor's own encoder is relative.  The rest of this part covers the motor's
encoder (A1.29), letting the hub use it (A1.30), encoders of their own
(A1.31), and how to choose (A1.32).  The examples marked as ours use invented
labels.  Every other code line comes from FIRST's samples.

## A1.29  The encoder in a motor

A motor's encoder sits on the motor's own shaft, before the gearbox, and plugs
into the encoder connector beside the motor's port.  The SDK reads it through
the motor's `DcMotor` object.

| Member | What it does |
|---|---|
| `getCurrentPosition()` | the count, in ticks, as an `int` |
| `setMode(RunMode.STOP_AND_RESET_ENCODER)` | stops the motor and sets the count to zero |
| `getMotorType().getTicksPerRev()` | the ticks in one turn of the output shaft, for the motor type in the configuration |
| `DcMotorEx.getVelocity()` | the speed, in ticks per second |
| `DcMotorEx.getVelocity(AngleUnit.DEGREES)` | the speed of the output shaft, in degrees (or radians) per second |

**Ticks per turn.**  The count per turn of the output shaft is the encoder's
count per turn of the motor, times the gearbox's ratio.  The SDK's type for
the REV HD Hex 20-to-1 lists 560 ticks and a gearing of 20:  28 ticks per turn
of the motor, times 20.

| Motor type in the configuration | Ticks per output turn |
|---|---|
| REV Core Hex | 288 |
| REV HD Hex, 20 to 1 | 560 |
| REV HD Hex, 40 to 1 | 1120 |
| REV UltraPlanetary HD Hex | 560 |
| goBILDA 5202/3/4 series | 2786, the 99.5-to-1 gearbox |
| NeveRest 40 | 1120 |
| TETRIX | 1440 |
| a motor configured with no type | 1440, the TETRIX figure |

**The goBILDA row is one entry for a whole series.**  goBILDA sells the 5202,
5203, and 5204 motors with many gearbox ratios, and the SDK has one motor type
for all of them, with the 99.5-to-1 count.  For any other ratio,
`getTicksPerRev()` gives the wrong number, and so does
`getVelocity(AngleUnit)`, which divides by it.  goBILDA lists each motor's
count on its product page.  Put that number in a constant in the code.

**Direction flips the count.**  `setDirection(REVERSE)` flips the sign of the
position, the velocity, and every target, as well as the power.  A reversed
motor driving forward counts up.

**The count carries over.**  The SDK doesn't zero the encoders when an OpMode
starts, so the count picks up from wherever the last OpMode left it.  Reset it
during init, and then choose the mode the OpMode runs in, as FIRST's sample
does:

```java
leftDrive.setMode(DcMotor.RunMode.STOP_AND_RESET_ENCODER);
rightDrive.setMode(DcMotor.RunMode.STOP_AND_RESET_ENCODER);
```

```java
leftDrive.setMode(DcMotor.RunMode.RUN_USING_ENCODER);
rightDrive.setMode(DcMotor.RunMode.RUN_USING_ENCODER);
```

**From ticks to inches.**  FIRST's sample works out how many ticks one inch of
travel takes, from the ticks per turn, any gearing outside the motor, and the
wheel:

```java
static final double     COUNTS_PER_MOTOR_REV    = 1440 ;    // eg: TETRIX Motor Encoder
static final double     DRIVE_GEAR_REDUCTION    = 1.0 ;     // No External Gearing.
static final double     WHEEL_DIAMETER_INCHES   = 4.0 ;     // For figuring circumference
static final double     COUNTS_PER_INCH         = (COUNTS_PER_MOTOR_REV * DRIVE_GEAR_REDUCTION) /
                                                  (WHEEL_DIAMETER_INCHES * 3.1415);
```

An arm turns the same way into degrees.  This example is ours:

```java
// a 20:1 motor, then 3:1 gears to the arm
static final double TICKS_PER_ARM_DEGREE = 560 * 3.0 / 360;
```

Sample:  `RobotAutoDriveByEncoder_Linear`.

## A1.30  Letting the hub use the encoder

Two run modes hand the encoder to the hub, and the hub runs the control on its
own processor.

**`RUN_USING_ENCODER`** holds a steady speed.  The SDK turns the power into a
target speed, as a fraction of the top speed its motor type lists, and the hub
adds power when a load slows the motor down.  With the wrong motor type, the
top speed is wrong too.  `DcMotorEx.setVelocity(ticksPerSecond)` asks for a speed directly.

**`RUN_TO_POSITION`** drives to a target count, and holds it there.  FIRST's
sample does it in this order:

```java
leftDrive.setTargetPosition(newLeftTarget);
rightDrive.setTargetPosition(newRightTarget);
```

```java
leftDrive.setMode(DcMotor.RunMode.RUN_TO_POSITION);
rightDrive.setMode(DcMotor.RunMode.RUN_TO_POSITION);
```

```java
leftDrive.setPower(Math.abs(speed));
rightDrive.setPower(Math.abs(speed));
```

Then it waits in a loop while `leftDrive.isBusy() && rightDrive.isBusy()`,
sets the power to 0, and switches back to `RUN_USING_ENCODER`.

| Rule | Why |
|---|---|
| Set the target before the power. | Setting a power in `RUN_TO_POSITION` before any target throws `TargetPositionNotSetException`:  "Failed to enable motor. You must set a target position before switching to RUN_TO_POSITION mode". |
| The power's sign doesn't matter. | In `RUN_TO_POSITION`, `setPower` uses the power's size, and the target decides the direction. |
| `isBusy()` means "not there yet." | It's `true` until the count is within the **tolerance** of the target, and `false` in every other mode. |
| The tolerance is 5 ticks. | `DcMotorEx.setTargetPositionTolerance(ticks)` changes it, and the new tolerance reaches the hub with the next `setTargetPosition`. |

With two motors, the loop test decides when the move ends.  `&&` ends it when
either motor arrives, and `||` waits for both.  The sample uses `&&`, and its
comment calls that "safer":  the motion ends as soon as possible.

|\|` waits for both. | The sample uses `&&`, and its comment calls that "safer":  the motion ends as soon as possible. |

The `while` loop in the sample blocks:  nothing else runs while it waits.  In
the Robot Object Model, a component sets a target and checks `isBusy()` once
per pass through the loop, so the rest of the robot keeps moving.

## A1.31  An encoder of its own

A motor's encoder counts the motor.  Between the motor and the thing that
matters, there may be belts that slip, chains with slack, and gears with
**backlash**, the play between teeth.  A servo has no encoder the code can
read, and a `CRServo` reports nothing about position at all.  The team's
`Claw` has a `TODO` about exactly that.  The answer, in each case, is an encoder
on the shaft that matters.

**On a motor port's encoder connector.**  Each hub has four motor ports, and
each port has an encoder connector beside it.  The SDK reads the encoder by
port number, so the count comes from whatever is plugged into that connector.
Give the port a motor entry in the configuration, with a label, and read it
through `DcMotor`.  This example is ours:

```java
DcMotor armEncoder = hardwareMap.get(DcMotor.class, "armEncoder");
int armTicks = armEncoder.getCurrentPosition();
```

A port can drive one motor and read a different encoder.  Plug a motor into
port 2's power, and an external encoder into port 2's encoder connector, and
that motor's `getCurrentPosition()` reads the external encoder.  Three things
follow.

- **The hub's control uses that encoder too.**  `RUN_USING_ENCODER` and
  `RUN_TO_POSITION` steer by whatever is on the connector.  That works when
  the encoder counts up as the motor drives forward.  Otherwise, run the motor
  in `RUN_WITHOUT_ENCODER`, and close the loop in code.
- **One direction setting covers both.**  `setDirection` flips the power and
  the count together (A1.29).  If the motor and the encoder disagree, fix one
  of them with a minus sign in code.
- **The motor type's numbers are wrong for it.**  `getTicksPerRev()` and
  `getVelocity(AngleUnit)` use the motor's type.  Use `getVelocity()` in ticks
  per second, and the encoder's own count from its datasheet.

**On a shaft a servo drives.**  The servo goes on a servo port, the encoder
goes on any motor port's encoder connector, and the code closes the loop
itself:  read the count, compare it with the target, and set the servo's power
toward it.  This example is ours, with a made-up gain:

```java
int error = targetTicks - armEncoder.getCurrentPosition();
armServo.setPower(Range.clip(error * 0.002, -1, 1));
```

`Range.clip` keeps the power between -1 and 1.  The farther the arm is from
its target, the harder the servo pushes, and it eases off as the arm arrives.
That's a **proportional controller**, the simplest kind of feedback loop.

**Absolute encoders.**  An absolute encoder sends its angle one of two ways.

| Output | Where it goes |
|---|---|
| a voltage that rises with the angle | an analog port (A1.19).  The encoder's datasheet gives the voltage for a full turn. |
| a pulse, whose width in microseconds is the angle | an OctoQuad.  The SDK has no way to measure a pulse width on a hub's own ports. |

FIRST's OctoQuad sample names the REV Through Bore Encoder as one that does
both:  a relative count on its quadrature wires, and an absolute angle as a
pulse from 1 to 1024 microseconds.  The sample's cable needs one wire moved to
reach the absolute signal, and its comment says which.

**The OctoQuad.**  It reads eight encoders over I2C, and each bank of four
channels can be set to quadrature or pulse width.

| Member | What it does |
|---|---|
| `setChannelBankConfig(config)` | `ALL_QUADRATURE`, `ALL_PULSE_WIDTH`, or `BANK1_QUADRATURE_BANK2_PULSE_WIDTH` |
| `readSinglePosition(n)` | the count on channel `n`, 0 to 7 |
| `readAllEncoderData(block)` | all eight at once, into `block.positions[]` and `block.velocities[]` |
| `setSingleEncoderDirection(n, dir)` | flips one channel's count |
| `resetSinglePosition(n)`, `resetAllPositions()` | zeroes counts |
| `setAllVelocitySampleIntervals(ms)` | how long each velocity is measured over, from 1 to 255 ms |

A velocity from the OctoQuad is in ticks per sample interval, so the advanced
sample multiplies by the number of intervals in a second:

```java
octoquad.setChannelBankConfig(OctoQuad.ChannelBankConfig.BANK1_QUADRATURE_BANK2_PULSE_WIDTH);
```

```java
driveCountsPerSec = encoderDataBlock.velocities[channel] * VELOCITY_SAMPLES_PER_S;
```

Two odometry pods can go on the goBILDA Pinpoint instead, which turns their
counts into a position on the field (A1.21).

Samples:  `SensorOctoQuad`, `SensorOctoQuadAdv`.

## A1.32  Choosing an encoder

| The question | The tool |
|---|---|
| How far has the motor turned? | the motor's own encoder (A1.29) |
| Where is the output, past belts, chains, or gears with play? | an encoder on the output shaft, on a motor port's connector (A1.31) |
| Where is a shaft a servo drives? | an encoder on that shaft, on a spare motor port's connector, with the loop in code (A1.31) |
| Where is it the moment the robot turns on? | an absolute encoder, on an analog port or an OctoQuad (A1.31) |
| More encoders than the hubs have ports for? | an OctoQuad (A1.31) |
| Where is the robot on the field? | odometry pods, on a Pinpoint or an OctoQuad (A1.21) |

Reading many encoders every loop takes time.  Bulk reads (A1.27) bring every
motor port's count in one message.

---

# Part Eight - Known issues

## A1.33  What to watch for

Every item here was found in SDK 12.0.0 or in the course's code, and checked.

| Where | What happens | What to do |
|---|---|---|
| `Gamepad.aWasPressed()`, and every `...WasPressed()` | The first call after a press gets `true` and uses it up.  If two components each check `gamepad2.aWasPressed()` in the same loop, only the first one sees the press. | Read each button's `WasPressed()` in one place per loop.  For held buttons, read the field. |
| `Telemetry` captions | Several starter captions end in a colon, as in `"Left power:"`.  With the default separator `" : "`, the line comes out `Left power: : 0.0`.  The display is **to confirm on a robot.** | End captions without a colon, or call `setCaptionValueSeparator`. |
| `LinearOpMode.sleep()` | When STOP arrives during a `sleep`, the SDK interrupts it, and `sleep` returns early, with no exception.  A loop that sleeps and never checks `opModeIsActive()` carries on. | Check `opModeIsActive()` in every loop. |
| `Limelight3A.getLatestResult()` | Before the camera sends anything, it returns an empty result.  The team's `LimelightExtensions` checks only for `null`, which this never is in practice. | Check `isValid()`. |
| `IMU` in the team's `MecanumDrive` and `BillyRobot` | Both get the IMU, and neither calls `initialize`, so the IMU doesn't know how the hub is mounted.  `MecanumDrive` has a `TODO` about it. | Call `initialize` once, with the hub's real mounting (A1.10). |
| `HardwareMap.get` | The same exception covers a misspelled label and a wrong type. | Check the type chosen in the configuration as well as the spelling. |
| `DcMotor.RunMode` | `RUN_WITHOUT_ENCODERS`, `RUN_USING_ENCODERS`, and `RESET_ENCODERS` are deprecated. | Use the four names in A1.6. |
| `AprilTagProcessor.getDetections()` | In SDK 12.0.0 a detection can be a single tag or a cluster, and only `AprilTagSingleDetection` has an `id`.  A tag missing from the tag library has `null` for `metadata` and `ftcPose`. | Check `instanceof AprilTagSingleDetection`, then check `metadata` for `null` (A1.23). |
| `Rev2mDistanceSensor.getDistance()` | Out of range comes back as the chip's own large reading.  `DistanceSensor.distanceOutOfRange` plays no part. | Read it with nothing in front of it, and treat anything past the sensor's range as "nothing there" (A1.16). |
| a touch sensor read as a `DigitalChannel` | `getState()` is `false` while the REV touch sensor is pressed. | Read it as a `TouchSensor`, or flip the test (A1.18). |
| `GoBildaPinpointDriver` | `getPosition()` returns what the last `update()` read. | Call `update()` once per loop (A1.21). |
| `LynxModule` bulk caching in `MANUAL` | Every read repeats the last bulk read until the cache is cleared. | Call `clearBulkCache()` once per loop, or use `AUTO` (A1.27). |
| `DcMotor` in `RUN_TO_POSITION` | Setting a power before any target throws `TargetPositionNotSetException`. | Call `setTargetPosition` first, then `setMode`, then `setPower` (A1.30). |
| `DcMotor.getCurrentPosition()` | The SDK doesn't zero the count when an OpMode starts.  It picks up where the last OpMode left it. | Use `STOP_AND_RESET_ENCODER` during init (A1.29). |
| the goBILDA 5202/3/4 motor type | One type covers the whole series, with the 99.5-to-1 count of 2786 ticks.  For other ratios, `getTicksPerRev()`, `getVelocity(AngleUnit)`, and the top speed behind `RUN_USING_ENCODER` are all wrong. | Keep the motor's real count in a constant, and use `getVelocity()` in ticks per second (A1.29). |
| `DcMotorEx.setTargetPositionTolerance` | The new tolerance reaches the hub only with the next `setTargetPosition`. | Set the tolerance before the target. |
| an external encoder on a driven motor's port | `setDirection` flips the motor's power and the encoder's count together, and the hub's run modes steer by that encoder. | Fix a mismatch with a minus sign in code, or run the motor in `RUN_WITHOUT_ENCODER` (A1.31). |
| `OctoQuad` velocities | A velocity is in ticks per sample interval, from 1 to 255 ms. | Multiply by the intervals in a second, as the sample does (A1.31). |
