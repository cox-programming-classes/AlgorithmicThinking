# Appendix 2 - The Limelight 3A

*A computer of its own, bolted to the robot.*

---

The Limelight 3A looks like a camera, and it's a whole computer.  It takes the
pictures, runs its own vision software on them, and works out what it sees:
which AprilTags, where they are, where the robot must be on the field.  Then
it hands the answers to the Control Hub as numbers.  The robot's code reads
those conclusions, and the pictures themselves are on the camera.

So programming a Limelight means programming two computers.  Part of the job
happens in the Limelight's own setup screens, before a match, and part
happens in Java, on the Control Hub.  This appendix covers the Java side in
full, and the Limelight side as far as the Java needs it.

**Version 12.0.0.**  Every Java class and method below was checked in the
SDK's source.  The Limelight's Java files, and the navigation classes it
returns, are identical in SDK 11.2.1 and 12.0.0.  Facts about the camera
itself, its setup screens and its firmware, come from Limelight's own
documentation, and say so.  The team's research notes on the Limelight, which
go into more detail than this appendix, are in
`TeamRepo/doc/limelight3a/`.  Limelight's documentation is at
`docs.limelightvision.io`.

| Part | What it covers |
|---|---|
| One | **Two computers.**  What runs where, setup, and pipelines. |
| Two | **`Limelight3A`.**  Starting it, the background polling, and the commands it can send. |
| Three | **`LLResult`.**  Reading one answer, and the targets in it. |
| Four | **Where the robot is.**  Poses, MegaTag, and field maps. |
| Five | **The rest.**  Python scripts, status, calibration, and snapshots. |
| Six | **Known issues.** |

---

# Part One - Two computers

## A2.1  What runs where

```
 Limelight 3A                            Control Hub
 ------------                            -----------
 takes a picture                         Limelight3A, in the background:
 runs the current pipeline                 asks for the newest answer,
 works out targets and poses                100 times a second,
 keeps the newest answer        ---->       and keeps the last one
                                USB
                                         your code:
                                           getLatestResult()
                                           reads the kept answer
```

The two computers run on their own clocks.  The Limelight finishes an answer
whenever its pipeline finishes a picture.  The Control Hub asks for one on a
timer.  Your code reads whatever answer the Control Hub has kept, and that
answer can be new, or a few loops old, or the same one twice.  Part Three is
about telling which.

## A2.2  Setup

From Limelight's documentation and the team's notes:

- The 3A plugs into the Control Hub's blue USB 3.0 port, with a USB-C to USB-A
  cable.
- In the Driver Station's configuration, scan for it and label it.  The team's
  code and FIRST's sample both use the label `limelight`.
- Pipelines are set up in the Limelight's own web page, at
  `http://limelight.local:5801`, with the camera plugged into a laptop.  The
  Limelight Hardware Manager app finds the camera too.
- The 3A has no lights of its own, and runs neural-network pipelines on its own
  processor.

## A2.3  Pipelines

A **pipeline** is one saved setup:  what to look for, and how.  The Limelight
stores up to ten, in slots 0 to 9, and runs one at a time.  Each kind of
pipeline fills a different list in the answer.

| Pipeline | What it finds | Where its targets go (A2.10) |
|---|---|---|
| fiducial | AprilTags | `getFiducialResults()` |
| color | patches of one color | `getColorResults()` |
| neural detector | trained objects, with where they are | `getDetectorResults()` |
| neural classifier | what the whole picture shows | `getClassifierResults()` |
| barcode | barcodes and QR codes | `getBarcodeResults()` |
| Python | whatever a script decides (A2.15) | `getPythonOutput()` |

Code picks a pipeline by its slot number, with `pipelineSwitch(n)`.

---

# Part Two - `Limelight3A`

## A2.4  Starting it

FIRST's sample starts the camera like this:

```java
limelight = hardwareMap.get(Limelight3A.class, "limelight");
```

```java
limelight.pipelineSwitch(0);
limelight.start();
```

