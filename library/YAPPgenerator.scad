/*
***************************************************************************  
**  Yet Another Parameterised Projectbox generator
**
**  Version "v1.0 (02-01-2022)"
**
**  Copyright (c) 2021, 2022 Willem Aandewiel
**
**  TERMS OF USE: MIT License. See bottom offile.                                                            
***************************************************************************      
*/
//---------------------------------------------------------
// This design is parameterized based on the size of a PCB.
//---------------------------------------------------------
// Note: length/lengte refers to X axis, 
//       width/breedte to Y, 
//       height/hoogte to Z

/*
      padding-back|<------pcb length --->|<padding-front
                            RIGHT
        0    X-as ---> 
        +----------------------------------------+   ---
        |                                        |    ^
        |                                        |   padding-right 
        |                                        |    v
        |    -5,y +----------------------+       |   ---              
 B    Y |         | 0,y              x,y |       |     ^              F
 A    - |         |                      |       |     |              R
 C    a |         |                      |       |     | pcb width    O
 K    s |         |                      |       |     |              N
        |         | 0,0              x,0 |       |     v              T
      ^ |    -5,0 +----------------------+       |   ---
      | |                                        |    padding-left
      0 +----------------------------------------+   ---
        0    X-as --->
                          LEFT
*/

//-- which half do you want to print?
printTop          = true;
printBottom       = true;

//-- Edit these parameters for your own board dimensions
wall_thickness        = 2.0;
bottomPlane_thickness = 1.0;
topPlane_thickness    = 1.0;

//-- Total height of box = bottomPlane_thickness + topPlane_thickness 
//--                     + bottomWall_height + topWall_height
//-- space between pcb and topPlane :=
//--      (bottonWall_height+topWall_heigth) - (standoff_heigth+pcb_thickness)
bottomWall_height = 6;
topWall_height    = 5;

//-- ridge where bottom and top off box can overlap
//-- Make sure this isn't less than topWall_height
ridge_height      = 2;

//-- pcb dimensions
pcb_length        = 30;
pcb_width         = 20;
pcb_thickness     = 1.5;

//-- How much the PCB needs to be raised from the bottom
//-- to leave room for solderings and whatnot
standoff_height   = 4.0;
pin_diameter      = 1.0;
standoff_diameter = 3;
                            
//-- padding between pcb and inside wall
padding_front = 1;
padding_back  = 1;
padding_right = 1;
padding_left  = 1;


//-- D E B U G ----------------------------
show_side_by_side = true;       //-> true
showTop           = true;       //-> true
colorTop          = "yellow";   
showBottom        = true;       //-> true
colorBottom       = "white";
showPCB           = false;      //-> false
showMarkers       = false;      //-> false
intersect         = 0;  //-> 0=none (>0 from front, <0 from back)
//-- D E B U G ----------------------------

/*
********* don't change anything below this line ***************
*/

//-- constants, do not change
yappRectOrg     = 0;
yappRectCenter  = 1;
yappCircle      = 2;
yappBoth        = 3;
yappTopOnly     = 4;
yappBottomOnly  = 5;
yappHole        = 6;
yappPin         = 7;

//-- pcb_standoffs  -- origin is pcb-0,0
pcbStands = [//[ [0]pos_x, [1]pos_y
             //       , [2]{yappBoth|yappTopOnly|yappBottomOnly}
             //       , [3]{yappHole|yappPin} ]
//               [3,  3, yappBoth, yappHole] 
//              ,[3,  pcb_width-3, yappBoth, yappPin]
             ];

//-- front plane  -- origin is pcb-0,0 (red)
cutoutsFront = [//[ [0]y_pos, [1]z_pos, [2]width, [3]height
                //      , [4]{yappRectOrg | yappRectCenterd | yappCircle} ]
//                 [(pcb_width/2)-(12/2), -5, 12, 9, yappRectOrg]
//               , [10, 0, 12.5, 7, yappCircle]
                ];

//-- back plane   -- origin is pcb-0,0 (blue)
cutoutsBack = [//[ [0]y_pos, [1]z_pos, [2]width, [3]height
               //     , [4]{yappRectOrg | yappRectCenterd | yappCircle} ]
//                  [0, 0, 8, 5]
//                , [0, 2, 8, 5]
               ];

//-- top plane    -- origin is pcb-0,0
cutoutsTop = [//[ [0]x_pos,  [1]y_pos, [2]width, [3]length
              //    , [4]{yappRectOrg | yappRectCenterd | yappCircle} ]
//                  [0, 6, (pcb_length-12), 4, yappRectOrg]
//                , [pcb_width-4, 6, pcb_length-12, 4, yappCircel]
//             // , [0, 5, 8, 4, yappRectCenter]
              ];

