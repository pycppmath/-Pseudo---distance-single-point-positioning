function [PRN,C1]=readfileo(file,hour,minute,second)
if second<15
    second=0;
elseif second<45
    second=30;
else
    minute=minute+1;
    if minute==60
        minute=0;
        hour=hour+1;
    end
    second=0;
end
if hour==24
   hour=23;
   minute=59;
   second=30;
end
data=importdata(file,'\n');
%Ѱ������ʱ�������λ��
for i=1:length(data(:,:))
    if eval(data{i,1}(11:12))==hour&&eval(data{i,1}(14:15))==minute&&eval(data{i,1}(16:26))==second
        SatNum=eval(data{i,1}(31:32));
        data_out=data(i:i+SatNum,1);
        SatDiscard=zeros(1,SatNum);
        for i=1:SatNum
           if  length(data_out{i+1}(:))<35||data_out{i+1}(41)==' '
%                length(data{i+1}(:))<48||data{i+1}(54)==' '
               SatDiscard(i)=i;
           end
        end
        for i=1:3:3*SatNum
        if ismember((i+2)./3,SatDiscard)
            continue;
        else
            PRN((i+2)./3)=eval(data_out{1,1}(33+i:33+i+1));
        end
        end
        PRN(PRN==0)=[];
        for i=1:SatNum
        if ismember(i,SatDiscard)
            continue;
        else
            C1(i)=eval(data_out{i+1}(35:46));
%             P1(i)=eval(data{i+1}(51:62));
%           P2(i)=eval(data{i+1}(67:78));
        end
        end
        C1(C1==0)=[];
    break;
    end
end
% %��Ѱ�ҳ���������д��o_selected.txt�����û��鿴
% SatNum=eval(data{i,1}(31:32));
% data_out=data(i:i+SatNum,1);
% fileID = fopen('o_selected.txt','w');
% formatSpec = '%s \n';
% [nrows,~] = size(data_out);
% for row = 1:nrows
%     fprintf(fileID,formatSpec,data_out{row,:}); % ע��˴�����{}�����ǣ���ʱ���õ����ַ��������ţ���ע��
% end
% fclose(fileID);
% clear data th i j tmp finded thf formatSpec nrows row fileID data_out hour minute second ;
% %�ٶ���
% data=importdata('o_selected.txt','\n');
% SatDiscard=zeros(1,SatNum);
% for i=1:SatNum
%    if  length(data{i+1}(:))<35||data{i+1}(41)==' '
% %        length(data{i+1}(:))<48||data{i+1}(54)==' '
%        SatDiscard(i)=i;
%    end
% end
% for i=1:3:3*SatNum
%     if ismember((i+2)./3,SatDiscard)
%         continue;
%     else
%         PRN((i+2)./3)=eval(data{1,1}(33+i:33+i+1));
%     end
% end
% PRN(PRN==0)=[];
% for i=1:SatNum
%     if ismember(i,SatDiscard)
%         continue;
%     else
%         C1(i)=eval(data{i+1}(35:46));
% %         P1(i)=eval(data{i+1}(51:62));
% %         P2(i)=eval(data{i+1}(67:78));
%     end
% end
% C1(C1==0)=[];
