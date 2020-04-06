function [Xs,Ys,Zs,Deltat]=comsatpos(t,toc,a0,a1,a2,Crs,Delta_n,M0,Cuc,e,Cus,sqrtA,toe,Cic,OMEGA,Cis,i0,Crc,omega,OMEGA_DOT,iDOT)
%�㶯��������������uk������ʸ��rk�͹�����ik
%�����ڹ��������ϵ�е�����x,y
%����ʱ��������ľ���L
%�����ڵع�����ϵ������Xs,Ys,Zs
%�۲�ʱ��t���ο�ʱ��toe��a0,a1,a2
%16����
%Crs Delta_n M0  
%Cuc e Cus sqrtA 
%toe Cic  OMEGA Cis
%i0 Crc omega OMEGA_DOT  iDOT
%
%����Ϊ�������
%1.�����������е�ƽ�����ٶ�
n0=sqrt(3.986005E+14)/(sqrtA.^3);
n=n0+Delta_n;
%2.�����źŷ���ʱ���ǵ�ƽ�����
Deltat=a0+a1*(t-toc)+a2*(t-toc).^2;%tΪδ���Ӳ�����Ĺ۲�ʱ��
t=t-Deltat;%����tΪ���Ӳ�������ֵ
tk=t-toe;%�黯ʱ��
% if tk>302400
%     tk=tk-604800;
% elseif tk<-302400
%     tk=tk+604800;
% else
%     tk=tk+0;
% end
Mk=M0+n*tk;
%3.����ƫ����ǣ�������
%E=M+e*sin(E);
ed(1)=Mk;
for i=1:4
   ed(i+1)=Mk+e*sin(ed(i));
end
Ek=ed(5);
%4.����������
Vk=atan2(sqrt(1-e.^2)*sin(Ek),(cos(Ek)-e));
%5.����������ǣ�δ���Ľ�ʱ��
u=omega+Vk;
%6.�����㶯������
deltau=Cuc*cos(2*u)+Cus*sin(2*u);
deltar=Crc*cos(2*u)+Crs*sin(2*u);
deltai=Cic*cos(2*u)+Cis*sin(2*u);
%7.�����㶯��������������uk������ʸ��rk�͹�����ik
uk=u+deltau;
rk=(sqrtA.^2)*(1-e*cos(Ek))+deltar;
ik=i0+deltai+iDOT*tk;
%8.���������ڹ��������ϵ�е�����
x=rk*cos(uk);
y=rk*sin(uk);
%9.���㷢��ʱ��������ľ���67
L=OMEGA+(OMEGA_DOT-7.29211567E-5)*tk-7.292115E-5*toe;
%10.���������ڵع�����ϵ������
Xs=x*cos(L)-y*cos(ik)*sin(L);
Ys=x*sin(L)+y*cos(ik)*cos(L);
Zs=y*sin(ik);
% DeltaX=Xs-(-20274509.129)
% DeltaY=Ys-(13349329.456)
% DeltaZ=Zs-(-10661361.857)
end