clear all; clc;close all;
tic
DATOSCOVID= readtable('General.csv');
ENFERMEDADES= readtable('Enfermedades.csv');
toc
% FECHA_ACT=(DATOSCOVID(:,1));
% EDAD=(DATOSCOVID(:,16));-
% FECHA_DEFUNCION =(DATOSCOVID(:,13));

%% NÚMERO DE MUERTES CONFIRMADAS POR RANGO DE EDADES
NUM_MUERTOS = height(DATOSCOVID)- nnz(ismember(DATOSCOVID.FECHA_DEF, '9999-99-99'));
RANGO_EDADES={0:9,10:19,20:29,30:39,40:49,50:59,60:69,70:150};
NUM_MUERTOS_EDAD=zeros(1,length(RANGO_EDADES));
NUM_CONT_EDAD=zeros(1,length(RANGO_EDADES));

for i=1:length(RANGO_EDADES)
NUM_MUERTOS_EDAD(i)= nnz(ismember(DATOSCOVID.EDAD(ismember(DATOSCOVID.FECHA_DEF, '9999-99-99') == false), RANGO_EDADES{i}));
NUM_CONT_EDAD(i)= nnz(ismember(DATOSCOVID.EDAD,RANGO_EDADES{i}));
end
RE={'0-9','10-19','20-29','30-39','40-49','50-59','60-69','70+'};
Rangos_edad = categorical(RE,RE);
% f=figure('WindowState','fullscreen');
s1=subplot(2,2,1);
s2=subplot(2,2,2);
s3=subplot(2,2,[3 4]);
bar(s1,Rangos_edad,NUM_MUERTOS_EDAD,'k');
set(gca,'FontSize',20)
title(s1,'\fontsize{20}Muertes en la población mexicana');
%DENSIDAD DE MORTALIDAD POR COVID 19 SEGÚN RANGO DE EDADES
Poblacion_RE=[21523328,22000529,19918412,17540189,15023137,11002068,6877071,5559250];

bar(s2,Rangos_edad,Poblacion_RE,'k');
title(s2,'\fontsize{20}Población mexicana por rangos de edades');
set(gca,'FontSize',20)
Muertes_Densidad=NUM_MUERTOS_EDAD./Poblacion_RE;
bar(s3,Rangos_edad,Muertes_Densidad,'r');
set(gca,'FontSize',16)
title(s3,'\fontsize{20}Relación Letalidad/Población de COVID-19 en México por rango de edades');
% sgtitle('\bf{\fontsize{32}Estadisticas del COVID-19 en México}')
%% 





%% CURVA DE CONTAGIO POR DÍAS DE LA POBLACIÓN GENERAL

%EXTRACCIÓN DE VECTOR DE DÍAS DESDE EL PRIMER CONTAGIO AL ÚLTIMO REPORTADO
a = datenum({'27-Jan-2020 00:00:00';'29-Sep-2020 0:00:00'});
DIAS_CONTAGIO = datevec(a(1):a(2)); DIAS_CONTAGIO=DIAS_CONTAGIO(:,1:3);
DIAS_CONTAGIO = strcat(num2str(DIAS_CONTAGIO(:,1)),'-',num2str(DIAS_CONTAGIO(:,2)),'-',num2str(DIAS_CONTAGIO(:,3)));
DIAS_CONTAGIO = datetime(DIAS_CONTAGIO,'InputFormat','yyyy-MM-dd');

curva_Contagio=zeros(1,length(DIAS_CONTAGIO));

for cont=1:length(DIAS_CONTAGIO)
    curva_Contagio(cont)= nnz(ismember(DATOSCOVID.FECHA_SINTOMAS, DIAS_CONTAGIO(cont)));
end
%CURVA DE CONTAGIO GENERAL EN MÉXICO HASTA EL 29 DE SEPTIEMBRE DEL 2020
figure()
plot(DIAS_CONTAGIO,curva_Contagio);
%CURVA DE CONTAGIO ACUMULADO EN MÉXICO HASTA EL 29 DE SEPTIEMBRE DEL 2020
figure()
plot(DIAS_CONTAGIO,cumsum(curva_Contagio));

%% CURVAS DE CONTAGIO A TRAVÉS DEL TIEMPO POR EDADES
figure()

CURVA_EDADES_CELL={zeros(1,247),zeros(1,247),zeros(1,247),zeros(1,247),zeros(1,247),zeros(1,247),zeros(1,247),zeros(1,247),zeros(1,247),zeros(1,247),zeros(1,247),zeros(1,247),zeros(1,247),zeros(1,247),zeros(1,247),zeros(1,247),zeros(1,247),zeros(1,247)};
s1=subplot(2,1,1);
s2=subplot(2,1,2);
hold (s1, 'on')
hold (s2, 'on')
for c=1:length(RANGO_EDADES) 
    for cont=1:length(DIAS_CONTAGIO)
        CURVA_EDADES_CELL{c}(cont)= nnz(ismember(DATOSCOVID.FECHA_SINTOMAS(ismember(DATOSCOVID.EDAD,RANGO_EDADES{c}) == true), DIAS_CONTAGIO(cont)));
    end
    if(c==length(RANGO_EDADES))
        plot(s1,DIAS_CONTAGIO,CURVA_EDADES_CELL{c},'c','LineWidth',2);
    else
        plot(s1,DIAS_CONTAGIO,CURVA_EDADES_CELL{c},'LineWidth',2);
    end
    if(c==length(RANGO_EDADES))
        plot(s2,DIAS_CONTAGIO,cumsum(CURVA_EDADES_CELL{c}),'c','LineWidth',2);
    else
    plot(s2,DIAS_CONTAGIO,cumsum(CURVA_EDADES_CELL{c}),'LineWidth',2);
    end
