# Seguimento de Caminho

Este repositório contém a implementação de um método de seguimento de caminho para drones. Cada seção abaixo corresponde a um caminho gerado por diferentes métodos

---

## Circulo e Lemniscata

**Geração do caminho:**  
Não existe nenhuma restrição de tempo para essa abordagem, foram gerados 1000 pontos que correspondem a um circulo e 1000 pontos para a lemniscata com variação de altura.

![Imagem 1](circulo/circulo_lenminscata.png)  

### Animação/GIF
Seguimento do circulo representado graficamente. Detalhe para a orientação do drone simulado representado pelo eixo cordenado, em que Vermelho, Azul e Verde representam X,Y e Z respectivamente.
![circulo](circulo/circulo.gif)

### Resultado - Erro de posição e velocidade
Erro de posição no seguimento do caminho em função do tempo
![Imagem 1](circulo/Posicoes-circulo.txt.png)
Erro de velocidade no seguimento do caminho em função do tempo
![Imagem 2](circulo/Velocidades-circulo.txt.png) 

O Drone simulado seguio o caminho com a velocidade desejada, que é regulada por meio o Joystick com baixo erro.
...

---

## Lemniscata

Novamente nao existe nenhuma restrição de tempo, o drone simulado percorre o caminho seguindo a velocidade escolhida pela analogico do Joystick, podendo ser pausado ou tendo o sentido invertido.

### Animação/GIF
![lemniscata](lemniscata/lemniscata.gif)

### Resultado - Erro de posição e velocidade
Erro de posição no seguimento do caminho em função do tempo
![Imagem 1](lemniscata/Posicoes-lemniscata.txt.png)
Erro de velocidade no seguimento do caminho em função do tempo
![Imagem 2](lemniscata/Velocidades-lemniscata.txt.png)  
...

---

## Retas concatenadas

3 retas foram calculadas com pontos que preenchem o caminho entre elas, assim como no exemplo anterior, nenhuma restrição de tempo.

### Animação/GIF
![retasconcatenadas](retasconcatenadas/retasconcatenadas.gif)

### Resultado - Erro de posição e velocidade
Erro de posição no seguimento do caminho em função do tempo
![Imagem 1](retasconcatenadas/Posicoes-retasconcatenadas.txt.png)  
Erro de velocidade no seguimento do caminho em função do tempo
![Imagem 2](retasconcatenadas/Velocidades-retasconcatenadas.txt.png)  
...


---


# Seguimento de Caminho - Restrição de velocidade, aceleração e Jerk


...

## Caminho - 2 waypoints linear

Semelhante ao exemplo anterior de retas concatenadas, dessa vez a velocidade não é mais definida pelo Joystick multiplicando a norma da direção desejada, mas sim pela definição de tempo passada no momento da geração do caminho, em que cada seguimente carrega consigo a velocidade desejada.

Caminho gerado
![Imagem 1](2waypoints_linear/geradordecaminho2waypoints_linear.png)
Definição da velocidade que deve ser obedecida no decorrer da trajetória.
![Imagem 2](2waypoints_linear/vel_geradordecaminho2waypoints_linear.png)  

### Animação/GIF - Seguimento pelo drone
O seguimento não é suave como nos casos seguintes, pois a velocidade é sempre constante, existindo então um degrau de velocidade e por consequencia a solicitação de uma aceleração infinita (limitada pelos 10°).
![2waypoints_linear](2waypoints_linear/2waypoints_linear.gif)

### Resultado - Erro de posição e velocidade
Erro de posição no seguimento do caminho em função do tempo
![Imagem 1](2waypoints_linear/Posicoes-2waypoints_linear.txt.png)  
Erro de velocidade no seguimento do caminho em função do tempo, é possivel observar o degrau quando eu solicito fazer a trajetória ao contrario no momento final. Nos outros casos mais complexos a velocidade no final é zero graças as contraints requistadas.
![Imagem 2](2waypoints_linear/Velocidades-2waypoints_linear.txt.png)  
...

...
## Caminho - 2 waypoints ordem cubica

Neste caso, uma matriz contendo as posições e restrições é passada na elaboração do caminho, que possui requisição de posição, velocidade e aceleração. Por limitação da ordem da matriz, não é possivel requisitar variação suave da aceleração, logo o drone vai realizar mudanças de inclinação abruptas para seguir esse modelo.

![Imagem 1](2waypoints_3ordem/geradordecaminho2waypoints_3ordem.png)  
![Imagem 2](2waypoints_3ordem/pos_geradordecaminho2waypoints_3ordem.png)  
![Imagem 3](2waypoints_3ordem/vel_geradordecaminho2waypoints_3ordem.png)  
![Imagem 4](2waypoints_3ordem/acc_geradordecaminho2waypoints_3ordem.png)  

A posição e velocidade são suaves em função do tempo, sem haver descontinuidade, entretanto em Jerk existe descontinuidade, que resulta na aceleração variar de forma abrupta.

### Animação/GIF - Seguimento pelo drone
![2waypoints_3ordem](2waypoints_3ordem/2waypoints_3ordem.gif)

### Resultado - Erro de posição, velocidade e orientação
![Imagem 1](2waypoints_3ordem/Posicoes-2waypoints_3ordem.txt.png)  
![Imagem 2](2waypoints_3ordem/Velocidades-2waypoints_3ordem.txt.png)  
![Imagem 3](2waypoints_3ordem/Orientacoes-2waypoints_3ordem.txt.png)  

...

---

## Caminho - 2 waypoints 5° ordem

Neste caso, a matriz contendo as posições e restrições é de maior ordem, em que torna possivel solicitar continuidade na variação da aceleração, logo o resultado na variação da aceleração torna-se suave.

