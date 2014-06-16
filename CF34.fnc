//
//------------------------------------------------------------------------
//                                                                       |
//   File Name:     CF34.fnc                                             |
//   Date(s):       October, 2009                                        |
//   Author:        Jeff Berton, after Scott Jones                       |
//                                                                       |
//   Description:   This file declares the model solver variables and    |
//                  sets up functions for activating them for different  |
//                  engine operating conditions                          |
//                                                                       |
//------------------------------------------------------------------------

//------------------------------------------------------------------------
Option switchBenignSet {
  allowedValues = { "SET", "UNSET" } 
  description = "Switch to determine whether to set to benign conditions";
  rewritableValues = FALSE;  
}

Option switchTurbineCoolingLogic {
  allowedValues = { "TRUE", "FALSE" };
  description = "Switch to determine whether to run Coolit.int turbine cooling logic";
  trigger = FALSE;
  rewritableValues = FALSE;
} 
setOption( "switchTurbineCoolingLogic", "FALSE" );

//------------------------------------------------------------------------
//     Cycle independents, Dependents, and Constraints
//------------------------------------------------------------------------

// Self-consistent constraints used to limit engine operation for the ADP and reference point calibration/matching:
real maxT4SLSref      = 3100.06; // SLS, ISA+27F maximum T4, yields SLS rated thrust of 14506lb
real maxT4RTOref      = 3170.0;  // Rolling takeoff (SL, M0.25, ISA+27F), maximum T4, yields RTO thrust of 12400lb
real maxNcref         = 1.0000;  // Simulated cruise (M0.80/35kft, ISA+0) maximum corrected fan map speed
real maxNcref2        = 1.00682; // Top of climb (M0.80/35kft, ISA+0) maximum corrected fan map speed (for EDS Point 2).
real custBleedref     = 0.0;     // Customer bleed 

// Self-consistent constraints used to limit engine operation throughout the performance flight envelope for creating
// FLOPS data, when the customer bleed may differ and conditions are ISA+0:
real maxT4SLSop1      = 3126.4;  // SLS, ISA+0 maximum T4, yields SLS rated thrust of 14506lb
real maxT4RTOop1      = 3170.0;  // Rolling takeoff (SL, M0.25, ISA+0), maximum T4
real maxNcop1         = 1.00682; // Top of climb (M0.80/35kft, ISA+0) maximum corrected fan map speed
real custBleedop1     = 1.0;     // Customer bleed for flight envelope performance computations
//------------------------------------------------------------------------

Independent Burner_FAR {
  varName = "Burner.FAR"; }

Dependent Max_T4 { 
  eq_lhs = "HPT.Fl_I.Tt";
  eq_rhs = toStr(maxT4RTOref);} 

Dependent Max_NcFan { 
  eq_lhs = "Fan.S_map.NcMap";
  eq_rhs = toStr(maxNcref); }

Dependent Max_LP_RPM { 
  eq_lhs = "LP_Shaft.Nmech";
  // Set high enough so that it is not a binding constraint, but it's there if needed:
  eq_rhs = "10000.0";     
  // Potentially binding constraint on maximum corrected fan map speed:
  Max_LP_RPM.addConstraint("Max_NcFan", "MAX", 1, 1); 
  // Potentially binding constraint on maximum T4:
  Max_LP_RPM.addConstraint("Max_T4", "MAX", 1, 1); }  

Dependent Target_Fnet { 
  eq_lhs = "PERF.myFn";
  eq_rhs = "TargetThrust"; }

Independent HPT_Cool1 { varName = "Bld3.Cool1.fracW"; }
Independent HPT_Cool2 { varName = "Bld3.Cool2.fracW"; }
Independent LPT_Cool1 { varName = "HPC.Cool1.fracBldW"; }
Independent LPT_Cool2 { varName = "HPC.Cool2.fracBldW"; }

