
clc
clearvars
warning off



T = readtable("Copia.csv");
id_collision = sort(unique(T.COLLISION_ID));
calendario = datetime(2020,1,(1:366));

 
numCollisioni = array2table(NaN(length(id_collision), length(calendario)+1));
numCollisioni.Properties.VariableNames = ["COLLISION_ID" string(calendario)];
numCollisioni.id_collision = id_collision;

numPersoneFerite=array2table(NaN(length(id_collision), length(calendario)+1));
numPersoneFerite.Properties.VariableNames = ["COLLISION_ID" string(calendario)];
numPersoneFerite.id_collision = id_collision;

numPersoneMorte=array2table(NaN(length(id_collision), length(calendario)+1));
numPersoneMorte.Properties.VariableNames = ["COLLISION_ID" string(calendario)];
numPersoneMorte.id_collision = id_collision;

numPedoniFeriti=array2table(NaN(length(id_collision), length(calendario)+1));
numPedoniFeriti.Properties.VariableNames = ["COLLISION_ID" string(calendario)];
numPedoniFeriti.id_collision = id_collision;

numPedoniMorti=array2table(NaN(length(id_collision), length(calendario)+1));
numPedoniMorti.Properties.VariableNames = ["COLLISION_ID" string(calendario)];
numPedoniMorti.id_collision = id_collision;

numCiclistiFeriti=array2table(NaN(length(id_collision), length(calendario)+1));
numCiclistiFeriti.Properties.VariableNames = ["COLLISION_ID" string(calendario)];
numCiclistiFeriti.id_collision = id_collision;

numCiclistiMorti=array2table(NaN(length(id_collision), length(calendario)+1));
numCiclistiMorti.Properties.VariableNames = ["COLLISION_ID" string(calendario)];
numCiclistiMorti.id_collision = id_collision;

numMotoFeriti=array2table(NaN(length(id_collision), length(calendario)+1));
numMotoFeriti.Properties.VariableNames = ["COLLISION_ID" string(calendario)];
numMotoFeriti.id_collision = id_collision;

numMotoMorti=array2table(NaN(length(id_collision), length(calendario)+1));
numMotoMorti.Properties.VariableNames = ["COLLISION_ID" string(calendario)];
numMotoMorti.id_collision = id_collision;



numIncidenti = length(id_collision);
latitudine = zeros(numIncidenti, 1);
longitudine = zeros(numIncidenti, 1);

disp("ciao")
for i=1:numIncidenti
    temp = T(T.COLLISION_ID==id_collision(i, 1), :);
    latitudine(i, 1) = temp{1, "LATITUDE"};
    longitudine(i, 1) = temp{1, "LONGITUDE"};
end
disp("CIAO")


disp("INIZIO")
disp(" ")

contGiorni = 1;

  for k=1:length(calendario)
        for j=1:length(id_collision)
            selector = T.COLLISION_ID == id_collision(j, 1)...
                & T.CRASHDATE.Day == k;
            temp = T(selector, :);
           
            count = size(temp, 1);
            numCollisioni(numCollisioni.id_collision==id_collision(j, 1), contGiorni + 1) = {count};
           
            contPersoneFerite = size(temp(temp.NUMBEROFPERSONSINJURED==1, :), 1);
            numPersoneFerite(numPersoneFerite.id_collision==id_collision(j, 1), contGiorni + 1) = {contPersoneFerite};

            contPersoneMorte = size(temp(temp.NUMBEROFPERSONSKILLED==1, :),1);
            numPersoneMorte(numPersoneMorte.id_collision==id_collision(j,1), contGiorni+1)={contPersoneMorte};

            contPedoniFeriti = size(temp(temp.NUMBEROFPEDESTRIANSINJURED==1, :),1);
            numPedoniFeriti(numPedoniFeriti.id_collision==id_collision(j,1), contGiorni+1)={contPedoniFeriti};

            contPedoniMorti = size(temp(temp.NUMBEROFPEDESTRIANSINJURED==1,:),1);
            numPedoniMorti(numPedoniMorti.id_collision==id_collision(j,1),contGiorni+1)={contPedoniMorti};

            contCiclistiFeriti= size(temp(temp.NUMBEROFCYCLISTINJURED==1,:),1);
            numCiclistiFeriti(numCiclistiFeriti.id_collision==id_collision(j,1),contGiorni+1)={contCiclistiFeriti};

            contCiclistiMorti=size(temp(temp.NUMBEROFCYCLISTKILLED==1,:),1);
            numCiclistiMorti(numCiclistiMorti.id_collision==id_collision(j,1),contGiorni+1)={contCiclistiMorti};
           
            contMotoFeriti=size(temp(temp.NUMBEROFMOTORISTINJURED==1,:),1);
            numMotoFeriti(numMotoFeriti.id_collision==id_collision(j,1),contGiorni+1)={contMotoFeriti};
           
            contMotoMorti=size(temp(temp.NUMBEROFMOTORISTKILLED==1,:),1);
            numMotoMorti(numMotoMorti.id_collision==id_collision(j,1),contGiorni+1)={contMotoMorti};
        end
        disp(k);
        contGiorni = contGiorni + 1;
  end
 disp("FINE");


