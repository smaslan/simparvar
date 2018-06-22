function [len,par_val] = var_get_par_by_name(vr, par, name)
% Get parameter length and its values by its name.
%
% License:
% --------
% This is part of VAR library for automatic multidim. variation of simulation parameters.
% (c) 2018, Stanislav Maslan, s.maslan@seznam.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT

    % find parameter id
    pid = find(strcmp(vr.names,name),1,'first');

    if(~numel(pid))
        % paramter not found
        error(['Paramter ''' name ''' is not member of paramters structure!']);
    end

    % return length of the parameter
    len = vr.par_n(pid);

    % return vector of parameters
    par_val = getfield(par,vr.names{pid});

end