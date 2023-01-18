// Switch guard for a Canon RF 800mm f/11 IS STM lens
// Note: this is an untested (unprinted) model

// fine
$fa = 1;
$fs = 0.4;

//fast
//$fa = 2;
//$fs = 5;

// Configuration
// units: mm (we can measure this with a flexible tape, easier than measuring diameter or angle)
barrelCircumferenceMeasured = 286; // measured, at peak of rim
barrelCircumference = 280; // Work from measured, at valley, 89 * PI = 279.602
echo("barrelCircumference",barrelCircumference);
switchArc = 80; // 80 by tape at switch surface to base of slope
footOffsetArc = 12; // from end of switches, slope base to slope base
footWidthArc = 36; // slope base to slope base

bandWidth = 32; // cylinder height of band
bandInnerRadius = barrelCircumference / (2 * PI);
bandThickness = 2;
broadSwitchGuardWidth = 3; // how much we leave on the camera side of the cut-out for the switches
narrowSwitchGuardWidth = 3; // < 0… don't
narrowSwitchGuardRelief = 2; // space to let us slide the front guard over the switches
// probably only need 2mm narrowSwitchGuardRelief if measures are valid
shieldThickness = 5; // mm, starts just beyond the inner edge of the band
shieldSquareTrim = - 1; // how far we cut the shield back from being circular; <0 = "don't

// Switch ring profile (measured by transfer calipers)
//  TOWARDS SUBJECT (outside is left)
//    / - slope -   91mm, asymmetric
//   | key plateau
//  || switch       92mm (in groove?)  asymmetric, 3mm from valley
//   | key plateau  92mm asymmetric
//    ) valley -    89mm ⌀ symmetric
//   ( rim          91mm ⌀ symmetric                1 mm from valley
//  TOWARDS CAMERA

// With barrelCircumference 286, bandInnerDiameter = 91.0366
// With barrelCircumference 290, bandInnerDiameter = 92.3099

// Possible opportunity to add "spring lever" grippers on inside
// (diagonal, fixed at one end: ト - tricky to print/support?)

// Maths
switchGapAngle = switchArc * (360 / barrelCircumference);
footGapStartAngle = ((switchArc / 2) + footOffsetArc) * (360 / barrelCircumference);
footGapWidthAngle = footWidthArc * (360 / barrelCircumference);
shieldEdgeAngle = footGapStartAngle - (switchGapAngle / 2); // how wide we want the "pillars"

// Modules
module switchShield() {
  translate([0, 0, - bandWidth / 2])
    rotate(- switchGapAngle / 2 - shieldEdgeAngle)
      rotate_extrude(angle = switchGapAngle + (shieldEdgeAngle * 2))
        translate([bandInnerRadius + 0.5, 0, 0])
          square([shieldThickness, bandWidth]);
}

module switchWindowWedge(xProject = 0, reduceAngle = 0) {
  // gap for switches, wedge version

  switchCutWedgeHeight = bandWidth - (broadSwitchGuardWidth + narrowSwitchGuardWidth);

  // bottom of our wedge should be on z-plane after extrusion
  // if we move down by (bandWidth / 2), wedge bottom is at ring bottom
  translate([xProject, 0, + broadSwitchGuardWidth - (bandWidth / 2)]) // move down to leave visor space
    rotate(- (switchGapAngle - reduceAngle) / 2)
      rotate_extrude(angle = (switchGapAngle - reduceAngle))
        translate([(bandInnerRadius - xProject) - 0.5, 0, 0])
          square([(shieldThickness) * 1.5, switchCutWedgeHeight]);
}

module switchWindowBox() {
  // gap for switches, box version - not currently used

  switchCutWedgeHeight = bandWidth - (broadSwitchGuardWidth + narrowSwitchGuardWidth);

  // we only want to span the z-plane if we're assuming symmetry…
  //  translate([0, 0, - switchCutWedgeHeight / 2]) // span z-plane
  // bottom of our wedge should be on z-plane after extrusion
  // if we move down by (bandWidth / 2), wedge bottom is at ring bottom

  slotBoxLength = bandInnerRadius + 2 * shieldThickness;
  slotBoxWidth = 2 * (bandInnerRadius * sin(switchGapAngle / 2));

  translate([0, - slotBoxWidth / 2, + broadSwitchGuardWidth - (bandWidth / 2)]) // move down to leave visor space
    cube([slotBoxLength, slotBoxWidth, switchCutWedgeHeight]);
}

module switchShieldBoundingBox() {
  limiterEdge = (bandInnerRadius + shieldThickness - shieldSquareTrim) * 2;
  fudge = 4; // stop "nicks" at edge of visor
  cube([limiterEdge, bandInnerRadius * 2 - fudge, bandWidth], center = true);
}

module narrowShieldReliefWedge() {
  // bottom of our wedge should be on z-plane after extrusion
  // if we move down by (bandWidth / 2), wedge bottom is at ring bottom
  translate([0, 0, - narrowSwitchGuardWidth * 1.5 + bandWidth / 2]) // move down to leave visor space
    rotate(- (switchGapAngle) / 2)
      rotate_extrude(angle = (switchGapAngle))
        square([bandInnerRadius + narrowSwitchGuardRelief, narrowSwitchGuardWidth * 2]);
}

module footWindow() {
  footCutWedgeHeight = bandWidth * 1.1;
  translate([0, 0, - footCutWedgeHeight / 2]) // span z-plane
    rotate(- footGapStartAngle)
      rotate_extrude(angle = - footGapWidthAngle)
        square([bandInnerRadius * 1.1, footCutWedgeHeight]);
}

module mainBand() {
  difference() {
    cylinder(bandWidth, r = bandInnerRadius + bandThickness, center = true);
    cylinder(1.1 * bandWidth, r = bandInnerRadius, center = true);
  }
}

module subtractor() {
  // gaps / relief:
  union() {
    switchWindowWedge(0, 0);
    footWindow();
    narrowShieldReliefWedge();
  }
}

// Assembly
color("gray")
  difference() {
    union() {
      mainBand();
      intersection() {
        switchShield();
        switchShieldBoundingBox();
      }
    }

    subtractor();
  };
