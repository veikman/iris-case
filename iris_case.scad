// Design for a case to fit the Keebio Iris.

$fs = 1;
//$fs = 10;

matias_x2 = 13.4;
matias_x1a = 17.2;
matias_x1b = 7.2;
matias_x0 = 15.5;
matias_y2 = 13;  // Uneven; 12.5 might have served.
matias_y1a = 6.1;
matias_y1b = 14;
matias_y0 = 12.8;
matias_z = 11.6;
matias_z2 = 6.1;
matias_z1 = 1;
matias_z0 = 4.5;

pcb_thickness = 1.6;
pcb_hole_centers = [[28.155410, 46.238052],
                    [69.547785, 122.877339],
                    [65.908244, 46.327524],
                    [31.836313, 122.765746],
                    [92.440383, 29.718383]];
strut_foot_angles = [270,
                     340,
                     265,
                     200,
                     210];

cupola_d1 = 10;
cupola_d2 = 6;
cupola_h = cupola_d2;
pad_h = 30;
cupola_d_z0 = cupola_d2 + cupola_h * ((cupola_d1 - cupola_d2) / pad_h);

module matias_switch_body() {
  // A rough stack of bounding boxes for a Matias switch.
  layers = [[matias_x0, matias_y0, matias_z0],
            [matias_x1a, matias_y1a, matias_z1],
            [matias_x1b, matias_y1b, matias_z1],
            [matias_x0, matias_y0, matias_z1],
            [matias_x2, matias_y2, matias_z2]];
  heights = [matias_z0 / 2,
             matias_z0 + matias_z1 / 2,
             matias_z0 + matias_z1 / 2,
             matias_z0 + matias_z1 / 2,
             matias_z0 + matias_z1 + matias_z2 / 2];
  for (i = [0:len(layers) - 1])
    translate([0, 0, heights[i]])
      cube(layers[i], center=true);
}

module matias_socket_deep(thickness=2) {
  depth = matias_z0 + matias_z1 + thickness;
  difference() {
    translate([0, 0, (matias_z0 + matias_z1) - 2 * thickness])
      cube([matias_x1a + 2 * thickness, matias_y1b + 2 * thickness, depth], center=true);
    matias_switch_body();
  }
}

module matias_socket_rounded(r=3, thickness=2) {
  x = matias_x1a + thickness;
  y = matias_y1b + thickness;
  z = matias_z0 + matias_z1 - r;
  %matias_socket_deep();
  hull() {
    translate([x / 2, y / 2, z])
      sphere(r=r);
    translate([-x / 2, y / 2, z])
      sphere(r=r);
    translate([-x / 2, -y / 2, z])
      sphere(r=r);
    translate([x / 2, -y / 2, z])
      sphere(r=r);
  }
}

module matias_container() {
  hull()
    matias_switch_body();
}

module matias_legs() {
  translate([2.5, 4.5, -2])
    cylinder(r=1, h=4, center=true);
  translate([-2.5, 4, -2])
    cylinder(r=1, h=4, center=true);
}

module matias_switch_combo() {
  matias_switch_body();
  matias_legs();
}

module key(u=1) {
  translate([0, 0, 6.5 + 3.5])
    linear_extrude(11, scale=0.8)
      square([u * 18.1, 18.1], center=true);  // Cap in resting state.
  translate([0, 0, 6.5 + 3.5 / 2])
    cube([u * 18.1, 18.1, 3.5], center=true);  // Travel.
}

