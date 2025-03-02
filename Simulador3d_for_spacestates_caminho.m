
%% Planejador de movimento com plot dinâmico

clc; clear; close all;
cycle_count = 0;
joy = vrjoystick(1); % Assume que o primeiro joystick é o desejado
vel_seguimento = 1;

% caminho_name = '2waypoints_linear.txt';%feito
% caminho_name = '2waypoints_3ordem.txt'; %feito
% caminho_name = '2waypoints_5ordem.txt'; %feito
caminho_name = '4waypoints_linear.txt';%feito
% caminho_name = '4waypoints_3ordem.txt';%feito
% caminho_name = '4waypoints_5ordem.txt';
% caminho_name = 'lemniscata.txt';
% caminho_name = 'circulo.txt';
% caminho_name = 'retasconcatenadas.txt';

caminho_carregado = dlmread(caminho_name);

%% Parametros para o mp4
[~, nome_base, ~] = fileparts(caminho_name); % Obtém o nome do arquivo sem extensão
nome_mp4 = strcat(nome_base, '-Video.mp4');  % Nome do MP4

pasta_saida = fullfile(pwd, nome_base);
if ~exist(pasta_saida, 'dir')
    mkdir(pasta_saida);
end

% Criar o objeto VideoWriter para o MP4
video = VideoWriter(pasta_saida, 'MPEG-4');
video.FrameRate = 3; % Ajuste a taxa de quadros conforme necessário
open(video);



%%
xd = caminho_carregado(:, 1);
yd = caminho_carregado(:, 4);
zd = caminho_carregado(:, 7);
xddot = caminho_carregado(:, 2);
yddot = caminho_carregado(:, 5);
zddot = caminho_carregado(:, 8);
%%
% Número total de pontos
num_pontos = length(xd);

% Inicializa os vetores de derivadas
tangente = zeros(num_pontos, 2);

% Calcula a derivada usando diferenças finitas centradas para x e y
for i = 2:num_pontos-1
    tangente(i, 1) = (xd(i+1) - xd(i-1)) / 2;  % dx/dt
    tangente(i, 2) = (yd(i+1) - yd(i-1)) / 2;  % dy/dt
end

% Aproximação de primeira ordem para os extremos
tangente(1, :) = [xd(2) - xd(1), yd(2) - yd(1)];
tangente(num_pontos, :) = [xd(num_pontos) - xd(num_pontos-1), yd(num_pontos) - yd(num_pontos-1)];

% Normaliza os vetores para obter direções unitárias
normas = vecnorm(tangente, 2, 2);
tangentes = tangente ./ normas;

%% Criar a figura para plot dinâmico
figure('Position', [100, 100, 700, 700]);
hold on;
grid on;
plot3(xd, yd, zd, 'ro', 'MarkerSize', 0.5); % Pontos desejados
trajetoria_real = plot3(0, 0, 0, 'b--', 'LineWidth', 1);  % Linha azul para a trajetória real
trajetoria_desejada = plot3(0, 0, 0, 'r--', 'LineWidth', 1);  % Linha azul para a trajetória real

xlabel('X'); ylabel('Y'); zlabel('Z');
title('Controle de Trajetória Cúbica');
legend([trajetoria_real, trajetoria_desejada], {'Trajetória seguida', 'Trajetória Desejada'}); % Apenas os gráficos desejados
view(3);

% Simulação do controlador
dt = 0.01;  % Passo de tempo
tempo_total = 40;
t_sim = 0:dt:tempo_total;

% Estado inicial
 % [px, vx, py, vy, pz, vz]
x = [0; 0; 0; 0; 0; 0]; 
xdot = []; ydot = []; zdot = [];

% Ganhos do controlador PD
kpx = 42; kpy = 42; kpz = 30;
kdx = 4; kdy = 8; kdz = 5;

K = [kpx, kdx, 0,  0,  0,  0;
     0,   0,   kpy, kdy, 0,  0;
     0,   0,   0,   0,   kpz, kdz];

