clear; close all; clc;

%% Parâmetros Gerais
omega = 2 * pi / 10;  % Frequência do movimento desejado
dt = 0.01;           % Passo de tempo
t_final = 10;       % Tempo final
tempo = 0:dt:t_final;  % Vetor de tempo

%% Lemniscata
x_d = zeros(size(tempo)); x_dot = x_d; x_2dot = x_d;
y_d = zeros(size(tempo)); y_dot = y_d; y_2dot = y_d;
z_d = zeros(size(tempo)); z_dot = z_d; z_2dot = z_d;

for i = 1:length(tempo)
    t = tempo(i);
    
    % Posição desejada
    x_d(i) = 2 * cos(omega * t);
    y_d(i) = 2 * sin(omega * t) * cos(omega * t);
    z_d(i) = -2 * cos(omega * t);
    
    % Velocidade desejada (derivada da posição)
    x_dot(i) = -2 * omega * sin(omega * t);
    y_dot(i) = 2 * omega * (cos(2 * omega * t) - sin(omega * t) * sin(omega * t));
    z_dot(i) = 2 * omega * sin(omega * t);
    
    % Aceleração desejada (derivada da velocidade)
    x_2dot(i) = -2 * omega^2 * cos(omega * t);
    y_2dot(i) = -4 * omega^2 * sin(omega * t) * cos(omega * t);
    z_2dot(i) = -2 * omega^2 * cos(omega * t);
end

% Salvando os dados em arquivo
caminho = [x_d', x_dot', x_2dot', y_d', y_dot', y_2dot', z_d', z_dot', z_2dot'];
dlmwrite('lemniscataa.txt', caminho, 'Delimiter', '\t');

plot3(x_d, y_d, z_d, 'bo', 'MarkerSize', 0.5); hold on;

%% Círculo
x_d = zeros(size(tempo)); x_dot = x_d; x_2dot = x_d;
y_d = zeros(size(tempo)); y_dot = y_d; y_2dot = y_d;
z_d = zeros(size(tempo)); z_dot = z_d; z_2dot = z_d;

for i = 1:length(tempo)
    t = tempo(i);
    
    % Posição desejada
    x_d(i) = 2 * sin(omega * t);
    y_d(i) = 2 * cos(omega * t);
    z_d(i) = 0; % Mantém constante no plano XY
    
    % Velocidade desejada (derivada da posição)
    x_dot(i) = 2 * omega * cos(omega * t);
    y_dot(i) = -2 * omega * sin(omega * t);
    z_dot(i) = 0;
    
    % Aceleração desejada (derivada da velocidade)
    x_2dot(i) = -2 * omega^2 * sin(omega * t);
    y_2dot(i) = -2 * omega^2 * cos(omega * t);
    z_2dot(i) = 0;
end

% Salvando os dados em arquivo
caminho = [x_d', x_dot', x_2dot', y_d', y_dot', y_2dot', z_d', z_dot', z_2dot'];
dlmwrite('circuloo.txt', caminho, 'Delimiter', '\t');

plot3(x_d, y_d, z_d, 'ro', 'MarkerSize', 0.5);

% %%Exemplo de como carregar
% % Carregando o arquivo salvo para uma nova variável
% caminho_carregado = dlmread(filename);
% 
% % Separando as variáveis carregadas
% x_d_carregado = caminho_carregado(:, 1);
% y_d_carregado = caminho_carregado(:, 2);
% z_d_carregado = caminho_carregado(:, 3);
