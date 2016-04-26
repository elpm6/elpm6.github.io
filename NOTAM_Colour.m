NOTAMkey = readtable ('NOTAMDecode.xlsx');
clear vars B Array_C b Array_Colour
NOTAMlegend = cellstr(NOTAMkey{:,1});

Array_A = NOTAM_Filtered{:,4};

RowNumber = size(NOTAM_Filtered);

for k = 1:RowNumber(1,1)
    B = Array_A{k,1};
Array_C(k,:) = B(1,10:11);
end
Array_C = cellstr(Array_C);

for k = 1:RowNumber(1,1)
    b = find(strcmp(Array_C(k,:),NOTAMlegend(:,1)));
    Array_Colour(k,:) = NOTAMkey{b,2};
end
 