%% Pole Placement

% Parâmetros do sistema
% ax = 0.22; ay = 0.27; az = 1;
% bx = 9.8028; by = 9.8083; bz = 1;
%
ax = 0.0263; ay = 0.0283; az = 1;
bx = 0.1028; by = 0.1083; bz = 1;

Kv = [0  1  0  0  0  0;
      0 -ax 0  0  0  0;
      0  0  0  1  0  0;
      0  0  0 -ay 0  0;
      0  0  0  0  0  1;
      0  0  0  0  0 -az];

Ku = [0  0  0;
      bx 0  0;
      0  0  0;
      0  by 0;
      0  0  0;
      0  0  bz];

% Valores de Xi e tempo desejado
xi_values = [0.4, 0.6, 0.8];
t_values = [0.2, 1];

for t = t_values
    fprintf('\nPara tempo de estabilizacao t = %.1fs\n', t);
    fprintf('------------------------------------------------------------\n');
    
    for xi = xi_values
        wn = 4 / (xi * t);  % Frequência natural
        
        poles = [-xi * wn + 1j * wn * sqrt(1 - xi^2);
                 -xi * wn - 1j * wn * sqrt(1 - xi^2);
                 -xi * wn + 1j * wn * sqrt(1 - xi^2);
                 -xi * wn - 1j * wn * sqrt(1 - xi^2);
                 -xi * wn + 1j * wn * sqrt(1 - xi^2);
                 -xi * wn - 1j * wn * sqrt(1 - xi^2)];
        
        % Cálculo dos ganhos por alocação de polos
        K = place(Kv, Ku, poles);
        
        fprintf('\nXi = %.1f: Kp e Kd calculados\n', xi);
        disp('  K =');
        disp(round(K, 2));
    end
    
    fprintf('============================================================\n');
end

%% LQR

%clear; clc;

% Definição dos ganhos iniciais
kpx = 32; kpy = 10; kpz = 15;
kdx = 8; kdy = 4; kdz = 5;

% Parâmetros do sistema
ax = 0.27; ay = 0.22; az = 1;
bx = 9.8028; by = 9.8083; bz = 1;

% Matrizes do sistema
Kv = [0, 1, 0, 0, 0, 0;
      0, -ax, 0, 0, 0, 0;
      0, 0, 0, 1, 0, 0;
      0, 0, 0, -ay, 0, 0;
      0, 0, 0, 0, 0, 1;
      0, 0, 0, 0, 0, -az];

Ku = [0, 0, 0;
      bx, 0, 0;
      0, 0, 0;
      0, by, 0;
      0, 0, 0;
      0, 0, bz];

% Lista de valores de R e Q para teste
R_values = [0.1, 1, 10];
Q_values = [
    [1, 1, 1, 1, 1, 1];
    [1, 10, 1, 10, 1, 10];
];

for i = 1:size(Q_values, 1)
    Q = diag(Q_values(i, :));
    fprintf('\nQ = diag(%s)\n', mat2str(Q_values(i, :)));
    fprintf('--------------------------------------------------\n');
    
    for j = 1:length(R_values)
        R = diag([R_values(j), R_values(j), R_values(j)]);
        
        try
            % Resolve a equação de Riccati
            [P,~,~] = care(Kv, Ku, Q, R);
            
            % Calcula o ganho LQR
            K = inv(R) * Ku' * P;
            
            fprintf('R = %.1f, K =\n%s\n', R_values(j), mat2str(round(K, 2)));
        catch ME
            fprintf('Erro para R = %.1f: %s\n', R_values(j), ME.message);
        end
    end
    fprintf('==================================================\n');
end