//------------------------------------------------------------------------
//  WATE++ Independents
//------------------------------------------------------------------------
Independent Fan_Stator { varName = "WATEa.WATE_Fan.RSlenRatioPostSplit"; }
Independent Fan_Frame { varName = "WATEa.WATE_Fan.RSlenRatioBypass"; }
Independent Bypass_Duct { varName = "WATEa.WATE_Duct15.length_in"; }
Independent Bypass_Nozz_LDratio { varName = "WATEa.WATE_Byp_Nozz.LDratio"; }
Independent HPT_Loading { varName = "WATEa.WATE_HPT.GEloadingParam_in"; }
Independent LPT_Loading { varName = "WATEa.WATE_LPT.GEloadingParam_in"; }
Independent Duct14_Length { varName = "WATEa.WATE_Duct14.length_in"; }
Independent Splitter_Core_InletRR{ varName = "WATEa.WATE_Splitter.inletRR"; }

//------------------------------------------------------------------------
//  WATE++ Dependents and Constraints
//------------------------------------------------------------------------
  
// Extends bypass nozzle to align with end of HPC
Dependent Bypass_Nozz_Loc { 
  eq_lhs = "WATEa.WATE_Byp_Nozz.outPort.axialPosition - WATEa.WATE_HPC.outPort.axialPosition";
  eq_rhs = "2";}
  
// Aligns middle of fan stator in front of splitter
Dependent Fan_Stator_Loc { 
  eq_lhs = "WATEa.WATE_Fan.xcld1b";
  eq_rhs = "-1.8*WATEa.WATE_Fan.statorLen_stg[0]"; }

// Aligns fan frame with fan stator
Dependent Fan_Frame_Loc { 
  eq_lhs = "WATEa.WATE_Fan.xcld2b";
  eq_rhs = "-WATEa.WATE_Fan.statorLen_stg[0]"; }

// Positions Duct 14 (Dummy Duct) to end at splitter  
Dependent Duct14_Loc { 
  eq_lhs = "WATEa.WATE_Duct14.outPort.axialPosition - WATEa.WATE_Splitter.inPort.axialPosition ";
  eq_rhs = "0"; }

// Extends bypass duct to align with start of HPC
Dependent Bypass_Duct_Loc { 
  eq_lhs = "WATEa.WATE_Duct15.outPort.axialPosition - WATEa.WATE_HPC.inPort.axialPosition";
  eq_rhs = "0";}  
  
//------------------------------------------------------------------------
//               DEFINE FULL POWER AND PART POWER OPERATION
//------------------------------------------------------------------------

void RunMaxPower( real Mach, real altitude, real delTISA, real maxNcMap, real maxT4SLS, real maxT4RTO ) { 
  Ambient.MN  = Mach;
  Ambient.alt = altitude;
  Ambient.dTs = delTISA;
  autoSolverSetup(); 
  
  // Set the maximum T4:
  real maxT4CONT = 2987.02;
  if (Mach > 0.2501) { // Airspeeds above rolling takeoff (M0.25):
     Max_T4.eq_rhs = toStr(maxT4CONT);
  } 
  else {              // Airspeeds below rolling takeoff (M0.25):
     Max_T4.eq_rhs = toStr( maxT4RTO + (0.25 - Ambient.MN)/0.25 * (maxT4SLS - maxT4RTO ) );
  }
  
  solver.addIndependent( "Burner_FAR" );

  // Set the maximum low-pressure spool speed:
  Max_NcFan.eq_rhs = toStr(maxNcMap);
  solver.addDependent( "Max_LP_RPM" );

  // Run the maximum power point:
  if ( altitude <= 10000.0 && delTISA < 27.0 ) { 
     // To prevent the cycle from exceeding the maximum rated conditions when ambient temperatures are
     // under the break temperature, first run the hot-day rated thrust point:
     Ambient.dTs = 27.;
     run();
     MaxThrust = PERF.myFn; 
     MaxN1     = LP_Shaft.Nmech;
     // Now run the desired point using the cooler ambient temperature and part-power operation logic:
     Ambient.dTs = delTISA;
     autoSolverSetup(); 
     solver.addIndependent( "Burner_FAR" );
     solver.addDependent( "Target_Fnet" );
     TargetThrust = MaxThrust; 
  }
  run();  
  MaxThrust = PERF.myFn; 
  MaxN1     = LP_Shaft.Nmech;
}

//------------------------------------------------------------------------
void RunPartPower() { 
  autoSolverSetup(); 
  solver.addIndependent( "Burner_FAR" );
  solver.addDependent( "Target_Fnet" );
  TargetThrust = MaxThrust * PercentPower(PC); 
  run();
} 