| Method | What it does |
|---|---|
| `setPollRateHz(int hz)` | how often the Control Hub asks for an answer.  The default is 100.  It's clamped to 1 to 250, and **ignored while the polling is running**, so set it before `start()`. |
| `start()` | starts the background polling |
| `pause()` | pauses it.  `start()` picks it back up. |
| `stop()` | stops it.  The last answer is kept. |
| `isRunning()` | `true` while the polling runs.  It says nothing about whether the camera is answering. |
| `isConnected()` | `true` if an answer arrived in the last 250 milliseconds |
| `getTimeSinceLastUpdate()` | milliseconds since the last answer arrived |

To change the poll rate once it's running:  `stop()`, then `setPollRateHz(...)`,
then `start()`.  Polling 100 times a second doesn't make the camera finish 100
pictures a second.  It only means the Control Hub asks that often.

## A2.5  The background polling, and the methods that wait

Two kinds of method are on `Limelight3A`, and they cost very different amounts
of time.

- **`getLatestResult()` costs nothing.**  It hands back the answer the
  background polling already kept.  No message goes to the camera.
- **Everything else waits on the camera.**  `getStatus()`, the calibration
  getters, and every command in A2.6 send a request over USB and wait for the
  reply, on the thread that called them.  The driver gives up on connecting
  after 100 milliseconds, and on a read after 100 milliseconds, or 15 seconds
  for an upload.

A robot's main loop runs many times a second, so a 100-millisecond wait in it
is a stutter the drivers can feel.  Read results in the loop.  Send commands
in setup, or only when something changes.

## A2.6  Commands

| Method | What it does |
|---|---|
| `pipelineSwitch(int index)` | switches to pipeline `index` |
| `reloadPipeline()` | reloads the current pipeline from the camera's storage |
| `updateRobotOrientation(double yaw)` | sends the robot's heading, in degrees, for MegaTag2 (A2.13) |
| `updatePythonInputs(double[] inputs)` | sends 1 to 32 numbers to a Python pipeline (A2.15) |
| `uploadPipeline(String json, Integer index)` | saves a pipeline, written as JSON, into a slot |
| `uploadPython(String script, Integer index)` | saves a Python script into a slot |
| `uploadFieldmap(LLFieldMap map, Integer index)` | saves a field map (A2.14) |
| `captureSnapshot(String name)` | saves the current picture on the camera, for tuning later |
| `deleteSnapshot(String name)`, `deleteSnapshots()` | deletes one saved picture, or all of them |

Every command returns `true` when the camera accepted the request.  That's
all it means.  After `pipelineSwitch(2)` returns `true`, the next few answers
can still come from the old pipeline, already on their way.  Check
`result.getPipelineIndex()` before trusting an answer after a switch.

---

# Part Three - `LLResult`

## A2.7  Is there anything to read?

`getLatestResult()` returns an `LLResult`:  one answer from the camera.  Before
it uses one, code has several separate questions to ask, and each has its own
check.

| Check | What it tells you |
|---|---|
| `result.isValid()` | the pipeline found a target in this answer |
| `limelight.isConnected()` | an answer arrived in the last 250 milliseconds |
| `result.getStaleness()` | milliseconds since the Control Hub received this answer |
| `result.getPipelineIndex()` | which pipeline made this answer |
| `result.getTimestamp()` | the camera's own clock when it made the answer.  The same timestamp twice means the same answer twice. |

FIRST's sample checks `isValid()` before it reads anything:

```java
LLResult result = limelight.getLatestResult();
if (result.isValid()) {
```

**Before the first answer.**  `getLatestResult()` builds an empty answer, and
its `isValid()` is `false`.  A `null` check alone can't tell whether the
camera saw anything.

**Read it once per loop.**  The background polling can swap in a new answer
between two calls to `getLatestResult()`.  Take one answer at the top of the
loop, and read everything from that one.

## A2.8  The main target

Each answer picks one target as its main one, and reports where it is in the
picture.

