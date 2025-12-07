function simSet = read_simulation_table(filename, cfg)
% READ_SIMULATION_TABLE  Read simulated S-parameters from a text / tab file.
%
% This function supports two formats:
%
% (A) Lab-style multi-block file (like "Lab1.txt"):
%     Repeated blocks of the form:
%         freq    dB(S(1,1))
%         1.45e9  -3.24
%         ...
%
%     Each block starts with a line containing "freq" and "dB(S(i,j))".
%
% (B) Generic tabular file:
%     - First numeric column = frequency
%     - Remaining columns are |S_ij| in dB, with variable names containing
%       "Sij" or "S(i,j)" (e.g. "S11_dB", "S(2,1)", etc.), OR
%     - Single-S-parameter file with label inferred from the filename.
%
% Returns struct:
%   simSet.freqGHz      - Nx1 frequency vector in GHz
%   simSet.sParamLabels - cell array of labels {'S11','S21',...}
%   simSet.Sdb          - struct with one field per label, each Nx1 dB vector
%   simSet.sourceFile   - full filename

    text = fileread(filename);

    if contains(text, 'dB(S(', 'IgnoreCase', true)
        simSet = parse_block_style(text, filename);
    else
        simSet = parse_generic_table(filename, cfg);
    end
end

%==========================================================================
% BLOCK-STYLE PARSER (Lab1-style: repeated "freq   dB(S(i,j))" sections)
%==========================================================================
function simSet = parse_block_style(fileText, filename)

    lines = regexp(fileText, '\r\n|\n|\r', 'split');
    nLines = numel(lines);

    sLabels = {};
    SdbStruct = struct();
    freqGHz = [];

    i = 1;
    while i <= nLines
        line = strtrim(lines{i});
        if startsWith(line, 'freq', 'IgnoreCase', true)
            % Header line of form: "freq    dB(S(1,1))"
            tok = regexp(line, 'dB\s*\(\s*S\((\d+),\s*(\d+)\)\s*\)', ...
                         'tokens', 'once', 'ignorecase');
            if isempty(tok)
                i = i + 1;
                continue;
            end

            sLabel = upper(sprintf('S%s%s', tok{1}, tok{2}));

            % Collect numeric rows until blank or next 'freq' header
            fvals = [];
            svals = [];

            j = i + 1;
            while j <= nLines
                row = strtrim(lines{j});
                if isempty(row)
                    break;
                end
                if startsWith(row, 'freq', 'IgnoreCase', true)
                    break;
                end

                nums = sscanf(row, '%f');
                if numel(nums) >= 2
                    fvals(end+1,1) = nums(0+1); %#ok<AGROW>
                    svals(end+1,1) = nums(1+1); %#ok<AGROW>
                end
                j = j + 1;
            end

            if isempty(fvals)
                i = j;
                continue;
            end

            thisFreqGHz = fvals(:) / 1e9;

            if isempty(freqGHz)
                freqGHz = thisFreqGHz;
            else
                if numel(freqGHz) ~= numel(thisFreqGHz) || any(abs(freqGHz - thisFreqGHz) > 1e-6)
                    warning('Frequency grid mismatch for %s; overwriting previous freq vector.', sLabel);
                    freqGHz = thisFreqGHz;
                end
            end

            if isfield(SdbStruct, sLabel)
                warning('Duplicate simulation block for %s in "%s"; keeping first instance.', ...
                        sLabel, filename);
            else
                SdbStruct.(sLabel) = svals(:);
                sLabels{end+1} = sLabel; %#ok<AGROW>
            end

            i = j;
        else
            i = i + 1;
        end
    end

    if isempty(sLabels)
        error('No S-parameter blocks found in simulation file "%s".', filename);
    end

    simSet = struct();
    simSet.freqGHz      = freqGHz;
    simSet.sParamLabels = sLabels;
    simSet.Sdb          = SdbStruct;
    simSet.sourceFile   = filename;
end

%==========================================================================
% GENERIC TABULAR PARSER (fallback)
%==========================================================================
function simSet = parse_generic_table(filename, cfg)
% Fallback parser for generic tabular S-parameter simulation files.

    % Use detectImportOptions to guess structure
    if isempty(cfg.simulation.numHeaderLines)
        opts = detectImportOptions(filename, 'FileType', 'text');
    else
        opts = detectImportOptions(filename, 'FileType', 'text', ...
            'NumHeaderLines', cfg.simulation.numHeaderLines);
    end

    tbl = readtable(filename, opts);

    if isempty(tbl) || width(tbl) < 2
        error('Simulation file "%s" must contain at least two numeric columns.', filename);
    end

    nCols    = width(tbl);
    varNames = tbl.Properties.VariableNames;

    % Frequency column
    freqIdx = cfg.simulation.colFreq;
    if freqIdx < 1 || freqIdx > nCols
        error('cfg.simulation.colFreq (%d) is out of range for file "%s".', ...
              freqIdx, filename);
    end

    freqCol = tbl{:, freqIdx};

    switch upper(cfg.simulation.freqUnit)
        case 'HZ'
            freqGHz = freqCol / 1e9;
        case 'KHZ'
            freqGHz = freqCol / 1e6;
        case 'MHZ'
            freqGHz = freqCol / 1e3;
        case 'GHZ'
            freqGHz = freqCol;
        otherwise
            freqGHz = freqCol;
    end

    sLabels = {};
    SdbStruct = struct();

    % Try to detect columns with Sij labels in their names
    for c = 1:nCols
        if c == freqIdx
            continue;
        end
        vname = varNames{c};
        tok = regexp(lower(vname), 's(\d)(\d)', 'tokens', 'once');
        if isempty(tok)
            tok = regexp(lower(vname), 's\(\s*(\d)\s*[,;]\s*(\d)\s*\)', ...
                         'tokens', 'once');
        end
        if isempty(tok)
            continue;
        end
        sLabel = upper(sprintf('S%s%s', tok{1}, tok{2}));
        sLabels{end+1} = sLabel; %#ok<AGROW>
        SdbStruct.(sLabel) = tbl{:, c};
    end

    % If we still don't have any labels, assume single S-parameter file
    if isempty(sLabels)
        [~, baseName, ~] = fileparts(filename);
        tokFile = regexp(lower(baseName), 's(\d)(\d)', 'tokens', 'once');
        if isempty(tokFile)
            error(['Could not infer S-parameter label from file name "%s". ' ...
                   'Expected pattern like "...S33...".'], baseName);
        end
        sLabel = upper(sprintf('S%s%s', tokFile{1}, tokFile{2}));
        magIdx = cfg.simulation.colMagdB;
        if magIdx < 1 || magIdx > nCols
            error('cfg.simulation.colMagdB (%d) is out of range for file "%s".', ...
                  magIdx, filename);
        end
        SdbStruct.(sLabel) = tbl{:, magIdx};
        sLabels = {sLabel};
    end

    simSet = struct();
    simSet.freqGHz      = freqGHz(:);
    simSet.sParamLabels = sLabels;
    simSet.Sdb          = SdbStruct;
    simSet.sourceFile   = filename;
end
