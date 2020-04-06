function [GPSweek ,GPSsec]=UTC2GPST(y,m,d,h,min,s)

if y<90
    y=y+2000;
else
    y=y+1900;
end

if m<=2
    y=y-1;m=m+12;
end
MJD=fix(365.25*y)+fix(30.6001*(m+1))+d+(h+(min+s/60)/60)/24+1720981.5-2400000.5;
GPSweek=fix((MJD-44244)/7);
GPSsec=fix(mod((MJD-44244),7))*86400+h*3600+min*60+s;

