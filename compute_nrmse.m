% Code Taken from: 2016 QSM Challenge Codebase
% Link: https://www.neuroimaging.at/pages/qsm.php

function [ rmse ] = compute_nrmse( in, true )

    rmse = 100 * norm(in(:) - true(:)) / norm(true(:));

end