| Method | What it gives |
|---|---|
| `getTx()` | how far the main target is to the side of the crosshair, in degrees |
| `getTy()` | how far it is above or below the crosshair, in degrees |
| `getTxNC()`, `getTyNC()` | the same, measured from the center of the lens, with no crosshair |
| `getTa()` | how much of the picture the target fills |

The crosshair is set in the Limelight's web page, and can be moved off center.
`getTx()` is the number to turn toward.  It has no tag ID behind it, so with
several tags in view, it can be any of them.  To aim at one tag, find it in
the list (A2.11).

A value the camera left out of its answer comes back as zero.  So `getTx() ==
0` can mean "dead center," or it can mean "nothing reported."  Check
`isValid()` first.

## A2.9  Timing

| Method | What it gives, in milliseconds |
|---|---|
| `getCaptureLatency()` | how long the camera took to capture the picture |
| `getTargetingLatency()` | how long the pipeline took to process it |
| `getParseLatency()` | how long the Control Hub took to read the answer |
| `getStaleness()` | how long ago the Control Hub received it |

The sum is how old the information is, roughly, and the robot has moved since.
That gap matters at speed.

## A2.10  The lists of targets

Each kind of target has its own class, all inside `LLResultTypes`, and its own
list on the answer.

| List | Class | What each one has |
|---|---|---|
| `getFiducialResults()` | `LLResultTypes.FiducialResult` | a tag ID, its family, where it is in the picture, and five poses (A2.12) |
| `getColorResults()` | `LLResultTypes.ColorResult` | where it is in the picture, and the same five poses |
| `getDetectorResults()` | `LLResultTypes.DetectorResult` | what it is (`getClassName()`, `getClassId()`), how sure (`getConfidence()`), and where |
| `getClassifierResults()` | `LLResultTypes.ClassifierResult` | what the picture shows, and how sure.  No position. |
| `getBarcodeResults()` | `LLResultTypes.BarcodeResult` | the decoded text (`getData()`), and where |

Every class with a position shares these:

| Method | What it gives |
|---|---|
| `getTargetXDegrees()`, `getTargetYDegrees()` | this target's offset from the crosshair, in degrees |
| `getTargetXDegreesNoCrosshair()`, `getTargetYDegreesNoCrosshair()` | the same, from the lens center |
| `getTargetXPixels()`, `getTargetYPixels()` | where it is in the picture, in pixels |
| `getTargetArea()` | how much of the picture it fills |
| `getTargetCorners()` | its corners, as a list of `[x, y]` pairs |

These classes share methods, and they share no interface:  a
`FiducialResult` and a `ColorResult` can't be stored as one type.

The lists are the answer's own.  Sorting one changes the answer for every
other part of the code reading it.  Copy it first:
`new ArrayList<>(result.getFiducialResults())`.

## A2.11  Finding one tag

The team's `LimelightExtensions` finds a tag by its ID:

```java
public static LLResultTypes.FiducialResult tryGetFiducial(
        Limelight3A limelight,
        int tagId)
{
    LLResult result = limelight.getLatestResult();
    if (result == null)
        return null;

    return result
            .getFiducialResults()
            .stream()
            .filter(fr -> fr.getFiducialId() == tagId)
            .findFirst()
            .orElse(null);
}
```

`LimelightAutoTarget` then aims by that tag's own offset,
`tag.getTargetXDegrees()`, which is the right number:  this tag's, whatever the
camera picked as its main target.

The `null` check on `result` never fires in 12.0.0 (A2.7).  An empty answer
has an empty list, so the method still returns `null` when the tag isn't
there, through `orElse(null)`.

> **Aside:  streams, and `Optional`**
>
> `.stream().filter(...).findFirst().orElse(null)` is Java's version of C#'s
> LINQ, `.Where(...).FirstOrDefault()`.  `fr -> fr.getFiducialId() == tagId`
> is a lambda.  C# writes its arrow `=>`, and Java writes `->`.
>
> `findFirst()` returns an `Optional`:  a box with the tag in it, or an empty
> box.  `.orElse(null)` opens the box, and hands
> back the tag, or `null` if the box was empty.  C# 8's nullable references
> say "this might be null" in the type itself.  Java 8 has no such syntax, and
> `Optional` is its way of saying the same thing.