//-- bottom plane -- origin is pcb-0,0
cutoutsBottom = [//[ [0]x_pos,  [1]y_pos, [2]width, [3]length
                 //   , [4]{yappRectOrg | yappRectCenter | yappCircle} ]
//                   [0, 6, (pcb_length-12), 5, true]
//                 , [pcb_width-5, 6, pcb_length-12, 5, false]
                 ];

//-- left plane   -- origin is pcb-0,0
cutoutsLeft = [//[[0]x_pos,  [1]z_pos, [2]width, [3]height ]
               //   , [4]{yappRectOrg | yappRectCenter | yappCircle} ]
//                [0, 10, 5, 2]
//              , [pcb_length-5, 6, 7,7]
               ];

//-- right plane   -- origin is pcb-0,0
cutoutsRight = [//[[0]x_pos,  [1]z_pos, [2]width, [3]height ]
                //   , [4]{yappRectOrg | yappRectCenter | yappCircle} ]
//                 [0, 1, 5, 2]
                 ];

//-- origin of labels is box [0,0]
labelsTop = [// [0]x_pos, [1]y_pos, [2]orientation, [3]font, [4]size, [5]"text"]
              [10, 10, 0, "Liberation Mono:style=bold", 5, "YAPP" ]
            ];

//-------------------------------------------------------------------

// Calculated globals
//pin_height = bottomWall_height + topWall_height - standoff_height; 

module pcb(posX, posY, posZ)
{
  difference()
  {
    translate([posX, posY, posZ])
    {
      color("red")
        cube([pcb_length, pcb_width, pcb_thickness]);
    
      if (showMarkers)
      {
        markerHeight=bottomPlane_thickness+bottomWall_height+pcb_thickness;
    
        translate([0, 0, 0])
          color("black")
            %cylinder(
              r = .5,
              h = markerHeight,
              center = true,
              $fn = 20);

        translate([0, pcb_width, 0])
          color("black")
            %cylinder(
              r = .5,
              h = markerHeight,
              center = true,
              $fn = 20);

        translate([pcb_length, pcb_width, 0])
          color("black")
            %cylinder(
              r = .5,
              h = markerHeight,
              center = true,
              $fn = 20);

        translate([pcb_length, 0, 0])
          color("black")
            %cylinder(
              r = .5,
              h = markerHeight,
              center = true,
              $fn = 20);

        translate([((box_length-(wall_thickness*2))/2), 0, pcb_thickness])
          rotate([0,90,0])
            color("red")
              %cylinder(
                r = .5,
                h = box_length+(wall_thickness*2),
                center = true,
                $fn = 20);
    
        translate([((box_length-(wall_thickness*2))/2), pcb_width, pcb_thickness])
          rotate([0,90,0])
            color("red")
              %cylinder(
                r = .5,
                h = box_length+(wall_thickness*2),
                center = true,
                $fn = 20);
                
      } // show_markers
    } // translate
    
    if (intersect < 0)
    {
      translate([box_length+intersect, -1, -1])
        cube([box_length, box_width+2, box_height+2], false);
    }
    else if (intersect > 0)
    {
      translate([intersect-box_length, -1, -1])
        cube([box_length, box_width+2, box_height+2], false);
    }
    
  } // intersect
  
} // pcb()


module halfBox(do_show, do_color, width, length, wallHeight, plane_thickness) 
{
  // Floor
  color(do_color)
    cube([length, width, plane_thickness]);
  
  if (do_show)
  {
    color(do_color)
    {
    // Left wall
    translate([0, 0, plane_thickness])
        cube([
            length,
            wall_thickness,
            wallHeight]);
    
    // Right wall
    translate([0, width-wall_thickness, plane_thickness])
        cube([
            length,
            wall_thickness,
            wallHeight]);
   
    // Rear wall
    translate([length - wall_thickness, wall_thickness, plane_thickness])
        cube([
            wall_thickness,
            width - 2 * wall_thickness,
            wallHeight]);
   
    // Front wall
    translate([0, wall_thickness, plane_thickness])
        cube([
            wall_thickness,
            width - 2 * wall_thickness,
            wallHeight]);
            
     } // color
  } // do_show
  
} // halfBox()

        
module pcb_standoff(color, height, type) 
{
        module standoff(color)
        {
          color(color,1.0)
            cylinder(
              r = standoff_diameter / 2,
              h = height,
              center = false,
              $fn = 20);
        } // standoff()
        
        module stand_pin(color)
        {
          color(color, 1.0)
            cylinder(
              r = pin_diameter / 2,
              h = (pcb_thickness*2)+standoff_height,
              center = false,
              $fn = 20);
        } // stand_pin()
        
        module stand_hole(color)
        {
          color(color, 1.0)
            cylinder(
              r = (pin_diameter / 2)+.1,
              h = (pcb_thickness*2)+height,
              center = false,
              $fn = 20);
        } // standhole()
        