module outline() {
  // The outline of a Keebio PCB case plate.
  // Drawn in Inkscape from a raster scan of a real plate produced in late 2017.
  // Exported from Inkscape with OpenSCAD converter v6 by dnewman.
  polygon([[8.229290,27.210460],[3.490204,40.291260],[1.230911,52.652000],[0.605769,57.018190],[0.000015,64.867230],[0.074499,71.217510],[1.940713,92.745170],[3.021762,102.820480],[5.943017,121.521190],[6.714718,125.710490],[10.642858,141.544240],[10.889270,142.762250],[11.367868,143.509350],[12.158006,143.980770],[13.064017,144.177610],[87.816652,144.393820],[89.079475,144.310120],[89.792468,143.877220],[90.386764,143.210180],[90.562922,142.231620],[90.505152,141.410900],[90.510252,79.551890],[90.794393,78.537780],[91.586998,77.759500],[92.471096,77.338700],[105.021385,77.388600],[105.994745,77.115130],[106.667315,76.395850],[106.981545,75.618890],[106.996545,63.000420],[108.217415,52.642530],[109.931705,45.175670],[112.893955,36.806890],[120.654485,22.982720],[121.108845,21.921560],[121.056645,20.952740],[120.735705,19.955570],[119.968795,19.229380],[87.342788,0.563810],[86.391893,0.093570],[85.205332,0.161570],[84.110418,0.616930],[83.435818,1.547290],[81.021842,5.536800],[79.435025,8.059890],[76.842387,12.110060],[72.591288,18.347250],[69.930727,20.913620],[67.060181,23.272320],[63.049551,24.473890],[56.917360,25.060780],[10.520348,24.938270],[9.683838,25.008070],[8.909483,25.525030],[8.390111,26.294150]]);
}

module screw_placement() {
  // A set of displacements for the holes in a case plate.
  for (i = [0:len(pcb_hole_centers) - 1]) {
    translate(pcb_hole_centers[i])
      children();
  }
}

module tenting() {
  rotate([-10, 0, 0])
    children();
}

module main_switch_plane() {
  translate([0, 0, 32])
    tenting()
      children();
}
// #cube([150, 150, 7]); // Minimum safe height, lowest corner, due to PCB components on Iris board.

module wall_bound() {
  offset(2)
    outline();
}

module wall_footprint() {
  difference() {
    wall_bound();
    offset(-1.4)
      outline();
  }
}

module wall_block() {
  // The outside shape of the main block.
  difference() {
    linear_extrude(50)
      projection()
        tenting()
          linear_extrude(.01)
            wall_bound();
    ceiling();
  }
}

module wall_positive() {
  linear_extrude(50)
    projection()
      tenting()
        linear_extrude(.01)
          wall_footprint();
}

module ceiling() {
  main_switch_plane()
    linear_extrude(60)
      offset(20)  // Some margin.
        outline();
}

module case_floor() {
  depth = 50;
  translate([0, 0, -depth])
    cube([300, 300, depth]);
}

//module cupola_unrenderably_fancy() {
module cupola() {
  // A generic smooth nub for Minkowski sums.
  // OpenSCAD’s renderer throws an exception when this is highly detailed.
  hull() {
    translate([0, 0, cupola_h/2])
      sphere(d=cupola_d2);
    translate([0, 0, -pad_h])
      cylinder(h=0.001, d=cupola_d1);
  }
}

module cupola_simple() {
  // A generic smooth nub for Minkowski sums.
  union() {
  translate([0, 0, cupola_h/2])
    sphere(d=cupola_d2);
  translate([0, 0, -pad_h])
    cylinder(h=pad_h + cupola_h/2, d1=cupola_d1, d2=cupola_d2);
  }
}

module wall_base_composite() {
  difference() {
    wall_positive();
    ceiling();
  }
}

module pcb() {
  linear_extrude(pcb_thickness + 0.1)
    difference() {
      outline();
      screw_placement()
        circle(d=2);
    }
}

