function [Xs,Ys,Zs,Deltat]=readatandcomp(file,PRNwanted,tob,t)
%file        ������ļ���ȥ��ͷ�ļ����֣�������ǺŶ��е�����
%PRNwanted   ��Ҫ��ȡ���ݵ����Ǻ�PRN
%tob         �۲�ʱ�̵�������ʱ���룬��ȡ����λ
%t           �۲�ʱ�̶�Ӧ��GPST����ȱʡ
data=importdata(file);
j=1;
for i=1:8:length(data(:,:))
    temp=data(i:i+7,:);
    if str2double(temp{1,1}(1:2))==PRNwanted
        finded(j,:)=temp';
        j=j+1;
    end
end
findedNum=length(finded(:,1));
%ȡ��Сʱ�۲�ʱ��UTC������Ѱ�ҹ۲�ʱ�̵�����ʵ����ǲο�ʱ��
if mod(tob(4),2)~=0
    if tob(5)>0
        th=tob(4)+1;
    else
    th=tob(4)-mod(tob(4),2);
    end
else
    th=tob(4);
end
if  th==24
    th=0;
    th1=24;
    for i=1:findedNum
       jde(i)=(str2double(finded{i,1}(10:11))==(tob(3)+1)&&str2double(finded{i,1}(13:14))==th) || str2double(finded{i,1}(13:14))+1==th1;
    end
else
    th1=th;
    for i=1:findedNum
       jde(i)=str2double(finded{i,1}(13:14))==th || str2double(finded{i,1}(13:14))+1==th1;
    end
end
tmp=[];
for i=1:findedNum
    if jde(i)
        tmp=finded(i,:)';
        data=tmp{1,1};
        PRN=data(1:2);year=str2double(data(4:5));month=str2double(data(7:8));day=str2double(data(10:11));
        hour=str2double(data(13:14));mintue=str2double(data(16:17));second=str2double(data(19:22));
        a0=eval(data(23:41));a1=eval(data(42:60));a2=eval(data(61:79));
        
        Cuc=eval(tmp{3,1}(4:22));toe=eval(tmp{4,1}(4:22));i0=eval(tmp{5,1}(4:22));iDOT=eval(tmp{6,1}(4:22));
        Crs=eval(tmp{2,1}(23:41));e=eval(tmp{3,1}(23:41));Cic=eval(tmp{4,1}(23:41));Crc=eval(tmp{5,1}(23:41));
        Delta_n=eval(tmp{2,1}(42:60));Cus=eval(tmp{3,1}(42:60));OMEGA=eval(tmp{4,1}(42:60));omega=eval(tmp{5,1}(42:60));
        M0=eval(tmp{2,1}(61:79));sqrtA=eval(tmp{3,1}(61:79));Cis=eval(tmp{4,1}(61:79));OMEGA_DOT=eval(tmp{5,1}(61:79));
%         %��Ҫ�������������д��data_select.txt���û������в鿴
%         fileID = fopen('n_selected.txt','w');
%         formatSpec = '%s \n';
%         [nrows,~] = size(tmp);
%         for row = 1:nrows
%             fprintf(fileID,formatSpec,tmp{row,:}); % ע��˴�����{}�����ǣ���ʱ���õ����ַ����������ţ���ע��
%         end
%         fclose(fileID);
        break
    end
end
if isempty(tmp)
    disp('n�ļ�����ƥ������')
    close;
end
% clear data th i j tmp finded thf formatSpec nrows row fileID;
% %���йز������빤����
% [data1,data2,data3,data4]=textread('n_selected.txt','%f%f%f%f','headerlines', 1);
% Cuc=data1(2);toe=data1(3);i0=data1(4);iDOT=data1(5);
% Crs=data2(1);e=data2(2);Cic=data2(3);Crc=data2(4);
% Delta_n=data3(1);Cus=data3(2);OMEGA=data3(3);omega=data3(4);
% M0=data4(1);sqrtA=data4(2);Cis=data4(3);OMEGA_DOT=data4(4);
% data=importdata('n_selected.txt');
% data=data{1,1};
% PRN=data(1:2);year=str2double(data(4:5));month=str2double(data(7:8));day=str2double(data(10:11));
% hour=str2double(data(13:14));mintue=str2double(data(16:17));second=str2double(data(19:22));
% a0=eval(data(23:41));a1=eval(data(42:60));a2=eval(data(61:79));
% clear data data1 data2 data3 data4 ;
if nargin < 4
    [~, t]=UTC2GPST(tob(1),tob(2),tob(3),tob(4),tob(5),tob(6));
end
[~, toc]=UTC2GPST(year,month,day,hour,mintue,second);
[Xs,Ys,Zs,Deltat]=comsatpos(t,toc,a0,a1,a2,Crs,Delta_n,M0,Cuc,e,Cus,sqrtA,toe,Cic,OMEGA,Cis,i0,Crc,omega,OMEGA_DOT,iDOT);
end

