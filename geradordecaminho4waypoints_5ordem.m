clc; clear; close all;

%% Definir os waypoints 3D
waypoints = [  2  2  0;  % Ponto 1
              -0  0  1;  % Ponto 2
              -1 -1  0;  % Ponto 3
               2 -2  1]; % Ponto 4
          
t_waypoints = [0, 3, 8, 12]; % Tempos associados

% Defini��o dos tempos t0, t1, t2, t3
t0 = t_waypoints(1);
t1 = t_waypoints(2);
t2 = t_waypoints(3);
t3 = t_waypoints(4);

A = [
    % Posi��o nos waypoints
    t0^5   t0^4   t0^3   t0^2   t0   1        0      0      0      0      0      0          0      0      0      0      0      0;   % Posi��o inicial do segmento 1
    t1^5   t1^4   t1^3   t1^2   t1   1        0      0      0      0      0      0          0      0      0      0      0      0;   % Posi��o final do segmento 1
    0      0      0      0      0    0        t1^5   t1^4   t1^3   t1^2   t1     1          0      0      0      0      0      0;   % Posi��o inicial do segmento 2
    0      0      0      0      0    0        t2^5   t2^4   t2^3   t2^2   t2     1          0      0      0      0      0      0;   % Posi��o final do segmento 2
    0      0      0      0      0    0        0      0      0      0      0      0          t2^5   t2^4   t2^3   t2^2   t2     1;   % Posi��o inicial do segmento 3
    0      0      0      0      0    0        0      0      0      0      0      0          t3^5   t3^4   t3^3   t3^2   t3     1;   % Posi��o final do segmento 
    % Condi��es de velocidade 
    5*t0^4 4*t0^3 3*t0^2 2*t0   1    0        0      0      0      0      0      0          0      0       0     0      0      0;   % Velocidade no in�cio do trajeto (zero)
    0      0      0      0      0    0        0      0      0      0      0      0          5*t3^4 4*t3^3  3*t3^2 2*t3  1      0;   % Velocidade no fim do trajeto (zero)
    % Continuidade da velocidade
    5*t1^4 4*t1^3 3*t1^2 2*t1   1    0        -5*t1^4 -4*t1^3 -3*t1^2 -2*t1  -1   0         0        0       0       0       0   0;   % Entre segmentos 1 e 2
    0      0      0      0      0    0         5*t2^4 4*t2^3 3*t2^2 2*t2   1    0           -5*t2^4 -4*t2^3 -3*t2^2 -2*t2   -1   0;   % Entre segmentos 2 e 3
    % Condi��o acelera��o
    20*t0^3 12*t0^2 6*t0 2   0    0        0      0      0      0      0      0          0      0       0     0      0      0;   % Acelera��o no in�cio do trajeto (zero)
    0       0       0    0   0    0        0      0      0      0      0      0          20*t3^3 12*t3^2 6*t3 2      0      0;   % Acelera��o no final do trajeto (zero)
    % Continuidade acelera��o
    20*t1^3 12*t1^2 6*t1 2      0    0        -20*t1^3 -12*t1^2 -6*t1 -2  0   0         0        0       0       0       0    0;   % Entre segmentos 1 e 2
    0      0      0      0      0    0         20*t2^3 12*t2^2 6*t2 2      0    0       -20*t2^3 -12*t2^2 -6*t2 -2       0    0;    % Entre segmentos 2 e 3
    % Condi��o Jerk
    60*t0^2 24*t0   6    0   0    0        0      0      0      0      0      0          0      0       0     0      0      0;  % Jerk no in�cio do trajeto (zero)
    0       0       0    0   0    0        0      0      0      0      0      0          60*t3^2 24*t3  6     0      0      0;  % Jerk no final do trajeto (zero) 
    % Continuidade Jerk
    60*t1^2 24*t1 6      0      0    0        -60*t1^2 -24*t1 -6      0      0    0         0        0       0       0       0    0;   % Entre segmentos 1 e 2
    0      0      0      0      0    0         60*t2^2 24*t2   6      0      0    0       -60*t2^2 -24*t2   -6       0       0    0;   % Entre segmentos 2 e 3
];


