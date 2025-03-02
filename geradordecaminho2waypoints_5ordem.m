clc; clear; close all;

%% Definir os waypoints 3D
waypoints = [  2.5  -1  0;  % Ponto 1
               -1.5 2  1]; % Ponto 4
          
% Definir tempos associados
 t_waypoints = [0, 5]; % Tempos ajustados

% Definição dos tempos t0, t1, t2, t3
t0 = t_waypoints(1);
t1 = t_waypoints(2);

%% Construir a matriz 12x12 e o vetor B
A = zeros(6, 6);
B = zeros(6, 3);

%% Construir a matriz 6x6 e o vetor B
A = [
    t0^5     t0^4     t0^3     t0^2   t0   1;  % Posição inicial
    t1^5     t1^4     t1^3     t1^2   t1   1;  % Posição final
    5*t0^4   4*t0^3   3*t0^2   2*t0   1    0;  % Velocidade inicial (zero)
    5*t1^4   4*t1^3   3*t1^2   2*t1   1    0;  % Velocidade final (zero)
    20*t0^3  12*t0^2  6*t0     2      0    0;   % Aceleração inicial (zero)
    20*t1^3  12*t1^2  6*t1     2      0    0;   % Aceleração final (zero)
];


B = [
    waypoints(1, :);  % Posição inicial (x, y, z)
    waypoints(2, :);  % Posição final (x, y, z)  
    [0, 0, 0];  % Velocidade inicial (zero)
    [0, 0, 0];  % Velocidade final (zero)
    [0, 0, 0];  % Aceleração inicial (zero)
    [0, 0, 0];  % Aceleração final (zero)
];


%% Resolver o sistema Ax = B para cada dimensão
coeffs_x = A \ B(:,1);
coeffs_y = A \ B(:,2);
coeffs_z = A \ B(:,3);

coeffs = [coeffs_x'; coeffs_y'; coeffs_z']';
%% Interpolação
t =  0:0.01:t_waypoints(end);

xd = zeros(length(t), 3);  
xd_dot = zeros(length(t), 3);
xd_ddot = zeros(length(t), 3);


for i = 1:3
    xd(:,i) = 1*coeffs(6,i) + t*coeffs(5,i) + t.^2*coeffs(4,i) + t.^3*coeffs(3,i) + t.^4*coeffs(2,i) + t.^5*coeffs(1,i);
    xd_dot(:,i) =   1*coeffs(5,i) + 2*t.^1*coeffs(4,i) + 3*t.^2*coeffs(3,i) + 4*t.^3*coeffs(2,i) + 5*t.^4*coeffs(1,i);
    xd_ddot(:,i) =    2*coeffs(4,i) + 6*t.^1*coeffs(3,i) + 12*t.^2*coeffs(2,i) + 20*t.^3*coeffs(1,i);
end


%% Plotar a trajetória interpolada
figure;
plot3(waypoints(:,1), waypoints(:,2), waypoints(:,3), 'ro', 'MarkerSize', 8, 'LineWidth', 2); hold on;
plot3(xd(:,1), xd(:,2), xd(:,3), 'b-', 'LineWidth', 2);
xlabel('X'); ylabel('Y'); zlabel('Z');
title('Caminho 2 Waypoints ordem quinta');
legend('Waypoints', 'Trajetória Interpolada');
grid on;
axis equal;
view(3);
xlim([-3 3]);ylim([-3 3]);zlim([-1.5 1.5]);

% Plotar posição
figure;
subplot(3,1,1); plot(t, xd(:,1), 'r'); hold on; ylabel('x'); grid on;ylim([-3 3]);
title('posição em função do tempo - 2 Waypoints ordem quinta');
subplot(3,1,2); plot(t, xd(:,2), 'g'); ylabel('y'); grid on;ylim([-3 3]);
subplot(3,1,3); plot(t, xd(:,3), 'b'); ylabel('z'); xlabel('Tempo (s)'); grid on;ylim([-3 3]);

% Plotar velocidade
figure;
subplot(3,1,1); plot(t, xd_dot(:,1), 'r'); hold on; ylabel('v_x'); grid on;ylim([-2 2]);
title('Velocidade em função do tempo - 2 Waypoints ordem quinta');
subplot(3,1,2); plot(t, xd_dot(:,2), 'g'); ylabel('v_y'); grid on;ylim([-2 2]);
subplot(3,1,3); plot(t, xd_dot(:,3), 'b'); ylabel('v_z'); xlabel('Tempo (s)'); grid on;ylim([-2 2]);

% Plotar aceleração
figure;
subplot(3,1,1); plot(t, xd_ddot(:,1), 'r'); hold on; ylabel('a_x'); grid on;ylim([-2 2]);
title('Aceleração em função do tempo - 2 Waypoints ordem quinta');
subplot(3,1,2); plot(t, xd_ddot(:,2), 'g'); ylabel('a_y'); grid on;ylim([-2 2]);
subplot(3,1,3); plot(t, xd_ddot(:,3), 'b'); ylabel('a_z'); xlabel('Tempo (s)'); grid on;ylim([-2 2]);

%% Salvando o caminho em um arquivo .txt
caminho = [xd(:,1),xd_dot(:,1),xd_ddot(:,1),xd(:,2),xd_dot(:,2),xd_ddot(:,2),xd(:,3),xd_dot(:,3),xd_ddot(:,3)];
filename = '2waypoints_5ordem.txt';
dlmwrite(filename, caminho, 'Delimiter', '\t');

disp('Arquivo salvo com sucesso!');