%% Dinâmica do sistema
ax = 0.27; ay = 0.22; az = 1;
bx = 9.8028; by = 9.8083; bz = 1;

Ad = [0, 1, 0, 0, 0, 0;
     0, -ax, 0, 0, 0, 0;
     0, 0, 0, 1, 0, 0;
     0, 0, 0, -ay, 0, 0;
     0, 0, 0, 0, 0, 1;
     0, 0, 0, 0, 0, -az];

Bd = [0, 0, 0;
     bx, 0, 0;
     0, 0, 0;
     0, by, 0;
     0, 0, 0;
     0, 0, bz];

% Histórico da trajetória
x_hist = [];
xd_hist = [];

% Loop da simulação
% for i = 1:length(t_sim)
tq = 0;
[axes, buttons] = read(joy);
i = 1;  % Índice manual
ponto_atual = plot3(NaN, NaN, NaN, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r'); 
dtt_backup = 0;
sentido = 1;
pause = 1;
buttons_anterior1 = 1;

psi = 0; psid = 0; 
delta_x = 0; delta_y = 0;
K_psi = 1; psi_erro = 0;

h_quiver1 = quiver3(x(1), x(3), x(5), cos(psid) * 0.4, sin(psid) * 0.4, 0, 'r', 'LineWidth', 1, 'MaxHeadSize', 1);
h_quiver2 = quiver3(x(1), x(3), x(5), -sin(psid) * 0.4, cos(psid) * 0.4, 0, 'g', 'LineWidth', 1, 'MaxHeadSize', 1);
h_quiver3 = quiver3(x(1), x(3), x(5), 0, 0, 0.2, 'b', 'LineWidth', 1, 'MaxHeadSize', 1);
t = 0;
idx_mais_prox_old = 0;

while buttons(2) ~= 1
    [axes, buttons] = read(joy);
    
    %% Logica para andar pra tras
    if buttons(1) == 1 && buttons_anterior == 0
        sentido = -sentido;
        disp('Meia volta')
    end
    % Regular velocidade
    if abs(axes(2)) >= 0.2 && (vel_seguimento - axes(2)*0.001) > 0 && vel_seguimento < 5
        vel_seguimento = vel_seguimento - axes(2)*0.005;
        disp('velociade de seguimento:')
        disp(vel_seguimento)
    end
    
    % Pausar seguimento de trajetoria
    if (buttons(3) == 1 && buttons_anterior1 == 0)
        pause = 0;
        disp('Seguimento pausado')
    elseif (buttons(4) == 1 && buttons_anterior1 == 0)
        pause = 1;
        disp('Seguimento despausado')
    end
    
    %% Logica de seguir indices
    lim_inf = max(1, idx_mais_prox_old - 50); % limitar os indices
    lim_sup = min(length(xd), idx_mais_prox_old + 50);

    indices_faixa = lim_inf:lim_sup;% Obtém os índices dentro da faixa desejada

    if idx_mais_prox_old < 90 % Valores para nao confundir a lemniscata e passar do primeiro ao ultimo indice
        indices_faixa = union(indices_faixa, ((length(xd)-50):length(xd)));
    end
    if idx_mais_prox_old > (length(xd)-50)
        indices_faixa = union(indices_faixa, 1:50); % Corrigido de 0:50 para 1:50
    end

    % Calcula distâncias apenas nos índices da faixa válida
    pos_atual = x(1:2:end)'; 
    distancias_faixa = vecnorm([xd(indices_faixa), yd(indices_faixa), zd(indices_faixa)] - pos_atual, 2, 2);
    [~, idx_relativo] = min(distancias_faixa);% Obtém o índice mínimo dentro da faixa
    idx_mais_prox = indices_faixa(idx_relativo);% Converte índice relativo para índice global
    idx_mais_prox = mod(idx_mais_prox - 1, length(xd)) + 1;  % continuidade
    idx_mais_prox_old = idx_mais_prox; % Atualiza a referência
    vel_desejada = [tangentes(idx_mais_prox,1); tangentes(idx_mais_prox,2); 0]'; % Define velocidade desejada
    
    %% vel orientada ao caminho
%     vel_desejada = [xddot(idx_mais_prox),yddot(idx_mais_prox),zddot(idx_mais_prox)]';
    vel_desejada = vel_desejada * vel_seguimento * sentido * pause;
    %% vel desejada pelo caminho
%     vel_desejada = vel_desejada * vel_seguimento * sentido * pause;  % Aplica escala de velocidade

    % Define o ponto desejado
    xdes = [xd(idx_mais_prox); vel_desejada(1);
            yd(idx_mais_prox); vel_desejada(2);
            zd(idx_mais_prox); vel_desejada(3)];
         
%     disp([vel_desejada(1), vel_desejada(2), vel_desejada(3)]);

    buttons_anterior1 = buttons(3);
    buttons_anterior = buttons(1);
    
    t = t + dt;
    
    %% Matriz de rotação
    R = [cos(psi),-sin(psi),0;sin(psi),cos(psi),0;0,0,1];
   
    %% Cálculo da entrada de controle u
    u = R*(pinv(Bd)*Ad*x + (K *(xdes - x)));
    
    %% Limite de 10°
    limitex = 9.8028 * tan(deg2rad(10));
    limitey = 9.8083 * tan(deg2rad(10));
     u(1) = max(min(u(1), limitex), -limitex);
     u(2) = max(min(u(2), limitey), -limitey);

    %% Cálculo da derivada do estado
    xdot = Ad * x + Bd * (inv(R)*u);
    xdot(6) = max(min(xdot(6), 1), -1);
    
    x = x + xdot * abs(dt);  % Atualiza o estado
    
    %% Armazena para análise
    x_hist(i, :) = x(1:2:end)';
    xdot_hist(i, :) = x(2:2:end)'; 
    xd_hist(i, :) = xdes(1:2:end);
    xddot_hist(i, :) = xdes(2:2:end);
    t_values(i) = t;
    psi_hist(i, :) = [psi, psid];
    
    %% Orientação
    if length(xd_hist(:,1)) > 10
        delta_x = xd_hist(end, 1) - xd_hist(end-10, 1);  
        delta_y = xd_hist(end, 2) - xd_hist(end-10, 2);  
        psid = atan2(delta_y, delta_x);
        psi_erro = (psid - psi);
        
        if abs(psi_erro) > pi
            if psi_erro > pi
                psi_erro = psi_erro - 2 * pi;
            else
                psi_erro = psi_erro + 2 * pi;
            end
        end
        
        upsi = K_psi * psi_erro;
        
        % Saturando o em 50 deg/s
        if upsi > 0.0582 %deg2rad(100/30)
            upsi = 0.0582;
        end
        if upsi < -0.0582
            upsi = -0.0582;
        end
        %%
        psi = psi + upsi;

        eixo_x_rot = [cos(psi), sin(psi), 0];
        eixo_y_rot = [-sin(psi), cos(psi), 0];
        eixo_z_rot = [0, 0, 1];
    end
    
    %% Atualizar o gráfico dinamicamente
    cycle_count = cycle_count + 1;
    if mod(cycle_count, 10) == 0
        axis equal
        set(trajetoria_desejada, 'XData', xd_hist(1:i, 1), 'YData', xd_hist(1:i, 2), 'ZData', xd_hist(1:i, 3));
        set(trajetoria_real, 'XData', x_hist(1:i, 1), 'YData', x_hist(1:i, 2), 'ZData', x_hist(1:i, 3));
        set(ponto_atual, 'XData', x_hist(i, 1), 'YData', x_hist(i, 2), 'ZData', x_hist(i, 3));
        if isvalid(h_quiver1), delete(h_quiver1); end
        if isvalid(h_quiver2), delete(h_quiver2); end
        if isvalid(h_quiver3), delete(h_quiver3); end
        
        h_quiver1 = quiver3(x(1), x(3), x(5), cos(psi) * 0.2, sin(psi) * 0.6, 0, 'r', 'LineWidth', 1, 'MaxHeadSize', 1);
        h_quiver2 = quiver3(x(1), x(3), x(5), -sin(psi) * 0.2, cos(psi) * 0.6, 0, 'g', 'LineWidth', 1, 'MaxHeadSize', 1);
        h_quiver3 = quiver3(x(1), x(3), x(5), 0, 0, 0.3, 'b', 'LineWidth', 1, 'MaxHeadSize', 1);
        legend([trajetoria_real, trajetoria_desejada], {'Trajetória seguida', 'Trajetória Desejada'},'Location', 'southoutside'); % Coloca a legenda abaixo do gráfico
        title(sprintf('Simulação do Drone - Tempo: %.1f s, Velocidade: %.2f(ganho), Sentido: %.0f', t, vel_seguimento*pause, sentido), 'FontSize', 14, 'FontWeight', 'bold');
        axis([-4 3 -3 3 -2 2])
        
        % Definir ângulo dinâmico de rotação
        az = mod(i/20, 360); % Rotação lenta e contínua no eixo Z
        el = mod(10+(i/40), 360);%el = 20; % Mantém a elevação fixa

        % Aplicar nova visualização
        view(az, el);
        
        drawnow;
       
        % Capturar o frame e salvar no vídeo
        frame = getframe(gcf);
        writeVideo(video, frame);
        

        
    end
    i = i + 1;  % Atualiza o índice
    disp(t)
end

disp('encerrado pelo joystick')



%% Salvar video e GIF
close(video);
disp(['Vídeo salvo em: ', pasta_saida]);

%% Salvar Figuras
fig_names = {'Posicoes', 'Velocidades', 'Orientacoes'};
figs = [];

% Posições
figs(1) = figure('Position', [100, 100, 1000, 600]);
subplot(3,1,1);
plot(t_values, x_hist(:,1), 'b-', t_values, xd_hist(:,1), 'r--');
ylabel('Posição X'); legend('Real','Desejada');ylim([-4 4]);grid on;
title(sprintf('Posição desejada e real - %s', caminho_name));
subplot(3,1,2);
plot(t_values, x_hist(:,2), 'b-', t_values, xd_hist(:,2), 'r--');
ylabel('Posição Y'); legend('Real','Desejada');ylim([-3 3]);grid on;
subplot(3,1,3);
plot(t_values, x_hist(:,3), 'b-', t_values, xd_hist(:,3), 'r--');
ylabel('Posição Z'); xlabel('Tempo (s)');ylim([-3 3]);grid on;

% Velocidades
figs(2) = figure('Position', [100, 100, 1000, 600]);
subplot(3,1,1);
plot(t_values, xdot_hist(:,1), 'b-', t_values, xddot_hist(:,1), 'r--');
ylabel('Velocidade X'); legend('Calculada','Desejada');
ylim([-2 2]);grid on;
title(sprintf('Velocidade desejada e real - %s', caminho_name));

subplot(3,1,2);
plot(t_values, xdot_hist(:,2), 'b-', t_values, xddot_hist(:,2), 'r--');
ylabel('Velocidade Y'); legend('Calculada','Desejada');grid on;
ylim([-2 2]);

subplot(3,1,3);
plot(t_values, xdot_hist(:,3), 'b-', t_values, xddot_hist(:,3), 'r--');
ylabel('Velocidade Z'); xlabel('Tempo (s)');
title('Velocidades do Sistema');
ylim([-2 2]);grid on;

% Orientações
figs(3) = figure('Position', [100, 100, 1000, 200]);
title(sprintf('Orientação desejada e real - %s', caminho_name));
plot(t_values, psi_hist(:,1), 'b-', t_values, psi_hist(:,2), 'r--');grid on;
title('Orientações do Sistema');
ylabel('Orientação'); xlabel('Tempo (s)'); legend('psi drone','psi desejado');

% Salvar as figuras como PNG
for j = (1:length(figs))
    saveas(figs(j), fullfile(pasta_saida, strcat(fig_names{j},'-',caminho_name, '.png')));
end