B = [waypoints(1, :);  % Posi��o inicial (x1, y1, z1)
    waypoints(2, :);  % Posi��o final do primeiro segmento (x2, y2, z2)
    waypoints(2, :);  % Posi��o inicial do segundo segmento (x2, y2, z2)
    waypoints(3, :);  % Posi��o final do segundo segmento (x3, y3, z3)
    waypoints(3, :);  % Posi��o inicial do terceiro segmento (x3, y3, z3)
    waypoints(4, :);  % Posi��o final do terceiro segmento (x4, y4, z4)
    [0, 0, 0];  % Velocidade inicial (zero)
    [0, 0, 0];  % Velocidade final (zero)
    [0, 0, 0];  % Continuidade da velocidade entre segmentos 1 e 2
    [0, 0, 0];  % Continuidade da velocidade entre segmentos 2 e 3
    [0, 0, 0];  % Acelera��o incial
    [0, 0, 0];  % Acelera��o final 
    [0, 0, 0];  % Continuidade da acelera��o entre segmentos 1 e 2
    [0, 0, 0];   % Continuidade da acelera��o entre segmentos 2 e 3
    [0, 0, 0];  % Jerk incial
    [0, 0, 0];  % Jerk final
    [0, 0, 0];  % Jerk entre segmentos 1 e 2
    [0, 0, 0]];  % Jerk final entre segmentos 2 e 3
    


%% Resolver o sistema Ax = B para cada dimens�o
coeffs_x = A \ B(:,1);
coeffs_y = A \ B(:,2);
coeffs_z = A \ B(:,3);

