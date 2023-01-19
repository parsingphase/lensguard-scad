// Switch guard for a Canon RF 800mm f/11 IS STM lens
// Note: this is an untested (unprinted) model

// fine
$fa = 1;
$fs = 0.4;

//fast
//$fa = 2;
//$fs = 5;

// X-axis: towards switches
// Y-axis: away from foot
// Z-axis: towards subject

// Configuration
// units: mm (we can measure this with a flexible tape, easier than measuring diameter or angle)
barrelCircumferenceMeasured = 286; // measured, at peak of rim
//barrelCircumference = 286; // Work for 91mm diameter when closing loop with foot
barrelCircumference = 282; // Work for 90mm diameter when foot has adjustment
switchArc = 80; // 80 by tape at switch surface to base of slope
footOffsetArc = 12; // from end of switches, slope base to slope base
footWidthArc = 36; // slope base to slope base
footSurfaceFromCenter = 95 - (90 / 2);
footPlateThickness = 2; // balance between strength and required screw length

bandWidth = 32; // cylinder height of band; lens segment is 36 mm, minus 3 at back, 1 at front
bandInnerRadius = barrelCircumference / (2 * PI);
bandThickness = 2;
nearSwitchGuardWidth = 3; // how much we leave on the camera side of the cut-out for the switches
farSwitchGuardWidth = 3; // < 0… don't
farSwitchGuardRelief = 2; // space to let us slide the front guard over the switches
// probably only need 2mm farSwitchGuardRelief if measures are valid
shieldThickness = 5; // mm, starts just beyond the inner edge of the band
shieldSquareTrim = - 1; // how far we cut the shield back from being circular; <0 = "don't

bandAdjustmentGap = 3; // How wide a gap to leave in the band to allow tension adjustment, <=0 for none

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
pillarWidthFudge = 8; // increase angle until we don't get a notch when we apply bounding box
shieldEdgeAngle = footGapStartAngle - (switchGapAngle / 2) + pillarWidthFudge; // how wide we want the "pillars"

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

  switchCutWedgeHeight = bandWidth - (nearSwitchGuardWidth + farSwitchGuardWidth);

  // bottom of our wedge should be on z-plane after extrusion
  // if we move down by (bandWidth / 2), wedge bottom is at ring bottom
  translate([xProject, 0, + nearSwitchGuardWidth - (bandWidth / 2)]) // move down to leave visor space
    rotate(- (switchGapAngle - reduceAngle) / 2)
      rotate_extrude(angle = (switchGapAngle - reduceAngle))
        translate([(bandInnerRadius - xProject) - 0.5, 0, 0])
          square([(shieldThickness) * 1.5, switchCutWedgeHeight]);
}

module switchWindowBox() {
  // gap for switches, box version - not currently used

  switchCutWedgeHeight = bandWidth - (nearSwitchGuardWidth + farSwitchGuardWidth);

  // we only want to span the z-plane if we're assuming symmetry…
  //  translate([0, 0, - switchCutWedgeHeight / 2]) // span z-plane
  // bottom of our wedge should be on z-plane after extrusion
  // if we move down by (bandWidth / 2), wedge bottom is at ring bottom

  slotBoxLength = bandInnerRadius + 2 * shieldThickness;
  slotBoxWidth = 2 * (bandInnerRadius * sin(switchGapAngle / 2));

  translate([0, - slotBoxWidth / 2, + nearSwitchGuardWidth - (bandWidth / 2)]) // move down to leave visor space
    cube([slotBoxLength, slotBoxWidth, switchCutWedgeHeight]);
}

module switchShieldBoundingBox() {
  limiterEdge = (bandInnerRadius + shieldThickness - shieldSquareTrim) * 2;
  fudge = 0; // stop "nicks" at edge of visor
  cube([limiterEdge, bandInnerRadius * 2 - fudge, bandWidth], center = true);
}

module farShieldReliefWedge() {
  // bottom of our wedge should be on z-plane after extrusion
  // if we move down by (bandWidth / 2), wedge bottom is at ring bottom
  translate([0, 0, - farSwitchGuardWidth * 1.5 + bandWidth / 2]) // move down to leave visor space
    rotate(- (switchGapAngle) / 2)
      rotate_extrude(angle = (switchGapAngle))
        square([bandInnerRadius + farSwitchGuardRelief, farSwitchGuardWidth * 2]);
}

module footWindow() {
  // not used with mount
  footCutWedgeHeight = bandWidth * 1.1;
  translate([0, 0, - footCutWedgeHeight / 2]) // span z-plane
    rotate(- footGapStartAngle)
      rotate_extrude(angle = - footGapWidthAngle)
        square([bandInnerRadius * 1.1, footCutWedgeHeight]);
}

module footCutOut() {
  translate([0, - footSurfaceFromCenter / 2, 0])
    cube([footWidthArc, footSurfaceFromCenter, bandWidth * 1.1], center = true);
}

module cylinderCore() {
  cylinder(1.1 * bandWidth, r = bandInnerRadius, center = true);
}

module mainBand() {
  //  difference() {
  cylinder(bandWidth, r = bandInnerRadius + bandThickness, center = true);
  //    cylinderCore();
  //  }
}

module footMountBlock() {
  footMountThickness = (footSurfaceFromCenter + footPlateThickness - bandInnerRadius) * 2;
  translate([0, - bandInnerRadius, 0])
    difference() {
      // foot block main body
      cube([footWidthArc + 2 * footPlateThickness, footMountThickness, bandWidth], center = true);
      union() {
        // Main screw hole
        translate([0, 0, - 3])
          rotate([90, 0, 0])
            cylinder(footMountThickness * 1.1, r = 5, center = true);
        // Main screw should be centered 16 mm from back of lens segment (20 from front)
        // ie 13mm from back edge of band, 19 from front
        // band is 32 (CHECK CHANGES!), so default offset is 16
        // so move 3mm towards back / bottom
        // pin hole
        translate([0, 0, 11])
          rotate([90, 0, 0])
            cylinder(footMountThickness * 1.1, r = 3, center = true);
        // Pin should be 27 mm from back of band (5 from front), so r=3 means thin front band
      }
    }
}

module mainBandGap() {
  if (bandAdjustmentGap > 0) {
    translate([0, - footSurfaceFromCenter - bandThickness / 2, 0])
      cube([bandAdjustmentGap, , 2 * bandThickness, 1.1 * bandWidth], center = true);
  }
}

module subtractor() {
  // gaps / relief:
  union() {
    switchWindowWedge(0, 0);
    //    footWindow();
    footCutOut();
    farShieldReliefWedge();
    cylinderCore();
    mainBandGap();
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
      footMountBlock();
    }

    subtractor();
  };

//color("green")
//  subtractor();
