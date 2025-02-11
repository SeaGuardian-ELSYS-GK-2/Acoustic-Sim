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
t_end = 2.5e-4;
kgrid.t_array = makeTime(kgrid, medium.sound_speed, [], t_end);

% Define source (transducer emitting a pressure wave)
source.p_mask = zeros(Nx, Ny);
source_x = Nx * 1.25/4;
source_y = Ny * 3/4;
source.p_mask(source_x, source_y) = 1; % Place source 1/4th from top
disp(["Source: ", num2str(source_x), num2str(source_y)])

% Define source signal (tone burst)
freq = 100e3;  % 100 kHz frequency
n_cycles = 20;  % Number of wave cycles
source.p = sin(2 * pi * freq * kgrid.t_array) .* (kgrid.t_array < (n_cycles / freq));

% Define a single sensor (hydrophone sensor array)
num_sensors = 10;

% Calculate the wavelength
lambda = (medium.sound_speed / freq);
max_sensor_spacing = lambda / 2; % Calculate the maximum allowable spacing between sensors (half the wavelength)
array_center = Nx / 2;           % Define the center of the array

% Calculate the total length of the sensor array
sensor_array_length = (num_sensors - 1) * max_sensor_spacing / dx;

% Ensure the array is centered at Nx/2
sensor_x_start = array_center - sensor_array_length / 2;
sensor_x_end = array_center + sensor_array_length / 2;

% Generate sensor positions symmetrically around the center
sensor_x = linspace(sensor_x_start, sensor_x_end, num_sensors);
sensor_y = linspace(Ny * 5/10, Ny * 5/10, num_sensors); % Fixed y position (10 pixels from bottom)

% Convert to indices
sensor_positions = sub2ind([Nx, Ny], round(sensor_x), round(sensor_y));

% Assign sensor mask
sensor.mask = zeros(Nx, Ny);
sensor.mask(sensor_positions) = 1;  % Activate sensor locations
%sensor.mask = ones(Nx, Ny);         % For plotting entire wave, makes entire
                                    % (Nx, Ny) space into "sensors"

% Run the simulation
input_args = {'PMLSize', 20, 'PlotSim', true, 'DataCast', 'single'};
sensor_data = kspaceFirstOrder2D(kgrid, medium, source, sensor, input_args{:}); % , input_args{:}