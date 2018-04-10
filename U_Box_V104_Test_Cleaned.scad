/*//////////////////////////////////////////////////////////////////
              -    FB Aka Heartman/Hearty 2016     -
              -   http://heartygfx.blogspot.com    -
              -       OpenScad Parametric Box      -
              -         CC BY-NC 3.0 License       -
////////////////////////////////////////////////////////////////////
12/02/2016 - Fixed minor bug
28/02/2016 - Added holes ventilation option
09/03/2016 - Added PCB feet support, fixed the shell artefact on export mode.

*/////////////////////////// - Info - //////////////////////////////

// All coordinates are starting as integrated circuit pins.
// From the top view :

//   CoordD           <---       CoordC
//                                 ^
//                                 ^
//                                 ^
//   CoordA           --->       CoordB


////////////////////////////////////////////////////////////////////


////////// - Paramètres de la boite - Box parameters - /////////////

// - Epaisseur - Wall thickness
  Thick         = 2;//[2:5]

/* [Box options] */
// - Diamètre Coin arrondi - Filet diameter
  Filet         = 2;//[0.1:12]
// - lissage de l'arrondi - Filet smoothness
  Resolution    = 50;//[1:100]
// - Tolérance - Tolerance (Panel/rails gap)
  m             = 0.9;
// Pieds PCB - PCB feet (x4)
  PCBFeet       = 1;// [0:No, 1:Yes]
// - Decorations to ventilation holes
  Vent          = 1;// [0:No, 1:Yes]
// - Decoration-Holes width (in mm)
  Vent_width    = 1.5;

/* [PCB_Feet] */
//All dimensions are from the center foot axis

// - Longueur PCB - PCB Length
PCBLength       = 79.52;
// - Largeur PCB - PCB Width
PCBWidth        = 80.01;
// - Epaisseur PCB Thickness
PCBThick        = 1.6;
// - Heuteur pied - Feet height
FootHeight      = 6.35 - PCBThick;
// - Diamètre pied - Foot diameter
FootDia         = 5.6;
// - Diamètre trou - Hole diameter
CutoutMargin = 0.6;
ScrewTap        = 2.2606; // tap size for #4 coarse-thread
FootHole        = ScrewTap - CutoutMargin;

// Various special parameters for this project.
PanelMargin = 1;
EdgeMargin = 0.2; // Tolerance around cylindrical protrusions
LEDDiameter = 2.9 + EdgeMargin + CutoutMargin;
LEDHeight = 5.1;
LEDSpacing = 5.08;
LED1CenterFromLeftEdge = 10.16;
LED2CenterFromLeftEdge = LED1CenterFromLeftEdge + LEDSpacing;
LED3CenterFromLeftEdge = LED2CenterFromLeftEdge + LEDSpacing;
LED4CenterFromLeftEdge = LED3CenterFromLeftEdge + LEDSpacing;
LED5CenterFromLeftEdge = LED4CenterFromLeftEdge + LEDSpacing;
LED6CenterFromLeftEdge = LED5CenterFromLeftEdge + LEDSpacing;
LED7CenterFromLeftEdge = LED6CenterFromLeftEdge + LEDSpacing;
ButtonDiameter = 3.5 + EdgeMargin + CutoutMargin;
ButtonHeight = 4.05;
ButtonCenterFromLeftEdge = 48.55;
JackDiameter = 6 + EdgeMargin + CutoutMargin;
JackHeight = 7;
Jack1CenterFromLeftEdge = 57.52;
Jack2CenterFromLeftEdge = 66.41;
DB15Width = 39.2 + CutoutMargin;
DoubleDB15Width = 79.5 + CutoutMargin;
DB15Height = 12.55 + CutoutMargin;
DB151FromLeftEdge = 0.255;
DB152FromLeftEdge = 40.555;
RegulatorHeight = 19.35;

// Margins between PCB and box/panels.
// You likely need to maintain |Thick| margin on the left and right for tabs
// and whatnot.
FrontEdgeMargin = 0;
BackEdgeMargin = 0;
LeftEdgeMargin = Thick + 3;
RightEdgeMargin = Thick + 3;
TopMargin = PCBThick + RegulatorHeight;

// Foot centers are specified as distance from PCB top-left corner.
// X is along the "length" axis, and Y is along the "width" axis.
Foot1X = 17.29;
Foot1Y = 3.81;

Foot2X = 17.29;
Foot2Y = PCBWidth - 3.81;

Foot3X = PCBLength - 3.81;
Foot3Y = 3.81;