        if (type == yappPin)  // pin
        {
         standoff(color);
         stand_pin(color);
        }
        else            // hole
        {
          difference()
          {
            standoff(color);
            stand_hole(color);
          }
        }
        
} // pcb_standoff()


module cutoutSquare(color, w, h) 
{
  color(color, 1)
    cube([wall_thickness+2, w, h]);
  
} // cutoutSquare()


//===========================================================
module bottom_case() 
{
    floor_width = pcb_length + padding_front + padding_back + wall_thickness * 2;
    floor_length = pcb_width + padding_left + padding_right + wall_thickness * 2;
    
    module box() 
    {
      halfBox(showBottom, colorBottom, floor_length, floor_width, bottomWall_height, bottomPlane_thickness);        
      
      if (showBottom)
      {
        color(colorBottom)
        {
        // front Ridge
        translate([
            wall_thickness / 2,
            wall_thickness / 2,
            bottomPlane_thickness + bottomWall_height])
              cube([
                wall_thickness / 2,
                floor_length - wall_thickness,
                ridge_height]);
     
        // back Ridge
        translate([
            floor_width - wall_thickness,
            wall_thickness / 2,
            bottomPlane_thickness + bottomWall_height])
              cube([
                wall_thickness / 2,
                floor_length - wall_thickness,
                ridge_height]);
                
        // right Ridge
        translate([
            wall_thickness,
            floor_length - wall_thickness,
            bottomPlane_thickness + bottomWall_height])
              cube([
                floor_width - wall_thickness * 2,
                wall_thickness / 2,
                ridge_height]);
              
        // left Ridge
        translate([
            wall_thickness,
            wall_thickness / 2,
            bottomPlane_thickness + bottomWall_height])
              cube([
                floor_width - 2 * wall_thickness,
                wall_thickness / 2,
                ridge_height]);
       
       }  // color
       
     } // showBottom
     
    } //  box()
        
    // Place the standoffs and through-PCB pins in the Bottom Box
    module pcb_holder() 
    {        
      //-- place pcb Standoff's
      for ( stand = pcbStands )
      {
        //-- [0]posx, [1]posy, [2]{yappBoth|yappTopOnly|yappBottomOnly}
        //--          , [3]{yappHole, YappPin}
        posx=pcbX+stand[0];
        posy=pcbY+stand[1];
        if (stand[2] != yappTopOnly)
        {
          translate([posx, posy, bottomPlane_thickness])
            pcb_standoff("green", standoff_height, stand[3]);
        }
      }
        
    } // pcb_holder()
   
