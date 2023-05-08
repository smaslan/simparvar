function [vr,par] = var_init(par,varargin)
% Initialize automatic parameter variation algorithm.
% It will scan the elements of 'par' structure and each vector parameter
% will be used for the automatic parameter combinations generation.
% Note it will consider string elements as scalars. 
% This must be called once before all other 'var_*' function can be used!
%
% License:
% --------
% This is part of VAR library for automatic multidim. variation of simulation parameters.
% (c) 2018, Stanislav Maslan, s.maslan@seznam.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT 

    % parse inputs
    [~,no_cells,do_substr] = parseparams(varargin,'NoCells',true,'SubStructs',false);
    
    % explicit list of allowed sub-structures?
    sub_struct_list = {};
    if iscell(do_substr)
        sub_struct_list = do_substr;
        do_substr = true;
    end    
    
    % add paramter combination ID into the parameters structure
    par.pvpid = 0;
    par.pvpcnt = 0;
      
    if do_substr
        % recoursive with sub-strusts
        
        [vr.names, vr.par_n, vr.has_sub_structs] = var_init_rec(par, false, '', no_cells, sub_struct_list);
    
    else
        % simple with no sub-structs
        
        % get input parameter names
        vr.names = fieldnames(par);
            
        % get parameter types and lengths (1 for scalar, N for vector)
        vr.par_n = cellfun(@length,cellfun(@getfield,repmat({par},length(vr.names),1),vr.names,'UniformOutput',false));
        
        % assume char strings are scalars:
        is_charz = cellfun(@ischar,cellfun(@getfield,repmat({par},length(vr.names),1),vr.names,'UniformOutput',false));  
        vr.par_n(~~is_charz) = 1;
      
        % skip cell arrays?
        if no_cells
            is_cellz = cellfun(@iscell,cellfun(@getfield,repmat({par},length(vr.names),1),vr.names,'UniformOutput',false));
            vr.par_n(~~is_cellz) = 1;
        end
        
        % no sub-structs
        vr.has_sub_structs = false;
    
    end
    
    % get parameters count
    vr.n = length(vr.names);          
    
    % create variation counters for each paramter
    vr.par_cnt = ones(1,vr.n);
    
    % total varied parameters
    vr.var_par_cnt = sum(vr.par_n > 1);
  
    % get total variations count
    vr.var_n = prod(vr.par_n);
    par.pvpcnt = vr.var_n;
    
    % no paramter combinations generated yet
    vr.var_id = 0;
    
    % no results measured yet
    vr.res_n = 0;
  
end


% recoursive struct vector parameters search
function [names_list, counts_list, sub_structs] = var_init_rec(par, sub_structs, prefix, no_cells, sub_struct_list)

    % for each input field name
    names = fieldnames(par);
    names_list = {};
    counts_list = [];    
    for k = 1:numel(names)
        names_list{end+1} = strcat(prefix,names{k});
        counts_list(end+1) = 1;
        
        item = getfield(par, names{k});
        if iscell(item) && no_cells || ischar(item) || ~isstruct(item) && isscalar(item)
            % skip scalars 
            continue;
        end
        
        if isvector(item) && ~isstruct(item)
            % valid vector parameter
            counts_list(end) = numel(item);
        end
        
        if isstruct(item) && isscalar(item)
            % sub-struct: do recoursive search            
            
            if ~isempty(sub_struct_list)
                % filtering allowes sub-structures to search
                if ~any(strncmp(names_list{end}, sub_struct_list, numel(names_list{end})))
                    % not found in allowed list: skip this sub-struct
                    continue;
                end                
            end
            
            [sub_names,sub_counts,sub_structs] = var_init_rec(item, sub_structs, strcat(prefix,names{k},'.'), no_cells, sub_struct_list);
            if any(sub_counts > 1)
                % some vector there: replace last item by list of sub-items
                names_list = names_list(1:end-1);
                counts_list = counts_list(1:end-1);
                names_list = cat(2,names_list,sub_names);
                counts_list = cat(2,counts_list,sub_counts);
                sub_structs = true;                
            end             
        end                                
    end

end
