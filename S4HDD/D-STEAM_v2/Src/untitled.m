clc 
clearvars
warning off

addpath('D-STEAM_v2\Src\')
load 'tabella.mat'

file.Y{1} = data.collisionData{1};
file.Y_name{1} = data.nomeCollisione{1};
c = 9;
n1 = size(file.Y{1},1);
d = size(file.Y{1},2);

file.Y{2} = data.collisionData{2};
file.Y_name{2} = data.nomeCollisione{2};

% Costruzione di X (variabili climatiche)
X = ones(data.numCollisioni, c, d); 
X(1:data.numCollisioni,2,1:366) = data.clima{2}(:, 1:366);
X(1:data.numCollisioni,3,1:366) = data.clima{4}(:, 1:366);
X(1:data.numCollisioni,4,1:366) = data.clima{6}(:, 1:366);
X(1:data.numCollisioni,5,1:366) = data.clima{7}(:, 1:366);
X(1:data.numCollisioni,6,1:366) = data.clima{3}(:, 1:366); % umidità
X(1:data.numCollisioni,7,1:366) = data.clima{5}(:, 1:366); % nevicate
X(1:data.numCollisioni,8,1:366) = data.clima{8}(:, 1:366); % visibilità
X(1:data.numCollisioni,9,1:366) = data.clima{9}(:, 1:366);

% Definizione delle variabili per il modello
file.X_beta{1} = X; 
file.X_beta_name{1} = {'costant', data.nomeClima{2}, data.nomeClima{4}, data.nomeClima{6}, ...
    data.nomeClima{7}, data.nomeClima{3}, data.nomeClima{5}, data.nomeClima{8}, data.nomeClima{9}};

file.X_beta{2} = X; 
file.X_beta_name{2} = {'costant', data.nomeClima{2}, data.nomeClima{4}, data.nomeClima{6}, ...
    data.nomeClima{7}, data.nomeClima{3}, data.nomeClima{5}, data.nomeClima{8}, data.nomeClima{9}};

file.X_z{1} = ones(data.numCollisioni, 1);
file.X_z_name{1} = {'costant'};

file.X_z{2} = ones(data.numCollisioni, 1);
file.X_z_name{2} = {'costant'};

file.X_p{1} = file.X_beta{1}(:, 1, 1); 
file.X_p_name{1} = {'constant'}; 

file.X_p{2} = file.X_beta{2}(:, 1, 1); 
file.X_p_name{2} = {'constant'}; 

% Creazione dell'oggetto stem_varset
obj_stem_varset_p = stem_varset(file.Y, file.Y_name, [], [], file.X_beta, file.X_beta_name, file.X_z, file.X_z_name, file.X_p, file.X_p_name);

% Creazione delle griglie
obj_stem_gridlist_p = stem_gridlist();
ground.coordinates{1} = [data.lat, data.lon];
ground.coordinates{2} = [data.lat, data.lon];
obj_stem_grid1 = stem_grid(ground.coordinates{1}, 'deg', 'sparse', 'point');
obj_stem_grid2 = stem_grid(ground.coordinates{2}, 'deg', 'sparse', 'point');
obj_stem_gridlist_p.add(obj_stem_grid1);
obj_stem_gridlist_p.add(obj_stem_grid2);

% Impostazione del time stamp
obj_stem_datestamp = stem_datestamp('01-01-2020 00:00','31-12-2020 00:00', d);

% Selezione delle stazioni per la cross-validation
S_val = [4 42 50 32 38 30 25 49 31 33 28 43 46 51 26];
obj_stem_validation = stem_validation({data.nomeCollisione{1}, data.nomeCollisione{2}}, {S_val, S_val}, 0, {'point','point'});

% Creazione del modello
obj_stem_modeltype = stem_modeltype('DCM');
shape = [];
obj_stem_data = stem_data(obj_stem_varset_p, obj_stem_gridlist_p, [], [], obj_stem_datestamp, obj_stem_validation, obj_stem_modeltype, shape);
obj_stem_par_constraints = stem_par_constraints();
obj_stem_par_constraints.time_diagonal = 1;
obj_stem_par = stem_par(obj_stem_data, 'exponential', obj_stem_par_constraints);

% Parametri iniziali più conservativi
obj_stem_par.v_p = [1 0.6; 0.6 1];
obj_stem_par.beta = bivariate_model.get_beta0(); 
obj_stem_par.theta_p = 0.06;
obj_stem_par.sigma_eta = diag([0.2 0.2]) + 1e-3 * eye(2);  % Stabilizzazione di sigma_eta
obj_stem_par.G = diag([0.8 0.8]);
obj_stem_par.sigma_eps = diag([0.3 0.3]) + 1e-3 * eye(2);  % Stabilizzazione di sigma_eps

% Imposta valori iniziali nel modello
bivariate_model = stem_model(obj_stem_data, obj_stem_par);
bivariate_model.set_initial_values(obj_stem_par);

% Stima del modello tramite EM
exit_toll = 0.001;
max_iterations = 100;
obj_stem_EM_options = stem_EM_options();
obj_stem_EM_options.max_iterations = 300;
obj_stem_EM_options.exit_tol_par = 0.001;

% Esecuzione della stima EM
bivariate_model.EM_estimate(obj_stem_EM_options);

% Calcolo della varianza e log-likelihood
bivariate_model.set_varcov;
bivariate_model.set_logL;

% Stampa dei risultati
bivariate_model.print 

% Visualizzazione dei risultati del Kalman Smoother
bivariate_model.stem_EM_result.stem_kalmansmoother_result.plot;
saveas(gcf, 'bivariate_model.png')
