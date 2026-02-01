extends Node

# Variables que sobrevivirán al cambio de escena
var posicion_jugador : Vector2
var viene_de_mascara : bool = false

# Agregamos esto:
var vidas : int = 3

# Variable para saber si usamos la skin alternativa
var skin_alternativa : bool = false

var esencias_colectadas : int = 0