disp("INIZIO CLIMA")
disp(" ")

TabellaClima = readtable("climaData.csv");
calendario = convertTo(datetime(2020, 1, (1:366)), "datenum");

disp("FINE CLIMA")




%% Daily data formatting for DCM and HDGM

disp(" ")
disp("INIZIO FORMATTAZIONE")
disp(" ")

data.collisionData{1}=numCollisioni{:,2:end};
data.collisionData{2}=numPersoneFerite{:,2:end};
data.collisionData{3}=numPersoneMorte{:,2:end};
data.collisionData{4}=numPedoniFeriti{:,2:end};
data.collisionData{5}=numPedoniMorti{:,2:end};
data.collisionData{6}=numCiclistiFeriti{:,2:end};
data.collisionData{7}=numCiclistiMorti{:,2:end};
data.collisionData{8}=numMotoFeriti{:,2:end};
data.collisionData{9}=numMotoMorti{:,2:end};

data.nomeCollisione{1}='numero collisioni';
data.nomeCollisione{2}='numero persone ferite';
data.nomeCollisione{3}='numero persone morte';
data.nomeCollisione{4}='numero pedoni feriti';
data.nomeCollisione{5}='numero pedoni morti';
data.nomeCollisione{6}='numero ciclisti feriti';
data.nomeCollisione{7}='numero ciclisti morti';
data.nomeCollisione{8}='numero moto feriti';
data.nomeCollisione{9}='numero moto morti';

data.clima{1}=repmat(TabellaClima{:,"temp"},numIncidenti,1);
data.clima{1} = repmat(TabellaClima{:, "temp"}', numIncidenti, 1);
data.clima{2} = repmat(TabellaClima{:, "feelslike"}', numIncidenti, 1);
data.clima{3} = repmat(TabellaClima{:, "humidity"}', numIncidenti, 1);
data.clima{4} = repmat(TabellaClima{:, "precip"}', numIncidenti, 1);
data.clima{5} = repmat(TabellaClima{:, "snow"}', numIncidenti, 1);
data.clima{6} = repmat(TabellaClima{:, "windspeed"}', numIncidenti, 1);
data.clima{7} = repmat(TabellaClima{:, "cloudcover"}', numIncidenti, 1);
data.clima{8} = repmat(TabellaClima{:, "visibility"}', numIncidenti, 1);
data.clima{9} = repmat(TabellaClima{:, "uvindex"}', numIncidenti, 1);


data.nomeClima{1} = 'avg temperature';
data.nomeClima{2} = 'avg feels like temperature';
data.nomeClima{3} = 'humidity';
data.nomeClima{4} = 'rainfall';
data.nomeClima{5} = 'snowfall';
data.nomeClima{6} = 'windspeed';
data.nomeClima{7} = 'cloud cover';
data.nomeClima{8} = 'visibility';
data.nomeClima{9} = 'UV index';


data.calend = datetime(calendario, 'ConvertFrom', 'datenum');
data.num_calendar = calendario;

data.temporal_granularity = 'day';
data.measure_type = 'observed';
data.data_type = 'point';


data.numCollisioni = numIncidenti;
data.id = id_collision;
data.lat = latitudine;
data.lon = longitudine;

save("tabella.mat", "data")

disp("FINE FORMATTAZIONE")
toc;