module pcb_struts() {
  module strut(center) {
    hull() {
      intersection() {
	union() {
	  // One leg square with the PCB.
	  main_switch_plane()
	    translate([0, 0, -50])
	      linear_extrude(50)
		translate(center)
		  circle(d=4);
	  // One leg in line with gravity.
	  linear_extrude(40)
	    projection()
	      main_switch_plane()
		linear_extrude(0.01)
		  translate(center)
		    circle(d=4);
	}
        wall_block();
      }
    }
  }
  for (i = [0:len(strut_foot_angles) - 1]) {
    strut(pcb_hole_centers[i]);
    minkowski() {
      linear_extrude(1)
	hull() {
	  projection()
	    strut(pcb_hole_centers[i]);
	  translate(pcb_hole_centers[i])
	    rotate([0, 0, strut_foot_angles[i]])
	      translate([30, 0])
		circle(d=16);
	}
      cylinder(h=2, d1=2, d2=0);
    }
  }
}

module wrist_rest() {
  // With some garbage below z=0 and inside the case.
  plinth_x = 192;
  plinth_y = 110;
  
  module support() {
    translate([plinth_x, plinth_y, pad_h])
      scale([1.5, 1, 0.2])
        sphere(30);
  }

  minkowski() {
    cupola($fn=20);  // Will not render at $fs > ~7.
    difference() {
      union() {
	support();
	linear_extrude(0.001)
	  offset(-cupola_d_z0/2)
	    hull() {
	      //translate([115, 50, 0]) square([15, 15]);
	      translate([85, 78, 0])
		square([1, 66]);
	      offset(cupola_d1/2)
		projection()
		  support();
	    }
      }
      translate([plinth_x - 55, plinth_y - 35, 0])
	cylinder(h=100, d=100);
    }
  }
}

module half() {
  post_angle = 29;

  module t5() {
    // Thumb key reference frame.
    translate([113, 19, 14.4])
      rotate([90, -90, post_angle])
        children();
  }
  module t6() {
    translate([119, 49, 14.4])
      rotate([90, -90, post_angle])
        children();
  }
  module external_post() {
    // The socket for thumb key 6 is not beneath the PCB.
    hull() {
      union() {
        t6()
          matias_socket_rounded();
        linear_extrude(10)
          projection()
            t6()
              matias_socket_rounded();
      }
      intersection() {
        translate([100, 49, 0])
          rotate([0, 0, post_angle])
            linear_extrude(30)
              square(21);
      difference() {
        wall_block();
        linear_extrude(100)
          outline();
        }
      }
    }
  }
  module led_cutout() {
    rotate([90, 0, 0])
      cylinder(h=10, d=4);
    cube([5, 3, 5], center=true);
    cube([10, 2, 5], center=true);
  }

  // The model.
  difference() {
    union() {
      intersection() {
        union() {
          wall_positive();
          pcb_struts();
          linear_extrude(18)
            offset(2)
              projection()
                t5()
                  matias_container();
        }
        wall_block();
      }
      external_post();
      difference() {
	wrist_rest();
	wall_block();
	case_floor();
      }
    }
    main_switch_plane()
      translate([0, 0, -pcb_thickness])
        pcb();
    t5()
      matias_switch_combo();
    t6()
      matias_switch_combo();

    // A cutout for accessing the copper on thumb switch 6.
    translate([100, 41, 0])
      rotate([0, 0, post_angle])
        linear_extrude(18)
          square([18, 23]);

    // A cutout for the serial cable that runs between the halves.
    main_switch_plane()
      translate([58, 17, -8.75])
        rotate([0, 90, post_angle])
          cylinder(h=20, d1=15, d2=8);

    // A cutout for the Pro Micro, its connector and LED, and the reset switch.
    main_switch_plane()
      translate([-10, 60, -9])
        rotate([0, 90, 0])
          hull() {
            cylinder(h=20, d=13);
            translate([0, 20, 0])
              cylinder(h=20, d=13);
          }

    // Two cutout for LEDs.
    translate([20, 26, 18]) {
      led_cutout();
      translate([16.5, 0, 0])
        led_cutout();
    }
  }

  // For illustration, two simple models of the thumb keys.
  %t5()
    key();
  %t6()
    key();
}

half();