Foot4X = PCBLength - 3.81;
Foot4Y = PCBWidth - 3.81;


/* [STL element to export] */
//Coque haut - Top shell
TShell          = 0;// [0:No, 1:Yes]
//Coque bas- Bottom shell
BShell          = 1;// [0:No, 1:Yes]
//Panneau avant - Front panel
FPanL           = 1;// [0:No, 1:Yes]
//Panneau arrière - Back panel
BPanL           = 1;// [0:No, 1:Yes]



/* [Hidden] */
// - Couleur coque - Shell color
Couleur1        = "Navy";
// - Couleur panneaux - Panels color
Couleur2        = "Navy";
LetterColor     = "White";
// Thick X 2 - making decorations thicker if it is a vent to make sure they go through shell
Dec_Thick       = Vent ? Thick*2 : Thick;
// - Depth decoration
Dec_size        = Vent ? Thick*2 : 0.8;


// Calculate box dimensions from PCB.
Length = PCBLength + FrontEdgeMargin + BackEdgeMargin + (((Thick*2) + m)*2);
Width = PCBWidth + LeftEdgeMargin + RightEdgeMargin + (Thick*2);
Height = FootHeight + TopMargin + (Thick*2);

// Calculate panel dimensions from box dimensions.
PanelWidth = Width - (Thick*2) - m;
PanelHeight = Height - (Thick*2) - m;

// Calculate board-relative positions with respect to the panel, for
// convenience in placing panel elements.
TopOfBoardWRTPanel = FootHeight + PCBThick - (m/2);
LeftEdgeOfBoardWRTPanel = LeftEdgeMargin - (m/2);


/////////// - Boitier générique bord arrondis - Generic rounded box - //////////

module RoundBox($a=Length, $b=Width, $c=Height){// Cube bords arrondis
                    $fn=Resolution;
                    translate([0,Filet,Filet]){
                    minkowski (){
                        cube ([$a-(Length/2),$b-(2*Filet),$c-(2*Filet)], center = false);
                        rotate([0,90,0]){
                        cylinder(r=Filet,h=Length/2, center = false);
                            }
                        }
                    }
                }// End of RoundBox Module


////////////////////////////////// - Module Coque/Shell - //////////////////////////////////

module Coque(){//Coque - Shell
    Thick = Thick*2;
    difference(){
        difference(){//sides decoration
            union(){
                     difference() {//soustraction de la forme centrale - Substraction Fileted box

                        difference(){//soustraction cube median - Median cube slicer
                            union() {//union
                            difference(){//Coque
                                RoundBox();
                                translate([Thick/2,Thick/2,Thick/2]){
                                        RoundBox($a=Length-Thick, $b=Width-Thick, $c=Height-Thick);
                                        }
                                        }//Fin diff Coque
                                difference(){//largeur Rails
                                     translate([Thick+m,Thick/2,Thick/2]){// Rails
                                          RoundBox($a=Length-((2*Thick)+(2*m)), $b=Width-Thick, $c=Height-(Thick*2));
                                                          }//fin Rails
                                     translate([((Thick+m/2)*1.55),Thick/2,Thick/2+0.1]){ // +0.1 added to avoid the artefact
                                          RoundBox($a=Length-((Thick*3)+2*m), $b=Width-Thick, $c=Height-Thick);
                                                    }
                                                }//Fin largeur Rails
                                    }//Fin union
                               translate([-Thick,-Thick,Height/2]){// Cube à soustraire
                                    cube ([Length+100, Width+100, Height], center=false);
                                            }
                                      }//fin soustraction cube median - End Median cube slicer
                               translate([-Thick/2,Thick,Thick]){// Forme de soustraction centrale
                                    RoundBox($a=Length+Thick, $b=Width-Thick*2, $c=Height-Thick);
                                    }
                                }


                difference(){// wall fixation box legs
                    union(){
                        translate([3*Thick +5,Thick,Height/2]){
                            rotate([90,0,0]){
                                    $fn=6;
                                    cylinder(d=16,Thick/2);
                                    }
                            }

                       translate([Length-((3*Thick)+5),Thick,Height/2]){
                            rotate([90,0,0]){
                                    $fn=6;
                                    cylinder(d=16,Thick/2);
                                    }
                            }

                        }
                            translate([4,Thick+Filet,Height/2-57]){
                             rotate([45,0,0]){
                                   cube([Length,40,40]);
                                  }
                           }
                           translate([0,-(Thick*1.46),Height/2]){
                                cube([Length,Thick*2,10]);
                           }
                    } //Fin fixation box legs
            }

        union(){// outbox sides decorations

            for(i=[0:Thick:Length/4]){

                // Ventilation holes part code submitted by Ettie - Thanks ;)
                    translate([10+i,-Dec_Thick+Dec_size,1]){
                    cube([Vent_width,Dec_Thick,Height/4]);
                    }
                    translate([(Length-10) - i,-Dec_Thick+Dec_size,1]){
                    cube([Vent_width,Dec_Thick,Height/4]);
                    }
                    translate([(Length-10) - i,Width-Dec_size,1]){
                    cube([Vent_width,Dec_Thick,Height/4]);
                    }
                    translate([10+i,Width-Dec_size,1]){
                    cube([Vent_width,Dec_Thick,Height/4]);
                    }


                    }// fin de for
               // }
                }//fin union decoration
            }//fin difference decoration


            union(){ //sides holes
                $fn=50;
                translate([3*Thick+5,20,Height/2+4]){
                    rotate([90,0,0]){
                    cylinder(d=ScrewTap,20);
                    }
                }
                translate([Length-((3*Thick)+5),20,Height/2+4]){
                    rotate([90,0,0]){
                    cylinder(d=ScrewTap,20);
                    }
                }
                translate([3*Thick+5,Width+5,Height/2-4]){
                    rotate([90,0,0]){
                    cylinder(d=ScrewTap,20);
                    }
                }
                translate([Length-((3*Thick)+5),Width+5,Height/2-4]){
                    rotate([90,0,0]){
                    cylinder(d=ScrewTap,20);
                    }
                }
            }//fin de sides holes

        }//fin de difference holes
}// fin coque

