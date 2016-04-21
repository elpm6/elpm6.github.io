clear all
close all
clc
NOTAM = readtable('Notams.xlsx');
NOTAM(:,1:7) = []; % Eliminate bullcrap columns
NOTAM(1:2,:) = [];
NOTAM.Properties.VariableNames = {'NOTAM_ID' 'FROM' 'TO' 'Q_CODE' 'POSITION' 'POSITION_RADIUS' 'LOWER_ALT' 'UPPER_ALT' 'IFR_VFR' 'FLIGHT_PHASE' 'LOWER_FL' 'UPPER_FL' 'BODY'};

%NOTAM.FROM = datedisp(NOTAM.FROM,'InputFormat','yyyy/MM/dd HH:mm');
%d = datestr(38792.25,'yyyy/MM/dd HH:mm');

% Position_Radius = table2array(NOTAM(:,6));

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
end

Position_Radius = NOTAM_Filtered{:,6};
Position_Radius = char(Position_Radius);
LatitudeNS = Position_Radius(:,1:5);
LongitudeEW = Position_Radius(:,6:11);
Radius = Position_Radius(:,12:14);

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
end

Latitude = num2str(Latitude);
Longitude = num2str(Longitude);

DegreesLat = Latitude(:,1:2);
MinutesLat = Latitude(:,3:4);



for k = 1:RowNumber(1,1)
DegreesLatDBL(k,:) = str2double(DegreesLat(k,:));
MinutesLatDBL(k,:) = str2double(MinutesLat(k,:));
end


DecimalLat = abs(DegreesLatDBL) + abs(MinutesLatDBL)/60;

DegreesLong = Longitude(:,1:3);
MinutesLong = Longitude(:,4:5);

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


for k=1:RowNumber(1,1)
    h =1 ;
for alpha=0:pi/200:(2*pi-pi/200)
     eps(50);
     circle(h,1) = DecimalLong(k,1) + RadiusArray(k,1)/60*cos(alpha);
     circle(h,2) = DecimalLat(k,1) + RadiusArray(k,1)/60*sin(alpha);
     h=h+1;
end
DecimalLongCircle(:,k) = circle(:,1);
DecimalLatCircle(:,k) = circle(:,2);
end
 
DecimalLatCircle = transpose(DecimalLatCircle);
DecimalLongCircle = transpose(DecimalLongCircle);
NOTAM_BRIEF = char(NOTAM_Filtered.BODY);
NOTAM_NAME = char(NOTAM_Filtered.NOTAM_ID);

% kmlwritepolygon('NOTAMoverlay',DecimalLatCircle,DecimalLongCircle,'Name',NOTAM_NAME,'Description',NOTAM_BRIEF);
kmlwritepolygon('NOTAMoverlay',DecimalLatCircle,DecimalLongCircle);