coeffs = [coeffs_x'; coeffs_y'; coeffs_z']';
%% Interpola��o

t1 =  0:0.01:t_waypoints(2);
t2 =  t_waypoints(2):0.01:t_waypoints(3);
t3 =  t_waypoints(3):0.01:t_waypoints(4);
t = [t1, t2, t3];
% Inicializa as vari�veis com o tamanho total
length_total = length(t1) + length(t2) + length(t3);
xd      = zeros(length_total, 3);  
xd_dot  = zeros(length_total, 3);
xd_ddot = zeros(length_total, 3);

%%
% 6  5  4  3  2  1
% 12 11 10 9  8  7
% 18 17 16 15 14 13
%%
for i = 1:3
    % C�lculo para o segmento 1
    xd1 = 1*coeffs(6,i) + t1*coeffs(5,i) + t1.^2*coeffs(4,i) + t1.^3*coeffs(3,i) + t1.^4*coeffs(2,i) + t1.^5*coeffs(1,i);
    xd_dot1 = 1*coeffs(5,i) + 2*t1.^1*coeffs(4,i) + 3*t1.^2*coeffs(3,i) + 4*t1.^3*coeffs(2,i) + 5*t1.^4*coeffs(1,i);
    xd_ddot1 = 2*coeffs(4,i) + 6*t1.^1*coeffs(3,i) + 12*t1.^2*coeffs(2,i) + 20*t1.^3*coeffs(1,i);
    
    % C�lculo para o segmento 2
    xd2 = 1*coeffs(12,i) + t2*coeffs(11,i) + t2.^2*coeffs(10,i) + t2.^3*coeffs(9,i) + t2.^4*coeffs(8,i) + t2.^5*coeffs(7,i);
    xd_dot2 = 1*coeffs(11,i) + 2*t2.^1*coeffs(10,i) + 3*t2.^2*coeffs(9,i) + 4*t2.^3*coeffs(8,i) + 5*t2.^4*coeffs(7,i);
    xd_ddot2 = 2*coeffs(10,i) + 6*t2.^1*coeffs(9,i) + 12*t2.^2*coeffs(8,i) + 20*t2.^3*coeffs(7,i);
    
    % C�lculo para o segmento 3
    xd3 = 1*coeffs(18,i) + t3*coeffs(17,i) + t3.^2*coeffs(16,i) + t3.^3*coeffs(15,i) + t3.^4*coeffs(14,i) + t3.^5*coeffs(13,i);
    xd_dot3 = 1*coeffs(17,i) + 2*t3.^1*coeffs(16,i) + 3*t3.^2*coeffs(15,i) + 4*t3.^3*coeffs(14,i) + 5*t3.^4*coeffs(13,i);
    xd_ddot3 = 2*coeffs(16,i) + 6*t3.^1*coeffs(15,i) + 12*t3.^2*coeffs(14,i) + 20*t3.^3*coeffs(13,i);
    
    % Concatenando os resultados (note que os vetores j� s�o linhas, por isso transponha para coluna)
    xd(:,i)      = [xd1, xd2, xd3]';
    xd_dot(:,i)  = [xd_dot1, xd_dot2, xd_dot3]';
    xd_ddot(:,i) = [xd_ddot1, xd_ddot2, xd_ddot3]';
end

%% Plotar a trajet�ria interpolada
figure;
plot3(waypoints(:,1), waypoints(:,2), waypoints(:,3), 'ro', 'MarkerSize', 8, 'LineWidth', 2); hold on;ylim([-3 3]);xlim([-3 3]);
plot3(xd(:,1), xd(:,2), xd(:,3), 'b-', 'LineWidth', 2);
xlabel('X'); ylabel('Y'); zlabel('Z');
title('Caminho 4 Waypoints ordem Quinta');
legend('Waypoints', 'Trajet�ria Interpolada');
grid on;
axis equal;
view(3);

% Plotar posi��o
figure;
subplot(3,1,1); plot(t, xd(:,1), 'r'); hold on; ylabel('x'); grid on;ylim([-4 4]);
title('posi��o em fun��o do tempo - 4 Waypoints ordem Quinta');
subplot(3,1,2); plot(t, xd(:,2), 'g'); ylabel('y'); grid on;ylim([-4 4]);
subplot(3,1,3); plot(t, xd(:,3), 'b'); ylabel('z'); xlabel('Tempo (s)'); grid on;ylim([-4 4]);

% Plotar velocidade
figure;
subplot(3,1,1); plot(t, xd_dot(:,1), 'r'); hold on; ylabel('v_x'); grid on;ylim([-4 4]);
title('Velocidade em fun��o do tempo - 4 Waypoints ordem Quinta');
subplot(3,1,2); plot(t, xd_dot(:,2), 'g'); ylabel('v_y'); grid on;ylim([-4 4]);
subplot(3,1,3); plot(t, xd_dot(:,3), 'b'); ylabel('v_z'); xlabel('Tempo (s)'); grid on;ylim([-4 4]);

% Plotar acelera��o
figure;
subplot(3,1,1); plot(t, xd_ddot(:,1), 'r'); hold on; ylabel('a_x'); grid on;ylim([-2 2]);
title('Acelera��o em fun��o do tempo - 4 Waypoints ordem Quinta');
subplot(3,1,2); plot(t, xd_ddot(:,2), 'g'); ylabel('a_y'); grid on;ylim([-2 2]);
subplot(3,1,3); plot(t, xd_ddot(:,3), 'b'); ylabel('a_z'); xlabel('Tempo (s)'); grid on;ylim([-2 2]);

%% Salvando o caminho em um arquivo .txt
caminho = [xd(:,1),xd_dot(:,1),xd_ddot(:,1),xd(:,2),xd_dot(:,2),xd_ddot(:,2),xd(:,3),xd_dot(:,3),xd_ddot(:,3)];
filename = '4waypoints_5ordem.txt';
dlmwrite(filename, caminho, 'Delimiter', '\t');

disp('Arquivo salvo com sucesso!');



























% 
% %% Criar fun��es polinomiais e interpolar
% t_interp = linspace(0, 3, 1000);
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
% for i = 1:3
%     mask = (t_interp >= t_waypoints(i)) & (t_interp <= t_waypoints(i+1));
%     t_segment = t_interp(mask);
% 
%     % Posi��o
%     x_interp(mask) = polyval(coeffs_x((i-1)*4 + (1:4)), t_segment);
%     y_interp(mask) = polyval(coeffs_y((i-1)*4 + (1:4)), t_segment);
%     z_interp(mask) = polyval(coeffs_z((i-1)*4 + (1:4)), t_segment);
% 
%     % Velocidade: derivada da posi��o
%     vx_interp(mask) = polyval(polyder(coeffs_x((i-1)*4 + (1:4))), t_segment);
%     vy_interp(mask) = polyval(polyder(coeffs_y((i-1)*4 + (1:4))), t_segment);
%     vz_interp(mask) = polyval(polyder(coeffs_z((i-1)*4 + (1:4))), t_segment);
% 
%     % Acelera��o: derivada da velocidade
%     ax_interp(mask) = polyval(polyder(polyder(coeffs_x((i-1)*4 + (1:4)))), t_segment);
%     ay_interp(mask) = polyval(polyder(polyder(coeffs_y((i-1)*4 + (1:4)))), t_segment);
%     az_interp(mask) = polyval(polyder(polyder(coeffs_z((i-1)*4 + (1:4)))), t_segment);
% end
% 
% %% Plotar a trajet�ria interpolada
% figure;
% plot3(waypoints(:,1), waypoints(:,2), waypoints(:,3), 'ro', 'MarkerSize', 8, 'LineWidth', 2); hold on;
% plot3(x_interp, y_interp, z_interp, 'b-', 'LineWidth', 2);
% xlabel('X'); ylabel('Y'); zlabel('Z');
% title('Interpola��o C�bica Manual dos Waypoints');
% legend('Waypoints', 'Trajet�ria Interpolada');
% grid on;
% axis equal;
% view(3);
% 
% % Plotar velocidade
% figure;
% subplot(3,1,1); plot(t_interp, x_interp, 'r'); hold on; ylabel('x'); grid on;
% title('posi��o em fun��o do tempo');
% subplot(3,1,2); plot(t_interp, y_interp, 'g'); ylabel('y'); grid on;
% subplot(3,1,3); plot(t_interp, z_interp, 'b'); ylabel('z'); xlabel('Tempo (s)'); grid on;
% 
% % Plotar velocidade
% figure;
% subplot(3,1,1); plot(t_interp, vx_interp, 'r'); hold on; ylabel('v_x'); grid on;
% title('Velocidade em fun��o do tempo');
% subplot(3,1,2); plot(t_interp, vy_interp, 'g'); ylabel('v_y'); grid on;
% subplot(3,1,3); plot(t_interp, vz_interp, 'b'); ylabel('v_z'); xlabel('Tempo (s)'); grid on;
% 
% % Plotar acelera��o
% figure;
% subplot(3,1,1); plot(t_interp, ax_interp, 'r'); hold on; ylabel('a_x'); grid on;
% title('Acelera��o em fun��o do tempo');
% subplot(3,1,2); plot(t_interp, ay_interp, 'g'); ylabel('a_y'); grid on;
% subplot(3,1,3); plot(t_interp, az_interp, 'b'); ylabel('a_z'); xlabel('Tempo (s)'); grid on;
% 
% %% Salvando o caminho em um arquivo .txt
% caminho = [x_interp',vx_interp',ax_interp',y_interp',vy_interp',ay_interp',z_interp',vz_interp',az_interp'];
% filename = '4waypoints_3ordem.txt';
% dlmwrite(filename, caminho, 'Delimiter', '\t');
% 
% disp('Arquivo salvo com sucesso!');
