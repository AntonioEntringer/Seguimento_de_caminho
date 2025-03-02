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
A = zeros(4, 4);
B = zeros(4, 3); % Uma para cada dimensão (x, y, z)

A = [
    % Posição nos waypoints
    t0^3   t0^2   t0   1;   % Posição inicial do segmento 1
    t1^3   t1^2   t1   1;   % Posição final do segmento 1
    
    3*t0^2 2*t0   1    0;   % Velocidade no início do trajeto (zero)
    3*t1^2 2*t1   1    0;   % Velocidade no fim do trajeto (zero)
];


B = [
    waypoints(1, :);  % Posição inicial (x1, y1, z1)
    waypoints(2, :);  % Posição final do primeiro segmento (x2, y2, z2)  
    [0, 0, 0];  % Velocidade inicial (zero)
    [0, 0, 0];  % Velocidade final (zero)
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
    xd(:,i) = 1*coeffs(4,i) + t*coeffs(3,i) + t.^2*coeffs(2,i) + t.^3*coeffs(1,i);
    xd_dot(:,i) =   1*coeffs(3,i) + 2*t.^1*coeffs(2,i) + 3*t.^2*coeffs(1,i);
    xd_ddot(:,i) =    2*coeffs(2,i) + 6*t.^1*coeffs(1,i);
end


%% Plotar a trajetória interpolada
figure;
plot3(waypoints(:,1), waypoints(:,2), waypoints(:,3), 'ro', 'MarkerSize', 8, 'LineWidth', 2); hold on;
plot3(xd(:,1), xd(:,2), xd(:,3), 'b-', 'LineWidth', 2);
xlabel('X'); ylabel('Y'); zlabel('Z');
title('Caminho 2 Waypoints ordem cubica');
legend('Waypoints', 'Trajetória Interpolada');
grid on;
axis equal;
xlim([-3 3]);ylim([-3 3]);zlim([-1.5 1.5]);
view(3);

% Plotar posição
figure;
subplot(3,1,1); plot(t, xd(:,1), 'r'); hold on; ylabel('x'); grid on;ylim([-3 3]);
title('posição em função do tempo - 2 Waypoints ordem cubica');
subplot(3,1,2); plot(t, xd(:,2), 'g'); ylabel('y'); grid on;ylim([-2 2]);
subplot(3,1,3); plot(t, xd(:,3), 'b'); ylabel('z'); xlabel('Tempo (s)'); grid on;ylim([-2 2]);

% Plotar velocidade
figure;
subplot(3,1,1); plot(t, xd_dot(:,1), 'r'); hold on; ylabel('v_x'); grid on;ylim([-2 2]);
title('Velocidade em função do tempo - 2 Waypoints ordem cubica');
subplot(3,1,2); plot(t, xd_dot(:,2), 'g'); ylabel('v_y'); grid on;ylim([-2 2]);
subplot(3,1,3); plot(t, xd_dot(:,3), 'b'); ylabel('v_z'); xlabel('Tempo (s)'); grid on;ylim([-2 2]);

% Plotar aceleração
figure;
subplot(3,1,1); plot(t, xd_ddot(:,1), 'r'); hold on; ylabel('a_x'); grid on;ylim([-2 2]);
title('Aceleração em função do tempo - 2 Waypoints ordem cubica');
subplot(3,1,2); plot(t, xd_ddot(:,2), 'g'); ylabel('a_y'); grid on;ylim([-2 2]);
subplot(3,1,3); plot(t, xd_ddot(:,3), 'b'); ylabel('a_z'); xlabel('Tempo (s)'); grid on; ylim([-2 2]);

%% Salvando o caminho em um arquivo .txt
caminho = [xd(:,1),xd_dot(:,1),xd_ddot(:,1),xd(:,2),xd_dot(:,2),xd_ddot(:,2),xd(:,3),xd_dot(:,3),xd_ddot(:,3)];
filename = '2waypoints_3ordem.txt';
dlmwrite(filename, caminho, 'Delimiter', '\t');

disp('Arquivo salvo com sucesso!');








% 
% %% Criar funções polinomiais e interpolar
% t_interp = linspace(t_waypoints(1), t_waypoints(end), 1000);
% x_interp = zeros(size(t_interp));
% y_interp = zeros(size(t_interp));
% z_interp = zeros(size(t_interp));
% vx_interp = zeros(size(t_interp));
% vy_interp = zeros(size(t_interp));
% vz_interp = zeros(size(t_interp));
% ax_interp = zeros(size(t_interp));
% ay_interp = zeros(size(t_interp));
% az_interp = zeros(size(t_interp));
% 
% num_segments = length(t_waypoints) - 1; % Número de segmentos
% 
% for i = 1:num_segments
%     mask = (t_interp >= t_waypoints(i)) & (t_interp <= t_waypoints(i+1));
%     t_segment = t_interp(mask) - t_waypoints(i); % Normaliza o tempo dentro do segmento
% 
%     % Posição
%     x_interp(mask) = polyval(coeffs_x((i-1)*4 + (1:4)), t_segment);
%     y_interp(mask) = polyval(coeffs_y((i-1)*4 + (1:4)), t_segment);
%     z_interp(mask) = polyval(coeffs_z((i-1)*4 + (1:4)), t_segment);
% 
%     % Velocidade: derivada da posição
%     vx_interp(mask) = polyval(polyder(coeffs_x((i-1)*4 + (1:4))), t_segment);
%     vy_interp(mask) = polyval(polyder(coeffs_y((i-1)*4 + (1:4))), t_segment);
%     vz_interp(mask) = polyval(polyder(coeffs_z((i-1)*4 + (1:4))), t_segment);
% 
%     % Aceleração: derivada da velocidade
%     ax_interp(mask) = polyval(polyder(polyder(coeffs_x((i-1)*4 + (1:4)))), t_segment);
%     ay_interp(mask) = polyval(polyder(polyder(coeffs_y((i-1)*4 + (1:4)))), t_segment);
%     az_interp(mask) = polyval(polyder(polyder(coeffs_z((i-1)*4 + (1:4)))), t_segment);
% end
% 
% %% Plotar a trajetória interpolada
% figure;
% plot3(waypoints(:,1), waypoints(:,2), waypoints(:,3), 'ro', 'MarkerSize', 8, 'LineWidth', 2); hold on;
% plot3(x_interp, y_interp, z_interp, 'b-', 'LineWidth', 2);
% xlabel('X'); ylabel('Y'); zlabel('Z');
% title('Interpolação Cúbica dos Waypoints');
% legend('Waypoints', 'Trajetória Interpolada');
% grid on;
% axis equal;
% view(3);
% 
% % Plotar velocidade
% figure;
% subplot(3,1,1); plot(t_interp, x_interp, 'r'); hold on; ylabel('x'); grid on;
% title('posição em função do tempo');
% subplot(3,1,2); plot(t_interp, y_interp, 'g'); ylabel('y'); grid on;
% subplot(3,1,3); plot(t_interp, z_interp, 'b'); ylabel('z'); xlabel('Tempo (s)'); grid on;
% 
% % Plotar velocidade
% figure;
% subplot(3,1,1); plot(t_interp, vx_interp, 'r'); hold on; ylabel('v_x'); grid on;
% title('Velocidade em função do tempo');
% subplot(3,1,2); plot(t_interp, vy_interp, 'g'); ylabel('v_y'); grid on;
% subplot(3,1,3); plot(t_interp, vz_interp, 'b'); ylabel('v_z'); xlabel('Tempo (s)'); grid on;
% 
% % Plotar aceleração
% figure;
% subplot(3,1,1); plot(t_interp, ax_interp, 'r'); hold on; ylabel('a_x'); grid on;
% title('Aceleração em função do tempo');
% subplot(3,1,2); plot(t_interp, ay_interp, 'g'); ylabel('a_y'); grid on;
% subplot(3,1,3); plot(t_interp, az_interp, 'b'); ylabel('a_z'); xlabel('Tempo (s)'); grid on;
% 
% %% Salvando o caminho em um arquivo .txt
% caminho = [x_interp',vx_interp',ax_interp',y_interp',vy_interp',ay_interp',z_interp',vz_interp',az_interp'];
% filename = '2waypoints_3ordem.txt';
% dlmwrite(filename, caminho, 'Delimiter', '\t');
% 
% disp('Arquivo salvo com sucesso!');
