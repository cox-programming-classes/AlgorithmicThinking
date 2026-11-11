"""
Draws the robot model's diagrams for the chapters, as SVG, and exports them with Inkscape.

    py Course/reference/make_figures.py

Writes Course/chapters/figures/ch01/, each figure as .svg and .png:

    ch01_model      The model's shape:  a Robot has one DriveTrain and maybe a
                    MechAssembly, and a MechAssembly has components, and maybe
                    smaller MechAssemblies.  For 1.3.
    ch01_basebot    The same four abstract boxes, with the base bot's concrete
                    classes under them.  For 1.9.

The style is Jason's simplified UML:  boxes and arrows, with no properties and
no behaviors.  An abstract class is a pale box with <<abstract>> over its name.
A concrete class is a white box.  A plain arrow with a label means "has".  An
arrow with a hollow triangle means "is a", and points at the more general class.

Same palette and approach as OODP_Lessons/Course/reference/make_figures.py.
Edit the drawings and re-run.
"""

import html
import subprocess
from pathlib import Path

HERE = Path(__file__).resolve().parent
FIGURES = HERE.parent / "chapters" / "figures"
INKSCAPE = Path(r"C:\Program Files\Inkscape\bin\inkscape.com")

BLUE = "#1F4E79"
MID = "#2B6CB0"
PALE = "#EAF2FB"
LIGHT = "#CFE0F3"
INK = "#22303C"
SLATE = "#5B6B7A"

SANS = "Segoe UI, Lato, Helvetica, Arial, sans-serif"
MONO = "Consolas, Menlo, Monaco, monospace"

BOX_H = 92


def esc(s):
    return html.escape(s, quote=True)


def text(x, y, s, size=26, family=SANS, fill=INK, weight="normal", anchor="middle", style="normal"):
    return (f'<text x="{x}" y="{y}" font-family="{family}" font-size="{size}" fill="{fill}" '
            f'font-weight="{weight}" font-style="{style}" text-anchor="{anchor}">{esc(s)}</text>')


class Box:
    """A class, drawn as a box.  Abstract ones are pale, with <<abstract>> above the name."""

    def __init__(self, name, x, y, w, abstract):
        self.name, self.x, self.y, self.w, self.h = name, x, y, w, BOX_H
        self.abstract = abstract

    @property
    def cx(self):
        return self.x + self.w / 2

    @property
    def top(self):
        return self.y

    @property
    def bottom(self):
        return self.y + self.h

    @property
    def left(self):
        return self.x

    @property
    def right(self):
        return self.x + self.w

    def draw(self):
        fill = PALE if self.abstract else "#FFFFFF"
        stroke = BLUE if self.abstract else MID
        parts = [f'<rect x="{self.x}" y="{self.y}" width="{self.w}" height="{self.h}" rx="10" '
                 f'fill="{fill}" stroke="{stroke}" stroke-width="3"/>']
        if self.abstract:
            parts.append(text(self.cx, self.y + 32, "\u00ababstract\u00bb", size=19, fill=SLATE))
            parts.append(text(self.cx, self.y + 68, self.name, size=28, family=MONO,
                              fill=BLUE, weight="bold", style="italic"))
        else:
            parts.append(text(self.cx, self.y + 56, self.name, size=28, family=MONO, fill=INK, weight="bold"))
        return "\n".join(parts)


def markers():
    return f'''<defs>
<marker id="has" viewBox="0 0 20 20" refX="19" refY="10" markerWidth="22" markerHeight="22" orient="auto" markerUnits="userSpaceOnUse">
  <path d="M1,2 L19,10 L1,18 z" fill="{INK}"/>
</marker>
<marker id="isa" viewBox="0 0 20 20" refX="19" refY="10" markerWidth="20" markerHeight="20" orient="auto" markerUnits="userSpaceOnUse">
  <path d="M1,1 L19,10 L1,19 z" fill="#FFFFFF" stroke="{INK}" stroke-width="2"/>
</marker>
</defs>'''


def has(x0, y0, x1, y1, label, side="right"):
    """A 'has' arrow, from the owner to what it owns, labeled beside its midpoint on one side."""
    mx, my = (x0 + x1) / 2, (y0 + y1) / 2
    lx, anchor = (mx + 24, "start") if side == "right" else (mx - 24, "end")
    return (f'<line x1="{x0}" y1="{y0}" x2="{x1}" y2="{y1}" stroke="{INK}" stroke-width="3" marker-end="url(#has)"/>\n'
            + text(lx, my - 6 if x0 != x1 else my + 8, label, size=23, fill=INK, anchor=anchor, style="italic"))


def has_self(box, label):
    """A 'has' arrow from a box back to itself:  out of its top, around, and into its right side."""
    x_up, x_out = box.right - 50, box.right + 60
    y_high, y_in = box.top - 55, box.top + 28
    points = f"{x_up},{box.top} {x_up},{y_high} {x_out},{y_high} {x_out},{y_in} {box.right},{y_in}"
    return (f'<polyline points="{points}" fill="none" stroke="{INK}" stroke-width="3" '
            f'stroke-linejoin="round" marker-end="url(#has)"/>\n'
            + text(x_out + 14, y_high + 8, label, size=23, fill=INK, anchor="start", style="italic"))


