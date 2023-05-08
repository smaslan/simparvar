function [r,v,par_val,par_name,info_str,vec_labels] = var_get_results_vect(res,par,vr,varargin)
% Returns vector of results simulated using VAR lib for defined parameter 'name'.
%
% Example:
%  [r,v,par_val,par_name,info_str,vec_labels] = var_get_results_vect(res,par,vr)
%  [r,v,par_val,par_name,info_str,vec_labels] = var_get_results_vect(res,par,vr,name)
%  [r,v,par_val,par_name,info_str,vec_labels] = var_get_results_vect(res,par,vr,name,options)
%
% Parameters:
%  res - cell vector of results matching the 'vr' and 'par'
%  par - simulation parameters
%  vr - VAR lib control structure
%  name - parameter name (axis) of the dependence to return (optional)
%  options - 'param_1_name', param_1_index, 'param_2_name', param_2_index, ...
%            defines fixed parameter values of the remaining parameters (optional)
%            one parameter index can be list type like [2:5] in which case
%            te function returns 2D cell array of results instead of a vector  
% 
% Returns:
%  r        - results cell vector or matrix for list type parameter index
%  v        - results cell vector coverted to struct of paramters (vectors or arrays),
%             3rd dim is in case of list type parameter index
%  par_val  - vector of values of the variable parameter
%  par_name - name of the variable parameter
%  info_str - information about fixed parameters setup: 'param_1_name = param_1_value, param_2_name = param_2_value, ...'
%  vec_labels - list of labels in case of one parameter index is list or empty cells
%
% License:
% --------
% This is part of VAR library for automatic multidim. variation of simulation parameters.
% (c) 2018-2023, Stanislav Maslan, s.maslan@seznam.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT

    if ~length(varargin)
        %% parameter name undefined, search first vector parameter
        pid = find(vr.par_n>1,1,'first');
        
        if ~isscalar(pid)
            % take first parameter if non of the parameters is vector
            pid = 1;
        end
  
    else
        %% user defined paramter name, check whether exist in parameters list
        pid = find(strcmp(vr.names,varargin{1}),1,'first');        
        if isempty(pid)
            % not found
            error(sprintf('Invalid parameter name ''%s''!',varargin{1}));
        end                
        varargin = varargin(2:end);

    end
    
    %% no filtering yet
    fil_mult = zeros(1,vr.n);
    fil_ofs = num2cell(zeros(1,vr.n));
    
    %% process find filters
    if rem(numel(varargin),2)
        error('Parameter selection options must be in pairs, like ..., ''par_name'',par_value, ...!');    
    elseif numel(varargin) >= 2      
        %% function options: 'par_name_1', par_1_index, 'par_name_2', par_2_index, ...         
        
        % total optional paramters count
        n = length(varargin);
           
        % for each option
        for k = 1:2:n
          
            if k<n
                
                % find parameter in parameters list
                fid = find(strcmp(vr.names,varargin{k}),1,'first');
                if isempty(fid)
                    % parameter not found
                    error(['Parameter ''' inputname(2) '.' varargin{k} ''' not found!']);          
                end
                
                % check index range
                if any(varargin{k+1} < 1) || any(varargin{k+1} > vr.par_n(fid))
                    % parameter index out of range
                    error(['Parameter ''' inputname(2) '.' varargin{k} ''' index [' int2str(varargin{k+1}) '] out of range <1;' int2str(vr.par_n(fid)) '>!']);          
                end
                
                % filter multiplier
                fil_mult(fid) = prod([1, vr.par_n(1:fid-1)]);
                
                % filter offset
                fil_ofs{fid} = varargin{k+1} - 1;
            end      
        end
    end
    
    % check vector type indices
    is_vecs = ~cellfun(@isscalar, fil_ofs);
    id_vecs = find(is_vecs);
    num_vec = numel(id_vecs);
    if num_vec > 1
        error('More than one parameter index is a vector type! Only one can be of vector type.')
    end       
    
    % make lists result indices (vector_index,parameter_index) 
    len_vec = max(cellfun(@numel, fil_ofs));
    len_mat = zeros([len_vec numel(fil_ofs)]);
    for k = 1:numel(fil_ofs)
        if isscalar(fil_ofs{k})
            len_mat(:,k) = repmat(fil_ofs{k}, [len_vec 1]);
        else
            len_mat(:,k) = fil_ofs{k};
        end
    end
    
    % return variable parameter values
    %par_val = getfield(par,vr.names{pid});
    eval(['par_val = par.' vr.names{pid} ';']);
    
    % return name of the variable parameter
    par_name = vr.names{pid};
    
    % for each indices
    vec_labels = {};
    r = cell();
    v = [];
    for k = 1:len_vec
    
        % this step indices
        fil_ofs = len_mat(k,:);
    
        % finish filter
        ofs = fil_mult*fil_ofs';
        
        % get results diplacement in results buffer for selected vector of parameters
        idx_step = prod([1 vr.par_n(1:pid-1)]);
        
        % vector length
        idx_rng = vr.par_n(pid);
        
        % return results vector
        r = cat(1,r,{res{(0:idx_rng-1)*idx_step+1 + ofs}});
        
        % convert vector of result structs to struct of result vectors/arrays (hardcore implementation)
        v_new = vectorize_structs_elements(r(end,:));
        % put eventual vector index sliced in third dim
        if isempty(v)
            v = v_new;
        else
            rv_names = fieldnames(v_new);
            for m = 1:numel(rv_names)                
                eval(['v.' rv_names{m} '(:,:,end+1) = v_new.' rv_names{m} ';']);                
            end            
        end
                
        if ~isempty(id_vecs)
            
            % get param value
            eval(['val = par.' vr.names{id_vecs} ';']);
            vid = fil_ofs(id_vecs) + 1;
            val = val(vid);
            % format to string
            if iscell(val) && ischar(val{1})
                val_str = ['''' val{1} ''''];
            elseif ~iscell(val) && isnumeric(val)
                val_str = num2str(val);
            else
                val_str = '?';
            end                                    
            vec_labels{end+1} = sprintf('%s(%d) = %s',vr.names{id_vecs},vid,val_str); 
        end
        
    end
    
    % build info string for the fixed parameters
    % for each parameter
    info_str = '';
    for k = 1:vr.n
        if vr.par_n(k)>1 && k~=pid
          
            % only for vector parameters and not the variable parameter (var_name)
            if numel(info_str)
                info_str = [info_str ', '];
            end
            
            % get parameter value
            eval(['val = par.' vr.names{k} ';']);
            vid = len_mat(:,k) + 1;
            val = val(vid);
                         
            if isscalar(vid)
                if iscell(val) && ischar(val{1})
                    val_str = ['''' val{1} ''''];
                elseif ~iscell(val) && isnumeric(val)
                    val_str = num2str(val);
                else
                    val_str = '?';
                end                             
                par_str = sprintf('%s(%d) = %s',vr.names{k},vid,val_str);
            else
                par_str = sprintf('%s([%s])',vr.names{k},num2str(vid','%d '));
            end        
            
            % add to info string
            info_str = strcat(info_str,par_str);
                
        end
    end
   
end
