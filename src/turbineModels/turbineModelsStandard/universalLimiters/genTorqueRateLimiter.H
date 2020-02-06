            // Limit the change in generator torque.
            //
            scalar torqueGenRateCommanded = (generatorTorqueCommanded - currentGenTorque) / dt;
            torqueGenRateCommanded = min(max(torqueGenRateCommanded, -RateLimitGenTorque[j]), RateLimitGenTorque[j]);
            generatorTorqueCommanded = currentGenTorque + (torqueGenRateCommanded * dt);