    //-- place cutOuts in Bottom Box
    difference() 
    {
      box();        
      
      //-- [0]pcb_y, [1]pcb_z, [2]width, [3]height,
      //--                   [4]{yappRectOrg | yappRectCenterd | yappCircle} 
      for ( cutOut = cutoutsFront )
      {

        if (cutOut[4]==yappRectOrg)
        {
          posy=pcbY+cutOut[0];
          posz=pcbZ+cutOut[1];
          translate([box_length-wall_thickness, posy, posz])
            cutoutSquare("red", cutOut[2], cutOut[3]+bottomWall_height);
        }
        else if (cutOut[4]==yappRectCenter)
        {
          posy=pcbY+cutOut[0]-(cutOut[2]/2);
          posz=pcbZ+cutOut[1]-(cutOut[3]/2);
          translate([box_length-wall_thickness, posy, posz])
            cutoutSquare("red", cutOut[2], cutOut[3]+bottomWall_height);
        }
        else if (cutOut[4]==yappCircle)
        {
          posy=pcbY+cutOut[0]-(cutOut[2]/2);
          posz=pcbZ+cutOut[1];
          translate([box_length-wall_thickness, posy, posz])
            rotate([0,90,0])
              color("red")
                cylinder(h=wall_thickness, d=cutOut[2], $fn=20);
        }
      }
      
      //--[ [0]pcb_y, [1]pcb_z, [2]width, [3]height
      //--        , {yappRectOrg | yappRectCenter | yappCircle} ]
      for ( cutOut = cutoutsBack )
      {
        if (cutOut[4]==yappRectOrg)
        {
          posy=pcbY+cutOut[0];
          posz=pcbZ+cutOut[1];
          translate([0, posy, posz])
            cutoutSquare("red", cutOut[2], cutOut[3]+bottomWall_height);
        }
        else if (cutOut[4]==yappRectCenter)
        {
          posy=pcbY+cutOut[0]-(cutOut[2]/2);
          posz=pcbZ+cutOut[1]-(cutOut[3]/2);
          translate([0, posy, posz])
            cutoutSquare("red", cutOut[2], cutOut[3]+bottomWall_height);
        }
        else if (cutOut[4]==yappCircle)
        {
          posy=pcbY+cutOut[0]-(cutOut[2]/2);  // width = diameter
          posz=pcbZ+cutOut[1];
          translate([-1, posy, posz])
            rotate([0,90,0])
              color("red")
                cylinder(h=wall_thickness+2, d=cutOut[2], $fn=20);
        }
      }
   
      //-- place cutOuts in Left Plane Bottom Box
      
      //-- [0]pcb_x, [1]pcb_z, [2]width, [3]height, 
      //--                      {yappRectOrg | yappRectCenterd | yappCircle}           
      //         
      //      [0]pos_x->|
      //                |
      //  F  |          +-----------+  ^ 
      //  R  |          |           |  |
      //  O  |          |<[2]length>|  [3]height
      //  N  |          +-----------+  v   
      //  T  |            ^
      //     |            | [1]z_pos
      //     |            v
      //     +----------------------------- pcb(0,0)
      //
      for ( cutOut = cutoutsLeft )
      {
        //echo("bottomLeft:", cutOut);
        if (cutOut[4]==yappRectOrg)
        {
          posx=pcbX+cutOut[0];
          posz=pcbZ+cutOut[1];
          //echo("(org) - pcbX:",pcbX,", posx:", posx,", pcbZ:",pcbZ,", posz:",posz);
          translate([posx, wall_thickness*2, posz])
            rotate([0,0,270])
              cutoutSquare("brown", cutOut[2], cutOut[3]);
        }
        else if (cutOut[4]==yappRectCenter)
        {
          posx=pcbX+cutOut[0]-(cutOut[2]/2);
          posz=pcbZ+cutOut[1]-(cutOut[3]/2);
          //echo("(center) - pcbX:",pcbX,", posx:", posx,", pcbZ:",pcbZ,", posz:",posz);
          translate([posx, wall_thickness+1, posz])
            rotate([0,0,270])
            //cutoutSquare("brown", cutOut[2], cutOut[3]+bottomWall_height);
              cutoutSquare("brown", cutOut[2], cutOut[3]);
        }
        else if (cutOut[4]==yappCircle)
        {
          posx=pcbX+cutOut[0];
          posz=pcbZ+cutOut[1];
          echo("(circle) - pcbX:",pcbX,", posx:", posx,", pcbZ:",pcbZ,", posz:",posz);
          translate([posx, wall_thickness+1, posz])
            rotate([90,0,0])
              color("brown")
                cylinder(h=wall_thickness+2, d=cutOut[2], $fn=20);
        }
        
      } // for cutOut's ..
      
      //-- [0]pcb_x, [1]pcb_z, [2]width, [3]height, 
      //--                {yappRectOrg | yappRectCenterd | yappCircle}           
      for ( cutOut = cutoutsRight )
      {

        if (cutOut[4]==yappRectOrg)
        {
          posx=pcbX+cutOut[0];
          posz=pcbZ+cutOut[1];
          translate([posx, (wall_thickness*2)+pcb_width+padding_left+padding_right, posz])
            rotate(270)
              cutoutSquare("AntiqueWhite", cutOut[2], cutOut[3]);
        }
        else if (cutOut[4]==yappRectCenter)
        {
          posx=pcbX+cutOut[0]-(cutOut[2]/2);
          posz=pcbZ+cutOut[1]-(cutOut[3]/2);;
          translate([posx, (wall_thickness*2)+pcb_width+padding_left+padding_right, posz])
            rotate([0,0,270])
              cutoutSquare("AntiqueWhite", cutOut[2], cutOut[3]+bottomWall_height);
        }
        else if (cutOut[4]==yappCircle)
        {
          posx=pcbX+cutOut[0];
          posz=pcbZ+cutOut[1];
          translate([posx, (wall_thickness*2)+pcb_width+padding_left+padding_right, posz])
            rotate([90,0,0])
              color("AntiqueWhite")
                cylinder(h=wall_thickness+2, d=cutOut[2], $fn=20);
        }

      } // for ..

      //-- place cutOuts in Bottom Box
      
      // [0]pcb_x, [1]pcb_x, [2]width, [3]length, [4]{yappRectOrg | yappRectCenter | yappCircle}
      for ( cutOut = cutoutsBottom )
      {
        if (cutOut[4]==yappRectOrg)  // org pcb_x/y
        {
          posx=pcbX+cutOut[0];
          posy=pcbY+cutOut[1];
          translate([posx, posy, 0])
            linear_extrude(bottomPlane_thickness)
              square([cutOut[3],cutOut[2]], false);
        }
        else if (cutOut[4]==yappRectCenter)  // center around x/y
        {
          posx=pcbX+(cutOut[0]-(cutOut[3]/2));
          posy=pcbY+(cutOut[1]-(cutOut[2]/2));
          translate([posx, posy, 0])
            linear_extrude(bottomPlane_thickness)
              square([cutOut[3],cutOut[2]], false);
        }
        else if (cutOut[4]==yappCircle)  // circle centered around x/y
        {
          posx=pcbX+cutOut[0];
          posy=pcbY+(cutOut[1]+cutOut[2]/2)-cutOut[2]/2;
          translate([posx, posy, 0])
            linear_extrude(bottomPlane_thickness)
              circle(d=cutOut[2], $fn=20);
        }
      }
 
    } // diff 
    