////////////////////////////// - Experiment - ///////////////////////////////////////////





/////////////////////// - Foot with base filet - /////////////////////////////
module foot(FootDia,FootHole,FootHeight) {
  Filet=2;
  color(Couleur1) {
    difference() {
      difference() {
        cylinder(d=FootDia+Filet,FootHeight, $fn=100);
        rotate_extrude($fn=100) {
          translate([(FootDia+Filet*2)/2,Filet,0]) {
            minkowski() {
              square(10);
              circle(Filet, $fn=100);
            }
          }
        }
      }
      cylinder(d=FootHole,FootHeight+1, $fn=100);
    }
  }
}

module Feet() {
  translate([BackEdgeMargin + (Thick*2) + m,LeftEdgeMargin + Thick, Thick]) {
    //////////////////// - PCB only visible in the preview mode - /////////////////////
    translate([0,0,FootHeight]) {

      %cube ([PCBLength,PCBWidth,PCBThick]);
      translate([PCBLength/2,PCBWidth/2,PCBThick+0.5]) {
        color("Olive") {
          %text("PCB", halign="center", valign="center", font="Arial black");
        }
      }
    } // Fin PCB


    ////////////////////////////// - 4 Feet - //////////////////////////////////////////
    translate([Foot1X, Foot1Y]){
      foot(FootDia,FootHole,FootHeight);
    }
    translate([Foot2X, Foot2Y]){
      foot(FootDia,FootHole,FootHeight);
    }
    translate([Foot3X, Foot3Y]){
      foot(FootDia,FootHole,FootHeight);
    }
    translate([Foot4X, Foot4Y]){
      foot(FootDia,FootHole,FootHeight);
    }
  }
}




 ////////////////////////////////////////////////////////////////////////
////////////////////// <- Holes Panel Manager -> ///////////////////////
////////////////////////////////////////////////////////////////////////

//                           <- Panel ->
module Panel() {
  scale([0.5,1,1]) {
    minkowski() {
      cube([Thick,PanelWidth - (Filet*2),PanelHeight - (Filet*2)]);
      translate([0,Filet,Filet]) {
        rotate([0,90,0]) {
          cylinder(r=Filet,h=Thick, $fn=100);
        }
      }
    }
  }
}



//                          <- Circle hole ->
// Cx=Cylinder X position | Cy=Cylinder Y position | Cdia= Cylinder dia | Cheight=Cyl height
module CylinderHole(OnOff,Cx,Cy,Cdia){
    if(OnOff==1)
    translate([Cx,Cy,-1])
        cylinder(d=Cdia,10, $fn=50);
}
//                          <- Square hole ->
// Sx=Square X position | Sy=Square Y position | Sl= Square Length | Sw=Square Width | Filet = Round corner
module SquareHole(OnOff,Sx,Sy,Sl,Sw,Filet){
    if(OnOff==1)
     minkowski(){
        translate([Sx+Filet/2,Sy+Filet/2,-1])
            cube([Sl-Filet,Sw-Filet,10]);
            cylinder(d=Filet,h=10, $fn=100);
       }
}



