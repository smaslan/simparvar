function [str] = str_insert_escapes(str)
% latex 'Escapification' of formatting characters for Latex style strings.

    if iscell(str)
        str = cellfun('str_insert_escapes_s',str,'UniformOutput',false);
    else
        str = str_insert_escapes_s(str);
    end
end

function [str] = str_insert_escapes_s(str)
    tid = find(str=='_' | str=='^');
    for k=1:length(tid)
        str((tid(k)+k-1):end+1) = ['\' str((tid(k)+k-1):end)];
    end
end
