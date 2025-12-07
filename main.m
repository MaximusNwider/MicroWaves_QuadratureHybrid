function main()
% MAIN Entry point for the S-parameter comparison project.
%
% Usage:
%   >> cd SParamProject_Lab1
%   >> main

    % Add project folders to the MATLAB path
    addpath(genpath(pwd));

    % Load configuration
    cfg = config.default_config();

    % Ensure output folder exists
    util.ensure_dir_exists(cfg.outputDir);

    % Run the pipeline
    run_sparam_project(cfg);
end