    pcb_holder();
    
} //  bottom_case() 


//===========================================================
module top_case() 
{
    floor_width = pcb_length + padding_front + padding_back + wall_thickness * 2;
    floor_length = pcb_width + padding_left + padding_right + wall_thickness * 2;
  
    module box() 
    {
      difference() 
      {
        halfBox(showTop, colorTop, floor_length, floor_width, topWall_height 
                                            -ridge_height, topPlane_thickness);
        for ( label = labelsTop )
        {
          // [0]x_pos, [1]y_pos, [2]orientation, [3]font, [4]size, [5]"text" 

          translate([label[0], box_width-label[1], 0]) 
          {
            linear_extrude(0.5) 
            {
              rotate([0,0,(180-label[2])])
              {
                mirror(v=[1,0,0]) 
                {
                  text(label[5]
                        , font=label[3]
                        , size=label[4]
                        , direction="ltr"
                        , halign="left"
                        , valign="bottom");
                } // mirror..
              } // rotate
            } // extrude
          } // translate
        } // for labels...

      } // diff

      if (showTop)
      {
        color(colorTop)
        {
      // front Ridge
      translate([
            0,
            0,
            topPlane_thickness + topWall_height - ridge_height])
            cube([
                wall_thickness / 2,
                floor_length,
                ridge_height]);
       
      // back Ridge
      translate([
            floor_width - wall_thickness / 2,
            0,
            topPlane_thickness + topWall_height - ridge_height])
            cube([
                wall_thickness / 2,
                floor_length,
                ridge_height]);
               
      // right Ridge
      translate([
            wall_thickness / 2,
            floor_length - wall_thickness / 2,
            topPlane_thickness + topWall_height - ridge_height])
            cube([
                floor_width - wall_thickness,
                wall_thickness / 2,
                ridge_height]);
              
      // left Ridge
      translate([
            wall_thickness / 2,
            0,
            topPlane_thickness + topWall_height - ridge_height])
            cube([
                floor_width - wall_thickness,
                wall_thickness / 2,
                ridge_height]);        

        } // color
        
      } // showTop

    } // box()

    module pcb_pushdown() 
    {        
      //-- place pcb Standoff-pushdown
      difference()
      {
        for ( pushdown = pcbStands )
        {
          //-- [0]posx, [1]posy, [2]{yappBoth|yappTopOnly|yappBottomOnly}
          //--          , [3]{yappHole|YappPin}
          //
          //-- stands in Top are alway's holes!
          posx=pcbX+pushdown[0];
          posy=(pcbY+pushdown[1]);
          height=(bottomWall_height+topWall_height)
                        -(standoff_height+pcb_thickness);
          if (pushdown[2] != yappBottomOnly)
          {
            translate([posx, posy, topPlane_thickness])
              pcb_standoff("yellow", height, yappHole);
          }
        }
        if (intersect < 0)
        {
          translate([box_length+intersect, -1, -1])
          color("gray", 0.2)
            cube([box_length, box_width+2, box_height+2], false);
        }
        else if (intersect > 0)
        {
          translate([intersect-box_length, -1, -1])
          color("gray", 0.2)
            cube([box_length, box_width+2, box_height+2], false);
        }
        
      } // intersect.
        
    } // pcb_pushdown()
   
