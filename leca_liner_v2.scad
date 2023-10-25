$fa = 4.5;
$fs = 2.3;

// Instructions to create a pot liner:
//  - set is the height of the liner
//  - set the top_diameter
//  - set the bottom_diameter.

// Troubleshooting:
// If the holes in the side are overlapping, there are a couple things you can try:
//  - try changing the hole_radius to something smaller


// Notes:
//  - It's usually best to make the top_diameter a few mm smaller than the actual diameter
//  - Even if the pot is a cylinder and doesn't taper, set bottom_diameter about 10mm smaller than the top_diameter

height          = 100; // Height in millimeters from the rim of the pot to the bottom of the inside of the pot
top_diameter    = 100; // Top Diameter in millimeters.
bottom_diameter = 80; // Bottom Diameter in millimeters.

name_label      = "barrel";


// This is the tabs for the top to help make the liner easier to remove.
//    I typically melt these with a torch when it's in the pot to wrap them over the edge.
//    They can be pretty fragile and often fall off.
has_tab       = 1;
tab_width     = 10;
tab_height    = 15;
tab_thickness = 2.5;
tab_angle     = 45;


thickness     = 1.6; //<-- Make this param at least 2x the external perimeter width setting from your slicer
hole_radius   = 2.2;//3.7; //<-- might need to be adjusted for smaller pots. 3.7 seems good for standard leca.
num_vert      = (height/(2*hole_radius+1))-2; //<-- number of rows on the side of the liner

large         = false; //<-- experimental, will save filament, but you will need to manually change "hole_radius=2". You will probably also need to change openscad settings to handle more rendered elements (edit->preferences->advanced)

bottom_radius = bottom_diameter/2;
top_radius    = top_diameter/2;





//make horizontal hole first row
module make_horiz_holes_single(hole_radius, height, width, large_liner){
    for(k=[1:12])
    {
        translate([0,0,hole_radius*2+1]) 
        {
            if (large_liner == false) {
                rotate([90,0,20*k])
                {
                    cylinder($fs=4, width,r=hole_radius, center=true);
                }
            } else {
                rotate([90,0,15*k])
                {
                    scale([3.6,0.8,3]) {
                        cube([hole_radius*2, hole_radius*2, width], center=true);
                    }
                }    
            }
        }
    }
}
// Create copies first row of horizontal holes to match the height of the liner
module make_horiz_holes(hole_radius, height, top_radius, large_liner) {
    for(k=[0:num_vert])
    {
        if (large_liner == false) {
            translate([0,0,hole_radius*2.5*k]) 
            {
                rotate([0,0,10*k])
                {
                    make_horiz_holes_single(hole_radius, height, top_radius*2+50, large_liner);
                }
            }
        } else {
            hole_radius = 2;
            translate([0,0,hole_radius*2.5*k]) 
            {
                rotate([0,0,5.9*k])
                {
                    make_horiz_holes_single(hole_radius, height, top_radius*2+50, large_liner);
                }
            }
        }
    }
}


// Create the holes in the bottom of the liner based on the size of the bottom radius
module make_vert_holes(hole_radius, bottom_radius) {
    for (j=[1:8]) {
        // Normal Orientation
        rotate([0,0,45*j]) {
            for (i=[0:bottom_radius/13]) {
                translate([i*8,i*8,0]) 
                {
                    rotate([0,0,20])
                    {
                        cylinder($fs=5, 30,r=hole_radius, center=true);
                    }
                }    
            }
        }
        // Offset Orientation
        //   This was added to have more holes in the bottom without overlapping the holes
        rotate([0,0,45*j+22.5]) {
            for (i=[2:bottom_radius/13]) {
                translate([i*8,i*8,0]) 
                {
                    rotate([0,0,20])
                    {
                        cylinder($fs=5, 30,r=hole_radius, center=true);
                    }
                }    
            }
        }
    }
}

module make_outer_shell(top_radius, bottom_radius, height, thickness) {
    difference() {
        difference() {
            union () {
                cylinder(height, r1=bottom_radius, r2=top_radius, center=false);
                make_tab(tab_width, tab_height, tab_thickness, tab_angle, height, top_radius,thickness);
            }
            translate([0,0,thickness]) {
                difference() {
                    cylinder(height, r1=bottom_radius-(thickness), r2=top_radius-(thickness/2), center=false);
                    cylinder(4.9, r1=top_radius, r2=top_radius, center=false);
                }
            }
        }
        // Create angled wall at the bottom to stregthen the liner
        translate ([0,0,thickness]) {
            cylinder(5, r1=bottom_radius-thickness-6, r2=bottom_radius-(thickness));
        }
    }
}

module make_tab (tab_width, tab_height, tab_thickness, tab_angle, height, top_radius, thickness) {
    translate([0,top_radius-tab_thickness/2-thickness/2,height-tab_thickness]) {
        rotate([-tab_angle,0,0]){
            translate([0,0,tab_height/2]){
                cube(size = [tab_width, tab_thickness, tab_height], center=true);
            }
        }
    }
    translate([0,-1*(top_radius-tab_thickness/2-thickness/2),height-tab_thickness]) {
        rotate([tab_angle,0,0]){
            translate([0,0,tab_height/2]){
                cube(size = [tab_width, tab_thickness, tab_height], center=true);
            }
        }
    }
}

module make_label (name_label, top_diameter, bottom_diameter, height, thickness, hole_radius) {
    hole_diameter = hole_radius*2;
    translate([0,hole_diameter,-1]){
         resize([bottom_diameter-thickness*2, hole_diameter*2, 1.3]) {
             linear_extrude(1) {
                 rotate([0,180,0]) {
                     text(name_label, valign="center",halign="center");
                 }
             }
         }
     }
     size_label = str(height,"h ",top_diameter," ",bottom_diameter);
     translate([0,-(hole_diameter),-1]){
         resize([bottom_diameter-thickness*2, hole_diameter*2, 1.3]) {
             linear_extrude(1) {
                 rotate([0,180,0]) {
                     text(size_label, valign="center",halign="center");
                 }
             }
         }
     }
     
}

difference() {
    //Create the outer shell
    make_outer_shell(top_radius, bottom_radius, height, thickness);
    //Create the vertical and horizontal drainage holes
    union() {
        make_vert_holes(hole_radius, bottom_radius);            
        make_horiz_holes(hole_radius-0.1, height, top_radius, large);
        
    }
    make_label(name_label, top_diameter, bottom_diameter, height, thickness, hole_radius);
}


