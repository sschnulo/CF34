

// ==============================================================================
// deck_low
// ------------------------------------------------------------------------------
void deck_low(real maxNc, real maxT4SLS, real maxT4RTO) {
    FLOPsheetStream.open("deck.txt");

    // Run down to sea level if we are still at altitude:
    if (Ambient.alt > 20000.) {
       cout << "Running the model back to sea level...     \n"; 
       RunMaxPower( 0.70, 30000., 0., maxNc, maxT4SLS, maxT4RTO );
       RunMaxPower( 0.60, 20000., 0., maxNc, maxT4SLS, maxT4RTO );
       RunMaxPower( 0.55, 17000., 0., maxNc, maxT4SLS, maxT4RTO );
       RunMaxPower( 0.50, 15000., 0., maxNc, maxT4SLS, maxT4RTO );
       RunMaxPower( 0.40, 10000., 0., maxNc, maxT4SLS, maxT4RTO );
       RunMaxPower( 0.20, 5000.,  0., maxNc, maxT4SLS, maxT4RTO );
    }
    
    
    RunThrottleHook( 0.00,     0., 0., maxNc, maxT4SLS, maxT4RTO); //page.display(); 
    RunThrottleHook( 0.10,     0., 0., maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.20,     0., 0., maxNc, maxT4SLS, maxT4RTO);    
    RunThrottleHook( 0.25,     0., 0., maxNc, maxT4SLS, maxT4RTO); //page.display();  
    RunMaxPower(0.28, 0.0, 0., maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.30,     0., 0., maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.35,     0., 0., maxNc, maxT4SLS, maxT4RTO);


    RunThrottleHook( 0.00,  2000., 0., maxNc, maxT4SLS, maxT4RTO); 
    RunThrottleHook( 0.10,  2000., 0., maxNc, maxT4SLS, maxT4RTO); 
    RunThrottleHook( 0.20,  2000., 0., maxNc, maxT4SLS, maxT4RTO); 
    RunThrottleHook( 0.25,  2000., 0., maxNc, maxT4SLS, maxT4RTO); 
    RunThrottleHook( 0.30,  2000., 0., maxNc, maxT4SLS, maxT4RTO); 
    RunThrottleHook( 0.35,  2000., 0., maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.40,  2000., 0., maxNc, maxT4SLS, maxT4RTO);


    RunThrottleHook( 0.00,  5000., 0., maxNc, maxT4SLS, maxT4RTO); 
    RunThrottleHook( 0.10,  5000., 0., maxNc, maxT4SLS, maxT4RTO); 
    RunThrottleHook( 0.20,  5000., 0., maxNc, maxT4SLS, maxT4RTO); 
    RunThrottleHook( 0.25,  5000., 0., maxNc, maxT4SLS, maxT4RTO); 
    RunThrottleHook( 0.30,  5000., 0., maxNc, maxT4SLS, maxT4RTO); 
    RunThrottleHook( 0.35,  5000., 0., maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.40,  5000., 0., maxNc, maxT4SLS, maxT4RTO);
    RunMaxPower(0.42, 5000., 0., maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.45,  5000., 0., maxNc, maxT4SLS, maxT4RTO);


    RunThrottleHook( 0.10, 10000., 0., maxNc, maxT4SLS, maxT4RTO); 
    RunThrottleHook( 0.20, 10000., 0., maxNc, maxT4SLS, maxT4RTO); 
    RunThrottleHook( 0.25, 10000., 0., maxNc, maxT4SLS, maxT4RTO); 
    RunThrottleHook( 0.30, 10000., 0., maxNc, maxT4SLS, maxT4RTO); 
    RunThrottleHook( 0.35, 10000., 0., maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.40, 10000., 0., maxNc, maxT4SLS, maxT4RTO);
    RunMaxPower(0.42, 10000., 0., maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.45, 10000., 0., maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.50, 10000., 0., maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.55, 10000., 0., maxNc, maxT4SLS, maxT4RTO);


    RunThrottleHook( 0.30, 15000., 0., maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.35, 15000., 0., maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.40, 15000., 0., maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.45, 15000., 0., maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.50, 15000., 0., maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.55, 15000., 0., maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.60, 15000., 0., maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.65, 15000., 0., maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.70, 15000., 0., maxNc, maxT4SLS, maxT4RTO);

    FLOPsheet.display();
    FLOPsheetStream.close();
 
    Ambient.WAR = 0.0;

} // deck_low


