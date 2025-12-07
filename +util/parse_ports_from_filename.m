function [portIn, portOut] = parse_ports_from_filename(nameOrPath)
% PARSE_PORTS_FROM_FILENAME  Extract DUT port indices from "PXPY" style names.
%
%   [portIn, portOut] = parse_ports_from_filename('P2P3.s2p')
%       -> portIn  = 2
%          portOut = 3
%
% Assumes that the base file name (without extension) contains a substring
% of the form "P<integer>P<integer>", e.g. "P1P2", "myDevice_P2P3_meas".
%
% If the pattern cannot be found, an error is thrown.

    [~, base, ~] = fileparts(nameOrPath);

    tok = regexp(base, 'P(\d+)P(\d+)', 'tokens', 'once');
    if isempty(tok)
        error(['Could not parse port indices from file name "%s". ' ...
               'Expected pattern like "P2P3.s2p" with "PXPY".'], base);
    end

    portIn  = str2double(tok{1});
    portOut = str2double(tok{2});
end
