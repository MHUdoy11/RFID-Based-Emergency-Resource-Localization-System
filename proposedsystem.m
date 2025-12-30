% ---------------------------------------------------------
% RFID-Based System Framework Generator (Slide 7)
% ---------------------------------------------------------
clear; clc; close all;

% 1. Create Figure
f = figure('Name', 'Proposed System Framework', 'Color', 'w', 'Position', [100 100 1000 600]);
axis off; hold on;
% Set plotting range
xlim([0 10]); ylim([0 10]);

% 2. Define Styles
% Colors (Professional Blue/Grey Scheme)
col_hardware = [0.85 0.9 1];    % Light Blue
col_edge     = [0.9 0.95 0.9];  % Light Green
col_cloud    = [0.95 0.9 0.85]; % Light Orange
col_border   = [0.2 0.2 0.2];   % Dark Grey

% 3. Draw "Layers" (Background zones)
% Hardware Layer
rectangle('Position', [0.5, 0.5, 3, 9], 'Curvature', 0.1, 'EdgeColor', 'none', 'FaceColor', [0.98 0.98 1]);
text(2, 9.2, 'PHYSICAL LAYER', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'Color', [0.4 0.4 0.8]);

% Edge/Processing Layer
rectangle('Position', [3.8, 0.5, 2.4, 9], 'Curvature', 0.1, 'EdgeColor', 'none', 'FaceColor', [0.98 1 0.98]);
text(5, 9.2, 'EDGE LAYER', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'Color', [0.4 0.8 0.4]);

% Cloud/App Layer
rectangle('Position', [6.5, 0.5, 3, 9], 'Curvature', 0.1, 'EdgeColor', 'none', 'FaceColor', [1 0.98 0.95]);
text(8, 9.2, 'CLOUD/APP LAYER', 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'Color', [0.8 0.5 0.2]);

% 4. Draw Component Blocks (Helper Function below)
% RFID Tags
drawBlock(2, 7.5, 'RFID Tags', '(Patient/Asset)', col_hardware);

% RFID Readers
drawBlock(2, 4.5, 'RFID Readers', '(UHF Sensors)', col_hardware);

% Edge Device
drawBlock(5, 4.5, 'Edge Device', '(Local Filtering)', col_edge);

% Database Server
drawBlock(8, 4.5, 'Database Server', '(SQL/Cloud)', col_cloud);

% Web Interface
drawBlock(8, 7.5, 'Web Interface', '(Dashboard)', col_cloud);

% MATLAB Engine
drawBlock(8, 1.5, 'MATLAB Engine', '(Simulation Logic)', col_cloud);

% 5. Draw Arrows (Connections)
% Tags -> Readers (Wireless)
drawArrow([2, 2], [6.9, 5.1], '--'); 
text(2.1, 6, 'Wireless Signal', 'FontSize', 8, 'Color', 'b');

% Readers -> Edge (Wired/WiFi)
drawArrow([2.6, 4.4], [4.5, 4.5], '-');

% Edge -> Database (Internet)
drawArrow([5.6, 7.4], [4.5, 4.5], '-');
text(6.5, 4.7, 'Sync', 'FontSize', 8, 'HorizontalAlignment', 'center');

% Database <-> Web Interface (Bi-directional)
drawArrow([8, 8], [5.1, 6.9], '-');

% Database <-> MATLAB (Bi-directional)
drawArrow([8, 8], [3.9, 2.1], '-');
text(8.1, 3, 'Data Logs', 'FontSize', 8);

% 6. Add Titles and Annotations
title('Fig 1. Proposed Hybrid Edge-Cloud Architecture', 'FontSize', 14, 'FontWeight', 'bold');

% --- Helper Functions ---
function drawBlock(x, y, titleStr, subStr, col)
    w = 1.2; h = 0.6; % Half-width/height
    rectangle('Position', [x-w, y-h, 2*w, 2*h], 'Curvature', 0.2, ...
        'FaceColor', col, 'EdgeColor', [0.2 0.2 0.2], 'LineWidth', 1.5);
    text(x, y+0.2, titleStr, 'HorizontalAlignment', 'center', 'FontSize', 11, 'FontWeight', 'bold');
    text(x, y-0.2, subStr, 'HorizontalAlignment', 'center', 'FontSize', 9, 'Color', [0.3 0.3 0.3]);
end

function drawArrow(x, y, style)
    % Simple arrow drawer
    annotation('arrow', [0.1+0.8*(x(1)/10), 0.1+0.8*(x(2)/10)], ...
        [0.1+0.8*(y(1)/10), 0.1+0.8*(y(2)/10)], 'LineStyle', style, 'LineWidth', 1.5, 'HeadStyle', 'vback2');
end