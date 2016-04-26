clear all
close all
clc
NOTAM = readtable('Notams.xlsx');
NOTAM(:,1:7) = []; % Eliminate bullcrap columns
NOTAM(1:2,:) = [];
NOTAM.Properties.VariableNames = {'NOTAM_ID' 'FROM' 'TO' 'Q_CODE' 'POSITION' 'POSITION_RADIUS' 'LOWER_ALT' 'UPPER_ALT' 'IFR_VFR' 'FLIGHT_PHASE' 'LOWER_FL' 'UPPER_FL' 'BODY'};
NOTAMSAFE = readtable('NOTAM SAFE.xlsx');
NOTAMkey = readtable ('NOTAMDecode.xlsx');
%clear vars B Array_C b Array_Colour
NOTAMlegend = cellstr(NOTAMkey{:,1});

% Renames the variable columns to the above, was prior var1, var2....

NOTAM_Filtered = NOTAM;
RowNumber = size(NOTAM(:,1));               
pseudo_i = 1;       
for i = 1:1:RowNumber(1,1)
    Check_cell = char(NOTAM{i,6});
    Check_cell = size(Check_cell);
    if Check_cell(1,2) == 0
        NOTAM_Filtered(pseudo_i,:) = [];
    else
        pseudo_i = pseudo_i + 1;
    end
end                                 % for loop changes position and radius
                                    % to char
Position_Radius_delete = NOTAM_Filtered{:,6};
Position_Radius_delete = char(Position_Radius_delete);
Radius_delete = Position_Radius_delete(:,12:14);          % Extracts different fields
Radius_Array_delete = str2num(Radius_delete(:,:));
Delete_Radius = find(Radius_Array_delete>=999);
NOTAM_Filtered(Delete_Radius,:)=[]; 

RowNumber = size(NOTAM_Filtered(:,1));

NOTAM_Filtered(RowNumber(1,1)+1,:) = NOTAMSAFE(1,:);
                                    
Position_Radius = NOTAM_Filtered{:,6};
Position_Radius = char(Position_Radius);
LatitudeNS = Position_Radius(:,1:5);
LongitudeEW = Position_Radius(:,6:11);
Radius = Position_Radius(:,12:14);          % Extracts different fields
Radius_Array = str2num(Radius(:,:));




RowNumber = size(NOTAM_Filtered);

for k = 1:RowNumber(1,1)
if LatitudeNS(k,5) == 'N'
Lat = LatitudeNS(k,1:4);
Lat = str2double(Lat);
Latitude(k,1) = Lat;
else
Lat = LatitudeNS(k,1:4);
Lat = str2double(Lat);
Latitude(k,1) = -Lat;
end
if LongitudeEW(k,6) == 'E'
Long = LongitudeEW(k,1:5);
Long = str2double(Long);
Longitude(k,1) = Long;
else
Long = LongitudeEW(k,1:5);
Long = str2num(Long);
Longitude(k,1) = -Long;
end
end                                     % Changes data type a negate 
                                        % position of lat=S or long=W.

Latitude = num2str(Latitude);
Longitude = num2str(Longitude);         % File conversions

DegreesLat = Latitude(:,1:2);
MinutesLat = Latitude(:,3:4);           % Extracts degrees and minutes



for k = 1:RowNumber(1,1)
DegreesLatDBL(k,:) = str2double(DegreesLat(k,:));
MinutesLatDBL(k,:) = str2double(MinutesLat(k,:));
end


DecimalLat = abs(DegreesLatDBL) + abs(MinutesLatDBL)/60;

DegreesLong = Longitude(:,1:3);
MinutesLong = Longitude(:,4:5);

RowNumber = size(NOTAM_Filtered);
NOTAM_Filtered(RowNumber(1,1),:)=[];
RowNumber = size(NOTAM_Filtered);

for k = 1:RowNumber(1,1)
DegreesLongDBL(k,:) = str2double(DegreesLong(k,:));
MinutesLongDBL(k,:) = str2double(MinutesLong(k,:));
RadiusArray(k,:) = str2double(Radius(k,:));
end

DegreesLongDBL(isnan(DegreesLongDBL))=0;

DecimalLong = abs(DegreesLongDBL) + abs(MinutesLongDBL)/60;

for k = 1:RowNumber(1,1)
if LatitudeNS(k,5) == 'N'
DecimalLat(k,1);
else
DecimalLat(k,1) = -DecimalLat(k,1);
end
if LongitudeEW(k,6) == 'E'
DecimalLong(k,1);
else
DecimalLong(k,1) = -DecimalLong(k,1);
end
end

NOTAM_NAME = char(NOTAM_Filtered.NOTAM_ID);
NOTAM_BRIEF = char(NOTAM_Filtered.BODY);

for k=1:RowNumber(1,1)
    h =1 ;
for alpha=0:pi/200:2*pi
     eps(50);
     circle(h,1) = DecimalLong(k,1) + (RadiusArray(k,1)/60*cos(alpha))*cos((DecimalLong(k,1)*pi)/180);
     circle(h,2) = DecimalLat(k,1) + (RadiusArray(k,1)/60*sin(alpha))*cos((DecimalLat(k,1)*pi)/180);
     h=h+1;
end
DecimalLongCircle(:,k) = circle(:,1);
DecimalLatCircle(:,k) = circle(:,2);
circles(k,:) = geoshape(DecimalLatCircle(:,k),DecimalLongCircle(:,k),'Name',NOTAM_NAME);
end
 
DecimalLatCircle = transpose(DecimalLatCircle);
DecimalLongCircle = transpose(DecimalLongCircle);

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

% kmlwritepoint('NOTAMoverlay',DecimalLat,DecimalLong,'Name',NOTAM_NAME,'Description',NOTAM_BRIEF);

kmlwrite('NOTAMoverlay.kml',circles,'Name',NOTAM_Filtered.NOTAM_ID,'Description',NOTAM_Filtered.BODY,'Color',Array_Colour);