## A2.12  `FiducialResult`, in full

On top of the shared methods in A2.10:

| Method | What it gives |
|---|---|
| `getFiducialId()` | the tag's ID number |
| `getFamily()` | the tag family, the pattern system the tag uses |
| `getRobotPoseFieldSpace()` | where the robot is on the field, worked out from this one tag |
| `getRobotPoseTargetSpace()` | where the robot is, measured from the tag |
| `getTargetPoseRobotSpace()` | where the tag is, measured from the robot |
| `getTargetPoseCameraSpace()` | where the tag is, measured from the camera |
| `getCameraPoseTargetSpace()` | where the camera is, measured from the tag |

The pose methods (Part Four) need the camera's position on the robot set in
the Limelight's web page.  When the camera didn't send a pose, the method
returns a pose of all zeros, not `null`.

---

# Part Four - Where the robot is

## A2.13  Poses, and MegaTag

A **pose** is a position and a facing.  The Limelight gives them as `Pose3D`
objects, from the SDK's `navigation` package.

| Class | Member | What it gives |
|---|---|---|
| `Pose3D` | `getPosition()` | a `Position` |
| | `getOrientation()` | a `YawPitchRollAngles` |
| `Position` | `x`, `y`, `z` | public fields, in **meters** for every Limelight pose |
| | `unit` | the unit, `DistanceUnit.METER` |
| | `toUnit(DistanceUnit u)` | the position in another unit |
| `YawPitchRollAngles` | `getYaw(AngleUnit u)`, `getPitch(u)`, `getRoll(u)` | the facing.  Limelight poses store **degrees**. |

```java
Pose3D botpose = result.getBotpose();
```

That line is from FIRST's sample.  The position, in inches, would be
`botpose.getPosition().toUnit(DistanceUnit.INCH)`.  To change units, call
`toUnit`.  Setting the `unit` field relabels the numbers without converting
them.

**The robot's place on the field.**  The Limelight works it out two ways, from
every tag in view at once.  The method is called **MegaTag**.

| Method | What it gives |
|---|---|
| `getBotpose()` | the robot's field pose, by MegaTag1:  from the tags alone |
| `getBotpose_MT2()` | the robot's field pose, by MegaTag2:  from the tags, plus a heading your code supplies |
| `getBotposeTagCount()` | how many tags went into it |
| `getBotposeSpan()` | how far apart those tags are, in meters |
| `getBotposeAvgDist()` | how far away they are, on average, in meters |
| `getStddevMt1()`, `getStddevMt2()` | how uncertain each estimate is:  x, y, z, roll, pitch, yaw |

**MegaTag2 needs the heading every loop.**  Send the robot's heading, from
the IMU, before reading the pose:

```java
limelight.updateRobotOrientation(imu.getRobotYawPitchRollAngles().getYaw(AngleUnit.DEGREES));
Pose3D pose = limelight.getLatestResult().getBotpose_MT2();
```

Those two lines are ours, built from verified signatures.
`updateRobotOrientation` sends the yaw, with zeros for the other five values.
The heading has to be measured in the field's frame, so zero has to mean the
same direction on the field every match.

Both MegaTags need a **field map** on the camera:  where every tag on the field
is.

## A2.14  Field maps

A field map is usually set up in the Limelight's web page.  Java can build and
upload one too, with `LLFieldMap`.

| Class | Member | What it gives |
|---|---|---|
| `LLFieldMap` | `new LLFieldMap(List<Fiducial> tags, String type)` | a map.  The type is `"ftc"`. |
| | `getFiducials()`, `getNumberOfTags()` | the tags in it |
| | `isValid()` | a basic check, run by `uploadFieldmap` |
| `LLFieldMap.Fiducial` | `new LLFieldMap.Fiducial(id, size, family, transform, isUnique)` | one tag.  `size` is in **millimeters**.  `transform` is a 4-by-4 matrix, flattened into 16 numbers. |

