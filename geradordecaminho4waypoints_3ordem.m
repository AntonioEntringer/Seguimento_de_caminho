clc; clear; close all;

%% Definir os waypoints 3D
waypoints = [  2  2  0;  % Ponto 1
              -0  0  1;  % Ponto 2
              -1 -1  0;  % Ponto 3
               2 -2  1]; % Ponto 4
          
t_waypoints = [0, 3, 8, 12]; % Tempos associados
% t_waypoints = [0, 1, 2, 3]; % Tempos associados

% Definição dos tempos t0, t1, t2, t3
t0 = t_waypoints(1);
t1 = t_waypoints(2);
t2 = t_waypoints(3);
t3 = t_waypoints(4);

%% Construir a matriz 12x12 e o vetor B
A = zeros(12, 12);
B = zeros(12, 3); % Uma para cada dimensão (x, y, z)

A = [
    % Posição nos waypoints
    t0^3   t0^2   t0   1    0      0    0    0    0      0    0    0;   % Posição inicial do segmento 1
    t1^3   t1^2   t1   1    0      0    0    0    0      0    0    0;   % Posição final do segmento 1
    0      0      0    0    t1^3   t1^2 t1   1    0      0    0    0;   % Posição inicial do segmento 2
    0      0      0    0    t2^3   t2^2 t2   1    0      0    0    0;   % Posição final do segmento 2
    0      0      0    0    0      0    0    0    t2^3   t2^2 t2   1;   % Posição inicial do segmento 3
    0      0      0    0    0      0    0    0    t3^3   t3^2 t3   1;   % Posição final do segmento 3

    % Condições de velocidade 
    3*t0^2 2*t0   1    0    0      0    0    0    0      0    0    0;   % Velocidade no início do trajeto (zero)
    0      0      0    0    0      0    0    0    3*t3^2 2*t3 1    0;   % Velocidade no fim do trajeto (zero)

    % Continuidade da velocidade
    3*t1^2 2*t1   1    0   -3*t1^2 -2*t1 -1  0    0      0    0    0;   % Entre segmentos 1 e 2
    0      0      0    0    3*t2^2 2*t2 1    0   -3*t2^2 -2*t2 -1  0;   % Entre segmentos 2 e 3

    % Continuidade da aceleração
    6*t1   2      0    0   -6*t1   -2   0    0    0      0    0    0;   % Entre segmentos 1 e 2
    0      0      0    0    6*t2   2    0    0   -6*t2   -2   0    0    % Entre segmentos 2 e 3
];


B = [
    waypoints(1, :);  % Posição inicial (x1, y1, z1)
    waypoints(2, :);  % Posição final do primeiro segmento (x2, y2, z2)
    waypoints(2, :);  % Posição inicial do segundo segmento (x2, y2, z2)
    waypoints(3, :);  % Posição final do segundo segmento (x3, y3, z3)
    waypoints(3, :);  % Posição inicial do terceiro segmento (x3, y3, z3)
    waypoints(4, :);  % Posição final do terceiro segmento (x4, y4, z4)
    
    [0, 0, 0];  % Velocidade inicial (zero)
    [0, 0, 0];  % Velocidade final (zero)

    [0, 0, 0];  % Continuidade da velocidade entre segmentos 1 e 2
    [0, 0, 0];  % Continuidade da velocidade entre segmentos 2 e 3

    [0, 0, 0];  % Continuidade da aceleração entre segmentos 1 e 2
    [0, 0, 0]   % Continuidade da aceleração entre segmentos 2 e 3
];


%% Resolver o sistema Ax = B para cada dimensão
coeffs_x = A \ B(:,1);
coeffs_y = A \ B(:,2);
coeffs_z = A \ B(:,3);

