% ---------------------------------------------------------
% WORKFLOW DEMO: "Lifecycle of a Patient" (Slide 8 Logic)
% ---------------------------------------------------------
clear; clc; close all;

% --- 1. SETUP PARAMETERS ---
wardW = 20; wardH = 15;
numPatients = 30; % Start with fewer to show lifecycle clearly
rx = [5, 15, 10]; ry = [11.25, 11.25, 3.75]; % Readers

% Define Zone Centers for "Target" movement
targetA = [4, 11];  % Triage (Start)
targetB = [4, 4];   % Waiting
targetC = [14, 10]; % Treatment
targetD = [14, 2.5]; % Discharge

% Initialize Patients (All start off-screen)
px = ones(1, numPatients) * -2;
py = ones(1, numPatients) * 11;
state = zeros(1, numPatients); % 0=Off, 1=Arrive, 2=Wait, 3=Treat, 4=Discharge
timers = zeros(1, numPatients); % To control how long they stay in a zone

% --- 2. SETUP FIGURE ---
f = figure('Name', 'WORKFLOW SIMULATION', 'Color', [0.1 0.1 0.1], 'Position', [100 100 1100 600]);

% Map
subplot('Position', [0.05 0.1 0.65 0.85]);
hold on; axis equal; grid on; box on;
xlim([0 wardW]); ylim([0 wardH]);
set(gca, 'Color', 'k', 'XColor', 'w', 'YColor', 'w');
title('LIVE PATIENT WORKFLOW', 'Color', 'w', 'FontSize', 14);

% Draw Zones (A->B->C->D)
rectangle('Position', [0 7.5 8 7.5], 'EdgeColor', 'g', 'LineWidth', 2); text(1, 14, '1. ARRIVAL', 'Color', 'g');
rectangle('Position', [0 0 8 7.5], 'EdgeColor', 'c', 'LineWidth', 2); text(1, 1, '2. WAITING', 'Color', 'c');
rectangle('Position', [8 5 12 10], 'EdgeColor', 'r', 'LineWidth', 2); text(9, 14, '3. TREATMENT', 'Color', 'r');
rectangle('Position', [8 0 12 5], 'EdgeColor', 'y', 'LineWidth', 2); text(9, 1, '4. DISCHARGE', 'Color', 'y');

% Draw Patients (Scatter handle)
hPatients = scatter(px, py, 100, 'filled', 'MarkerFaceColor', 'w');

% Live Log Box
hLog = annotation('textbox', [0.72 0.1 0.25 0.8], 'String', 'SYSTEM LOGS initializing...', ...
    'Color', 'g', 'BackgroundColor', [0.2 0.2 0.2], 'FontSize', 10, 'EdgeColor', 'w');

logs = {}; % Log history

% --- 3. ANIMATION LOOP ---
for t = 1:600
    % A. Spawn new patients (Workflow Start)
    if mod(t, 20) == 0
        new_idx = find(state == 0, 1);
        if ~isempty(new_idx)
            state(new_idx) = 1; % Set to Arrive
            px(new_idx) = 0.5; py(new_idx) = 11 + rand();
            timers(new_idx) = 0;
            logs = [{' > New Patient Arrived (Tag Assigned)'}; logs(1:min(end, 15))];
        end
    end
    
    % B. Logic for each patient
    colors = zeros(numPatients, 3);
    for i = 1:numPatients
        if state(i) == 0; continue; end % Skip inactive
        
        target = [0,0];
        spd = 0.3;
        
        % State Machine (The Workflow from Slide 8)
        if state(i) == 1 % ARRIVAL
            target = targetB; % Walk to Waiting
            colors(i,:) = [0 1 0]; % Green
            if norm([px(i), py(i)] - target) < 2
                state(i) = 2; timers(i) = 30 + rand()*20; % Wait for 30-50 frames
                logs = [{' > Patient moved to Waiting'}; logs(1:min(end, 15))];
            end
            
        elseif state(i) == 2 % WAITING
            target = targetB; % Stay in Waiting
            colors(i,:) = [0 1 1]; % Cyan
            if timers(i) > 0
                timers(i) = timers(i) - 1;
                % Jiggle around
                target = target + [rand()-0.5, rand()-0.5]*3;
            else
                state(i) = 3; timers(i) = 60 + rand()*40; % Go to Treatment
                logs = [{' > Patient moved to Treatment'}; logs(1:min(end, 15))];
            end
            
        elseif state(i) == 3 % TREATMENT
            target = targetC;
            colors(i,:) = [1 0 0]; % Red
            if timers(i) > 0
                timers(i) = timers(i) - 1;
                target = target + [rand()-0.5, rand()-0.5]*4;
            else
                state(i) = 4; % Go to Discharge
                logs = [{' > Treatment Done. Discharging...'}; logs(1:min(end, 15))];
            end
            
        elseif state(i) == 4 % DISCHARGE
            target = targetD;
            colors(i,:) = [1 1 0]; % Yellow
            if norm([px(i), py(i)] - target) < 2
                state(i) = 0; % Remove from map
                px(i) = -10; py(i) = -10;
                logs = [{' > Patient Discharged (Data Archived)'}; logs(1:min(end, 15))];
            end
        end
        
        % Move towards target
        dir = target - [px(i), py(i)];
        if norm(dir) > 0.1
            dir = dir / norm(dir);
            px(i) = px(i) + dir(1)*spd;
            py(i) = py(i) + dir(2)*spd;
        end
    end
    
    % C. Update Graphics
    set(hPatients, 'XData', px, 'YData', py, 'CData', colors);
    set(hLog, 'String', logs);
    
    drawnow;
    pause(0.02);
end