    //-- place front & back cutOuts in Top Plane
    difference() 
    {
      box();        
      
      //-- place cutOuts in Top Plane
      
      //-- [0]pcb_x,  [1]pcb_y, [2]width, [3]length
      //--          , [4]{yappRectOrg | yappRectCenter | yappCircle}
      for ( cutOut = cutoutsTop )
      {
        //-- left 0,0
        if (cutOut[4]==yappRectOrg)
        {
          posx=pcbX+cutOut[0];
          //-- pcbYtop=wall_thickness+pcb_width+padding_right;
          posy=pcbYtop-(cutOut[1]+cutOut[2]);
          translate([posx, posy, 0])
            linear_extrude(topPlane_thickness+0.0001)
              color("white")
                square([cutOut[3],cutOut[2]], false);
        }
        else if (cutOut[4]==yappRectCenter)  //  center araound pcb_x/y
        {
          posx=pcbX+(cutOut[0]-(cutOut[3]/2));
          posy=(pcbY-padding_left)+padding_right+(pcb_width-(cutOut[2]/1)-(cutOut[1]-(cutOut[2]/2)));
          translate([posx, posy, 0])
            linear_extrude(topPlane_thickness+0.0001)
              color("white")
                square([cutOut[3],cutOut[2]], false);
          }
        else if (cutOut[4]==yappCircle)  // circle centered around x/y
        {
          posx=pcbX+cutOut[0];
          posy=(pcbY-padding_left)+padding_right+(pcb_width-(cutOut[2]/2)-(cutOut[1]-(cutOut[2]/2)));
          translate([posx, posy, -1])
            linear_extrude(topPlane_thickness+2)
              color("white")
                circle(d=cutOut[2], $fn=20);
        }
      }

      // [0]pcb_y, [1]pcb_z, [2]width, [3]height, [4]{yappRectOrg | yappRectCenterd | yappCircle} 
      for ( cutOut = cutoutsFront )
      {
        if (cutOut[4]==yappRectOrg)
        {
          posy=box_width-(wall_thickness+padding_left+cutOut[0])-cutOut[2];
          posz=topZpcb-cutOut[3];
          translate([box_length-(wall_thickness+2), posy, posz])
            cutoutSquare("gray", cutOut[2], cutOut[3]);
        }
        else if (cutOut[4]==yappRectCenter)
        {
          posy=box_width-(wall_thickness+padding_left+cutOut[0])-(cutOut[2]/2);
          posz=topZpcb-cutOut[1]-(cutOut[3]/2);
          translate([box_length-wall_thickness, posy, posz])
            cutoutSquare("gray", cutOut[2], cutOut[3]);
        }
        else if (cutOut[4]==yappCircle)
        {
          posy=box_width-(pcbY+(cutOut[0]-(cutOut[2]/2)));
          posz=topZpcb-cutOut[1];
          translate([box_length, posy, posz])
            rotate([0,270,0])
              color("gray")
                cylinder(h=wall_thickness, d=cutOut[2], $fn=20);
        }
      }
      
      //-- [0]pcb_y, [1]pcb_z, [2]width, [3]height, 
      //--  [4]{yappRectOrg | yappRectCenterd | yappCircle} 
      for ( cutOut = cutoutsBack )
      {
        //-- calculate part that sticks out of the bottom
        //       +=============== topPlane_thickness
        //       |     +---+          ---
        //       |     |   |           ^  height to calculate
        //       +-----+   +----       x 
        //       |     |   |           | cutOut_height
        //       |     |   |           v
        //       |     +---+          ---
        //       |                     floor_z
        //       |   ============ pcb ---
        //       |           []   stand
        //       |           []
        //       +=============== bottomPlane_thickness

        if (cutOut[4]==yappRectOrg)
        {
          posy=box_width-(wall_thickness+padding_left+cutOut[0])-cutOut[2];
          posz=topZpcb-cutOut[3];
          translate([0, posy, posz])
            cutoutSquare("green", cutOut[2], cutOut[3]+5);
        }
        else if (cutOut[4]==yappRectCenter)
        {
          posy=box_width-(wall_thickness+padding_left+cutOut[0]+(cutOut[2]/2));
          posz=topZpcb-(cutOut[1]+(cutOut[3]/2));
          translate([0, posy, posz])
            cutoutSquare("green", cutOut[2], cutOut[3]);
        }
        else if (cutOut[4]==yappCircle)
        {
          posy=box_width-(pcbY+(cutOut[0]+(cutOut[2]/2)));
          posz=(bottomWall_height+topWall_height+topPlane_thickness)
                        -(standoff_height+pcb_thickness);
          posz=topZpcb-cutOut[1];
          posy=box_width-(pcbY+(cutOut[0]-(cutOut[2]/2)));
          posz=topZpcb-cutOut[1];
          translate([1, posy, posz])
            rotate([0,270,0])
              color("green")
                cylinder(h=wall_thickness*2, d=cutOut[2], $fn=20);
        }
      }
   
      //-- place cutOuts in left plane
      //-- [0]pcb_x, [1]pcb_z, [2]width, [3]height, {yappRectOrg | yappRectCenterd | yappCircle}           
      //         
      //      [0]pos_x->|
      //                |
      //  F  |          +-----------+  ^ 
      //  R  |          |           |  |
      //  O  |          |<[2]length>|  [3]height
      //  N  |          +-----------+  v   
      //  T  |            ^
      //     |            | [1]z_pos
      //     |            v
      //     +----------------------------- pcb(0,0)
      //
      for ( cutOut = cutoutsLeft )
      {

        if (cutOut[4]==yappRectOrg)
        {
          posx=pcbX+cutOut[0];
          posz=topZpcb-cutOut[1];
          translate([posx, (wall_thickness+2)+padding_left+pcb_width+padding_right, posz])
            rotate(270)
              cutoutSquare("black", cutOut[2], cutOut[3]);
        }
        else if (cutOut[4]==yappRectCenter)
        {
          posx=pcbX+cutOut[0]-(cutOut[2]/2);
          posz=topZpcb-(cutOut[1]+cutOut[2]/2);
          translate([posx, (wall_thickness+2)+padding_left+pcb_width+padding_right, posz])
            rotate(270)
              cutoutSquare("black", cutOut[2], cutOut[3]);
        }
        else if (cutOut[4]==yappCircle)
        {
          posx=pcbX+cutOut[0];
          posz=topZpcb-cutOut[1];
          translate([posx, (wall_thickness+2)+padding_left+pcb_width+padding_right, posz])
            rotate([90,0,0])
              color("black")
                cylinder(h=wall_thickness+2, d=cutOut[2], $fn=20);
        }
        
      } //   for cutOut's ..

      //-- [0]pcb_x, [1]pcb_z, [2]width, [3]height,
      //--                      {yappRectOrg | yappRectCenterd | yappCircle}
      for ( cutOut = cutoutsRight )
      {
        if (cutOut[4]==yappRectOrg)
        {
          posx=pcbX+cutOut[0];
          //-- calculate part that sticks out of the bottom
          start_z=pcbZ+cutOut[1];
          used_height=start_z+cutOut[3];
          rest_height=used_height-(bottomPlane_thickness+standoff_height+bottomWall_height);
          rest_height=0;
          posz=(topWall_height+topPlane_thickness)-(rest_height+ridge_height);
          translate([posx, wall_thickness+1, posz])
            rotate(270)
              cutoutSquare("purple", cutOut[2], cutOut[3]);
        }
        else if (cutOut[4]==yappRectCenter)
        {
          posx=pcbX+cutOut[0]-(cutOut[2]/2);
          posz=topZpcb-(cutOut[1]+cutOut[2]/2);
          //-- calculate part that sticks out of the bottom
          //used_height=pcbZ+cutOut[1]+cutOut[2];
          //rest_height=used_height-(bottomPlane_thickness+standoff_height+bottomWall_height);
          translate([posx, wall_thickness+1, posz])
            rotate(270)
              cutoutSquare("purple", cutOut[2], cutOut[3]);
        }
        else if (cutOut[4]==yappCircle)
        {
          posx=pcbX+cutOut[0];
          posz=topZpcb-cutOut[1];
          translate([posx, wall_thickness+1, posz])
            rotate([90,0,0])
              color("purple")
                cylinder(h=wall_thickness+2, d=cutOut[2], $fn=20);
        }
      } //  for ...

    } // diff 
    
