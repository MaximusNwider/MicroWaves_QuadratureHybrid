function data = read_touchstone_s2p(filename, ~)
% READ_TOUCHSTONE_S2P  Read a 2-port Touchstone .s2p file.
%
% Supports DB, MA, RI formats. Returns:
%   data.freqGHz      - Nx1 frequency vector in GHz
%   data.S            - 2x2xN complex S-parameter matrix
%   data.Sdb          - struct with fields S11,S21,S12,S22 (magnitude in dB)
%   data.sParamLabels - cell array {'S11','S21','S12','S22'}
%   data.formatType   - 'DB' | 'MA' | 'RI'
%   data.sourceFile   - full filename

    fileText = fileread(filename);
    lines = regexp(fileText, '\r\n|\n|\r', 'split');

    formatType = 'DB';   % DB, MA, RI
    freqScale  = 1e9;    % default assume GHz
    numericRows = [];

    for i = 1:numel(lines)
        line = strtrim(lines{i});
        if isempty(line)
            continue;
        end

        if startsWith(line, '!', 'IgnoreCase', true)
            % Comment line, ignore
            continue;

        elseif startsWith(line, '#')
            % Option line: e.g. "# GHZ S DB R 50"
            tokens = upper(strsplit(line));
            if numel(tokens) >= 2
                switch tokens{2}
                    case 'HZ',  freqScale = 1;
                    case 'KHZ', freqScale = 1e3;
                    case 'MHZ', freqScale = 1e6;
                    case 'GHZ', freqScale = 1e9;
                end
            end
            if numel(tokens) >= 4
                formatType = tokens{4};
            end

        else
            % Numeric data row
            nums = sscanf(line, '%f')';
            if isempty(nums)
                continue;
            end
            numericRows = [numericRows; nums]; %#ok<AGROW>
        end
    end

    if isempty(numericRows)
        error('No numeric data found in %s', filename);
    end

    % Expect frequency + 8 numbers (S11, S21, S12, S22 in chosen format)
    if size(numericRows,2) ~= 9
        error('Expected 9 numeric columns (freq + 8 S entries) in %s, got %d.', ...
              filename, size(numericRows,2));
    end

    freqHz = numericRows(:,1) * freqScale;
    freqGHz = freqHz / 1e9;

    raw = numericRows(:,2:9);  % N x 8
    N = size(raw,1);
    S = zeros(2,2,N);

    for k = 1:N
        row = raw(k,:);
        S(1,1,k) = localConvertPair(row(1:2), formatType);
        S(2,1,k) = localConvertPair(row(3:4), formatType);
        S(1,2,k) = localConvertPair(row(5:6), formatType);
        S(2,2,k) = localConvertPair(row(7:8), formatType);
    end

    S11 = squeeze(S(1,1,:));
    S21 = squeeze(S(2,1,:));
    S12 = squeeze(S(1,2,:));
    S22 = squeeze(S(2,2,:));

    Sdb = struct();
    Sdb.S11 = 20*log10(abs(S11));
    Sdb.S21 = 20*log10(abs(S21));
    Sdb.S12 = 20*log10(abs(S12));
    Sdb.S22 = 20*log10(abs(S22));

    data = struct();
    data.freqGHz      = freqGHz(:);
    data.S            = S;
    data.Sdb          = Sdb;
    data.sParamLabels = {'S11','S21','S12','S22'};
    data.formatType   = formatType;
    data.sourceFile   = filename;
end

%---------------------------
% Local helper
%---------------------------
function z = localConvertPair(pair, formatType)
% Convert 2-element [a b] pair depending on Touchstone format.

    switch upper(strtrim(formatType))
        case 'DB'
            mag_db  = pair(1);
            ang_deg = pair(2);
            mag = 10.^(mag_db/20);
            ang_rad = deg2rad(ang_deg);
            z = mag .* exp(1j * ang_rad);

        case 'MA'
            mag     = pair(1);
            ang_deg = pair(2);
            ang_rad = deg2rad(ang_deg);
            z = mag .* exp(1j * ang_rad);

        case 'RI'
            z = complex(pair(1), pair(2));

        otherwise
            error('Unsupported Touchstone data format: %s (expected DB, MA or RI).', ...
                  formatType);
    end
end
