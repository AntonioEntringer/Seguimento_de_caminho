clc; clear; close all;

%% Definir os waypoints 3D
waypoints = [  2  2  0;  % Ponto 1
              -0  0  1;  % Ponto 2
              -1 -1  0;  % Ponto 3
               2 -2  1]; % Ponto 4
          
t_waypoints = [0, 3, 8, 12]; % Tempos associados

%% Criar a trajetória linear
n_points = 1000;
t_interp = linspace(0, t_waypoints(4), n_points);
x_interp = zeros(size(t_interp));
y_interp = zeros(size(t_interp));
z_interp = zeros(size(t_interp));
vx_interp = zeros(size(t_interp));
vy_interp = zeros(size(t_interp));
vz_interp = zeros(size(t_interp));

for i = 1:3
    t0 = t_waypoints(i);
    tf = t_waypoints(i+1);
    mask = (t_interp >= t0) & (t_interp <= tf);
    t_segment = t_interp(mask);
    
    % Trajetória linear
    x_interp(mask) = waypoints(i,1) + (waypoints(i+1,1) - waypoints(i,1)) / (tf - t0) * (t_segment - t0);
    y_interp(mask) = waypoints(i,2) + (waypoints(i+1,2) - waypoints(i,2)) / (tf - t0) * (t_segment - t0);
    z_interp(mask) = waypoints(i,3) + (waypoints(i+1,3) - waypoints(i,3)) / (tf - t0) * (t_segment - t0);
    
    % Velocidade constante
    vx_interp(mask) = (waypoints(i+1,1) - waypoints(i,1)) / (tf - t0);
    vy_interp(mask) = (waypoints(i+1,2) - waypoints(i,2)) / (tf - t0);
    vz_interp(mask) = (waypoints(i+1,3) - waypoints(i,3)) / (tf - t0);
end

%% Plotar a trajetória interpolada
figure;
plot3(waypoints(:,1), waypoints(:,2), waypoints(:,3), 'ro', 'MarkerSize', 8, 'LineWidth', 2); hold on;
plot3(x_interp, y_interp, z_interp, 'b-', 'LineWidth', 2);
xlabel('X'); ylabel('Y'); zlabel('Z');
title('Caminho 4 Waypoints linear');
legend('Waypoints', 'Trajetória Linear');
grid on;
axis equal;
ylim([-3 3]);xlim([-3 3]);
view(3);

% Plotar velocidade
figure;
subplot(3,1,1); plot(t_interp, vx_interp, 'r'); ylabel('v_x'); grid on;ylim([-3 3]);
title('Velocidade em função do tempo - 4 Waypoints linear');
subplot(3,1,2); plot(t_interp, vy_interp, 'g'); ylabel('v_y'); grid on;ylim([-2 2]);
subplot(3,1,3); plot(t_interp, vz_interp, 'b'); ylabel('v_z'); xlabel('Tempo (s)'); grid on;ylim([-2 2]);

%% Salvando o caminho em um arquivo .txt
zero_column = zeros(size(x_interp'));
caminho = [x_interp',vx_interp',zero_column, y_interp',vy_interp',zero_column,z_interp',vz_interp',zero_column];
filename = '4waypoints_linear.txt';
dlmwrite(filename, caminho, 'Delimiter', '\t');

disp('Arquivo salvo com sucesso!');