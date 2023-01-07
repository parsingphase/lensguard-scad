$fa = 1;
$fs = 0.4;

// units: mm
barrelCircumference = 286;
footOffsetArc = 12;
switchArc = 80;
footWidthArc = 40;

// All to be verified - inexactly measured so far!
bandWidth = 35;
bandInnerRadius = 90;
bandThickness = 4;
switchBandRemain = 10; // how much we leave above the cut-out for the switches
switchGapAngle = 60;
footGapStartAngle = 100;
footGapWidthAngle = 50;
shieldEdgeAngle = 15;
shieldOverhang = 30;
shieldLimiterWidth = bandInnerRadius * 1.5;
shieldSquareTrim = 10; // how far we cut the shield back from being circular
//buttonGapWidth = 20;

difference() {
    difference() {
        cylinder(bandWidth, r = bandInnerRadius + bandThickness, center = true);
        cylinder(1.1 * bandWidth, r = bandInnerRadius, center = true);
    }

    // gap for switches
    switchCutWedgeHeight = bandWidth;
    translate([0, 0, - switchCutWedgeHeight / 2]) // span z-plane
        translate([0, 0, - switchBandRemain])
            rotate_extrude(angle = switchGapAngle)
                square([bandInnerRadius * 1.1, switchCutWedgeHeight]);

    // gap for foot
    footCutWedgeHeight = bandWidth * 1.1;
    translate([0, 0, - footCutWedgeHeight / 2]) // span z-plane
        rotate(footGapStartAngle)
            rotate_extrude(angle = footGapWidthAngle)
                square([bandInnerRadius * 1.1, footCutWedgeHeight]);
}

//color("blue")
intersection() {
    union() {
        // button shield "visor"
        translate([0, 0, bandWidth / 2 - switchBandRemain])
            rotate(- switchGapAngle)
                rotate_extrude(angle = switchGapAngle + (switchGapAngle * 2))
                    translate([bandInnerRadius + 0.1, 0, 0])
                        square([shieldOverhang, switchBandRemain]);

        // button shield edges
        translate([0, 0, - bandWidth / 2])
            rotate(- shieldEdgeAngle)
                rotate_extrude(angle = shieldEdgeAngle)
                    translate([bandInnerRadius + 0.1, 0, 0])
                        square([shieldOverhang, bandWidth]);

        translate([0, 0, - bandWidth / 2])
            rotate(switchGapAngle)
                rotate_extrude(angle = shieldEdgeAngle)
                    translate([bandInnerRadius + 0.1, 0, 0])
                        square([shieldOverhang, bandWidth]);
    }
    // button shield limits
    rotate(- switchGapAngle)
        cube([shieldLimiterWidth, (bandInnerRadius + shieldOverhang - shieldSquareTrim) * 2, 1.1 * bandWidth], center =
        true);
}

