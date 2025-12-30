% ---------------------------------------------------------
% WORKFLOW DEMO: Patient Lifecycle + FALL DETECTION
% ---------------------------------------------------------
clear; clc; close all;

% --- 1. SETUP PARAMETERS ---
wardW = 20; wardH = 15;
numPatients = 30;
rx = [5, 15, 10]; ry = [11.25, 11.25, 3.75]; % Readers

% Define Zone Centers
targetA = [4, 11];  % Triage
targetB = [4, 4];   % Waiting
targetC = [14, 10]; % Treatment
targetD = [14, 2.5]; % Discharge

% Initialize Patients
px = ones(1, numPatients) * -2;
py = ones(1, numPatients) * 11;
state = zeros(1, numPatients); % 0=Off, 1=Arrive, 2=Wait, 3=Treat, 4=Discharge
isFallen = zeros(1, numPatients); % 0=Normal, 1=Fallen
fallTimer = zeros(1, numPatients); % How long they stay fallen
timers = zeros(1, numPatients); % Zone stay duration

% --- 2. SETUP FIGURE ---
f = figure('Name', 'WORKFLOW & SAFETY SIMULATION', 'Color', [0.1 0.1 0.1], 'Position', [100 100 1100 600]);

% Map
subplot('Position', [0.05 0.1 0.65 0.85]);
hold on; axis equal; grid on; box on;
xlim([0 wardW]); ylim([0 wardH]);
set(gca, 'Color', 'k', 'XColor', 'w', 'YColor', 'w');
title('LIVE WORKFLOW & SAFETY MONITORING', 'Color', 'w', 'FontSize', 14);

% Draw Zones
rectangle('Position', [0 7.5 8 7.5], 'EdgeColor', 'g', 'LineWidth', 2); text(1, 14, '1. ARRIVAL', 'Color', 'g');
rectangle('Position', [0 0 8 7.5], 'EdgeColor', 'c', 'LineWidth', 2); text(1, 1, '2. WAITING', 'Color', 'c');
rectangle('Position', [8 5 12 10], 'EdgeColor', 'r', 'LineWidth', 2); text(9, 14, '3. TREATMENT', 'Color', 'r');
rectangle('Position', [8 0 12 5], 'EdgeColor', 'y', 'LineWidth', 2); text(9, 1, '4. DISCHARGE', 'Color', 'y');

% Draw Patients
hPatients = scatter(px, py, 120, 'filled', 'MarkerFaceColor', 'w');
hLabels = text(px, py, '', 'Color', 'w', 'FontSize', 8, 'HorizontalAlignment', 'center');

% Live Log Box
hLog = annotation('textbox', [0.72 0.1 0.25 0.8], 'String', 'SYSTEM LOGS initializing...', ...
    'Color', 'g', 'BackgroundColor', [0.2 0.2 0.2], 'FontSize', 10, 'EdgeColor', 'w');

logs = {};

% --- 3. ANIMATION LOOP ---
for t = 1:1000
    % A. Spawn new patients
    if mod(t, 30) == 0
        new_idx = find(state == 0, 1);
        if ~isempty(new_idx)
            state(new_idx) = 1; % Arrive
            px(new_idx) = 0.5; py(new_idx) = 11 + rand();
            timers(new_idx) = 0;
            isFallen(new_idx) = 0;
            logs = [{' > New Patient Arrived'}; logs(1:min(end, 18))];
        end
    end
    
    % B. Random Fall Generator (Small chance every frame)
    if rand() < 0.02 % 2% chance per frame of a fall occurring somewhere
        active_ids = find(state > 0 & state < 4 & isFallen == 0); % Only active patients fall
        if ~isempty(active_ids)
            victim = active_ids(randi(length(active_ids)));
            isFallen(victim) = 1;
            fallTimer(victim) = 40; % Stay fallen for 40 frames (~2 sec)
            logs = [{[' *** ALERT: Fall Detected (ID ' num2str(victim) ') ***']}; logs(1:min(end, 18))];
        end
    end
    
    % C. Update Logic
    colors = zeros(numPatients, 3);
    labels = cell(1, numPatients);
    
    for i = 1:numPatients
        if state(i) == 0; continue; end
        
        % --- FALL HANDLING ---
        if isFallen(i) == 1
            colors(i,:) = [1 0 1]; % PURPLE for Fall
            labels{i} = 'FALL!';
            fallTimer(i) = fallTimer(i) - 1;
            
            % "Nurse" assists after timer
            if fallTimer(i) <= 0
                isFallen(i) = 0;
                logs = [{[' > Fall Resolved (ID ' num2str(i) ')']}; logs(1:min(end, 18))];
            end
            continue; % Skip movement if fallen
        end
        
        target = [0,0];
        spd = 0.3;
        labels{i} = num2str(i);
        
        % State Machine
        if state(i) == 1 % ARRIVAL
            target = targetB; 
            colors(i,:) = [0 1 0]; % Green
            if norm([px(i), py(i)] - target) < 2
                state(i) = 2; timers(i) = 30 + rand()*20;
            end
            
        elseif state(i) == 2 % WAITING
            target = targetB; 
            colors(i,:) = [0 1 1]; % Cyan
            if timers(i) > 0
                timers(i) = timers(i) - 1;
                target = target + [rand()-0.5, rand()-0.5]*3;
            else
                state(i) = 3; timers(i) = 60 + rand()*40;
                logs = [{[' > Patient ' num2str(i) ' -> Treatment']} ; logs(1:min(end, 18))];
            end
            
        elseif state(i) == 3 % TREATMENT
            target = targetC;
            colors(i,:) = [1 0 0]; % Red
            if timers(i) > 0
                timers(i) = timers(i) - 1;
                target = target + [rand()-0.5, rand()-0.5]*4;
            else
                state(i) = 4; 
                logs = [{[' > Patient ' num2str(i) ' Discharging...']} ; logs(1:min(end, 18))];
            end
            
        elseif state(i) == 4 % DISCHARGE
            target = targetD;
            colors(i,:) = [1 1 0]; % Yellow
            if norm([px(i), py(i)] - target) < 2
                state(i) = 0; px(i) = -10; py(i) = -10;
            end
        end
        
        % Move
        dir = target - [px(i), py(i)];
        if norm(dir) > 0.1
            dir = dir / norm(dir);
            px(i) = px(i) + dir(1)*spd;
            py(i) = py(i) + dir(2)*spd;
        end
    end
    
    % D. Update Graphics
    set(hPatients, 'XData', px, 'YData', py, 'CData', colors);
    
    % Update Labels (Only show for active patients)
    % Only update position of labels for active patients
    for k = 1:numPatients
        if state(k) > 0
            hLabels(k).Position = [px(k), py(k)+0.8];
            hLabels(k).String = labels{k};
            if isFallen(k)
                hLabels(k).Color = 'm'; hLabels(k).FontSize = 10; hLabels(k).FontWeight = 'bold';
            else
                hLabels(k).Color = 'w'; hLabels(k).FontSize = 8; hLabels(k).FontWeight = 'normal';
            end
        else
            hLabels(k).String = '';
        end
    end
    
    set(hLog, 'String', logs);
    
    drawnow;
    pause(0.02);
end