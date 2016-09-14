function [fpath_h5] = twoears2hdf5(fpath, dir_dst, phase, featureNames, numClasses)
% TWOEARS2HDF  load twoears training data and reformat into caffe-friendly HDF5
%   TWOEARS2HDF(fpath, dir_dst) loads data from .mat file designated by fpath
%     and writes them to hdf5 files under directory dir_dst
%   Assumes:
%       rows are examples, labels are features/class columns
%       label states are -1, 0, 1 for inactive, undefined, active
%       respectively
%   The general class is only present in the scalar representation of the
%   ground truth. It is equivalent to an all-zero ground truth vector.
% 
load(fpath, 'x', 'y');

dir_src = fileparts(fpath);
if isempty(phase)
    [~, phase] = fileparts(dir_src); % test or train from directory name
    assert( strcmp(phase, 'test') | strcmp(phase, 'train') | strcmp(phase, 'val'), ...
        'Unable to determine phase (test vs. train).' );
end

% random shuffle
o = randperm( length( y ) );
%x = x( o, : );
%y = y( o, : );
x = x(1:1000, :);
y = y(1:1000, :);

[x_feat, feature_type_names, y] = twoears2Blob(x, featureNames, y, numClasses);

% merge all features and ground truth into same hdf5
prefix_h5 = 'twoears_data';
fname_h5 = sprintf('%s_%s.h5', prefix_h5, phase);
fpath_h5 = fullfile(dir_dst, fname_h5);
for ii = 1 : numel(feature_type_names)
    % save formatted features to file
    if ii > 1
        write_mode = 'append';
    else
        write_mode = 'overwrite'; % first entry only
    end
    hdf5write( fpath_h5, ...
        strcat('/', feature_type_names{ii}), x_feat{ii}, ...
        'WriteMode', write_mode);
end
% append ground truth to hdf5
hdf5write( fpath_h5, ...
    '/label', y, ...
    'WriteMode', 'append');
% write hdf5 list files
file_id = fopen( fullfile(dir_dst, sprintf('%s_%s.txt', prefix_h5, phase) ), 'w');
fprintf(file_id, fpath_h5 );
fclose(file_id);
