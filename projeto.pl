% Henrique Afonso Coelho Dias: 89455

% -----------------------------------------------------------------------------
% propaga(Puz, Pos, Posicoes). Dado um puzzle Puz, o preenchimendo da posicao
% Pos implica o preenchimento das posicoes da lista ordenada Posicoes.
% -----------------------------------------------------------------------------

propaga([Termometros, _, _], Pos, Posicoes) :-
  member(Termometro, Termometros),
  append(Inicio, [Pos|_], Termometro),
  sort([Pos|Inicio], Posicoes), !.

% -----------------------------------------------------------------------------
% e_sublista(Lista1, Lista2). Sucede se a Lista1 estiver contida na Lista2.
% -----------------------------------------------------------------------------

e_sublista([], _).
e_sublista([P|Rs], [P|Ts]) :- e_sublista(Rs, Ts).
e_sublista(Rs, [_|Ts]) :- e_sublista(Rs, Ts).

% -----------------------------------------------------------------------------
% nao_altera_linhas_anteriores(Posicoes, L, Ja_Preenchidas). Dada uma lista de
% posicoes que representa a possibilidade de preencher a lista L, e uma lista
% de posicoes Ja_Preenchidas, o predicado sucede se a possibilidade Posicoes
% nao altera as linhas anteriores.
% -----------------------------------------------------------------------------

nao_altera_linhas_anteriores([], _, _).
nao_altera_linhas_anteriores(Posicoes, L, Ja_Preenchidas) :-
  sort(Posicoes, Posicoes_ordenadas),
  append(Linhas_anteriores, [(L, _)|_], Posicoes_ordenadas),
  e_sublista(Linhas_anteriores, Ja_Preenchidas), !.

% -----------------------------------------------------------------------------
% peso_coluna(Posicoes, Coluna, Peso). Dada uma lista de posicoes Posicoes, o numero
% Coluna de uma coluna, Peso e a quantidade de linhas preenchidas nessa coluna.
% -----------------------------------------------------------------------------

peso_coluna(Posicoes, Coluna, Peso) :-
  findall(X, member((X, Coluna), Posicoes), Colunas),
  length(Colunas, Peso).

% -----------------------------------------------------------------------------
% peso_colunas(Posicoes, Dim, Pesos). Dada uma lista de posicoes Posicoes, a
% dimensao Dim de um puzzle, Pesos e a lista do numero de linhas preenchidas por coluna.
% -----------------------------------------------------------------------------

peso_colunas(Posicoes, Dim, Res) :-
  findall(X, (between(1, Dim, I), peso_coluna(Posicoes, I, X)), Res), !.

% -----------------------------------------------------------------------------
% verifica_parcial(Puz, Ja_Preenchidas, Dim, Poss). Dado um puzzle Puz, a lista
% de posicoes Ja_Preenchidas, a dimensao Dim e Poss uma possibilidade para
% preencher uma linha, o predicado sucede se Poss nao viola os totais das colunas.
% -----------------------------------------------------------------------------

verifica_parcial([_, _, Maximos], Ja_Preenchidas, Dim, Poss) :- 
  append(Ja_Preenchidas, Poss, Pre_Posicoes),
  sort(Pre_Posicoes, Posicoes),
  peso_colunas(Posicoes, Dim, Pesos),
  maplist(=<, Pesos, Maximos), !.

% -----------------------------------------------------------------------------
% possibilidade(Puz, Posicoes, Ja_Preenchidas, Possibilidade). Dado um puzzle
% Puz, uma lista de posicoes Posicoes, a lista de posicoes Ja_Preenchidas, entao
% Possibilidade representa uma possibilidade para preencher uma posicao.
% -----------------------------------------------------------------------------

possibilidade(_, [], _, []).
possibilidade([T, Max_L, Max_C], Posicoes, Ja_Preenchidas, Possibilidade) :-
  member((L, C), Posicoes),
  length(Max_L, Dim),
  propaga([T, Max_L, Max_C], (L, C), Posicoes2),
  nao_altera_linhas_anteriores(Posicoes2, L, Ja_Preenchidas),
  verifica_parcial([T, Max_L, Max_C], Ja_Preenchidas, Dim, Posicoes2),
  sort(Posicoes2, Possibilidade).

% -----------------------------------------------------------------------------
% intersecao_propagada(Puz, Linha, Ja_Preenchidas, Intersecao). Dado um puzzle
% Puz, uma linha de posicoes Linha, uma lista de posicoes Ja_Preenchidas, entao
% Intersecao e a lista de todas as posicoes Ja_Preenchidas pertencentes a linha
% propagadas.
% -----------------------------------------------------------------------------

