            // Limit the change in blade pitch.

            scalar pitchRateCommanded = (bladePitchCommanded - (currentBladePitch*degRad)) / dt;
            pitchRateCommanded = min(max(pitchRateCommanded, -(RateLimitBladePitch[j]*degRad)), (RateLimitBladePitch[j]*degRad));
            bladePitchCommanded = (currentBladePitch*degRad) + (pitchRateCommanded * dt);