end


leg=legend(Rangos_edad,'Location','EastOutside');

%% SISTEMA DE PUNTAJE PARA COMPLICACIONES DEL COVID-19 SEGÚN GRUPOS DE EDAD
% Puntajes:
% Neumonia - 10
% Intubaron - 20
% Muerte - 30
PUNTOS_COMPLICACIONES= zeros(1,length(RANGO_EDADES));

for c=1:length(RANGO_EDADES)
    NEUMONIA(c)= nnz(ismember(DATOSCOVID.NEUMONIA(ismember(DATOSCOVID.EDAD,RANGO_EDADES{c}) == true),1)) *5;
    INTUBADOS(c)= nnz(ismember(DATOSCOVID.INTUBADO(ismember(DATOSCOVID.EDAD,RANGO_EDADES{c}) == true),1)) * 10;
    MUERTOS(c)=  NUM_MUERTOS_EDAD(c) *15;
    
    PUNTOS_COMPLICACIONES(c)= NEUMONIA(c)+INTUBADOS(c)+MUERTOS(c);
end
PROMEDIO_PUNTAJE= PUNTOS_COMPLICACIONES./NUM_CONT_EDAD;
figure()

datacombined=[PROMEDIO_PUNTAJE; (NUM_CONT_EDAD/10000)];
h=bar(Rangos_edad,datacombined,'grouped');
%% IDEA DE MARIO

    NEUMONIA= nnz(ismember(DATOSCOVID.NEUMONIA,1));
    NEUMONIA_MUERTE= nnz(ismember(DATOSCOVID.NEUMONIA(ismember(DATOSCOVID.FECHA_DEF,'9999-99-99') == false),1));
    INTUBADOS= nnz(ismember(DATOSCOVID.INTUBADO,1));
    INTUBADOS_MUERTE= nnz(ismember(DATOSCOVID.INTUBADO(ismember(DATOSCOVID.FECHA_DEF,'9999-99-99') == false),1));
    
    PERCENT_NEUMONIA=NEUMONIA_MUERTE/NEUMONIA;
    PERCENT_INTUBADO=INTUBADOS_MUERTE/INTUBADOS;
    
    PERCENT_TOTAL=PERCENT_INTUBADO+PERCENT_NEUMONIA;
    c=1;
    PUNTOS_NEUMONIA=(PERCENT_NEUMONIA/PERCENT_TOTAL)*c;
    PUNTOS_INTUBADO=(PERCENT_INTUBADO/PERCENT_TOTAL)*c;
    
    
    for c=1:length(RANGO_EDADES)
    NEUMONIA(c)= nnz(ismember(DATOSCOVID.NEUMONIA(ismember(DATOSCOVID.EDAD,RANGO_EDADES{c}) == true),1)) *PUNTOS_NEUMONIA;
    INTUBADOS(c)= nnz(ismember(DATOSCOVID.INTUBADO(ismember(DATOSCOVID.EDAD,RANGO_EDADES{c}) == true),1)) * PUNTOS_INTUBADO;

    PUNTOS_COMPLICACIONES(c)= NEUMONIA(c)+INTUBADOS(c);
    end
    
        s1=subplot(2,1,1);
        s2=subplot(2,1,2);

%     datacombined=[PUNTOS_COMPLICACIONES; NUM_CONT_EDAD/5];
%         sgtitle('Sistema de puntaje relativo para complicaciones del COVID-19')
        b2=bar(s2,Rangos_edad,NUM_CONT_EDAD,'r');
        ylabel(s2,'Número de contagios')
        b1=bar(s1,Rangos_edad,PUNTOS_COMPLICACIONES,'b');
        ylabel(s1,'Puntaje relativo')
        
%         s2.Position = s1.Position;
%         s1.Position = s2.Position;
%         s2.Color = 'none';
%         
%         s2.YAxisLocation = 'right';
%         s2.XAxisLocation = 'top';
%         
%         s1.XColor = 'b';
%         s2.XColor = 'r';
%         s1.YColor = 'b';
%         s2.YColor = 'r';
%         
%         s1.Box = 'off';
%         s2.Box = 'off'
%         
%         set(get(b2,'Children'),'FaceAlpha',0.2)
        
% li = min([s1.YAxis.Limits s2.YAxis.Limits]);
% ls = max([s1.YAxis.Limits s2.YAxis.Limits]);
% 
% s1.YLim = [li ls];
% s2.YLim = [li ls];

%         s2.XTick = [];
        
%         li = min([s1.XAxis.Limits s2.XAxis.Limits]);
%         ls = max([s1.XAxis.Limits s2.XAxis.Limits]);



%% SISTEMA DE PUNTAJE DE MORBILIDADES SEGÚN GRUPOS DE EDAD