//                      <- Linear text panel ->
module LText(OnOff,Tx,Ty,Font,Size,Content,HAlign="center"){
  if(OnOff==1) {
    translate([Tx,Ty,Thick+.5]) {
      linear_extrude(height = 0.5){
        text(Content, size=Size, font=Font, halign=HAlign);
      }
    }
  }
}

//                     <- Circular text panel->
module CText(OnOff,Tx,Ty,Font,Size,TxtRadius,Angl,Turn,Content){
      if(OnOff==1) {
      Angle = -Angl / len(Content);
      translate([Tx,Ty,Thick+.5])
          for (i= [0:len(Content)-1] ){
              rotate([0,0,i*Angle+90+Turn])
              translate([0,TxtRadius,0]) {
                linear_extrude(height = 0.5){
                text(Content[i], font = Font, size = Size,  valign ="baseline", halign ="center");
                    }
                }
             }
      }
}
////////////////////// <- New module Panel -> //////////////////////
module FPanL(){
  difference(){
    color(Couleur2) {
      Panel();
    }


    rotate([90,0,90]) {
      color(Couleur2) {
        //                     <- Cutting shapes from here ->
        CylinderHole(
            1,
            LeftEdgeOfBoardWRTPanel + LED1CenterFromLeftEdge,
            TopOfBoardWRTPanel + LEDHeight,
            LEDDiameter);
        CylinderHole(
            1,
            LeftEdgeOfBoardWRTPanel + LED2CenterFromLeftEdge,
            TopOfBoardWRTPanel + LEDHeight,
            LEDDiameter);
        CylinderHole(
            1,
            LeftEdgeOfBoardWRTPanel + LED3CenterFromLeftEdge,
            TopOfBoardWRTPanel + LEDHeight,
            LEDDiameter);
        CylinderHole(
            1,
            LeftEdgeOfBoardWRTPanel + LED4CenterFromLeftEdge,
            TopOfBoardWRTPanel + LEDHeight,
            LEDDiameter);
        CylinderHole(
            1,
            LeftEdgeOfBoardWRTPanel + LED5CenterFromLeftEdge,
            TopOfBoardWRTPanel + LEDHeight,
            LEDDiameter);
        CylinderHole(
            1,
            LeftEdgeOfBoardWRTPanel + LED6CenterFromLeftEdge,
            TopOfBoardWRTPanel + LEDHeight,
            LEDDiameter);
        CylinderHole(
            1,
            LeftEdgeOfBoardWRTPanel + LED7CenterFromLeftEdge,
            TopOfBoardWRTPanel + LEDHeight,
            LEDDiameter);
        CylinderHole(
            1,
            LeftEdgeOfBoardWRTPanel + ButtonCenterFromLeftEdge,
            TopOfBoardWRTPanel + ButtonHeight,
            ButtonDiameter);
        CylinderHole(
            1,
            LeftEdgeOfBoardWRTPanel + Jack1CenterFromLeftEdge,
            TopOfBoardWRTPanel + JackHeight,
            JackDiameter);
        CylinderHole(
            1,
            LeftEdgeOfBoardWRTPanel + Jack2CenterFromLeftEdge,
            TopOfBoardWRTPanel + JackHeight,
            JackDiameter);
        //                            <- To here ->
      }
    }
  }