Note the units:  observed poses come back in meters, and map sizes go in as
millimeters.

`isValid()` has a bug (A2.18).  Pass the type as the literal `"ftc"`, typed
right in the call.

---

# Part Five - The rest

## A2.15  Python pipelines

A Python pipeline runs a script on the Limelight, which Limelight calls a
SnapScript.  The robot and the script trade numbers.

| Method | What it does |
|---|---|
| `limelight.updatePythonInputs(double[] inputs)` | sends 1 to 32 numbers to the script.  An empty array or a longer one is refused, and returns `false`. |
| `limelight.updatePythonInputs(a, b, c, d, e, f, g, h)` | sends exactly eight |
| `result.getPythonOutput()` | the script's numbers, as an array of **exactly 32**.  A shorter output is padded with zeros. |

The array is always 32 long, so its length can't tell you how many numbers
the script sent.  Agree on which slots mean what, and have the script set one
slot as a flag that says the rest are real.

## A2.16  Status, and calibration

| Method | What it gives |
|---|---|
| `limelight.getStatus()` | an `LLStatus`:  `getName()`, `getTemp()` (Celsius), `getCpu()` and `getRam()` (percent), `getFps()`, `getPipelineIndex()`, `getPipelineType()` |
| `limelight.getCalDefault()`, `getCalFile()`, `getCalEEPROM()`, `getCalLatest()` | the camera's calibration reports, as `LLResultTypes.CalibrationResult` |

Both wait on the camera (A2.5).  When `getStatus()` fails, it returns a status
of zeros and empty text, with no error.  So a temperature of 0.0 means "no
answer," not a cold camera.

FIRST's sample calls `getStatus()` on every pass through its loop, to show the
camera's temperature and speed.  That's fine for a test OpMode.  On a robot
in a match, call it now and then, or not at all.

## A2.17  Snapshots

`captureSnapshot("name")` saves the picture the camera sees right now.  Saved
pictures appear in the Limelight's web page, where a pipeline can be tuned
against them later, with the robot off the field.  Snapshots taken during
practice, on the real field in the real light, are the ones to tune against.

---

# Part Six - Known issues

## A2.18  What to watch for

Every item here was checked in the SDK 12.0.0 source, unless it says
otherwise.

| Where | What happens | What to do |
|---|---|---|
| `getLatestResult()` | Before the first answer, it returns an empty answer.  The team's `null` check never fires. | Check `isValid()` (A2.7). |
| `pipelineSwitch()` | `true` means the camera accepted the request.  Answers from the old pipeline can still arrive. | Check `getPipelineIndex()` (A2.6). |
| `setPollRateHz()` | Ignored while the polling runs. | Set it before `start()`, or `stop()` first (A2.4). |
| `getStatus()`, calibration getters, every command | Each one waits on the camera, up to 100 ms, or 15 s for an upload. | Keep them out of the drive loop (A2.5). |
| missing values | A value the camera left out reads as zero, and a missing pose is all zeros. | Check `isValid()`, and for poses, `getBotposeTagCount()` (A2.8, A2.12). |
| `getTargetCorners()`, the result lists | They're the cached answer's own lists. | Copy before sorting or changing (A2.10). |
| `getPythonOutput()` | Always 32 numbers, zero-padded. | Use a flag slot (A2.15). |
| `LLFieldMap.isValid()` | It compares the type to `"ftc"` with `==` where Java needs `.equals()`.  A type string built at runtime can fail even when it reads `"ftc"`. | Pass the literal `"ftc"` (A2.14). |
| `LLResult.getPipelineType()` | It reads the key `pipelineType`.  Limelight's documentation names the key `pTYPE`, so the method may return empty text.  The SDK side is checked;  the firmware side is from the team's notes. | Read the pipeline type from `LLStatus.getPipelineType()` (A2.16). |
| `LLStatus` after a failure | Returns zeros and empty text, with no error. | Treat zeros as "no answer" (A2.16). |
