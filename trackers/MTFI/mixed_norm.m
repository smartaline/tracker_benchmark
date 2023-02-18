function total = mixed_norm(W, norm_type)
switch upper(norm_type),
        case 'L1-2',
            total = sum(W.^2,2);
            total = sum(sqrt(total));
        case 'L1-INF',
            total = sum(max(abs(W),[],2));
        case 'L1',
            total = sum(sum(abs(W)));
        otherwise,
            error('No such type of group norm.\n');
end