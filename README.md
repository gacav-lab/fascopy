# Fascopy - {Fas}t {Copy} - Cópia rápida

## Informações

Autor: Gabriel Cavalcante de Jesus Oliveira

Data: 02/04/2022

Linguagem de Programação: Shell Script

Interpretador: Bash (Bourn Again Shell)

Compatível com: sistemas Unix-like

Github: https://github.com/gacav-lab/fascopy

## Sobre

Realiza uma backup (cópia de segurança) de todos os diretórios e/ou arquivos especificados ou qualquer que desejar (editando o script) para o diretório ".backup" que ele cria "na home do usuário". O conteúdo desse diretório é compactado, e comprimido (caso deseje), gerando um arquivo binário em formato zip "backup.zip", que ele envia para a área de trabalho do usuário.

## Descrição

Foi utilizada a linguagem de script supracitada para criação do script, que tem como objetivo automatizar a realização de backup, anteriormente feita manualmente. O backup pode ser realizado através de duplo-clique sobre o script ou via linha de comando (console ou terminal), se preferir, que será feito de forma rápida, automática e eficiente. Ele executa em segundo plano, identificando o ambiente em que está sendo executado (CLI - Interface de Linha de Comando ou GUI - Interface Gráfica do Usuário) e dando respostas de acordo, sobre em qual etapa do processo está, quando o processo é concluído e caso encontre algum erro. Fascopy gera arquivos de log contendo informações sobre seu processamento e/ou erros encontrados. Dentro do código, foram feitas várias modificações para torná-lo mais eficiente.

## Boas práticas para nomeação de diretórios ou arquivos

1. Evite espaços entre nomes compostos, use técnicas como: hífen (bar-foo), none (barfoo) ou snake-case (bar_foo); pascal-case (BarFoo) e
camel-case (barFoo) não são recomendados;

2. Evite acentos e caracteres não alfanuméricos, priorize os caracteres alfanuméricos da tabela ASCII;

3. Evite caracteres em maiúsculo, o ideal é que todos eles sejam escritos em minúsculo;

Obs.: As regras acima não se aplicam a diretórios ou arquivos nativos, pois eles já vm com o sistema e não faz sentido, nem se deve
renomeá-los.
