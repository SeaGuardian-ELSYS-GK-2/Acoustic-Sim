% Given values
c = 1500;   % m/s
fs = 1 / kgrid.dt; % Hz
N = num_sensors;
lambda = (medium.sound_speed / freq); % meters
L = lambda/2;

% Convert back to meters
sensor_x_phys = sensor_x * dx;
sensor_y_phys = sensor_y * dy;

% Ground truth
sensor_x_center = mean(sensor_x);  % Center of the sensor array along x-axis
sensor_y_center = sensor_y;        % Fixed y position for all sensors

% Calculate the true angle of arrival using atan2
true_AoA = atan2(source_y - sensor_y_center, source_x - sensor_x_center);
true_AoA_deg = rad2deg(true_AoA) - 90; % Convert to degrees, and make -90 to 90

% Display the true AoA
disp(['True AoA: ', num2str(true_AoA_deg(1)), ' degrees']); % Display AoA relative to center of array

% Estimation
% Create UCA
array = phased.ConformalArray('ElementPosition', [sensor_x_phys; sensor_y_phys; zeros(1,N)]);

% Visualize the array
figure;
scatter(sensor_x_phys, sensor_y_phys, 'filled');
hold on;
plot([sensor_x_phys sensor_x_phys(1)], [sensor_y_phys sensor_y_phys(1)], 'r--');  % Connect points
xlabel('X (m)'); ylabel('Y (m)'); title('Uniform Circular Array (UCA)');
axis equal; grid on;

% Create a MUSIC DoA estimator for a UCA
estimator = phased.MUSICEstimator2D('SensorArray', array, ...
    'PropagationSpeed', c, 'AzimuthScanAngles', [-180:180], ...
    'OperatingFrequency', fs, 'DOAOutputPort', true, 'NumSignals', 1);

% Estimate DoA using received data
angles = estimator(sensor_data.');
angles_deg = rad2deg(angles);
disp(['Estimated DOA: ', num2str(angles_deg), ' degrees']);

avg_angle = mean(angles_deg);
disp(['Avg estimated DOA: ', num2str(avg_angle), ' degrees']);

% Create a plot of the estimated DoA
figure;
plot(angles_deg, 'o-');
xlabel('Snapshot Index');
ylabel('Estimated DoA (degrees)');
title('MUSIC Estimated DoA');
grid on;