% Define computational grid
Nx = 512;         % Number of grid points in x (width)
Ny = 512;         % Number of grid points in y (height)
dx = 1e-2;        % Grid point spacing in meters (100.0 mm)
dy = dx;          % Uniform spacing

% Source
source_pos_xy  = [420,200; 420,220; 420,240; 420,260; 420,280; 420,300; 420,320; 420,340;];
source_pos = [];  % Tom liste for å lagre resultatene

% Løkke over hver rad i matrise
for i = 1:size(source_pos_xy, 1)
    product = source_pos_xy(i, 1) + source_pos_xy(i, 2) * Nx;  % Multiplisere de to tallene
    source_pos = [source_pos, product];  % Append resultatet på listen
end

disp(source_pos);

source_freq = 4e3;   % 100 kHz frequency
source_n_cycles = 1;  % Number of wave cycles

function source_value = source_function(t, freq)
    source_value = sin(2 * pi * freq * t);
end

% Define a single sensor (hydrophone sensor array)
num_sensors = 10;

% Calculate the wavelength
speed_of_sound = 1500; % m/s
lambda = (speed_of_sound / source_freq);

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

% Convert to indices
% sensor_positions = sub2ind([Nx, Ny], round(sensor_x), round(sensor_y));

% For plotting entire wave
sensor_positions = 1:(Nx * Ny);

% Run sim
[time_array, x_array, y_array, sensor_data] = k_wave_sim(Nx, Ny, dx, dy, sensor_positions, 2.5e-3, source_pos, source_freq, @source_function);