![Imagem 1](2waypoints_5ordem/geradordecaminho2waypoints_5ordem.png)  
![Imagem 2](2waypoints_5ordem/pos_geradordecaminho2waypoints_5ordem.png)  
![Imagem 3](2waypoints_5ordem/vel_geradordecaminho2waypoints_5ordem.png)  
![Imagem 4](2waypoints_5ordem/acc_geradordecaminho2waypoints_5ordem.png)  

### Animação/GIF - Seguimento pelo drone
![2waypoints_3ordem](2waypoints_5ordem/2waypoints_5ordem.gif)

### Resultado - Erro de posição, velocidade e orientação
![Imagem 1](2waypoints_5ordem/Posicoes-2waypoints_5ordem.txt.png)  
![Imagem 2](2waypoints_5ordem/Velocidades-2waypoints_5ordem.txt.png)  
![Imagem 3](2waypoints_5ordem/Orientacoes-2waypoints_5ordem.txt.png)  

...


---

## Caminho - 4 waypoints linear

Semelhante ao exemplo anterior de retas concatenadas, dessa vez a velocidade não é mais definida pelo Joystick multiplicando a norma da direção desejada, mas sim pela definição de tempo passada no momento da geração do caminho, em que cada seguimente carrega consigo a velocidade desejada.

Caminho gerado
![Imagem 1](4waypoints_linear/geradordecaminho4waypoints_linear.png)
Definição da velocidade que deve ser obedecida no decorrer da trajetória.
![Imagem 2](4waypoints_linear/vel_geradordecaminho4waypoints_linear.png)  

### Animação/GIF - Seguimento pelo drone
O seguimento não é suave como nos casos seguintes, pois a velocidade é sempre constante, existindo então um degrau de velocidade e por consequencia a solicitação de uma aceleração infinita (limitada pelos 10°).
![2waypoints_linear](4waypoints_linear/4waypoints_linear.gif)

### Resultado - Erro de posição e velocidade
Erro de posição no seguimento do caminho em função do tempo
![Imagem 1](4waypoints_linear/Posicoes-4waypoints_linear.txt.png)  
Erro de velocidade no seguimento do caminho em função do tempo, é possivel observar o degrau quando eu solicito fazer a trajetória ao contrario no momento final. Nos outros casos mais complexos a velocidade no final é zero graças as contraints requistadas.
![Imagem 2](4waypoints_linear/Velocidades-4waypoints_linear.txt.png)  
...

...
## Caminho - 4 waypoints ordem cubica

Neste caso, uma matriz contendo as posições e restrições é passada na elaboração do caminho, que possui requisição de posição, velocidade e aceleração. Por limitação da ordem da matriz, não é possivel requisitar variação suave da aceleração, logo o drone vai realizar mudanças de inclinação abruptas para seguir esse modelo.

![Imagem 1](4waypoints_3ordem/geradordecaminho4waypoints_3ordem.png)  
![Imagem 2](4waypoints_3ordem/pos_geradordecaminho4waypoints_3ordem.png)  
![Imagem 3](4waypoints_3ordem/vel_geradordecaminho4waypoints_3ordem.png)  
![Imagem 4](4waypoints_3ordem/acc_geradordecaminho4waypoints_3ordem.png)  

A posição e velocidade são suaves em função do tempo, sem haver descontinuidade, entretanto em Jerk existe descontinuidade, que resulta na aceleração variar de forma abrupta.

### Animação/GIF - Seguimento pelo drone
![2waypoints_3ordem](4waypoints_3ordem/4waypoints_3ordem.gif)

### Resultado - Erro de posição, velocidade e orientação
![Imagem 1](4waypoints_3ordem/Posicoes-2waypoints_4ordem.txt.png)  
![Imagem 2](4waypoints_3ordem/Velocidades-2waypoints_4ordem.txt.png)  
![Imagem 3](4waypoints_3ordem/Orientacoes-2waypoints_4ordem.txt.png)  

...

---

## Caminho - 4 waypoints 5° ordem

Neste caso, a matriz contendo as posições e restrições é de maior ordem, em que torna possivel solicitar continuidade na variação da aceleração, logo o resultado na variação da aceleração torna-se suave.

![Imagem 1](4waypoints_5ordem/geradordecaminho4waypoints_5ordem.png)  
![Imagem 2](4waypoints_5ordem/pos_geradordecaminho4waypoints_5ordem.png)  
![Imagem 3](4waypoints_5ordem/vel_geradordecaminho4waypoints_5ordem.png)  
![Imagem 4](4waypoints_5ordem/acc_geradordecaminho4waypoints_5ordem.png)  

### Animação/GIF - Seguimento pelo drone
![2waypoints_3ordem](4waypoints_5ordem/4waypoints_5ordem.gif)

### Resultado - Erro de posição, velocidade e orientação
![Imagem 1](4waypoints_5ordem/Posicoes-4waypoints_5ordem.txt.png)  
![Imagem 2](4waypoints_5ordem/Velocidades-4waypoints_5ordem.txt.png)  
![Imagem 3](4waypoints_5ordem/Orientacoes-4waypoints_5ordem.txt.png)  

...



---

## PolePlance_and_LQR.m

**Descrição:**  
(Este arquivo MATLAB contém a implementação dos controladores Pole Placement e LQR.)

---

## Simulador3d_for_spacestates_caminho.m

**Descrição:**  
(Este script MATLAB simula o comportamento 3D do drone utilizando modelos de espaço de estados.)

---

::contentReference[oaicite:0]{index=0}
 
