function [res,ax_values,ax_names] = var_resize_result(res,vr,par)
% This function will take the 1D vector of results matching the 1D vector
% of parameters generated by 'var_get_all*' function and it will reshape
% it so it matches the dimnesions of the variable parameters in 'par'.
% Example:
%  par.a = [1 2];
%  par.b = [1 2 3];
%
%  [vr,pp] = var_init(par);
%  [p_list] = var_get_all_fast(ppp, vr, 5000, 1);
%  res = cellfun(@my_fun, p_list, 'UniformOutput',false)
%
%  >> res = array of cells of size 6x1
%
%  [res,ax_values,ax_names] = var_resize_result(res, vr, par)
%
%  >> res = array of cells of size 2x3
%  >> ax_values = {[1;2], [1 2 3]}
%  >> ax_names = {'a', 'b'}
%
% License:
% --------
% This is part of VAR library for automatic multidim. variation of simulation parameters.
% (c) 2018, Stanislav Maslan, s.maslan@seznam.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT      
 
    % dimensions of the parameter axes:
    dims = vr.par_n(vr.par_n > 1);   
    
    % reshape results:
    if numel(dims) < 1
        % scalar - do nothing
        ax_names = {};
        ax_values = {};
        return;
    elseif numel(dims) < 2
        % 1D
        dims = [dims;1];
    end
    res = reshape(res,[dims(:)]');
    
    % extract parameter axes names:
    ax_names = vr.names(vr.par_n > 1);
    
    % load vectors:
    vn = sum(vr.par_n > 1);
    vids = [1:numel(vr.par_n)];
    vids = vids(vr.par_n > 1);
    %vars = {};        
    for v = 1:vn
        % get variable vector:
        v_val = getfield(par,vr.names{vids(v)});
        
        % reshape the vector to their dim:
        dimn = eye(max(vn,2));
        dimn = [dimn(v,:)*(numel(v_val)-1) + 1]
        ax_values{v} = reshape(v_val,dimn);    
    end

end
