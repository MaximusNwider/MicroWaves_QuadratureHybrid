function ensure_dir_exists(pathStr)
% ENSURE_DIR_EXISTS  Create directory if it doesn't already exist.

    if ~exist(pathStr, 'dir')
        mkdir(pathStr);
    end
end
