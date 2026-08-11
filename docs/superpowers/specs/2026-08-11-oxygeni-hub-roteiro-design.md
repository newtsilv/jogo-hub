# Oxygeni Hub Roteiro Design

## Objetivo

Implementar o roteiro "Oxygeni Hub: Jornada da Faixa Branca" no fluxo atual de NPCs, diálogos, perguntas e recompensas.

## Fluxo

O jogador começa com Gabriel, que apresenta a jornada e explica os três pins. Gabriel não entrega pin e não faz perguntas.

Depois, o jogador segue para Emanuel, Laura e MB/Marcos Barros, nessa ordem. Emanuel representa Incode, Laura representa TechX e MB representa Oxygeni Hub.

## Perguntas

A interface atual possui três botões de resposta. As perguntas do roteiro serão mantidas, mas cada uma terá uma alternativa errada removida para caber no layout atual.

## Recompensas

Emanuel entrega o Pin Incode. Laura entrega o Pin TechX. MB entrega o Pin Hub. O comportamento de erro permanece como está no jogo: erro leva ao game over.

## Escopo

Não será criado um quarto botão de resposta. Não será implementada repetição automática de perguntas ao errar.
