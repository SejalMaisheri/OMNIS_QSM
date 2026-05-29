function [ rmse ] = compute_nrmse( in, true )

    rmse = 100 * norm(in(:) - true(:)) / norm(true(:));

end
