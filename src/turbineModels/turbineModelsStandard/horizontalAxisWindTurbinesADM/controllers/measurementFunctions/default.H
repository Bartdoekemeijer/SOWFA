// Write measurements for the superController.

// Proceed turbine by turbine.
    forAll(deltaNacYaw, i)
    {
        superInfoToSSC[i*nInputsToSSC+0] = powerGenerator[i]; // Generator power [W]
        superInfoToSSC[i*nInputsToSSC+1] = rotSpeedF[i];      // Filtered rotor speed [rad/s]
        superInfoToSSC[i*nInputsToSSC+2] = azimuth[i]/degRad; // Azimuth angle [deg]
        superInfoToSSC[i*nInputsToSSC+3] = thrust[i];         // Turbine thrust force [N]
        superInfoToSSC[i*nInputsToSSC+4] = torqueRotor[i];    // Rotor torque [Nm]
        superInfoToSSC[i*nInputsToSSC+5] = torqueGen[i];      // Generator torque [Nm]
        superInfoToSSC[i*nInputsToSSC+6] = nacYaw[i]/degRad;  // Nacelle yaw [deg]
        superInfoToSSC[i*nInputsToSSC+7] = pitch[i];          // Pitch angle [deg]
    }