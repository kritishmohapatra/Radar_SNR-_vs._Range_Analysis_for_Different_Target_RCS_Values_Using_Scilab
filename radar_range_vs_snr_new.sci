clc;           // Clear the command window
clear;         // Clear all existing variables from memory

// ------------------ Radar Parameters ------------------

peak_transmit_power = 20e3; // Radar peak transmit power in Watts (19.2 kW)

gain_in_db_of_t = 39;              // Antenna gain in decibels (dB)
gain_in_db_of_r=39;
gain_t = 10^(gain_in_db_of_t/10);    // Convert gain from dB to linear scale
gain_r = 10^(gain_in_db_of_r/10);    // Convert gain from dB to linear scale

fre = 3.2e9;                 // Operating frequency in Hz (3.2 GHz)
c = 3e8;                      // Speed of light in meters per second
lambda = c / fre;            // Wavelength = speed of light / frequency
to=3e-3;

k = 1.38e-23;                 // Boltzmann's constant in J/K
ts = 300;                  // System noise temperature in Kelvin (25°C ≈ 298.15 K)

loss_in_db = 6.5;               // Total system losses in dB
loss = 10^(loss_in_db/10);    // Convert loss from dB to linear scale
noise_in_db=3;
noise=10^(noise_in_db/10);

sigma_dBsm_values = [-25, -15, -10]; // Radar Cross Section (RCS) values in dBsm


// ------------------ Range Vector ------------------

r_min =1e3; // Minimum detection range in meters (800 m)
r_max = 40e3;  // Maximum detection range in meters (90 km)
num_points = 500; // Number of range points for plotting
R = linspace(r_min, r_max, num_points); // Linearly spaced range values (array)

// ------------------ Initialize Legend ------------------

legends = []; // Initialize an empty array for legend labels

// Precompute constant part of the SNR denominator
denominator_constant = (4 * %pi)^3 * k * ts * noise * loss;

// ------------------ Compute SNR for Each RCS ------------------

// Extract individual RCS values in dBsm
sigma_dbsm_1 = sigma_dBsm_values(1);
sigma_dbsm_2 = sigma_dBsm_values(2);
sigma_dbsm_3 = sigma_dBsm_values(3);

// Convert RCS from dBsm to linear scale (m^2)
sigma_1 = 10^(sigma_dbsm_1/10);
sigma_2 = 10^(sigma_dbsm_2/10);
sigma_3 = 10^(sigma_dbsm_3/10);

// Compute the numerator for SNR for each RCS value
numerator_1 = peak_transmit_power * gain_t*gain_r* lambda^2 * sigma_1*to;
numerator_2 = peak_transmit_power * gain_t*gain_r * lambda^2 * sigma_2*to;
numerator_3 = peak_transmit_power * gain_t*gain_r * lambda^2 * sigma_3*to;

// Compute SNR in linear scale
SNR_linear_1 = numerator_1 ./ (R.^4 * denominator_constant);
SNR_linear_2 = numerator_2 ./ (R.^4 * denominator_constant);
SNR_linear_3 = numerator_3 ./ (R.^4 * denominator_constant);

// Convert SNR from linear to dB scale
SNR_dB_1 = 10 * log10(SNR_linear_1);
SNR_dB_2 = 10 * log10(SNR_linear_2);
SNR_dB_3 = 10 * log10(SNR_linear_3);

// ------------------ Plot SNR vs Range ------------------

// Plot SNR for σ = -25 dBsm in blue line
plot(R/1000, SNR_dB_1, "-b") // Range is divided by 1000 to convert to kilometers

// Plot SNR for σ = -15 dBsm in red line
plot(R/1000, SNR_dB_2, "-r")

// Plot SNR for σ = -10 dBsm in green line
plot(R/1000, SNR_dB_3, "-g")

// ------------------ Add Legends ------------------

// Append legend strings for each RCS value
legends($+1) = "σ = " + string(sigma_dbsm_1) + " dBsm";
legends($+1) = "σ = " + string(sigma_dbsm_2) + " dBsm";
legends($+1) = "σ = " + string(sigma_dbsm_3) + " dBsm";

// ------------------ Final Plot Customization ------------------

xlabel('Range (km)'); // Label x-axis
ylabel('SNR (dB)');   // Label y-axis
title('Radar Range vs. SNR for Different Target RCS Values'); // Plot title
xgrid();              // Add a grid to the plot
legend(legends);      // Add the legend to identify each line

