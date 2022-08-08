%% Open document
clear
clc
disp('select the directory of your data') %initial message
path=uigetdir; %Matlab give you the name of the path selected
addpath(path); %Matlab add this path to be able to open files from there
file_name=input('what is the name of your file: ','s'); %to be able to run differents files with this script
groups=input('how many groups you have: '); %how many differents gruops have you experiment
replicates=input('how many replicates per sample: '); %replicates per sample
data=readtable(file_name) %to open your file with your data as a matrix
width_original_table=width(data);

%% modification in the table
while 1
    choice1=questdlg('Would you like to do any calculation','Calculation','Yes','No','No');
if isequal(choice1,'Yes')
    choice2=questdlg('Which one','Selection','Density','Proportion','Other','Density');

        if isequal(choice2,'Density')
        msgbox('This option will calculate the density as cell/mm^2')
        area=input('in which column is your area data: ');
        area_array=table2array(data(:,area));
        cell=input('in which column is your number of cell data: ');
        cell_array=table2array(data(:,cell));
        choice3=questdlg('In which unit are your area','unit of your area','um^2','mm^2','m^2','um^2');
        if isequal(choice3,'um^2')
        Density=(cell_array./(area_array./10^6));
        data=addvars(data,Density,'After',width(data))
        elseif isequal(choice3,'mm^2')
        Density=(cell_array./(area_array));
        data=addvars(data,Density,'After',width(data))
        elseif isequal(choice3,'m^2')
        Density=(cell_array./(area_array.*10^6));
        data=addvars(data,Density,'After',width(data))
        else
        msgbox('Change in your excel for one of this units')
        end
 
    elseif isequal(choice2,'Proportion')
         msgbox('This option will calculate the proportion in %')
         total=input('in  which column is your total data: ');
         total_array=table2array(data(:,total));
         prop=input('in which column is your number of cell to make the proportion: ');
         prop_array=table2array(data(:,prop));
         Proportion=(prop_array./total_array).*100;
         data=addvars(data,Proportion,'After',width(data))
    elseif isequal(choice2,'Other')
        msgbox('WORK IN PROGRESS')
        end
 end
if isequal(choice1,'No')
    break
end
end

%% Mean of replicates
  
if replicates > 1
    v=input('how many columns you want to do the mean of the replicates?: ');
replicates_vector=zeros((height(data))/2,v);
for e=1:v
n=1;
m=2;
column_to_analyse=input('in which column are your data that you want to do the mean(this is a loop write 1 column by 1: ');
for i=1:(height(data)/2)
    average_replicates=(table2array(data(n,column_to_analyse))+table2array(data(m,column_to_analyse)))/2;
    n=n+replicates;
    m=m+replicates;
    replicates_vector(i,e)=average_replicates;
end
end
else
data_array=table2array(data);
end

%% define your groups
if replicates > 1
w=size(replicates_vector);
matrix_groups=zeros(w(1),1);
start=1;
finish=0;
msgbox('Write the n of your groups in the order of the table')
for i2=1:groups
    n=input('write the n of your group(one by one): ');
    finish_mod=finish+n;
    matrix_groups(start:finish_mod)=i2;
    start=start+n;
    finish=finish+n;
end
else 
w=size(data_array);
matrix_groups=zeros(w(1),1);
start=1;
finish=0;
msgbox('Write the n of your groups in the order of the table')
for i3=1:groups
    n=input('write the n of your group(one by one): ');
    finish_mod=finish+n;
    matrix_groups(start:finish_mod)=i3;
    start=start+n;
    finish=finish+n;