//------------------------------------------------------------------------
void RunThrottleHook( real Mach, real altitude, real delTISA, real maxNcMap, real maxT4SLS, real maxT4RTO ) { 
  Ambient.MN = Mach;
  Ambient.alt = altitude;
  Ambient.dTs = delTISA;

  cout << "Mach  " << toStr(Mach, "f4.2") << "    altitude " << toStr(altitude, "f6.0") << "   ISA+" << toStr(delTISA, "f3.0") << "   maxNcMap" << toStr(maxNcMap, "f7.4") << "\n";
  
  PC = 50.0; ++CASE; RunMaxPower( Mach, altitude, delTISA, maxNcMap, maxT4SLS, maxT4RTO );  FLOPsheet.update(); page.display(); //saveMapPoint();

  PC = 48.0; ++CASE; RunPartPower(); FLOPsheet.update(); page.display();  //saveMapPoint();
  PC = 46.0; ++CASE; RunPartPower(); FLOPsheet.update(); page.display();  //saveMapPoint(); 
  PC = 44.0; ++CASE; RunPartPower(); 
  PC = 42.0; ++CASE; RunPartPower(); FLOPsheet.update(); page.display();  //saveMapPoint(); 
  PC = 40.0; ++CASE; RunPartPower();  
  PC = 38.0; ++CASE; RunPartPower(); FLOPsheet.update(); page.display();  //saveMapPoint(); 
  PC = 34.0; ++CASE; RunPartPower(); FLOPsheet.update(); page.display();  //saveMapPoint(); 
  PC = 30.0; ++CASE; RunPartPower(); FLOPsheet.update(); page.display();  //saveMapPoint(); 
  PC = 28.0; RunPartPower(); 
  PC = 26.0; ++CASE; RunPartPower(); FLOPsheet.update(); page.display();  //saveMapPoint(); 
  PC = 24.0; ++CASE; RunPartPower(); FLOPsheet.update(); page.display();  //saveMapPoint(); 
  PC = 22.0; ++CASE; RunPartPower(); FLOPsheet.update(); page.display();  //saveMapPoint(); 
  PC = 21.0; ++CASE; RunPartPower(); FLOPsheet.update(); page.display();  //saveMapPoint(); 

//  if (Ambient.alt > 14000.) { 
//    PC = 21.0; ++CASE; RunPartPower(); FLOPsheet.update(); page.display();  //saveMapPoint(); 
//  } 

  // Run back up throttle curve without printing any data:
  PC = 32.0; RunPartPower();
  PC = 44.0; RunPartPower();
  PC = 50.0; RunMaxPower( Mach, altitude, delTISA, maxNcMap, maxT4SLS, maxT4RTO );
} 

//------------------------------------------------------------------------
void benignConditions(string switchBenignSet) { 
  int benignSetTrigger;
  if ( switchBenignSet == "SET" ) {
    if ( HP_Shaft.HPX == 0 && HPC.BleedFlow == 0 && Inlet.S_install.s_eRam == 0 && Inlet.S_install.a_eRam == 1 ){
        // Throw warning if conditions have already been set:
        ESOregCreate( 1073200, 7, "" );
        ESOreport( 1073200, "Benign conditions have already been set once." );
        return;
     }
     // Save these, then set them to their benign values:
     real HPX_temp1 = HP_Shaft.HPX;
     real bleed_temp1 = HPC.BleedFlow;
     real s_eRam_temp1 = Inlet.S_install.s_eRam;
     real a_eRam_temp1 = Inlet.S_install.a_eRam;
     HP_Shaft.HPX = 0;
     HPC.BleedFlow= 0;
     Inlet.S_install.s_eRam = 0.0;
     Inlet.S_install.a_eRam = 1.0;
     benignSetTrigger = 1;
  }
  else if ( switchBenignSet == "UNSET" ){
     if ( benignSetTrigger == 0 ) {
        // Throw warning if conditions have not been set:
        ESOregCreate( 1073201, 7, "" );
        ESOreport( 1073201, "Benign conditions must be set before they are unset." );
        return;
     }
     // Reset these to their original values:
     HP_Shaft.HPX = HPX_temp1;
     HPC.BleedFlow= bleed_temp1;
     Inlet.S_install.s_eRam = s_eRam_temp1;
     Inlet.S_install.a_eRam = a_eRam_temp1;
     benignSetTrigger = 0;
  }
} 
