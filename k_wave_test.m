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
t_end = 2.5e-4; % 0.25 ms
kgrid.t_array = makeTime(kgrid, medium.sound_speed, [], t_end);

% Define source (transducer emitting a pressure wave)
source_x = 450;
source_y = 256;

% Clamp and round the source position
source_x = clip(round(source_x), 1, Nx);
source_y = clip(round(source_y), 1, Ny);

source.p_mask = zeros(Nx, Ny);
source.p_mask(source_x, source_y) = 1; % Place source 1/4th from top
disp(["Source: ", num2str(source_x), num2str(source_y)])

% Define source signal (tone burst)
freq = 100e3;  % 100 kHz frequency
n_cycles = 1;  % Number of wave cycles
source.p = sin(2 * pi * freq * kgrid.t_array) .* (kgrid.t_array < (n_cycles / freq));

% Define a single sensor (hydrophone sensor array)
num_sensors = 10;

% Calculate the wavelength
lambda = (medium.sound_speed / freq);

% Create a UCA (uniform circular array)
R = lambda/4 + lambda/(2*pi) * (num_sensors-1); % Optimal radius of array
uca_theta = linspace(0, 2*pi, num_sensors+1);
uca_theta(end) = [];

sensor_x = R * cos(uca_theta);
sensor_y = R * sin(uca_theta);

% Convert sensor positions to x,y coordinates and center sensors around a position
sensor_center_x = 256;
sensor_center_y = 256;

sensor_x = (sensor_x / dx) + sensor_center_x;
sensor_y = (sensor_y / dy) + sensor_center_y;

disp(["Sensor positions: x: ", num2str(sensor_x), " y: ", num2str(sensor_y)]);

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