import pandas as pd
import numpy as np

main_path = "D:/Grado de Matemáticas/3º UCM/1º cuatrimestre/Bases de Datos (4º)/Trabajo Kung Fu Panda/base_de_datos/"
f1 = "practicantes.csv"
f2 = "estilos.csv"

practicantes = pd.read_csv(f1)
estilos = pd.read_csv(f2)
estilos["codigo"] += 1

np.random.seed(99)

# -------------------------------
entrenamientos = []
maestros = []
d_entrena = {}
for i in range(80):
	nif, cod = np.random.choice(practicantes["NIF"]), np.random.choice(estilos["codigo"])
	if d_entrena.get(nif) == None:
		d_entrena[nif] = [cod]
	else:
		d_entrena[nif].append(cod)
for nif in d_entrena:
	d_entrena[nif] = list(set(d_entrena[nif]))
	for cod in d_entrena[nif]:
		maestros.append(nif)
		entrenamientos.append([nif, cod])

maestros = list(set(maestros))

# -------------------------------
fundar = []
nifs = np.random.choice(maestros, 15)
cods = np.random.choice(estilos["codigo"], 15)
nifs = list(set(nifs))
cods = list(set(cods))
n_min = min(len(nifs), len(cods))
d_fundar = {}
for i in range(n_min):
	nif, cod = nifs[i], cods[i]
	fundar.append([nif, cod])
	if d_fundar.get(nif) == None:
		d_fundar[nif] = [cod]
	else:
		d_fundar[nif].append(cod)

# -------------------------------
derivar = []
cods = [np.random.choice(estilos["codigo"]) for i in range(10)]
cods  = list(set(cods))
if len(cods) % 2 != 0: cods = cods[:-1]
derivar = [[cods[2*i], cods[2*i+1]] for i in range(int(len(cods)/2))]

# -------------------------------
guiar = []
nif_estudiantes = np.random.choice(practicantes["NIF"], 200)
entrenas_index = np.random.randint(0, len(entrenamientos), 200)
entrenas = [entrenamientos[i] for i in entrenas_index]  

d = {}
for i in range(200):
	if d.get(str(entrenas[i])) == None:
		d[str(entrenas[i])] = [nif_estudiantes[i]]
	else:
		d[str(entrenas[i])].append(nif_estudiantes[i])
for entrena in d:
	for NIF_est in set(d[entrena]):
		s = entrena.split("'")
		nif_mae, cod = s[1], int(s[2][1:-1])
		if d_entrena.get(NIF_est) != None:
			if cod in d_entrena[NIF_est]:
				continue
		if d_fundar.get(NIF_est) != None:
			if cod in d_fundar[NIF_est]:
				continue
		if NIF_est != nif_mae:
			guiar.append([NIF_est, nif_mae, cod])

def insert_df_in_SQL(df, table, integers=[], drop=False):
	insert = ""
	insert += f"INSERT INTO {table} VALUES"
	for i in range(len(df)):
		string = ""
		for j in range(len(df[0])): 
			if drop and j == 0:
				continue
			if j in integers:
				string += str(df[i][j]) + ","
			else:
				string += '"' + str(df[i][j]) + '",'
		string = string[:-1]
		insert += f"\n\t({string}),"
	insert = insert[:-1]
	insert += "\n;"
	print(insert)

def insert_list_in_SQL(lista, table):
	insert = ""
	insert += f"INSERT INTO {table} VALUES "
	for i in range(len(lista)):
		insert += f'\n\t("{lista[i]}"),'
	insert = insert[:-1]
	insert += "\n;"
	print(insert)

insert_df_in_SQL(practicantes.values, "practicantes")
insert_df_in_SQL(estilos.values, "estilos(nombre,origen,tipo)", [0], True)
insert_df_in_SQL(fundar, "fundar", [1])
insert_df_in_SQL(derivar, "derivar", [0,1])
insert_df_in_SQL(entrenamientos, "entrenamientos", [1])
insert_df_in_SQL(guiar, "guiar", [2])