def isa(x0, y0, x1, y1):
    """An 'is a' arrow, from the specific class to the general one."""
    return f'<line x1="{x0}" y1="{y0}" x2="{x1}" y2="{y1}" stroke="{INK}" stroke-width="2.5" marker-end="url(#isa)"/>'


def legend(x, y, show_isa):
    rows = [f'<line x1="{x}" y1="{y}" x2="{x + 70}" y2="{y}" stroke="{INK}" stroke-width="3" marker-end="url(#has)"/>',
            text(x + 86, y + 8, "has", size=22, anchor="start")]
    if show_isa:
        rows += [f'<line x1="{x + 170}" y1="{y}" x2="{x + 240}" y2="{y}" stroke="{INK}" stroke-width="2.5" marker-end="url(#isa)"/>',
                 text(x + 256, y + 8, "is a", size=22, anchor="start")]
    return "\n".join(rows)


def svg(view_w, view_h, body, title):
    return (f'<?xml version="1.0" encoding="UTF-8"?>\n'
            f'<svg xmlns="http://www.w3.org/2000/svg" width="{view_w}" height="{view_h}" '
            f'viewBox="0 0 {view_w} {view_h}">\n<title>{esc(title)}</title>\n{markers()}\n'
            f'<rect width="{view_w}" height="{view_h}" fill="#FFFFFF"/>\n{body}\n</svg>\n')


def model():
    """The model's shape, for 1.3."""
    robot = Box("Robot", 390, 40, 260, True)
    drive = Box("DriveTrain", 90, 290, 300, True)
    mech = Box("MechAssembly", 610, 290, 340, True)
    comp = Box("MechComponent", 600, 540, 360, True)
    body = [b.draw() for b in (robot, drive, mech, comp)]
    body.append(has(robot.cx - 50, robot.bottom, drive.cx, drive.top, "exactly 1", side="left"))
    body.append(has(robot.cx + 50, robot.bottom, mech.cx, mech.top, "0 or 1"))
    body.append(has(mech.cx, mech.bottom, comp.cx, comp.top, "some"))
    body.append(has_self(mech, "0 or more"))
    body.append(legend(90, 610, show_isa=False))
    return svg(1160, 680, "\n".join(body), "The Robot Object Model:  a Robot has one DriveTrain and maybe a MechAssembly, which has components and maybe smaller MechAssemblies")


def basebot():
    """The base bot's classes under the abstract model, for 1.9."""
    robot = Box("Robot", 560, 40, 260, True)
    base = Box("BaseBot", 1060, 40, 260, False)
    drive = Box("DriveTrain", 270, 300, 300, True)
    mech = Box("MechAssembly", 830, 300, 340, True)
    arm = Box("Arm", 1290, 336, 200, False)      # low enough that its arrow clears the loop
    std = Box("StandardTankDrive", 40, 560, 360, False)
    one = Box("OneStickTank", 440, 560, 300, False)
    comp = Box("MechComponent", 820, 560, 360, True)
    dlm = Box("DoublyLimitedMotor", 640, 820, 380, False)
    claw = Box("Claw", 1080, 820, 220, False)
    boxes = (robot, base, drive, mech, arm, std, one, comp, dlm, claw)
    body = [b.draw() for b in boxes]
    body.append(has(robot.cx - 50, robot.bottom, drive.cx, drive.top, "exactly 1", side="left"))
    body.append(has(robot.cx + 50, robot.bottom, mech.cx, mech.top, "0 or 1"))
    body.append(has(mech.cx, mech.bottom, comp.cx, comp.top, "some"))
    body.append(has_self(mech, "0 or more"))
    body.append(isa(base.left, base.y + BOX_H / 2, robot.right, robot.y + BOX_H / 2))
    body.append(isa(arm.left, arm.y + BOX_H / 2, mech.right, arm.y + BOX_H / 2))
    body.append(isa(std.cx, std.top, drive.cx - 60, drive.bottom))
    body.append(isa(one.cx, one.top, drive.cx + 60, drive.bottom))
    body.append(isa(dlm.cx, dlm.top, comp.cx - 60, comp.bottom))
    body.append(isa(claw.cx, claw.top, comp.cx + 60, comp.bottom))
    body.append(legend(40, 980, show_isa=True))
    return svg(1540, 1040, "\n".join(body), "The base bot's classes, under the abstract Robot Object Model")


def export(svg_path):
    png = svg_path.with_suffix(".png")
    subprocess.run([str(INKSCAPE), str(svg_path), "--export-type=png",
                    f"--export-filename={png}", "--export-dpi=150"], check=True, capture_output=True)
    return png


def main():
    out = FIGURES / "ch01"
    out.mkdir(parents=True, exist_ok=True)
    for name, draw in (("ch01_model", model), ("ch01_basebot", basebot)):
        path = out / f"{name}.svg"
        path.write_text(draw(), encoding="utf-8")
        print("wrote", path)
        print("wrote", export(path))


if __name__ == "__main__":
    main()
