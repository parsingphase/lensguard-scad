// Switch guard for a Sigma 100-400mm zoom lens
// Measured on a Canon EF mount variant
// Note: this is an untested (unprinted) model

// fine
$fa = 1;
$fs = 0.4;

//fast
//$fa = 2;
//$fs = 5;

// X-axis: towards switches
// Y-axis: towards distance dial (top of lens)
// Z-axis: towards subject

// Switch ring profile is FLAT

// Configuration
// units: mm (we can measure this with a flexible tape, easier than measuring diameter or angle)
barrelCircumferenceMeasured = 268;
barrelCircumference = barrelCircumferenceMeasured;
switchArc = 92;
displayArc = 42;
switchDisplayOffsetArc = 6;

ringSegmentWidth = 34; // how wide the actual lens segment is - not used for calculation
ringSegmentMeasuredDiameter = 84; // caliper-measured, not used for calculation, just for checking radius

bandWidth = 32; // cylinder height of band
bandInnerRadius = barrelCircumference / (2 * PI);
bandThickness = 2;
nearSwitchGuardWidth = 3; // how much we leave on the camera side of the cut-out for the switches
farSwitchGuardWidth = 3; // < 0… don't
farSwitchGuardRelief = 5; // space to let us slide the front guard over the switches
shieldThickness = 8; // mm, starts just beyond the inner edge of the band
shieldSquareTrim = - 1; // how far we cut the shield back from being circular; <0 = "don't
shieldPillarWidthArc = 12; // limited gap from switches to display, we might make one end wider
displayPanelHeight = 12;
bandAdjustmentGap = 3; // How wide a gap to leave in the band to allow tension adjustment, <=0 for none
closureScrewOutsideDiameter = 3 ; // #4 screw = 0.1120" = 2.84 mm
closureScrewWasherDiameter = 7; // Larger of head / washer. If you want clearance from washer to band, add it here
// Estimate on #4 screw - 1/4" per https://threadsource.com/us-nut-size-table/

// Maths
switchGapAngle = switchArc * (360 / barrelCircumference);
shieldEdgeAngle = shieldPillarWidthArc * (360 / barrelCircumference);
displayGapWidthAngle = displayArc * (360 / barrelCircumference);
displayGapStartAngle = (0.5 * switchGapAngle) + (switchDisplayOffsetArc * (360 / barrelCircumference));

// Modules
module switchShield() {
  translate([0, 0, - bandWidth / 2])
    rotate(- switchGapAngle / 2 - shieldEdgeAngle)
      rotate_extrude(angle = switchGapAngle + (shieldEdgeAngle * 2))
        translate([bandInnerRadius + 0.5, 0, 0])
          square([shieldThickness, bandWidth]);
}

//module switchWindowWedge(xProject = 0, reduceAngle = 0) {
//  // gap for switches, wedge version
//
//  switchCutWedgeHeight = bandWidth - (nearSwitchGuardWidth + farSwitchGuardWidth);
//
//  // bottom of our wedge should be on z-plane after extrusion
//  // if we move down by (bandWidth / 2), wedge bottom is at ring bottom
//  translate([xProject, 0, + nearSwitchGuardWidth - (bandWidth / 2)]) // move down to leave visor space
//    rotate(- (switchGapAngle - reduceAngle) / 2)
//      rotate_extrude(angle = (switchGapAngle - reduceAngle))
//        translate([(bandInnerRadius - xProject) - 0.5, 0, 0])
//          square([(shieldThickness) * 1.5, switchCutWedgeHeight]);
//}

module switchWindowBox() {
  // gap for switches, box version

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

module displayWindow() {
  displayCutWedgeHeight = displayPanelHeight;
  translate([0, 0, - displayCutWedgeHeight / 2]) // span z-plane
    rotate(displayGapStartAngle)
      rotate_extrude(angle = displayGapWidthAngle)
        square([bandInnerRadius * 1.1, displayCutWedgeHeight]);
}

module mainBandOuterCylinder() {
    cylinder(bandWidth, r = bandInnerRadius + bandThickness, center = true);
}

module mainBandInnerCylinder() {
    cylinder(1.1 * bandWidth, r = bandInnerRadius, center = true);
  }

module closingScrewMount() {
  // screw mount natural radius:
  screwMountRadius = bandWidth / 2;
  screwMountScale = (closureScrewWasherDiameter / screwMountRadius);
  //subtract mainBandGap from this
  if (bandAdjustmentGap > 0) {
    // screw mount
    translate([- (bandInnerRadius + bandThickness), 0, 0])
      rotate([90, 0, 0])
        scale([screwMountScale, 1, 1]) // Reduce from semicircle.
          // scale depends on screw size & hole offset
          cylinder(2 * bandThickness + bandAdjustmentGap, r = screwMountRadius, center = true);
  }
}

//subtractable
module mainBandGap() {
  if (bandAdjustmentGap > 0) {
    // gap
    translate([- bandInnerRadius - bandThickness / 2, 0, 0])
      cube([2 * bandWidth, bandAdjustmentGap, 1.1 * bandWidth], center = true);

    // screw hole
    translate([- bandInnerRadius - bandThickness - (closureScrewWasherDiameter / 2), 0, 0])
      rotate([90, 0, 0])
        cylinder(2.2 * bandThickness + bandAdjustmentGap, r = closureScrewOutsideDiameter / 2, center = true);
  }
}

module subtractor() {
  // gaps / relief:
  union() {
    mainBandInnerCylinder();
    switchWindowBox();
    displayWindow();
    intersection() {
      farShieldReliefWedge();
      translate([0, 0, bandWidth / 2])
        switchWindowBox();
    }
    mainBandGap();
  }
}

// Assembly
color("gray")
  difference() {
    union() {
      mainBandOuterCylinder();
      intersection() {
        switchShield();
        switchShieldBoundingBox();
      }
      closingScrewMount();
    }

    subtractor();
  };

//color("green")
//  subtractor();