intersecao_propagada(Puz, Linha, Ja_Preenchidas, Intersecao) :-
  intersection(Linha, Ja_Preenchidas, Necessarios),
  findall(X, (
    member(Pos, Necessarios),
    propaga(Puz, Pos, X)
  ), Propagacoes),
  flatten(Propagacoes, Intersecao).

% -----------------------------------------------------------------------------
% junta_a_todos(Lista_De_Listas, A_Juntar, Resultado). Dada uma lista
% de listas Lista_De_Listas, uma lista de itens a juntar A_Juntar, entao
% Resultado e uma lista de listas resultante de juntar cada lista de
% Lista_De_Listas a A_Juntar.
% -----------------------------------------------------------------------------

junta_a_todos(Lista, A_Juntar, Resultado) :-
  member(X, Lista),
  append(X, A_Juntar, Lista_juntada),
  sort(Lista_juntada, Resultado).

% -----------------------------------------------------------------------------
% procura_final(Possibilidades, Possibilidade, Linha, Total). Dada uma
% lista de possibilidades possibilidade, o numero de uma linha Linha e o
% Total de posicoes a preencher da mesma, entao Possibilidade preenche
% validamente a linha.
% -----------------------------------------------------------------------------

procura_final(Posses, Poss, Line, Total) :-
  e_sublista(K, Posses),
  flatten(K, K1),
  sort(K1, Poss),
  findall(X, member((Line, X), Poss), Cols),
  length(Cols, Total).

% -----------------------------------------------------------------------------
% possibilidades_linha(Puz, Posicoes_linha, Total, Ja_Preenchidas, Possibilidades_L).
% Dado um puzzle Puz, uma lista de posicoes da linha a preencher Posicoes_linha,
% o numero total de posicoes a preencher Total, a lista de posicoes ja preenchidas
% Ja_Preenchidas, entao Possibilidades_L e a lista de possibilidades para preencher
% a linha em questao.
% -----------------------------------------------------------------------------

possibilidades_linha(_, _, 0, _, [[]]).
possibilidades_linha(Puz, [(L, C)|K], Total, Ja_Preenchidas, Possibilidades_L) :-
  intersecao_propagada(Puz, [(L, C)|K], Ja_Preenchidas, Necessarios),
  findall(X, possibilidade(Puz, [(L, C)|K], Ja_Preenchidas, X), Posses),
  findall(X, junta_a_todos(Posses, Necessarios, X), Posses3),
  findall(X, procura_final(Posses3, X, L, Total), P3),
  sort(P3, Possibilidades_L), !.

% -----------------------------------------------------------------------------
% linha_aux(Puz, Count, Total, Linha). Dado um puzzle Puzz, o total de
% elementos da linha Total, Linha sao os elementos da linha Linha.
% -----------------------------------------------------------------------------

linha_aux([_, Maximos, _], Count, Total, Linha) :-
  length(Maximos, Dim),
  Numero_Linha is Dim - Count + 1,
  findall((Numero_Linha, X), between(1, Dim, X), Linha),
  nth1(Numero_Linha, Maximos, Total).

% -----------------------------------------------------------------------------
% resolve(Puzz, Solucao). Dado um puzzle Puzz, a sua solucao e Solucao.
%
% resolve(Puzz, Dim, Contagem, Ja_Preenchidas, Solucao). Dado um
% puzzle Puzz, a sua dimensao Dim, a contagem decrescente Contagem, a
% lista de posicoes Ja_Preenchidas, entao Solucao e a sua solucao.
% -----------------------------------------------------------------------------

resolve(_, 0, Sol, Sol).
resolve(Puz, Count, Ja_Preenchidas, Solucao) :-
  linha_aux(Puz, Count, Total, Linha),
  possibilidades_linha(Puz, Linha, Total, Ja_Preenchidas, Possibilidades),
  member(X, Possibilidades),
  append(Ja_Preenchidas, X, Lista_Desordenada),
  sort(Lista_Desordenada, Lista_Ordenada),
  NextCount is Count-1,
  resolve(Puz, NextCount, Lista_Ordenada, Solucao), !.

resolve([Termometros, Max_Linhas, Max_Cols], Solucao) :-
  length(Max_Linhas, Dim),
  resolve([Termometros, Max_Linhas, Max_Cols],  Dim, [], Solucao),
  peso_colunas(Solucao, Dim, Pesos),
  maplist(=<, Pesos, Max_Cols), !.
