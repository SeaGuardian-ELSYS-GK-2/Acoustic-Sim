% OLD AoA code, works well, but only gives negative angles, so not very
% practicle

L = max_sensor_spacing;
N = num_sensors;
angles = -90:0.1:90;
theta_scan = deg2rad(angles);

if (L / lambda) > 0.5
    warning("Sensor spacing is greater than λ/2. Aliasing may be occurring.");
end

% Steering vector computation
sensor_indices = 0:N-1; % Centered around zero

% Compute the steering vectors
% Broadcast the sensor indices and angle data properly
steering_vectors = exp(1j * 2 * pi * (L / lambda) * sin(theta_scan).' * (0:N-1));

% Beamforming
beamforming_output = zeros(size(angles));
for i = 1:length(angles)
    beamforming_output(i) = sum(abs(steering_vectors(i,:) * sensor_data));
end

% Find the angle that maximizes beamforming output
[~, idx] = max(beamforming_output);
estimated_angle = angles(idx);

fprintf("Estimated AoA: %.2f degrees\n", estimated_angle);