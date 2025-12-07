function cfg = default_config()
% DEFAULT_CONFIG  Default configuration for the S-parameter project.

    projectRoot = pwd;  % assume main.m is run from project root

    cfg = struct();

    %-------------------------------
    % Paths
    %-------------------------------
    cfg.measurementDir = fullfile(projectRoot, 'data', 'measurements');
    cfg.simulationDir  = fullfile(projectRoot, 'data', 'simulations');
    cfg.outputDir      = fullfile(projectRoot, 'output');

    %-------------------------------
    % Plot settings
    %-------------------------------
    % Vertical axis fixed from -60 dB to 0 dB as requested
    cfg.yLimits_dB = [-40 0];
    % Frequency where we annotate both curves (set [] to disable)
    cfg.annotationFreqGHz = 2.45;
    % PNG resolution
    cfg.exportDPI = 300;
    % Whether to show figures on screen
    cfg.showFigures = false;

    % Measured curve style (red solid)
    cfg.styles.meas.LineStyle        = '-';
    cfg.styles.meas.LineWidth        = 1.8;
    cfg.styles.meas.Color            = [0.85 0.1 0.1];
    cfg.styles.meas.MarkerFaceColor  = [0 0 0];   % black marker
    cfg.styles.meas.MarkerEdgeColor  = [0 0 0];
    cfg.styles.meas.MarkerTextColor  = [0 0 0];

    % Simulated curve style (blue dashed)
    cfg.styles.sim.LineStyle         = '--';
    cfg.styles.sim.LineWidth         = 1.8;
    cfg.styles.sim.Color             = [0 0.45 0.9];
    cfg.styles.sim.MarkerFaceColor   = [1 0 1];   % magenta marker
    cfg.styles.sim.MarkerEdgeColor   = [1 0 1];
    cfg.styles.sim.MarkerTextColor   = [1 0 1];

    cfg.styles.markerSize = 8;

    %-------------------------------
    % Simulation file format
    %-------------------------------
    % These are mainly used by the generic table parser branch; the Lab1-style
    % block parser ignores them.
    cfg.simulation.freqUnit      = 'Hz';   % Lab1 uses Hz in the "freq" column
    cfg.simulation.numHeaderLines = [];    % auto-detect for generic tabular
    cfg.simulation.colFreq       = 1;
    cfg.simulation.colMagdB      = 2;
end
