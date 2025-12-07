function plot_sparam_comparison(freqMeasGHz, measDb, freqSimGHz, simDb, ...
    sLabel, saveName, cfg)
% PLOT_SPARAM_COMPARISON  Plot Measured vs Simulated magnitude in dB.
%
%   - Simulated: blue dashed
%   - Measured:  red solid
%   - Annotation at cfg.annotationFreqGHz (if within range)
%   - Y-axis forced to cfg.yLimits_dB (e.g. [-60, 0])
%   - Saved as PNG to cfg.outputDir with name [saveName '.png']

    if cfg.showFigures
        visFlag = 'on';
    else
        visFlag = 'off';
    end

    f = figure('Visible', visFlag);
    hold on;

    % Simulated (blue dashed)
    plot(freqSimGHz, simDb, ...
        'LineStyle', cfg.styles.sim.LineStyle, ...
        'LineWidth', cfg.styles.sim.LineWidth, ...
        'Color',     cfg.styles.sim.Color);

    % Measured (red solid)
    plot(freqMeasGHz, measDb, ...
        'LineStyle', cfg.styles.meas.LineStyle, ...
        'LineWidth', cfg.styles.meas.LineWidth, ...
        'Color',     cfg.styles.meas.Color);

    grid on;
    xlabel('Frequency (GHz)');
    ylabel('dB');
    title(sLabel, 'Interpreter', 'none');

    % X-limits: union of both traces
    xMin = min([freqMeasGHz(:); freqSimGHz(:)]);
    xMax = max([freqMeasGHz(:); freqSimGHz(:)]);
    xlim([xMin xMax]);

    % Y-limits: forced to configured range (e.g. [-60, 0])
    ylim(cfg.yLimits_dB);

    legend({'Simulated','Measured'}, 'Location','best');

    %---------------------------
    % Annotation at a specific frequency
    %---------------------------
    fAnnot = cfg.annotationFreqGHz;
    if ~isempty(fAnnot)
        % Measured marker (black)
        if fAnnot >= min(freqMeasGHz) && fAnnot <= max(freqMeasGHz)
            yMeas = interp1(freqMeasGHz, measDb, fAnnot, 'linear');
            plot(fAnnot, yMeas, 'o', ...
                'MarkerFaceColor', cfg.styles.meas.MarkerFaceColor, ...
                'MarkerEdgeColor', cfg.styles.meas.MarkerEdgeColor, ...
                'MarkerSize',      cfg.styles.markerSize);
            text(fAnnot, yMeas, ...
                sprintf(' %.2f dB @ %.3gG', yMeas, fAnnot), ...
                'Color',            cfg.styles.meas.MarkerTextColor, ...
                'VerticalAlignment','bottom', ...
                'HorizontalAlignment','left');
        end

        % Simulated marker (magenta)
        if fAnnot >= min(freqSimGHz) && fAnnot <= max(freqSimGHz)
            ySim = interp1(freqSimGHz, simDb, fAnnot, 'linear');
            plot(fAnnot, ySim, 'o', ...
                'MarkerFaceColor', cfg.styles.sim.MarkerFaceColor, ...
                'MarkerEdgeColor', cfg.styles.sim.MarkerEdgeColor, ...
                'MarkerSize',      cfg.styles.markerSize);
            text(fAnnot, ySim, ...
                sprintf(' %.2f dB @ %.3gG', ySim, fAnnot), ...
                'Color',            cfg.styles.sim.MarkerTextColor, ...
                'VerticalAlignment','top', ...
                'HorizontalAlignment','left');
        end
    end

    %---------------------------
    % Save to file
    %---------------------------
    util.ensure_dir_exists(cfg.outputDir);
    outPath = fullfile(cfg.outputDir, [saveName '.png']);

    if exist('exportgraphics','file') == 2
        exportgraphics(f, outPath, 'Resolution', cfg.exportDPI);
    else
        % Fallback for older MATLAB versions
        set(f, 'PaperPositionMode', 'auto');
        print(f, outPath, '-dpng', sprintf('-r%d', cfg.exportDPI));
    end

    if ~cfg.showFigures
        close(f);
    end
end