    shift=(pcbY+pcb_width+padding_right+(wall_thickness*1))*-1;
    mirror([1,1,0])
      rotate([0,0,270])
        translate([0,shift,0])
          pcb_pushdown();
    
} //  top_case() 

module showOrientation()
{
  translate([-10, 10, 0])
    rotate(90)
     linear_extrude(1) 
          %text("BACK"
            , font="Liberation Mono:style=bold"
            , size=8
            , direction="ltr"
            , halign="left"
            , valign="bottom");

  translate([box_length+15, 10, 0])
    rotate(90)
     linear_extrude(1) 
          %text("FRONT"
            , font="Liberation Mono:style=bold"
            , size=8
            , direction="ltr"
            , halign="left"
            , valign="bottom");

  translate([15, -15, 0])
     linear_extrude(1) 
          %text("LEFT"
            , font="Liberation Mono:style=bold"
            , size=8
            , direction="ltr"
            , halign="left"
            , valign="bottom");

} // showOrientation()


//========= MAIN CALL's ===========================================================
  
pcbX=wall_thickness+padding_back;
pcbY=wall_thickness+padding_left;
pcbYtop=wall_thickness+pcb_width+padding_right;
pcbZ=bottomPlane_thickness+standoff_height+pcb_thickness;
topZpcb=(bottomWall_height+topWall_height+bottomPlane_thickness)-(standoff_height);
topZpcb=(bottomWall_height+topWall_height+topPlane_thickness)
                        -(standoff_height+pcb_thickness);

box_width=(pcb_width+(wall_thickness*2)+padding_left+padding_right);
box_length=(pcb_length+(wall_thickness*2)+padding_front+padding_back);
box_height=bottomPlane_thickness+bottomWall_height+topWall_height+topPlane_thickness;