// ==============================================================================
// deck_high
// ------------------------------------------------------------------------------
void deck_high(real maxNc, real maxT4SLS, real maxT4RTO){
    FLOPsheetStream.open("deck.txt");

    // Run down to sea level if we are still at altitude:
    if (Ambient.alt > 20000.) {
       cout << "Running the model back to sea level...     \n"; 
       RunMaxPower( 0.70, 30000., 0., maxNc, maxT4SLS, maxT4RTO );
       RunMaxPower( 0.60, 20000., 0., maxNc, maxT4SLS, maxT4RTO );
       RunMaxPower( 0.55, 17000., 0., maxNc, maxT4SLS, maxT4RTO );
       RunMaxPower( 0.50, 15000., 0., maxNc, maxT4SLS, maxT4RTO );
       RunMaxPower( 0.40, 10000., 0., maxNc, maxT4SLS, maxT4RTO );
       RunMaxPower( 0.20, 5000.,  0., maxNc, maxT4SLS, maxT4RTO );
    }    

    RunThrottleHook( 0.40, 20000., 0.0, maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.45, 20000., 0.0, maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.50, 20000., 0.0, maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.55, 20000., 0.0, maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.60, 20000., 0.0, maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.65, 20000., 0.0, maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.70, 20000., 0.0, maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.75, 20000., 0.0, maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.80, 20000., 0.0, maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.85, 20000., 0.0, maxNc, maxT4SLS, maxT4RTO);
    RunMaxPower(0.80, 20000., 0., maxNc, maxT4SLS, maxT4RTO);
    RunMaxPower(0.70, 20000., 0., maxNc, maxT4SLS, maxT4RTO);
    RunMaxPower(0.60, 20000., 0., maxNc, maxT4SLS, maxT4RTO);
    RunMaxPower(0.45, 20000., 0., maxNc, maxT4SLS, maxT4RTO);


    RunThrottleHook( 0.45, 25000., 0.0, maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.50, 25000., 0.0, maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.55, 25000., 0.0, maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.60, 25000., 0.0, maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.65, 25000., 0.0, maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.70, 25000., 0.0, maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.75, 25000., 0.0, maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.80, 25000., 0.0, maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.85, 25000., 0.0, maxNc, maxT4SLS, maxT4RTO);
    RunMaxPower(0.80, 25000., 0., maxNc, maxT4SLS, maxT4RTO);
    RunMaxPower(0.70, 25000., 0., maxNc, maxT4SLS, maxT4RTO);
    RunMaxPower(0.60, 25000., 0., maxNc, maxT4SLS, maxT4RTO);


    RunThrottleHook( 0.55, 30000., 0.0, maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.60, 30000., 0.0, maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.65, 30000., 0.0, maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.70, 30000., 0.0, maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.75, 30000., 0.0, maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.80, 30000., 0.0, maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.85, 30000., 0.0, maxNc, maxT4SLS, maxT4RTO);
    RunMaxPower(0.80, 30000., 0., maxNc, maxT4SLS, maxT4RTO);
    RunMaxPower(0.70, 30000., 0., maxNc, maxT4SLS, maxT4RTO);
    RunMaxPower(0.60, 30000., 0., maxNc, maxT4SLS, maxT4RTO);


    RunThrottleHook( 0.60, 35000., 0.0, maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.65, 35000., 0.0, maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.70, 35000., 0.0, maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.75, 35000., 0.0, maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.80, 35000., 0.0, maxNc, maxT4SLS, maxT4RTO); //page.display();
    RunThrottleHook( 0.85, 35000., 0.0, maxNc, maxT4SLS, maxT4RTO); //page.display();
    RunMaxPower(0.87, 35000., 0., maxNc, maxT4SLS, maxT4RTO);
    RunMaxPower(0.88, 35000., 0., maxNc, maxT4SLS, maxT4RTO);
    RunMaxPower(0.89, 35000., 0., maxNc, maxT4SLS, maxT4RTO);
    RunMaxPower(0.90, 35000., 0., maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.90, 35000., 0.0, maxNc, maxT4SLS, maxT4RTO);
    RunMaxPower(0.85, 35000., 0., maxNc, maxT4SLS, maxT4RTO);
    RunMaxPower(0.80, 35000., 0., maxNc, maxT4SLS, maxT4RTO);
    RunMaxPower(0.75, 35000., 0., maxNc, maxT4SLS, maxT4RTO);
    RunMaxPower(0.70, 35000., 0., maxNc, maxT4SLS, maxT4RTO);
    RunMaxPower(0.60, 35000., 0., maxNc, maxT4SLS, maxT4RTO);


    RunThrottleHook( 0.60, 39000., 0.0, maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.65, 39000., 0.0, maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.70, 39000., 0.0, maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.75, 39000., 0.0, maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.80, 39000., 0.0, maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.85, 39000., 0.0, maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.90, 39000., 0.0, maxNc, maxT4SLS, maxT4RTO);
    RunMaxPower(0.85, 39000., 0., maxNc, maxT4SLS, maxT4RTO);
    RunMaxPower(0.80, 39000., 0., maxNc, maxT4SLS, maxT4RTO);
    RunMaxPower(0.75, 39000., 0., maxNc, maxT4SLS, maxT4RTO);
    RunMaxPower(0.70, 39000., 0., maxNc, maxT4SLS, maxT4RTO);


    RunThrottleHook( 0.70, 43000., 0.0, maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.75, 43000., 0.0, maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.80, 43000., 0.0, maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.85, 43000., 0.0, maxNc, maxT4SLS, maxT4RTO);
    RunThrottleHook( 0.90, 43000., 0.0, maxNc, maxT4SLS, maxT4RTO);

    FLOPsheet.display();
    FLOPsheetStream.close();

} // deck_high


