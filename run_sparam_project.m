function run_sparam_project(cfg)
% RUN_SPARAM_PROJECT  Orchestrates reading, processing, and plotting.
%
% Workflow:
%   - Measurement files:  .s2p named like "P2P3.s2p"
%       * "PXPY" means VNA port1 is connected to DUT port X (input),
%         VNA port2 is connected to DUT port Y (output).
%       * The .s2p always contains local S11, S21, S12, S22 referenced to
%         those measurement ports.
%       * These are mapped to GLOBAL S_ij entries as:
%             local S11 -> S_XX
%             local S21 -> S_YX
%             local S12 -> S_XY
%             local S22 -> S_YY
%
%   - Simulation file(s): Lab-style text file with blocks:
%         freq   dB(S(i,j))
%     which represent GLOBAL S_ij for the full multi-port network.
%
%   - For each measurement file and each local S-parameter, the code:
%       * maps local S to global S_ij using the filename,
%       * looks up the matching simulated S_ij,
%       * generates a plot "Simulated vs Measured" in dB,
%       * fixes the Y-axis to [-60, 0] dB,
%       * saves it as "<Sij>.png" into cfg.outputDir.

    %------------------------------------------
    % 1) Discover measurement and simulation files
    %------------------------------------------
    measFiles = dir(fullfile(cfg.measurementDir, '*.s2p'));
    if isempty(measFiles)
        warning('No .s2p measurement files found in %s', cfg.measurementDir);
    end

    simFiles = [
        dir(fullfile(cfg.simulationDir, '*.txt'));
        dir(fullfile(cfg.simulationDir, '*.tab'));
        dir(fullfile(cfg.simulationDir, '*.dat'))
    ];
    if isempty(simFiles)
        warning('No simulation text files found in %s', cfg.simulationDir);
    end

    %------------------------------------------
    % 2) Build a map of simulation data keyed by GLOBAL S-parameter label
    %    Each simulation file may contain ONE or MANY S-parameters.
    %------------------------------------------
    simMap = containers.Map('KeyType','char','ValueType','any');

    for k = 1:numel(simFiles)
        simPath = fullfile(simFiles(k).folder, simFiles(k).name);
        simSet  = io.read_simulation_table(simPath, cfg);

        for idx = 1:numel(simSet.sParamLabels)
            sLabel = simSet.sParamLabels{idx};   % e.g. 'S22', 'S23', ...
            key    = upper(sLabel);

            if isKey(simMap, key)
                warning('Multiple simulation sources for %s; keeping first (%s), ignoring %s.', ...
                    key, simMap(key).sourceFile, simSet.sourceFile);
                continue;
            end

            entry            = struct();
            entry.freqGHz    = simSet.freqGHz;
            entry.Sdb        = simSet.Sdb.(sLabel);
            entry.sourceFile = simSet.sourceFile;

            simMap(key) = entry;
        end
    end

    %------------------------------------------
    % 3) Loop over measurement files and create plots
    %------------------------------------------
    for k = 1:numel(measFiles)
        measPath = fullfile(measFiles(k).folder, measFiles(k).name);
        measBase = measFiles(k).name;

        fprintf('\nProcessing measurement file: %s\n', measBase);
        measData = io.read_touchstone_s2p(measPath, cfg);

        % Parse DUT port indices X (input) and Y (output) from filename "PXPY"
        [portIn, portOut] = util.parse_ports_from_filename(measBase);

        % Local S-parameters in every .s2p
        localLabels = {'S11','S21','S12','S22'};

        for idx = 1:numel(localLabels)
            localLabel = localLabels{idx};

            if ~isfield(measData.Sdb, localLabel)
                continue;
            end

            % Map local S to GLOBAL S_ij based on PXPY naming
            switch localLabel
                case 'S11'
                    i = portIn;  j = portIn;   % S_XX
                case 'S21'
                    i = portOut; j = portIn;   % S_YX
                case 'S12'
                    i = portIn;  j = portOut;  % S_XY
                case 'S22'
                    i = portOut; j = portOut;  % S_YY
                otherwise
                    continue;
            end

            globalLabel = sprintf('S%d%d', i, j);

            if ~isKey(simMap, globalLabel)
                fprintf('  No simulation data for %s (from local %s) -> skipping.\n', ...
                        globalLabel, localLabel);
                continue;
            end

            simData = simMap(globalLabel);

            % Output file name: just "Sij.png" as requested
            saveName = globalLabel;

            % Generate and save the comparison plot
            plotting.plot_sparam_comparison( ...
                measData.freqGHz, measData.Sdb.(localLabel), ...
                simData.freqGHz,  simData.Sdb, ...
                globalLabel, saveName, cfg);
        end
    end

    fprintf('\nAll done. Plots written to folder: %s\n', cfg.outputDir);
end