end
end
%% Calculation of the mean and standard deviation
if replicates > 1
mean=splitapply(@mean,replicates_vector,matrix_groups)
standard_desviation=splitapply(@std,replicates_vector,matrix_groups)
else
data_stats=data_array(:,width_original_table+1:end)
mean=splitapply(@mean,data_stats,matrix_groups)
standard_desviation=splitapply(@std,data_stats,matrix_groups)
end
%% Graph selection
if replicates > 1
while 1
choice4=questdlg('Would you like to do a graph?','Graphs','Yes','No','No');
if isequal(choice4,'Yes')
choice5=questdlg('Which type?','Graph selection','Box','Bar','Bar');
if isequal(choice5, 'Box')
    choice6=questdlg('This graph type required all groups have the same n, DO YOU WANT TO CONTINUE?','WARNING','YES','NO','NO');
    if isequal(choice6,'YES')
        box_matrix=zeros(n,groups);
        c1=input('which column do you want to do the box chart: ');
        z0=1;
        for i3=1:groups
            for i4=1:n
            box_matrix(i4,i3)=replicates_vector(z0,c1);
            z0=z0+1;
            end
        end
       boxchart(box_matrix) 
        else 
    break
    end
end
if isequal(choice5, 'Bar')
   x1=1:groups;
   v2=input('in which column of your mean array you want a bar plot: ');
   bar(x1,mean(:,v2))
   hold on
   er=errorbar(x1,mean(:,v2),standard_desviation(:,v2),standard_desviation(:,v2));
   er.Color=[0 0 0];
   er.LineStyle = 'none';
   hold off
else
break
end
else
break   
end
end
else
while 1
choice4=questdlg('Would you like to do a graph?','Graphs','Yes','No','No');
if isequal(choice4,'Yes')
choice5=questdlg('Which type?','Graph selection','Box','Bar','Bar');
if isequal(choice5, 'Box')
    choice6=questdlg('This graph type required all groups have the same n, DO YOU WANT TO CONTINUE?','WARNING','YES','NO','NO');
    if isequal(choice6,'YES')
        box_matrix=zeros(n,groups);
        c1=input('which column do you want to do the box chart: ');
        z0=1;
        for i3=1:groups
            for i4=1:n
            box_matrix(i4,i3)=data_stats(z0,c1);
            z0=z0+1;
            end
        end
       boxchart(box_matrix) 
        else 
    break
    end
end
if isequal(choice5, 'Bar')
   x1=1:groups;
   v2=input('in which column of your mean array you want a bar plot: ');
   bar(x1,mean(:,v2))
   hold on
   er=errorbar(x1,mean(:,v2),standard_desviation(:,v2),standard_desviation(:,v2));
   er.Color=[0 0 0];
   er.LineStyle = 'none';
   hold off
else
break
end
else
break   
end
end
end

%% Hypothesis contrast
if replicates >1
    stats_vector=replicates_vector;
else
    stats_vector=data_stats;
end
choice7=questdlg('Which statistical test would you like to do','statistical test','2-ways ANOVA - Multiple comparison','Welchs t-test','Welchs t-test');
if isequal(choice7,'2-ways ANOVA - Multiple comparison')
  msgbox('For this analysis the n of your groups should be the same')
    n1=input('what is the number of samples of your groups: ');
    ANOVA2_matrix=zeros(n1,groups);
        c1=input('which column do you want to do the analysis: ');
        z0=1;
        for i3=1:groups
            for i4=1:n1
            ANOVA2_matrix(i4,i3)=stats_vector(z0,c1);
            z0=z0+1;
            end 
        end
 [~,~,stats]=anova2(ANOVA2_matrix,1);
 statistics=multcompare(stats);
 table_stats=array2table(statistics,"VariableNames",["Group","Group to compare","Lower Limit","difference","Upper Limit","P-value"])
elseif isequal(choice7,'Welchs t-test')
      msgbox('h=0 means are equal, h=1 means are significantly differents')
    c2=input('which column do you want to do the analysis: ');
    n_group1=input('insert the number of sample of group 1: ')
   [h,p]=ttest2(data_stats(1:n_group1,c2),data_stats(n_group1+1:end,c2),'Vartype','unequal')
end
