% Clear workspace
clear; close all; clc;

% Define computational grid
Nx = 512;         % Number of grid points in x (width)
Ny = 512;         % Number of grid points in y (height)
dx = 1e-3;        % Grid point spacing in meters (10.0 mm)
dy = dx;          % Uniform spacing

kgrid = kWaveGrid(Nx, dx, Ny, dy);  % Create k-Wave computational grid

% Define medium properties (water)
medium.sound_speed = 1500;  % Speed of sound in water (m/s)
medium.density = 1000;      % Density of water (kg/m^3)

% Define time array (automatically determined for stability)
% kgrid.makeTime(medium.sound_speed);
t_end = 4e-4;
kgrid.t_array = makeTime(kgrid, medium.sound_speed, [], t_end)

% Define source (transducer emitting a pressure wave)
source.p_mask = zeros(Nx, Ny);
source.p_mask(0, Ny/4) = 1; % Place source 1/4th from top

% Define source signal (tone burst)
freq = 10e3;  % 100 kHz frequency
n_cycles = 2;  % Number of wave cycles
source.p = sin(2 * pi * freq * kgrid.t_array) .* (kgrid.t_array < (n_cycles / freq));

% Define a single sensor (hydrophone sensor array)
num_sensors = 10;
sensor_x = linspace(Nx/4, 3*Nx/4, num_sensors); % Evenly spaced along x-axis
sensor_y = Ny - 10; % Fixed y position (10 pixels from bottom)

% Convert to indices
sensor_positions = sub2ind([Nx, Ny], round(sensor_x), repmat(sensor_y, size(sensor_x)));

% Assign sensor mask
sensor.mask = zeros(Nx, Ny);
sensor.mask(sensor_positions) = 1; % Activate sensor locations

% Run the simulation
input_args = {'PMLSize', 20, 'PlotSim', true, 'DataCast', 'single'};
sensor_data = kspaceFirstOrder2D(kgrid, medium, source, sensor); % , input_args{:}
% sensor_data = reshape(sensor_data, Nx, Ny, kgrid.Nt);
% size(sensor_data)


% ========== MATH STUFF ==========
arrival_times = zeros(num_sensors, 1);
for i = 1:num_sensors
    % Find the first peak in the signal (arrival time)
    [~, peak_index] = max(abs(sensor_data(i, :)));
    arrival_times(i) = kgrid.t_array(peak_index);
end

% Plot sensor data
figure;
imagesc(kgrid.t_array * 1e6, sensor_x * dx * 1e3, sensor_data); % Scale axes
xlabel('Time [\mus]');
ylabel('Sensor Position [mm]');
title('Recorded Pressure at Sensor Array');
colorbar;

% 3D Wave Plot
% N = 10;
% 
% % Find the global min and max pressure values over the entire simulation
% min_pressure = min(sensor_data(:));
% max_pressure = max(sensor_data(:));
% 
% figure;
% % Plot a sample frame to create the initial plot and color bar
% h = surf(kgrid.x_vec * 1e3, kgrid.y_vec * 1e3, sensor_data(:, :, 1)); % Scale to mm
% shading interp;  % Smooth the surface
% colormap(jet);
% colorbar;
% 
% % Set the color axis limits and z-axis limits
% caxis([min_pressure, max_pressure]); % Fix the color range
% zlim([min_pressure, max_pressure]); % Fix the z-axis range
% 
% % Label the axes
% xlabel('x [mm]');
% ylabel('y [mm]');
% zlabel('Pressure');
% title(['Time Step: 1']);
% 
% % Loop through the time steps and update the surface plot
% for t = 1:N:kgrid.Nt
%     % Update the surface plot with new data for the current time step
%     set(h, 'ZData', sensor_data(:, :, t)); % Update the Z data of the surface plot
% 
%     % Update the title for the current time step
%     title(['Time Step: ', num2str(t)]);
% 
%     % Pause to control the animation speed
%     pause(0.05); % Adjust speed (0.05 sec per frame)
% end
% 
