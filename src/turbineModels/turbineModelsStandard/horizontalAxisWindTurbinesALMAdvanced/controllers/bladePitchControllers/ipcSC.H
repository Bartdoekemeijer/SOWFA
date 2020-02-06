            // Copy collective blade pitch angles to individual blade pitch angles
            for(int ibl = 0; ibl < numberOfBlades; ibl++)
            {
                // Import pitch angles from SSC, assuming entry [2] for blade [0] and onwards
                individualBladePitchCommanded.append(superInfoFromSSC[i*nOutputsFromSSC+2+ibl]);
            }