module YAPPgenerate()
{
  
echo("===========================");
echo("*       pcbX [", pcbX,"]");
echo("*       pcbY [", pcbY,"]");
echo("*    pcbYtop [", pcbYtop,"]");
echo("*       pcbZ [", pcbZ,"]");
echo("*    topZpcb [", topZpcb,"]");
echo("*  box width [", box_width,"]");
echo("* box length [", box_length,"]");
echo("* box height [", box_height,"]");
echo("===========================");

if (showMarkers)
{
  //-- box[0,0] marker --
  translate([0, 0, 8])
    color("blue")
      %cylinder(
              r = .5,
              h = 20,
              center = true,
              $fn = 20);
} //  showMarkers


if (printBottom) 
{
  if (showPCB) %pcb(pcbX, pcbY, bottomPlane_thickness+standoff_height);
  difference()
  {
    bottom_case();
    if (intersect < 0)
    {
      translate([box_length+intersect, -1, -1])
        cube([box_length, box_width+2, box_height+2], false);
    }
    else if (intersect > 0)
    {
      translate([intersect-box_length, -1, -1])
        cube([box_length, box_width+2, box_height+2], false);
    }
  }
  
  showOrientation();
  
} // if printBottom ..


if (printTop)
{
  if (show_side_by_side)
  {
    translate([
      0,
      5 + pcb_width + standoff_diameter + padding_front + padding_right + wall_thickness * 2,
      0])
    {
      if (showPCB) 
      {
        posZ=(bottomWall_height+topWall_height+bottomPlane_thickness)
                        -(standoff_height);
        rotate([0,180,0])
          %pcb((pcb_length+wall_thickness+padding_front)*-1,
               padding_right+wall_thickness,
               (posZ)*-1);
      }
      difference()
      {
        top_case();
        if (intersect < 0)
        {
          translate([box_length+intersect, -1, -1])
            cube([box_length, box_width+2, box_height+2], false);
        }
        else if (intersect > 0)
        {
          translate([intersect-box_length, -1, -1])
            cube([box_length, box_width+2, box_height+2], false);
        }
      }
      if (showMarkers)
      {
        translate([pcbX, pcbYtop, 8])
          color("red")
            %cylinder(
              r = .5,
              h = 20,
              center = true,
              $fn = 20);
        
        translate([pcbX, pcbYtop-pcb_width, 8])
          color("red")
            %cylinder(
              r = .5,
              h = 20,
              center = true,
              $fn = 20);
        translate([pcbX+pcb_length, pcbYtop-pcb_width, 8])
          color("red")
            %cylinder(
              r = .5,
              h = 20,
              center = true,
              $fn = 20);
        
        translate([pcbX+pcb_length, pcbYtop, 8])
          color("red")
            %cylinder(
              r = .5,
              h = 20,
              center = true,
              $fn = 20);
              
      } // show_markers
      
      translate([box_length-15, box_width+15, 0])
        linear_extrude(1) 
          rotate(180)
          %text("LEFT"
            , font="Liberation Mono:style=bold"
            , size=8
            , direction="ltr"
            , halign="left"
            , valign="bottom");

    } // translate
  }
  else  //  show on top of each other
  {
    
    translate([
      0,
      (wall_thickness*2)+padding_left+pcb_width+padding_right,
      bottomPlane_thickness+bottomWall_height+topPlane_thickness+topWall_height
    ])
    {
      rotate([180,0,0])
      {
        difference()
        {
          top_case();
          if (intersect < 0)
          {
            translate([box_length+intersect, -1, -1])
              cube([box_length, box_width+2, box_height+2], false);
          }
          else if (intersect > 0)
          {
            translate([intersect-box_length, -1, -1])
              cube([box_length, box_width+2, box_height+2], false);
          }
        }
        if (showMarkers)
        {
          translate([pcbX, pcbYtop, 8])
            color("red")
              %cylinder(
                r = .5,
                h = 20,
                center = true,
                $fn = 20);
        
          translate([pcbX, pcbYtop-pcb_width, 8])
            color("red")
              %cylinder(
                r = .5,
                h = 20,
                center = true,
                $fn = 20);
          
          translate([pcbX+pcb_length, pcbYtop-pcb_width, 8])
            color("red")
              %cylinder(
                r = .5,
                h = 20,
                center = true,
                $fn = 20);
        
          translate([pcbX+pcb_length, pcbYtop, 8])
            color("red")
              %cylinder(
                r = .5,
                h = 20,
                center = true,
                $fn = 20);
                
        } // showMarkers
      } //  rotate
    } //  translate
  } // show "on-top"

} // printTop()

} //  YAPPgenerate()

/*
****************************************************************************
*
* Permission is hereby granted, free of charge, to any person obtaining a
* copy of this software and associated documentation files (the
* "Software"), to deal in the Software without restriction, including
* without limitation the rights to use, copy, modify, merge, publish,
* distribute, sublicense, and/or sell copies of the Software, and to permit
* persons to whom the Software is furnished to do so, subject to the
* following conditions:
*
* The above copyright notice and this permission notice shall be included
* in all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
* OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
* CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT
* OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR
* THE USE OR OTHER DEALINGS IN THE SOFTWARE.
* 
****************************************************************************
*/