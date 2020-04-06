function [SatUsed,Xr]=fuc_of_Prange_Positioning(tob,geodeticHstation,chooseTropo,Alpha,Beta,filen,fileo,filem)
%----------------------------���ò���------------------------------------
% tob=[01,9,4,9,30,0];                                     %�۲�ʱ�̵�UTCʱ����ȡ����λ
% geodeticHstation=93.4e-3;%NaN                            %��վ��ظ�km�������֪����NaN
% chooseTropo=2;                                           %���õĶ�����ģ��1:�򻯻��շƶ��£�Hopfield������ģ�� 2:��˹��Ī����Saastamoinen������ģ��
% Alpha=[0.2235D-07  0.2235D-07 -0.1192D-06 -0.1192D-06];  %��������ͷ�ļ��еĵ����Alpha
% Beta=[0.1290D+06  0.4915D+05 -0.1966D+06  0.3277D+06];   %��������ͷ�ļ��еĵ����Beta
% filen='wuhn2470_clearhdr.01n';                           %ȥͷ��n�ļ�
% fileo='wuhn2470_clearhdr.01o';                           %ȥͷ��o�ļ�
% filem='wuhn2470_clearhdr.01m';                           %ȥͷ��m�ļ�
%------------------------------------------------------------------------
%----------------------------������--------------------------------------
omegaE=7.29211511467e-5;                                 %������ת���ٶ�rad/s
cv=299792458;                                            %����m/s
a=6378137;                                               %WGS84����볤��m
finv=298.2572236;                                        %WGS84������ʵ���
if chooseTropo==1
[P0,T,e0]=readfilem(filem,tob(4),tob(5),tob(6));         %��m�ļ��ж�ȡ��Ӧʱ�̵���ѹ��mbar�����¶ȣ�K����ʪ�ȣ�%��
end
%------------------------------------------------------------------------
%����Ϊ�������
%1����O�ļ�����ȡ�Ŀ��������ǵ�C1�۲�ֵ��
[PRN,C1]=readfileo(fileo,tob(4),tob(5),tob(6));%ȥͷ��o�ļ�
SatNum=length(PRN(:));
%2����N�ļ�����ȡ��Ӧ���ǵ����ݡ�
[~,GPST]=UTC2GPST(tob(1),tob(2),tob(3),tob(4),tob(5),tob(6));
for i=1:SatNum
    [~,~,~,deltat(i)]=readatandcomp(filen,PRN(i),tob);
end
%3�������ʼ�����ò�վ����λ��ΪXr�����ջ��Ӳ��ֵΪdt��
X0=[0;0;0;0];
%4��ѡ��epoch��һ������Si������α��ΪGSiC1
 while 1   
     for i=1:SatNum
%5����������Si�������Ӳ�dt
%�ɼ�����������ʱ����
%6����������-���ջ��Ľ��Ƽ��ξ���Rs
%��1�����ݽ���ʱ���α�� �����źŷ���ʱ��
        Deltat(i)=C1(i)./cv;
        Tems(i)=GPST-(Deltat(i)+deltat(i));
%��2�����㷢��ʱ�̵��������� ����������������е�����ת����
        [Xs(i),Ys(i),Zs(i),deltat(i)]=readatandcomp(filen,PRN(i),tob,Tems(i));
        Prec=[cos(omegaE*Deltat(i)),sin(omegaE*Deltat(i)),0;
            -sin(omegaE*Deltat(i)),cos(omegaE*Deltat(i)),0;
            0,0,1]*[Xs(i);Ys(i);Zs(i)];
%��3��������Ƽ��ξ���
        Rs=sqrt((Prec(1,1)-X0(1,1))^2+(Prec(2,1)-X0(2,1))^2+(Prec(3,1)-X0(3,1))^2);
%7������������ӳ� dtrop
        dx=Prec-X0(1:3,1);
        [~, E1(i), ~] = topocent(X0(1:3,1),dx);
        if isnan(geodeticHstation)
           [~,~,h] = togeod(a,finv,X0(1,1),X0(2,1),X0(3,1)); 
           geodeticHstation=h*10^(-3);
        end
        if chooseTropo==1
            dtrop = tropo(sind(E1(i)),geodeticHstation,P0,T,e0,geodeticHstation,geodeticHstation,geodeticHstation);
        elseif chooseTropo==2
            dtrop = tropo_error_correction(E1(i),geodeticHstation);
        end
% dtrop=0;%�ݲ�����dtrop
%8�����������ӳ� diono
        diono=Error_Ionospheric_Klobuchar(X0(1:3,1)',[Xs(i);Ys(i);Zs(i)]',Alpha,Beta,GPST);
% diono=0;%�ݲ�����dtrop
%9��������Si�ڹ۲ⷽ���е�������
        l(i)=C1(i)-Rs+cv*deltat(i)-dtrop-diono+0;
%10��������Si��������
        b0(i)=(X0(1,1)-Prec(1,1))./Rs;
        b1(i)=(X0(2,1)-Prec(2,1))./Rs;
        b2(i)=(X0(3,1)-Prec(3,1))./Rs;
        b3(i)=1;
    end
% 11��ѡ��Epoch�е���һ�����ǣ�����α��Ϊ��S��
% 12���ظ�5--11��������ÿ�����ǵ�ϵ���������
%13�����������ǵ�ϵ��������̣��ԣ�x,y,z,cdtr��Ϊδ֪��������⣬��ʽΪ:AX=L
    A=[b0',b1',b2',b3'];L=l';
%14����⣺ X(i)=(inv(A'*P*A))*(A'*P*L)���ó���λ�����
    X=(inv(A'*A))*(A'*L);
    V=A*X-L;
% PȨ��
% P=[sind(E1(1))^2,0,0,0,0,0;
%     0,sind(E1(2))^2,0,0,0,0;
%     0,0,sind(E1(3))^2,0,0,0;
%     0,0,0,sind(E1(4))^2,0,0;
%     0,0,0,0,sind(E1(5))^2,0;
%     0,0,0,0,0,sind(E1(6))^2];
% X=(inv(A'*P*A))*(A'*P*L);
    Xi=X0+X;%��һ����Ҫ
% 15����X0���бȽϣ��ж�λ�ò�ֵ��
    if abs(X(1,1))>0.001||abs(X(2,1))>0.001||abs(X(3,1))>0.001
       X0=Xi;
    else
       X0=Xi;
       break;
    end
end
% %16���������������Xi��
Xr=X0(1:3,1);
SatUsed=num2str(PRN);
% deltax=X0(1:3,1)-[-2267749.30600679;5009154.2824012134;3221290.677045021]
% deltas=sqrt(deltax(1,1)^2+deltax(2,1)^2+deltax(3,1)^2)
% E1
% P=zeros(SatNum,SatNum);
% for i=1:SatNum
%     P(i,i)=sind(E1(i))^2;
% end
% Qx=inv(A'*P*A);
% GDOP=sqrt(Qx(1,1)+Qx(2,2)+Qx(3,3)+Qx(4,4))
% PDOP=sqrt(Qx(1,1)+Qx(2,2)+Qx(3,3))
% TDOP=sqrt(Qx(4,4))
% HDOP=sqrt(Qx(1,1)^2+Qx(2,2)^2+Qx(3,3)^2+Qx(4,4)^2)
% VDOP=sqrt(Qx(1,1)^2+Qx(2,2)^2+Qx(3,3)^2+Qx(4,4)^2)