coeffs = [coeffs_x'; coeffs_y'; coeffs_z']';
%% Interpolação


t1 =  0:0.01:t_waypoints(2);
t2 =  t_waypoints(2):0.01:t_waypoints(3);
t3 =  t_waypoints(3):0.01:t_waypoints(4);
t = [t1, t2, t3];
% Inicializa as variáveis com o tamanho total
N_total = length(t1) + length(t2) + length(t3);
xd      = zeros(N_total, 3);  
xd_dot  = zeros(N_total, 3);
xd_ddot = zeros(N_total, 3);

for i = 1:3
    % Cálculo para o segmento 1
    xd1 = coeffs(4,i) + t1.*coeffs(3,i) + t1.^2.*coeffs(2,i) + t1.^3.*coeffs(1,i);
    xd_dot1 = coeffs(3,i) + 2*t1.*coeffs(2,i) + 3*t1.^2.*coeffs(1,i);
    xd_ddot1 = 2*coeffs(2,i) + 6*t1.*coeffs(1,i);
    
    % Cálculo para o segmento 2
    xd2 = coeffs(8,i) + t2.*coeffs(7,i) + t2.^2.*coeffs(6,i) + t2.^3.*coeffs(5,i);
    xd_dot2 = coeffs(7,i) + 2*t2.*coeffs(6,i) + 3*t2.^2.*coeffs(5,i);
    xd_ddot2 = 2*coeffs(6,i) + 6*t2.*coeffs(5,i);
    
    % Cálculo para o segmento 3
    xd3 = coeffs(12,i) + t3.*coeffs(11,i) + t3.^2.*coeffs(10,i) + t3.^3.*coeffs(9,i);
    xd_dot3 = coeffs(11,i) + 2*t3.*coeffs(10,i) + 3*t3.^2.*coeffs(9,i);
    xd_ddot3 = 2*coeffs(10,i) + 6*t3.*coeffs(9,i);
    
    % Concatenando os resultados (note que os vetores já são linhas, por isso transponha para coluna)
    xd(:,i)      = [xd1, xd2, xd3]';
    xd_dot(:,i)  = [xd_dot1, xd_dot2, xd_dot3]';
    xd_ddot(:,i) = [xd_ddot1, xd_ddot2, xd_ddot3]';
end

%% Plotar a trajetória interpolada
figure;
plot3(waypoints(:,1), waypoints(:,2), waypoints(:,3), 'ro', 'MarkerSize', 8, 'LineWidth', 2); hold on;ylim([-3 3]);xlim([-3 3]);
plot3(xd(:,1), xd(:,2), xd(:,3), 'b-', 'LineWidth', 2);
xlabel('X'); ylabel('Y'); zlabel('Z');
title('Caminho 4 Waypoints ordem cubica');
legend('Waypoints', 'Trajetória Interpolada');
grid on;
axis equal;
view(3);

% Plotar posição
figure;
subplot(3,1,1); plot(t, xd(:,1), 'r'); hold on; ylabel('x'); grid on;ylim([-2 2]);
title('posição em função do tempo - 4 Waypoints ordem cubica');
subplot(3,1,2); plot(t, xd(:,2), 'g'); ylabel('y'); grid on;ylim([-2 2]);
subplot(3,1,3); plot(t, xd(:,3), 'b'); ylabel('z'); xlabel('Tempo (s)'); grid on;ylim([-2 2]);

% Plotar velocidade
figure;
subplot(3,1,1); plot(t, xd_dot(:,1), 'r'); hold on; ylabel('v_x'); grid on;ylim([-2 2]);
title('Velocidade em função do tempo - 4 Waypoints ordem cubica');
subplot(3,1,2); plot(t, xd_dot(:,2), 'g'); ylabel('v_y'); grid on;ylim([-2 2]);
subplot(3,1,3); plot(t, xd_dot(:,3), 'b'); ylabel('v_z'); xlabel('Tempo (s)'); grid on;ylim([-2 2]);

% Plotar aceleração
figure;
subplot(3,1,1); plot(t, xd_ddot(:,1), 'r'); hold on; ylabel('a_x'); grid on;ylim([-2 2]);
title('Aceleração em função do tempo - 4 Waypoints ordem cubica');
subplot(3,1,2); plot(t, xd_ddot(:,2), 'g'); ylabel('a_y'); grid on;ylim([-2 2]);
subplot(3,1,3); plot(t, xd_ddot(:,3), 'b'); ylabel('a_z'); xlabel('Tempo (s)'); grid on;ylim([-2 2]);

%% Salvando o caminho em um arquivo .txt
caminho = [xd(:,1),xd_dot(:,1),xd_ddot(:,1),xd(:,2),xd_dot(:,2),xd_ddot(:,2),xd(:,3),xd_dot(:,3),xd_ddot(:,3)];
filename = '4waypoints_3ordem.txt';
dlmwrite(filename, caminho, 'Delimiter', '\t');

disp('Arquivo salvo com sucesso!');
