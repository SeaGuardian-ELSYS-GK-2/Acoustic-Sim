sensor_data_2d = reshape(sensor_data, Nx, Ny, kgrid.Nt);

% Set N to the interval between frames you want to display (e.g., 10)
N = 10;

% Find the global min and max pressure values over the entire simulation
min_pressure = min(sensor_data(:));
max_pressure = max(sensor_data(:));

figure;
% Plot a sample frame to create the initial plot and color bar
h = surf(kgrid.x_vec * 1e3, kgrid.y_vec * 1e3, sensor_data_2d(:, :, 1)); % Scale to mm
shading interp;  % Smooth the surface
colormap(jet);
colorbar;

% Set the color axis limits and z-axis limits
caxis([min_pressure, max_pressure]); % Fix the color range
zlim([min_pressure, max_pressure]); % Fix the z-axis range

% Label the axes
xlabel('x [mm]');
ylabel('y [mm]');
zlabel('Pressure');
title(['Time Step: 1']);

% Loop through the time steps and update the surface plot
for t = 1:N:kgrid.Nt
    % Update the surface plot with new data for the current time step
    set(h, 'ZData', sensor_data_2d(:, :, t)); % Update the Z data of the surface plot
    
    % Update the title for the current time step
    title(['Time Step: ', num2str(t)]);
    
    % Pause to control the animation speed
    pause(0.05); % Adjust speed (0.05 sec per frame)
end