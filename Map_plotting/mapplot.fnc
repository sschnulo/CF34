//
// NPSS functions used for turbomachinery component map plotting
// a PYTHON script file, "mapplot.py", is also required 
//
// createMapDataFiles()
// saveOpPoint("")

//-------------------------------------------------------------------------
// declare GLOBAL variables (used in both functions)
//-------------------------------------------------------------------------
string COMP_NAMES[];   // names of all the compressors
string TURB_NAMES[];   // names of all the turbines
string mapType;        // compressor map type - Rline or Beta
int firstcall = 1;     // flag for the first call to function saveOpPoint() 
int nosave = 0;        // flag to prevent plotting of operating points


void createMapDataFiles() {

   //-------------------------------------------------------------------------
   // declare DATA streams and variables
   //-------------------------------------------------------------------------
   OutFileStream COMPONENT_LIST { }    // list of turbomachinery components
   OutFileStream DATA_MAP { }          // component map data stream
   int n;                              // index number for turbomachinery maps


   //-------------------------------------------------------------------------
   // create a list of all compressors and turbines in this model
   //-------------------------------------------------------------------------
   COMP_NAMES = list( "Compressor", TRUE ); 
   TURB_NAMES = list( "Turbine", TRUE ); 


   //-------------------------------------------------------------------------
   // write the start of the component list file as a PYTHON variable
   //-------------------------------------------------------------------------
   COMPONENT_LIST.filename = "Map_plotting/mapCompList.txt";
   COMPONENT_LIST << "component_list=[ ";

   for ( n=0; n < COMP_NAMES.entries(); ++n ) {
      COMPONENT_LIST << "\"" << "Map_plotting/mapData" + COMP_NAMES[n] + ".txt" << "\", ";
   } 
   for ( n=0; n < TURB_NAMES.entries(); ++n ) {
      COMPONENT_LIST << "\"" << "Map_plotting/mapData" + TURB_NAMES[n] + ".txt" << "\", ";
   } 

   COMPONENT_LIST << "\"done\" ]";
   COMPONENT_LIST.close();


   //-------------------------------------------------------------------------
   // for each compressor, write its map data to a file in PYTHON format
   //-------------------------------------------------------------------------
   for ( n=0; n < COMP_NAMES.entries(); ++n ) {

      //----------------------------------------------------------------------
      // declare map index variables, their meaning depends on map type:
      //
      //      map type:      RLINE        BETA
      //       index i       alpha       alpha       -> alphaVals
      //       index j       speed        beta       -> betaVals
      //       index k       rline       speed       -> gammaVals
      //----------------------------------------------------------------------
      int i,j,k;
      real alphaVals[];                          // array of alpha values
      real betaVals[];                           // array of beta/speed values
      real gammaVals[];                          // array of speed/rline values
      real mapXK1, mapXK2, mapPRref, mapWCref;   // BETA map constants
      real dataFlow, dataPR, dataEff;            // map dependent data values

      // set the map data filename
      DATA_MAP.width = 0;
      DATA_MAP.filename = "Map_plotting/mapData" + COMP_NAMES[n] + ".txt";
      DATA_MAP << "mapname = '" << COMP_NAMES[n] << "'" << endl;

      // determine if the compressor map is RLINE type or BETA type
      if ( exists( COMP_NAMES[n] + ".S_map.S_eff" ) ) { 
         mapType = "RLINE";
         string map = "parent." + COMP_NAMES[n] + ".S_map.S_eff";
         string Tbl_flow = map + ".TB_Wc";
         string Tbl_PR   = map + ".TB_PR";
         string Tbl_eff  = map + ".TB_eff";
         string indepNames[] = Tbl_flow->getIndependentNames(); 
      } 
      else { 
         mapType = "BETA";
         string map = "parent." + COMP_NAMES[n] + ".S_map";
         string Tbl_flow = map + ".TB_Wc";
         string Tbl_eff  = map + ".TB_eff";
         string indepNames[] = Tbl_flow->getIndependentNames(); 
         mapXK1 = map->XK1;
         mapXK2 = map->XK2;
         mapPRref = map->PRMapDes;
         mapWCref = map->WcMapDes;
      } 

      // write the map type, index and dependent variable headers to the file
      DATA_MAP << "maptype = '" << mapType << "'" << endl << endl;
      if ( mapType == "BETA" ) { 
         DATA_MAP << "#        alpha         beta        speed";
      } 
      else { 
         DATA_MAP << "#        alpha        speed        Rline";
      } 
      DATA_MAP << "        Wcorr           PR          eff  \n";
      DATA_MAP.width = 2; DATA_MAP << "mapdata=["; DATA_MAP << endl;


      //----------------------------------------------------------------------
      // write the data to the file in nested loops of i, j, and k
      //----------------------------------------------------------------------
      alphaVals = Tbl_flow->getValues( indepNames[0] );

      // for each alpha value
      for ( i=0; i < alphaVals.entries(); ++i ) {
         DATA_MAP.width = 2; DATA_MAP << "["; DATA_MAP << endl;
         betaVals = Tbl_flow->getValues( indepNames[1], alphaVals[i] );

         // for each beta value
         for ( j=0; j < betaVals.entries(); ++j ) {
            DATA_MAP.width = 2; DATA_MAP << "["; DATA_MAP << endl;
            gammaVals = Tbl_flow->getValues( indepNames[2], alphaVals[i], betaVals[j] );

            // for each speed value
            for ( k=0; k < gammaVals.entries(); ++k ) {
               DATA_MAP.width = 2; DATA_MAP << "[";

               // get value of corrected flow
               dataFlow = Tbl_flow->eval( alphaVals[i], betaVals[j], gammaVals[k] );
               // get value of adiabatic efficiency
               dataEff = Tbl_eff->eval( alphaVals[i], betaVals[j], gammaVals[k] );

               // get value or calculate pressure ratio (Rline or BETA map type)
               if ( mapType == "BETA" ) { 
                  dataPR = mapXK1 +( (mapPRref-mapXK1)*( (dataFlow/mapWCref)**1.43
                  - betaVals[j] + 1. ) ); }
               else { 
                  dataPR = Tbl_PR->eval( alphaVals[i], betaVals[j], gammaVals[k] );
               } 

               // write alpha, beta, gamma, Wc, PR, and efficiency to the file
               DATA_MAP.showpoint = TRUE;
               DATA_MAP.precision = 6;
               DATA_MAP.width = 12;
               DATA_MAP << alphaVals[i];
               DATA_MAP.width = 1; DATA_MAP << ","; DATA_MAP.width = 12;
               DATA_MAP << betaVals[j];
               DATA_MAP.width = 1; DATA_MAP << ","; DATA_MAP.width = 12;
               DATA_MAP << gammaVals[k];
               DATA_MAP.width = 1; DATA_MAP << ","; DATA_MAP.width = 12;
               DATA_MAP << dataFlow;
               DATA_MAP.width = 1; DATA_MAP << ","; DATA_MAP.width = 12;
               DATA_MAP << dataPR;
               DATA_MAP.width = 1; DATA_MAP << ","; DATA_MAP.width = 12;
               DATA_MAP << dataEff;

               // close groups (lists) of data based on PYTHON format
               if ( k+1 < gammaVals.entries() ) { 
                  DATA_MAP.width = 2; DATA_MAP << "],"; } 
               else { 
                  if ( j+1 < betaVals.entries() ) { 
                     DATA_MAP.width = 4; DATA_MAP << "] ],"; }
                  else { 
                     if ( i+1 < alphaVals.entries() ) { 
                        DATA_MAP.width = 6; DATA_MAP << "] ] ],"; }
                     else { 
                        DATA_MAP.width = 7; DATA_MAP << "] ] ] ]"; } 
                  }
               }
               DATA_MAP << endl;
            }
         }
      }
      DATA_MAP << endl;


      //----------------------------------------------------------------------
      // write the variables that specify different map plotting options
      // default values:
      //       scaled maps                              TRUE
      //       multiple alpha plots                    FALSE
      //       overlay alpha plots                     FALSE
      //       filled efficiency contours               TRUE
      //       show beta lines or rlines                TRUE
      //       specify plot axes                         -
      //       specify efficiency contour levels         -
      //       specify gamma contour levels              -
      //----------------------------------------------------------------------
      real user_array[];        // used for specific axes or contour levels
      int count;                // the number of user input values 

      // OPTION for scaled maps, write the map scalars regardless
      if ( exists( map+".SCALED_MAP" ) && ( map+".SCALED_MAP" )->value == 0 ) { 
         DATA_MAP << "scaled_map=0" << endl;
      } 
      else { 
         DATA_MAP << "scaled_map=1" << endl;
      }
      DATA_MAP << "scalars=[ ";
      DATA_MAP.width=7; DATA_MAP << map->s_WcDes;
      DATA_MAP.width=2; DATA_MAP << ", ";
      DATA_MAP.width=7; DATA_MAP << map->s_PRdes;
      DATA_MAP.width=2; DATA_MAP << ", ";
      DATA_MAP.width=7; DATA_MAP << map->s_effDes;
      DATA_MAP.width=2; DATA_MAP << ", ";
      DATA_MAP.width=7; DATA_MAP << "1.00000";      //map->s_NcDes;
      DATA_MAP.width=2; DATA_MAP << " ]";
      DATA_MAP << endl;


      // OPTION for multiple alpha plots
      // OPTION to overlay plots of multiple alphas
      if ( exists( map+".MULTIPLE_ALPHAS" ) && ( map+".MULTIPLE_ALPHAS" )->value == 1 ) { 
         DATA_MAP << "multiple_alphas=1" << endl;
         if ( exists( map+".OVERLAY" ) && ( map+".OVERLAY" )->value == 1 ) { 
            DATA_MAP << "overlay=1" << endl;
         } 
         else {
            DATA_MAP << "overlay=0" << endl;
         }
      } 
      else { 
         DATA_MAP << "multiple_alphas=0" << endl;
         DATA_MAP << "overlay=0" << endl;
      }


      // OPTION for filled efficiency contours
      if ( exists( map+".FILLED" ) && ( map+".FILLED" )->value == 0 ) { 
         DATA_MAP << "filled=0" << endl;
      } 
      else { 
         if ( exists( map+".OVERLAY" ) && ( map+".OVERLAY" )->value == 1 ) { 
            DATA_MAP << "filled=0" << endl;
         } 
         else {
            DATA_MAP << "filled=1" << endl;
         }
      }


      // OPTION for showing lines of constant Beta or Rline value
      if ( exists( map+".SHOW_LINES" ) && ( map+".SHOW_LINES" )->value == 0 ) { 
         DATA_MAP << "show_lines=0" << endl;
      } 
      else { 
         DATA_MAP << "show_lines=1" << endl;
      }


      // OPTION to specify plot boundaries
      if ( exists( map+".AXES" )  && ( map+".AXES" )->entries() == 4 ) { 
         user_array = ( map+".AXES" )->value;
         DATA_MAP << "axes=[ ";
         for ( count=0; count < user_array.entries()-1; ++count ) {
            DATA_MAP << user_array[count] << ", ";
         } 
         DATA_MAP << user_array[count] << " ]" << endl;
      } 


      // OPTION to specify speed contour levels
      if ( exists( map+".CONTOUR_SPD" ) && ( map+".CONTOUR_SPD" )->entries() > 2 ) { 
         user_array = ( map+".CONTOUR_SPD" )->value;
         DATA_MAP << "Vspd=[ ";
         for ( count=0; count < user_array.entries()-1; ++count ) {
            DATA_MAP << user_array[count] << ", ";
         } 
         DATA_MAP << user_array[count] << " ]" << endl;
      } 


      // OPTION to specify efficiency contour values
      if ( exists( map+".CONTOUR_EFF" ) && ( map+".CONTOUR_EFF" )->entries() > 2 ) { 
         user_array = ( map+".CONTOUR_EFF" )->value;
         DATA_MAP << "Veff=[ ";
         for ( count=0; count < user_array.entries()-1; ++count ) {
            DATA_MAP << user_array[count] << ", ";
         } 
         DATA_MAP << user_array[count] << " ]" << endl;
      } 

      // close the file
      DATA_MAP.close();
   } 

   //-------------------------------------------------------------------------
   // for each turbine, write its map data to a file in PYTHON format
   //-------------------------------------------------------------------------
   for ( n=0; n < TURB_NAMES.entries(); ++n ) {

      // set the map data filename
      DATA_MAP.width = 0;
      DATA_MAP.filename = "Map_plotting/mapData" + TURB_NAMES[n] + ".txt";
      DATA_MAP << "mapname = '" << TURB_NAMES[n] << "'" << endl;

      // determine if the turbine map is type 1 or 2
      if ( exists( TURB_NAMES[n] + ".S_map.S_eff" ) ) { 
         mapType = "TURBone";
         map = "parent." + TURB_NAMES[n] + ".S_map.S_eff";
         Tbl_flow = map + ".TB_Wp";
         Tbl_eff  = map + ".TB_eff";
         indepNames = Tbl_flow->getIndependentNames(); 
      } 
      else { 
         mapType = "TURBtwo";
         map = "parent." + TURB_NAMES[n] + ".S_map";
         Tbl_flow = map + ".TB_Wp";
         Tbl_eff  = map + ".TB_eff";
         indepNames = Tbl_flow->getIndependentNames(); 
      } 

      // write the map type, index and dependent variable headers to the file
      DATA_MAP << "maptype = '" << mapType << "'" << endl << endl;
      DATA_MAP << "#        alpha        speed           PR";
      DATA_MAP << "        Wcorr          eff  \n";
      DATA_MAP.width = 2; DATA_MAP << "mapdata=["; DATA_MAP << endl;


      //----------------------------------------------------------------------
      // write the data to the file in nested loops of i, j, and k
      //----------------------------------------------------------------------
      alphaVals = Tbl_flow->getValues( indepNames[0] );

      // for each alpha value
      for ( i=0; i < alphaVals.entries(); ++i ) {
         DATA_MAP.width = 2; DATA_MAP << "["; DATA_MAP << endl;
         betaVals = Tbl_flow->getValues( indepNames[1], alphaVals[i] );

         // for each beta value
         for ( j=0; j < betaVals.entries(); ++j ) {
            DATA_MAP.width = 2; DATA_MAP << "["; DATA_MAP << endl;
            gammaVals = Tbl_flow->getValues( indepNames[2], alphaVals[i], betaVals[j] );

            // for each speed value
            for ( k=0; k < gammaVals.entries(); ++k ) {
               DATA_MAP.width = 2; DATA_MAP << "[";

               // get value of corrected flow
               dataFlow = Tbl_flow->eval( alphaVals[i], betaVals[j], gammaVals[k] );
               // get value of adiabatic efficiency
               dataEff = Tbl_eff->eval( alphaVals[i], betaVals[j], gammaVals[k] );

               // get value or calculate pressure ratio (Rline or BETA map type)
//             if ( mapType == "BETA" ) { 
//                dataPR = mapXK1 +( (mapPRref-mapXK1)*( (dataFlow/mapWCref)**1.43
//                - betaVals[j] + 1. ) ); }
//             else { 
//                dataPR = Tbl_PR->eval( alphaVals[i], betaVals[j], gammaVals[k] );
//             } 

               // write alpha, beta, gamma, Wc, PR, and efficiency to the file
               DATA_MAP.showpoint = TRUE;
               DATA_MAP.precision = 6;
               DATA_MAP.width = 12;
               DATA_MAP << alphaVals[i];
               DATA_MAP.width = 1; DATA_MAP << ","; DATA_MAP.width = 12;
               DATA_MAP << betaVals[j];
               DATA_MAP.width = 1; DATA_MAP << ","; DATA_MAP.width = 12;
               DATA_MAP << gammaVals[k];
               DATA_MAP.width = 1; DATA_MAP << ","; DATA_MAP.width = 12;
               DATA_MAP << dataFlow;
//             DATA_MAP.width = 1; DATA_MAP << ","; DATA_MAP.width = 12;
//             DATA_MAP << dataPR;
               DATA_MAP.width = 1; DATA_MAP << ","; DATA_MAP.width = 12;
               DATA_MAP << dataEff;

               // close groups (lists) of data based on PYTHON format
               if ( k+1 < gammaVals.entries() ) { 
                  DATA_MAP.width = 2; DATA_MAP << "],"; } 
               else { 
                  if ( j+1 < betaVals.entries() ) { 
                     DATA_MAP.width = 4; DATA_MAP << "] ],"; }
                  else { 
                     if ( i+1 < alphaVals.entries() ) { 
                        DATA_MAP.width = 6; DATA_MAP << "] ] ],"; }
                     else { 
                        DATA_MAP.width = 7; DATA_MAP << "] ] ] ]"; } 
                  }
               }
               DATA_MAP << endl;
            }
         }
      }
      DATA_MAP << endl;

      //----------------------------------------------------------------------
      // write the variables that specify different map plotting options
      // default values:
      //       scaled maps                              TRUE
      //       multiple alpha plots                    FALSE
      //       overlay alpha plots                     FALSE
      //       filled efficiency contours               TRUE
      //       specify plot axes                         -
      //       specify efficiency contour levels         -
      //----------------------------------------------------------------------
      real user_array2[];       // used for specific axes or contour levels
      int count2;               // the number of user input values 

      // OPTION for scaled maps, write the map scalars regardless
      if ( exists( map+".SCALED_MAP" ) && ( map+".SCALED_MAP" )->value == 0 ) { 
         DATA_MAP << "scaled_map=0" << endl;
      } 
      else { 
         DATA_MAP << "scaled_map=1" << endl;
      }
      DATA_MAP << "scalars=[ ";
      DATA_MAP.width=7; DATA_MAP << map->s_Wp;
      DATA_MAP.width=2; DATA_MAP << ", ";
      DATA_MAP.width=7; DATA_MAP << map->s_dPqP;
      DATA_MAP.width=2; DATA_MAP << ", ";
      DATA_MAP.width=7; DATA_MAP << map->s_eff;
      DATA_MAP.width=2; DATA_MAP << ", ";
      DATA_MAP.width=7; DATA_MAP << "1.00000";      //map->s_NcDes;
      DATA_MAP.width=2; DATA_MAP << " ]";
      DATA_MAP << endl;


      // OPTION for multiple alpha plots
      // OPTION to overlay plots of multiple alphas
      if ( exists( map+".MULTIPLE_ALPHAS" ) && ( map+".MULTIPLE_ALPHAS" )->value == 1 ) { 
         DATA_MAP << "multiple_alphas=1" << endl;
         if ( exists( map+".OVERLAY" ) && ( map+".OVERLAY" )->value == 1 ) { 
            DATA_MAP << "overlay=1" << endl;
         } 
         else {
            DATA_MAP << "overlay=0" << endl;
         }
      } 
      else { 
         DATA_MAP << "multiple_alphas=0" << endl;
         DATA_MAP << "overlay=0" << endl;
      }


      // OPTION for filled efficiency contours
      if ( exists( map+".FILLED" ) && ( map+".FILLED" )->value == 0 ) { 
         DATA_MAP << "filled=0" << endl;
      } 
      else { 
         if ( exists( map+".OVERLAY" ) && ( map+".OVERLAY" )->value == 1 ) { 
            DATA_MAP << "filled=0" << endl;
         } 
         else {
            DATA_MAP << "filled=1" << endl;
         }
      }


      // OPTION for showing lines of constant Beta or Rline value
      // this option has no meaning for turbine maps


      // OPTION to specify plot boundaries
      if ( exists( map+".AXES" )  && ( map+".AXES" )->entries() == 4 ) { 
         user_array2 = ( map+".AXES" )->value;
         DATA_MAP << "axes=[ ";
         for ( count2=0; count2 < user_array2.entries()-1; ++count2 ) {
            DATA_MAP << user_array2[count2] << ", ";
         } 
         DATA_MAP << user_array2[count2] << " ]" << endl;
      } 


      // OPTION to specify speed contour levels
      if ( exists( map+".CONTOUR_SPD" ) && ( map+".CONTOUR_SPD" )->entries() > 2 ) { 
         user_array2 = ( map+".CONTOUR_SPD" )->value;
         DATA_MAP << "Vspd=[ ";
         for ( count2=0; count2 < user_array2.entries()-1; ++count2 ) {
            DATA_MAP << user_array2[count2] << ", ";
         } 
         DATA_MAP << user_array2[count2] << " ]" << endl;
      } 


      // OPTION to specify efficiency contour values
      if ( exists( map+".CONTOUR_EFF" ) && ( map+".CONTOUR_EFF" )->entries() > 2 ) { 
         user_array2 = ( map+".CONTOUR_EFF" )->value;
         DATA_MAP << "Veff=[ ";
         for ( count2=0; count2 < user_array2.entries()-1; ++count2 ) {
            DATA_MAP << user_array2[count2] << ", ";
         } 
         DATA_MAP << user_array2[count2] << " ]" << endl;
      } 

      // close the file
      DATA_MAP.close();
   } 
}



