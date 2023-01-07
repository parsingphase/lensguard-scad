$fa = 1;
$fs = 0.4;

// units: mm
barrelCircumference = 286; // measured - to give wriggle-room, we could increase this a little
footOffsetArc = 12;
switchArc = 80;
footWidthArc = 40;

// All to be verified - inexactly measured so far!
bandWidth = 35;
bandInnerRadius = 90;
bandThickness = 3;
switchBandRemain = 8; // how much we leave above the cut-out for the switches
switchGapAngle = ceil(switchArc * (360 / barrelCircumference));
echo("switchGapAngle", switchGapAngle);

footGapStartAngle = ceil(((switchArc / 2) + footOffsetArc) * (360 / barrelCircumference));
echo("footGapStartAngle", footGapStartAngle);

footGapWidthAngle = ceil(footWidthArc * (360 / barrelCircumference));
shieldEdgeAngle = (footGapStartAngle - (switchGapAngle / 2)); // how wide we want the "pillars"
shieldOverhang = 30; // mm
shieldLimiterWidth = bandInnerRadius * 1.5;
shieldSquareTrim = - 1; // how far we cut the shield back from being circular; <0 = "don't

color("gray")
    difference() {
        union() {
            difference() {
                // ring wall
                difference() {
                    cylinder(bandWidth, r = bandInnerRadius + bandThickness, center = true);
                    cylinder(1.1 * bandWidth, r = bandInnerRadius, center = true);
                }

                // gap for switches
                switchCutWedgeHeight = bandWidth;
                translate([0, 0, - switchCutWedgeHeight / 2]) // span z-plane
                    translate([0, 0, - switchBandRemain]) // move down to leave visor space
                        rotate(- switchGapAngle / 2)
                            rotate_extrude(angle = switchGapAngle)
                                square([bandInnerRadius * 1.1, switchCutWedgeHeight]);


            }

            intersection() {
                union() {
                    // button shield "visor"
                    translate([0, 0, bandWidth / 2 - switchBandRemain])
                        rotate(- switchGapAngle / 2 - shieldEdgeAngle)
                            rotate_extrude(angle = switchGapAngle + (shieldEdgeAngle * 2))
                                translate([bandInnerRadius + 0.5, 0, 0])
                                    square([shieldOverhang, switchBandRemain]);

                    // button shield edges
                    translate([0, 0, - bandWidth / 2])
                        rotate(switchGapAngle / 2)
                            rotate_extrude(angle = shieldEdgeAngle)
                                translate([bandInnerRadius + 0.1, 0, 0])
                                    square([shieldOverhang, bandWidth]);

                    translate([0, 0, - bandWidth / 2])
                        rotate(- switchGapAngle / 2 - shieldEdgeAngle)
                            rotate_extrude(angle = shieldEdgeAngle)
                                translate([bandInnerRadius + 0.1, 0, 0])
                                    square([shieldOverhang, bandWidth]);
                }
                //// button shield limits
                limiterEdge = (bandInnerRadius + shieldOverhang - shieldSquareTrim) * 2;
                fudge = 9; // stop "nicks" at edge of visor
                color("green")
                    cube([limiterEdge, bandInnerRadius * 2 - fudge, 1.1 * bandWidth], center = true);
            }
        }

        // gap for foot
        footCutWedgeHeight = bandWidth * 1.1;
        translate([0, 0, - footCutWedgeHeight / 2]) // span z-plane
            rotate(footGapStartAngle)
                rotate_extrude(angle = footGapWidthAngle)
                    square([bandInnerRadius * 1.1, footCutWedgeHeight]);
    }
