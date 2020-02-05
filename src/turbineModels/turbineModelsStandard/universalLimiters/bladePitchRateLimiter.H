            // Limit the change in blade pitch.

            scalar pitchRateCommanded = (bladePitchCommanded - currentBladePitch) / dt; // in deg/s
            pitchRateCommanded = min(max(pitchRateCommanded, -RateLimitBladePitch[j]), RateLimitBladePitch[j]);
            bladePitchCommanded = currentBladePitch + (pitchRateCommanded * dt);
