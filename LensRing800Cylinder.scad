// fine
$fa = 1;
$fs = 0.4;

//fast
$fa = 2;
$fs = 5;

// units: mm
barrelCircumferenceMeasured = 286; // measured - to give wriggle-room, we could increase this a little
barrelCircumference = 290;
footOffsetArc = 12;
switchArc = 80;
footWidthArc = 40;

bandWidth = 35;
bandInnerRadius = barrelCircumference / (2 * PI);
bandThickness = 2;
upperSwitchGuardThickness = 8; // how much we leave above the cut-out for the switches
lowerSwitchGuardThickness = 3;
switchGapAngle = ceil(switchArc * (360 / barrelCircumference));
footGapStartAngle = ceil(((switchArc / 2) + footOffsetArc) * (360 / barrelCircumference));
footGapWidthAngle = ceil(footWidthArc * (360 / barrelCircumference));
shieldEdgeAngle = (footGapStartAngle - (switchGapAngle / 2)); // how wide we want the "pillars"
shieldOverhang = 15; // mm
shieldLimiterWidth = bandInnerRadius * 1.5;
shieldSquareTrim = 5; // how far we cut the shield back from being circular; <0 = "don't

module switchShield() {
  translate([0, 0, - bandWidth / 2])
    rotate(- switchGapAngle / 2 - shieldEdgeAngle)
      rotate_extrude(angle = switchGapAngle + (shieldEdgeAngle * 2))
        translate([bandInnerRadius + 0.5, 0, 0])
          square([shieldOverhang, bandWidth]);
}

module switchWindowWedge() {
  // gap for switches

  switchCutWedgeHeight = bandWidth - (upperSwitchGuardThickness + lowerSwitchGuardThickness);

  // we only want to span the z-plane if we're assuming symmetry…
  //  translate([0, 0, - switchCutWedgeHeight / 2]) // span z-plane
  // bottom of our wedge should be on z-plane after extrusion
  // if we move down by (bandWidth / 2), wedge bottom is at ring bottom
  translate([0, 0, + lowerSwitchGuardThickness - (bandWidth / 2)]) // move down to leave visor space
    rotate(- switchGapAngle / 2)
      rotate_extrude(angle = switchGapAngle)
        square([(bandInnerRadius + shieldOverhang) * 1.1, switchCutWedgeHeight]);
}

module switchWindowBox() {
  // gap for switches

  switchCutWedgeHeight = bandWidth - (upperSwitchGuardThickness + lowerSwitchGuardThickness);

  // we only want to span the z-plane if we're assuming symmetry…
  //  translate([0, 0, - switchCutWedgeHeight / 2]) // span z-plane
  // bottom of our wedge should be on z-plane after extrusion
  // if we move down by (bandWidth / 2), wedge bottom is at ring bottom

  slotBoxLength = bandInnerRadius + 2 * shieldOverhang;
  slotBoxWidth = 2 * (bandInnerRadius * sin(switchGapAngle / 2));
  echo("slotBoxLength", slotBoxLength);
  echo("slotBoxWidth", slotBoxWidth);
  echo("switchCutWedgeHeight", switchCutWedgeHeight);
  translate([0, - slotBoxWidth / 2, + lowerSwitchGuardThickness - (bandWidth / 2)]) // move down to leave visor space
    cube([slotBoxLength, slotBoxWidth, switchCutWedgeHeight]);
}

module switchShieldBoundingBox() {
  limiterEdge = (bandInnerRadius + shieldOverhang - shieldSquareTrim) * 2;
  fudge = 4; // stop "nicks" at edge of visor
  cube([limiterEdge, bandInnerRadius * 2 - fudge, bandWidth], center = true);
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

color("gray")
  difference() {
    union() {
      mainBand();
      intersection() {
        switchShield();
        switchShieldBoundingBox();
      }
    }

    // gaps:
    union() {
      switchWindowBox();
      // gap for foot
      footWindow();
    }
  }

