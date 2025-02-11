% Ground truth
sensor_x_center = mean(sensor_x);  % Center of the sensor array along x-axis
sensor_y_center = sensor_y;        % Fixed y position for all sensors

% Calculate the true angle of arrival using atan2
true_AoA = atan2(source_y - sensor_y_center, source_x - sensor_x_center);
true_AoA_deg = rad2deg(true_AoA) - 90; % Convert to degrees, and make -90 to 90

% Display the true AoA
disp(['True AoA: ', num2str(true_AoA_deg(1)), ' degrees']); % Display AoA relative to center of array

% Plot
figure;
imagesc(kgrid.t_array * 1e6, sensor_x * dx * 1e3, sensor_data); % Scale axes
xlabel('Time [\mus]');
ylabel('Sensor Position [mm]');
title('Recorded Pressure at Sensor Array');
colorbar;

% ============= MATH =============
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

disp(["Steering vectors size: ", size(steering_vectors)]);
disp(["Sensor data size: ", size(sensor_data)]);

% Beamforming
beamforming_output = zeros(size(angles));
for i = 1:length(angles)
    beamforming_output(i) = sum(abs(steering_vectors(i,:) * sensor_data));
end

% Find the angle that maximizes beamforming output
[~, idx] = max(beamforming_output);
estimated_angle = angles(idx);

fprintf("Estimated AoA: %.2f degrees\n", estimated_angle);