void saveOpPoint(string descriptor) {

   //-------------------------------------------------------------------------
   // declare the DATA stream and filename one time only
   //-------------------------------------------------------------------------
   if ( firstcall == 1 ) { 
      OutFileStream DATA_PNT { } 
      DATA_PNT.filename = "Map_plotting/mapOpPoints.txt";
      DATA_PNT << "#   name     arg  alpha1  alpha2       Wc      PR      eff";
      DATA_PNT << endl << endl;
      DATA_PNT << "points_data=[" << endl;
      firstcall = 0;
   } 

   //-------------------------------------------------------------------------
   // if operating points are not desired, close the file and ignore 
   // all subsequent calls to this function
   //-------------------------------------------------------------------------
   if ( descriptor == "NOSAVE" ) {
      DATA_PNT << "] " << endl;
      DATA_PNT.close();
      nosave = 1;
   } 

   DATA_PNT.showpoint = TRUE;
   DATA_PNT.width = 0;
   //-------------------------------------------------------------------------
   // write the operating data to the file by point, component, then data
   //-------------------------------------------------------------------------
   if ( nosave != 1 ) {

      int i, n;
      string varstring[];

      // start a point block each time this fucntion is called
      DATA_PNT << " [ " << endl;
      
      //----------------------------------------------------------------------
      // for each compressor: write name, description, alpha, alpha, Wc, PR, and eff
      //----------------------------------------------------------------------
      for ( n=0; n < COMP_NAMES.entries(); ++n ) {

         // set varstring based on compressor map type - BETA or RLINE
         if ( exists( COMP_NAMES[n] + ".S_map.S_eff" ) ) { 
            varstring = { ".S_map.alpha", ".S_map.alpha", ".Wc", ".PR", ".eff" };
         } 
         else { 
            varstring = { ".S_map.alphaMap", ".S_map.alphaMap", ".Wc", ".PR", ".eff" };
         } 
         DATA_PNT << " [";
         DATA_PNT << " '" << COMP_NAMES[n]  << "', '" << descriptor << "',";
         for ( i=0; i < varstring.entries(); ++i ) {
            // format stuff to make it look nice
            if ( i == 0 || i == 1 ) { DATA_PNT.precision=3; DATA_PNT.width=7; }
            else if ( i == 2 ) { DATA_PNT.precision=5; DATA_PNT.width=8; }
            else if ( i == 3 ) { DATA_PNT.precision=4; DATA_PNT.width=7; }
            else { DATA_PNT.precision=4; DATA_PNT.width=8; }

            DATA_PNT << ( COMP_NAMES[n]+varstring[i] )->value;
            DATA_PNT.width=0;
            if ( i+1 < varstring.entries() ) { DATA_PNT << ","; }
         } 
         DATA_PNT << " ]," << endl;
      } 

      //----------------------------------------------------------------------
      // for each turbine: write name, description, alpha, alpha, Wc, PR, and eff
      //----------------------------------------------------------------------
      for ( n=0; n < TURB_NAMES.entries(); ++n ) {

         if ( exists( TURB_NAMES[n] + ".S_map.S_eff" ) ) { 
            varstring = { ".S_map.parmGeom", ".S_map.parmGeom", ".WpIn", ".PR", ".eff" };
         } 
         else { 
            varstring = { ".S_map.alpha", ".S_map.alpha", ".WpIn", ".PR", ".eff" };
         } 
         DATA_PNT << " [";
         DATA_PNT << " '" << TURB_NAMES[n]  << "', '" << descriptor << "',";
         for ( i=0; i < varstring.entries(); ++i ) {
            // format stuff to make it look nice
            if ( i == 0 || i == 1 ) { DATA_PNT.precision=3; DATA_PNT.width=7; }
            else if ( i == 2 ) { DATA_PNT.precision=5; DATA_PNT.width=8; }
            else if ( i == 3 ) { DATA_PNT.precision=4; DATA_PNT.width=7; }
            else { DATA_PNT.precision=4; DATA_PNT.width=8; }

            DATA_PNT << ( TURB_NAMES[n]+varstring[i] )->value;
            DATA_PNT.width=0;
            if ( i+1 < varstring.entries() ) { DATA_PNT << ","; }
         } 
         if ( n+1 < TURB_NAMES.entries() ) { DATA_PNT << " ]," << endl; }
         else { DATA_PNT << " ] ]"; }
      } 

      //----------------------------------------------------------------------
      // if this is the last point, close the file; otherwise start a new block
      //----------------------------------------------------------------------
      if ( descriptor == "DONE" ) { 
         DATA_PNT << " ] " << endl;
         DATA_PNT.close();
      }
      else { 
         DATA_PNT << "," << endl;
      } 
   }
}


