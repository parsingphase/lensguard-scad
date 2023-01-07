// Switch guard for a Canon RF 800mm f/11 IS STM lens
// Note: this is an untested (unprinted) model

// fine
//$fa = 1;
//$fs = 0.4;

//fast
$fa = 2;
$fs = 5;

// Configuration
// units: mm (we can measure this with a flexible tape, easier than measuring diameter or angle)
barrelCircumferenceMeasured = 286; // measured - to give wriggle-room, we could increase this a little
barrelCircumference = 290;
switchArc = 80;
footOffsetArc = 12; // from end of switches
footWidthArc = 40;

bandWidth = 35; // cylinder height of band
bandInnerRadius = barrelCircumference / (2 * PI);
bandThickness = 2;
upperSwitchGuardWidth = 8; // how much we leave above the cut-out for the switches
lowerSwitchGuardWidth = 3; // < 0… don't
lowerSwitchGuardRelief = 4; // space to let us slide the lower (front) guard over the switches

// Maths
switchGapAngle = switchArc * (360 / barrelCircumference);
footGapStartAngle = ((switchArc / 2) + footOffsetArc) * (360 / barrelCircumference);
footGapWidthAngle = footWidthArc * (360 / barrelCircumference);
shieldEdgeAngle = footGapStartAngle - (switchGapAngle / 2); // how wide we want the "pillars"
shieldThickness = 8; // mm, starts just beyond the inner edge of the band
shieldSquareTrim = - 1; // how far we cut the shield back from being circular; <0 = "don't

// Modules
module switchShield() {
  translate([0, 0, - bandWidth / 2])
    rotate(- switchGapAngle / 2 - shieldEdgeAngle)
      rotate_extrude(angle = switchGapAngle + (shieldEdgeAngle * 2))
        translate([bandInnerRadius + 0.5, 0, 0])
          square([shieldThickness, bandWidth]);
}

module switchWindowWedge(xProject = 0, reduceAngle = 0) {
  // gap for switches

  switchCutWedgeHeight = bandWidth - (upperSwitchGuardWidth + lowerSwitchGuardWidth);

  // bottom of our wedge should be on z-plane after extrusion
  // if we move down by (bandWidth / 2), wedge bottom is at ring bottom
  translate([xProject, 0, + lowerSwitchGuardWidth - (bandWidth / 2)]) // move down to leave visor space
    rotate(- (switchGapAngle - reduceAngle) / 2)
      rotate_extrude(angle = (switchGapAngle - reduceAngle))
        translate([(bandInnerRadius - xProject) - 0.5, 0, 0])
          square([(shieldThickness) * 1.5, switchCutWedgeHeight]);
}

module switchWindowBox() {
  // gap for switches

  switchCutWedgeHeight = bandWidth - (upperSwitchGuardWidth + lowerSwitchGuardWidth);

  // we only want to span the z-plane if we're assuming symmetry…
  //  translate([0, 0, - switchCutWedgeHeight / 2]) // span z-plane
  // bottom of our wedge should be on z-plane after extrusion
  // if we move down by (bandWidth / 2), wedge bottom is at ring bottom

  slotBoxLength = bandInnerRadius + 2 * shieldThickness;
  slotBoxWidth = 2 * (bandInnerRadius * sin(switchGapAngle / 2));
  echo("slotBoxLength", slotBoxLength);
  echo("slotBoxWidth", slotBoxWidth);
  echo("switchCutWedgeHeight", switchCutWedgeHeight);
  translate([0, - slotBoxWidth / 2, + lowerSwitchGuardWidth - (bandWidth / 2)]) // move down to leave visor space
    cube([slotBoxLength, slotBoxWidth, switchCutWedgeHeight]);
}

module switchShieldBoundingBox() {
  limiterEdge = (bandInnerRadius + shieldThickness - shieldSquareTrim) * 2;
  fudge = 4; // stop "nicks" at edge of visor
  cube([limiterEdge, bandInnerRadius * 2 - fudge, bandWidth], center = true);
}

module lowerShieldReliefWedge() {
  // gap for switches
  switchCutWedgeHeight = bandWidth - (upperSwitchGuardWidth + lowerSwitchGuardWidth);
  // bottom of our wedge should be on z-plane after extrusion
  // if we move down by (bandWidth / 2), wedge bottom is at ring bottom
  translate([0, 0, - lowerSwitchGuardWidth / 2 - bandWidth / 2]) // move down to leave visor space
    rotate(- (switchGapAngle) / 2)
      rotate_extrude(angle = (switchGapAngle))
        square([bandInnerRadius + lowerSwitchGuardRelief, lowerSwitchGuardWidth * 2]);
}

module footWindow() {
  footCutWedgeHeight = bandWidth * 1.1;
  translate([0, 0, - footCutWedgeHeight / 2]) // span z-plane
    rotate(footGapStartAngle)
      rotate_extrude(angle = footGapWidthAngle)
        square([bandInnerRadius * 1.1, footCutWedgeHeight]);
}

module mainBand() {
  difference() {
    cylinder(bandWidth, r = bandInnerRadius + bandThickness, center = true);
    cylinder(1.1 * bandWidth, r = bandInnerRadius, center = true);
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

    // gaps / relief:
    union() {
      switchWindowWedge(0, 0);
      footWindow();
      lowerShieldReliefWedge();
    }
  };