  color(LetterColor) {
    translate ([-.5,0,0]) {
      rotate([90,0,90]) {
        //                      <- Adding text from here ->
        FontSize = 2.5;

        LText(
            1,
            LeftEdgeOfBoardWRTPanel + LED1CenterFromLeftEdge,
            Thick + (m/2) + PanelMargin,
            "Arial Black",
            FontSize,
            "P");
        LText(
            1,
            LeftEdgeOfBoardWRTPanel + LED2CenterFromLeftEdge,
            Thick + (m/2) + PanelMargin,
            "Arial Black",
            FontSize,
            "B");
        LText(
            1,
            LeftEdgeOfBoardWRTPanel + LED3CenterFromLeftEdge,
            Thick + (m/2) + PanelMargin,
            "Arial Black",
            FontSize,
            "L");
        LText(
            1,
            LeftEdgeOfBoardWRTPanel + LED4CenterFromLeftEdge,
            Thick + (m/2) + PanelMargin,
            "Arial Black",
            FontSize,
            "1");
        LText(
            1,
            LeftEdgeOfBoardWRTPanel + LED5CenterFromLeftEdge,
            Thick + (m/2) + PanelMargin,
            "Arial Black",
            FontSize,
            "2");
        LText(
            1,
            LeftEdgeOfBoardWRTPanel + LED6CenterFromLeftEdge,
            Thick + (m/2) + PanelMargin,
            "Arial Black",
            FontSize,
            "B1");
        LText(
            1,
            LeftEdgeOfBoardWRTPanel + LED7CenterFromLeftEdge,
            Thick + (m/2) + PanelMargin,
            "Arial Black",
            FontSize,
            "B2");
        LText(
            1,
            LeftEdgeOfBoardWRTPanel + ButtonCenterFromLeftEdge,
            Thick + (m/2) + PanelMargin,
            "Arial Black",
            FontSize,
            "RST");
        LText(
            1,
            LeftEdgeOfBoardWRTPanel + Jack1CenterFromLeftEdge,
            Thick + (m/2) + PanelMargin,
            "Arial Black",
            FontSize,
            "Mic");
        LText(
            1,
            LeftEdgeOfBoardWRTPanel + Jack2CenterFromLeftEdge,
            Thick + (m/2) + PanelMargin,
            "Arial Black",
            FontSize,
            "Line");
        LText(
            1,
            LeftEdgeOfBoardWRTPanel + PanelMargin,
            PanelHeight - Thick - (m/2) - PanelMargin - (FontSize + 2),
            "Arial Black",
            FontSize + 2,
            "Blubaru",
            "left");
        //                            <- To here ->
      }
    }
  }
}

module BPanL() {
  // This is done like the front panel, but then we rotate it around so the
  // text is on the correct side. (We must also translate since the panel isn't
  // centered.)
  translate([Thick, PanelWidth, 0]) {
    rotate([0, 0, 180]) {
      difference() {
        color(Couleur2) {
          Panel();
        }

        rotate([90,0,90]) {
          color(Couleur2) {
            SquareHole(
                1,
                LeftEdgeOfBoardWRTPanel + DB151FromLeftEdge,
                TopOfBoardWRTPanel - (CutoutMargin / 2),
                DB15Width,
                DB15Height,
                0);
            SquareHole(
                1,
                LeftEdgeOfBoardWRTPanel + DB152FromLeftEdge,
                TopOfBoardWRTPanel - (CutoutMargin / 2),
                DB15Width,
                DB15Height,
                0);
            SquareHole(
                0,
                LeftEdgeOfBoardWRTPanel + DB151FromLeftEdge,
                TopOfBoardWRTPanel - (CutoutMargin / 2),
                DoubleDB15Width,
                DB15Height,
                0);
          }
        }
      }

      color(LetterColor) {
        translate([-.5, 0, 0]) {
          rotate([90,0,90]) {
            FontSize = 3;

            LText(
              1,
              LeftEdgeOfBoardWRTPanel + DB151FromLeftEdge + DB15Width/2,
              PanelHeight - Thick - (m/2) - PanelMargin - (FontSize - 1),
              "Arial Black",
              FontSize,
              "Stereo");
            LText(
              1,
              LeftEdgeOfBoardWRTPanel + DB152FromLeftEdge + DB15Width/2,
              PanelHeight - Thick - (m/2) - PanelMargin - (FontSize - 1),
              "Arial Black",
              FontSize,
              "CD");
          }
        }
      }
    }
  }
}


/////////////////////////// <- Main part -> /////////////////////////

if (TShell==1) {
  // Coque haut - Top Shell
  color( Couleur1,1){
    translate([0,Width,Height+0.2]){
      rotate([0,180,180]){
        Coque();
      }
    }
  }
}

if (BShell==1) {
  // Coque bas - Bottom shell
  color(Couleur1){
    Coque();
  }
  // Pied support PCB - PCB feet
  if (PCBFeet==1)
    Feet();
}

// Panneau avant - Front panel  <<<<<< Text and holes only on this one.
if (FPanL==1) {
  translate([Length-(Thick*2+m/2),Thick+m/2,Thick+m/2])
    FPanL();
}

//Panneau arrière - Back panel
if (BPanL==1) {
  translate([Thick+m/2,Thick+m/2,Thick+m/2])
    BPanL();
}
