// Write measurements for the superController.

// Proceed turbine by turbine.
    forAll(deltaNacYaw, i)
    {
        superInfoToSSC[i*nInputsToSSC+0] = generatorPower[i];      // Generator power [W]
        superInfoToSSC[i*nInputsToSSC+1] = rotorSpeedF[i];         // Filtered rotor speed [rad/s]
        superInfoToSSC[i*nInputsToSSC+2] = rotorAzimuth[i]/degRad; // Azimuth angle [deg]
        superInfoToSSC[i*nInputsToSSC+3] = rotorAxialForce[i];     // Turbine axial force [N]
        superInfoToSSC[i*nInputsToSSC+4] = rotorTorque[i];         // Rotor torque [Nm]
        superInfoToSSC[i*nInputsToSSC+5] = generatorTorque[i];     // Generator torque [Nm]
        superInfoToSSC[i*nInputsToSSC+6] = nacYaw[i]/degRad;       // Nacelle yaw [deg]
        superInfoToSSC[i*nInputsToSSC+7] = bladePitch[i];          // Pitch angle [deg]
    }