%% Get next combination of parameters. Set 'count' to 0 to return all combinations.

function [outp,vr,da_end] = var_get_next(par,vr,count)   
  
    % return single combinarion if count undefined
    if nargin() < 3
        count = 1;
    end
    % return all combinations for zero 'count'
    if ~count
        count = vr.var_n;
    end
       
    %% prepare list of variable parameters
    % vector parameter id's
    vids = find(vr.par_n>1); 
    
    % vector paramter names
    v_names = {vr.names{vids}};
    
    % vector paramter indexes
    v_cnt = vr.par_cnt(vids);
    
    % vector paramter lengths
    v_max = vr.par_n(vids);
    
    % vector parametrs count
    v_n = length(vids);
    
    if vr.has_sub_structs
        % --- slower version with sub-structs
        
        % generate output prototype with removed vectors for varied parameters
        outprot = par;
        v_vals = {};
        for p = 1:v_n            
            eval(['v_vals{end+1} = outprot.' v_names{p} ';']);
            eval(['outprot.' v_names{p} ' = 0;']);            
        end
        
        % allocate output vector
        outp = repmat(outprot,min(count,vr.var_n),1);
        
        %% return up to 'count' combinationations
        da_end = 0;
        k = 0;
        while ~da_end && k < count
            
            % copy current set of parameters
            outp(++k) = outprot;
            for p = 1:v_n
                eval(['outp(k).' v_names{p} ' = v_vals{p}(v_cnt(p));']);                
                %outp(k) = setfield(outp(k),v_names{p},v_vals{p}(v_cnt(p)));
            end
            % store combination id
            outp(k).pvpid = ++vr.var_id;
                     
            % prepare next combination of parameters
            for p = 1:v_n
                if v_cnt(p) >= v_max(p)
                    v_cnt(p) = 1;
                    da_end = (p==v_n);
                else
                    v_cnt(p)++;
                    break;
                end          
            end
        end
                
    
    else    
        % --- simpler version for no sub-structs
    
        % cell array of vetor paramters values
        v_vals = cellfun(@getfield,repmat({par},1,v_n),v_names,'UniformOutput',false');
            
        % generate output prototype
        outprot = par;
        for p = 1:v_n
            outprot = setfield(outprot,v_names{p},0);
        end
        
        % allocate output vector
        outp = repmat(outprot,min(count,vr.var_n),1);
        
        %% return up to 'count' combinationations
        da_end = 0;
        k = 0;
        while ~da_end && k < count
            
            % copy current set of parameters
            outp(++k) = outprot;
            for p = 1:v_n
                outp(k) = setfield(outp(k),v_names{p},v_vals{p}(v_cnt(p)));
            end
            % store combination id
            outp(k).pvpid = ++vr.var_id;
                     
            % prepare next combination of parameters
            for p = 1:v_n
                if v_cnt(p) >= v_max(p)
                    v_cnt(p) = 1;
                    da_end = (p==v_n);
                else
                    v_cnt(p)++;
                    break;
                end          
            end
        end
    
    end
    
    % store work variables back to the 'vr' struct
    vr.par_cnt(vids) = v_cnt;
          
    % reduce allocated cells vector to actual size
    if k==1
        outp = outp(1);
    else
        outp = outp(1:k);
    end
    

end
