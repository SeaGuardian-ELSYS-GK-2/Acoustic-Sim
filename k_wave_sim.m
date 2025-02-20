function [t, x, y, sensor_data] = k_wave_sim(Nx, Ny, dx, dy, sensor_positions, time, source_pos, source_freq, source_func)

kgrid = kWaveGrid(Nx, dx, Ny, dy);  % Create k-Wave computational grid

% Define medium properties (water)
medium.sound_speed = 1500;  % Speed of sound in water (m/s)
medium.density = 1000;      % Density of water (kg/m^3)

% Define time array (automatically determined for stability)
% kgrid.makeTime(medium.sound_speed);
t_end = time; % 0.25 ms
kgrid.t_array = makeTime(kgrid, medium.sound_speed, [], t_end);

source.p_mask = zeros(Nx, Ny);
source.p_mask(source_pos) = 1;

% Define source signal (tone burst)
source.p = source_func(kgrid.t_array, source_freq);

% Assign sensor mask
sensor.mask = zeros(Nx, Ny);
sensor.mask(sensor_positions) = 1;  % Activate sensor locations

% Run the simulation
input_args = {'PMLSize', 20, 'PlotSim', true, 'DataCast', 'single'};
sensor_data = kspaceFirstOrder2D(kgrid, medium, source, sensor, input_args{:}); % , input_args{:}
t = kgrid.t_array;
x = kgrid.x_vec;
y = kgrid.y_vec;

end