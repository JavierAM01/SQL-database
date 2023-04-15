# SQL-tables


## Índice 

 - [Enunciado](#id0)
 - [Pasos a seguir](#id1)
 - [Esquemas](#id2)
	 - [Esquema E/R](#id2.1)
	 - [Esquema Relacional](#id2.2)
 - [Tablas](#id3)
	 - [Entidades (y superentidades)](#id3.1)
	 - [Relaciones](#id3.2)
 - [Funciones y procedimientos](#id4)
 - [Disparadores](#id5)
 - [Inserción de datos](#id6)
 - [Conclusión](#id7)


## Enunciado <a name=id0></a>

El Kung Fu es un arte milenario chino que engloba todos los aspectos
de la defensa personal y el manejo de las armas, basado en principios filosófos budistas y taoístas. El
maestro de Kung Fu Shifu se encarga de entrenar a los grandes luchadores de su territorio incluyendo
los famosos Cinco Furiosos (Tigresa, Víbora, Grulla, Mono y Mantis).
Recientemente, el Maestro Oogway ha designado al Panda Po como Guerrero del Dragón, lo que
le ha liberado de sus deberes como aprendiz de fabricante de fideos en el restaurante de su padre. Esto
ha provocado un gran incremento en el número de solicitudes de admisión en la escuela de Shifu, lo
que hace urgente diseñar una base de datos que permita a los maestros de Kung Fu consultar de forma
eficiente la información de sus alumnos:

 1. Los practicantes se registran en la base de datos indicando su NIF, nombre, apellido y fecha
de nacimiento. Estos se clasifican en estudiantes, los cuales no han perseverado lo suficiente
en la práctica del Kung Fu, y maestros, que han alcanzado el nivel de perfección necesario para
compartir sus conocimientos.

 2. El Kung Fu se compone de una enorme variedad de estilos, haciendo de él una de las disciplinas
marciales más completas al comprender todo tipo de técnicas, tanto de brazos como de piernas y
ya sea sin armas o con ellas. Esto lo diferencia de otros sistemas de lucha que se han especializado
limitando el uso de las técnicas. Cada estilo se identifica mediante un código numérico y posee
un nombre único dentro del sistema. Los estilos se pueden clasificar según su origen geográfico
en estilos del norte y estilos del sur. También se pueden dividir atendiendo al tipo de técnicas
que emplean en estilos internos o estilos externos, aunque algunos de ellos combinan todas ellas.
Por ejemplo, el estilo de la Grulla Blanca procede del sur de China y es un estilo externo, ya que
en él predomina el uso de las técnicas fuertes.

 3. Ciertos estilos de Kung Fu incorporan los mejores aspectos de otros, considerándose derivados.
Por ejemplo, el estilo de la Mantis Religiosa deriva del estilo Shaolín e incluye la técnica de pies
del estilo Mono. Asimismo, existen seis variaciones del estilo Mono, entre las que podemos citar
el estilo del Mono Borracho y el estilo del Mono Perdido.

 4. Se desconoce el origen histórico de algunos estilos, sin embargo se sabe que otros fueron fundados
por importantes maestros de Kung Fu. Por ejemplo, la monja budista Ng Mui ideó el estilo Wing
Chun inspirada por una escena de combate entre una serpiente y una grulla. Para ello, tomó de la
grulla su calma, suavidad y sentido del equilibrio, e incorporó de los movimientos de la serpiente
su direccionalidad y ataque recto.

 5. Los practicantes de Kung Fu practican al menos uno de los estilos almacenados en el sistema.
Los maestros guían a otros practicantes, entrenándolos en los estilos que ellos mismos practican,
entre los cuales se incluyen los que han fundado. Por ejemplo, la maestra Ng Mui practica los
estilos Gung Fu y Wing Chun, transmitiendo ambos a su alumno Leung Bok Chau.



## Pasos a seguir <a name=id1></a>

   1. Ejecutar el script completo *kung_fu_panda.sql* para crear la base de datos.
   2. Ejecutar el script completo: *insertar_datos.sql* para rellenar la base de datos.
   3. Abrir *pruebas.sql* para que el profesor pueda probar y escribir el código que 
  crea necesario para probar la base de datos (seguir los comentarios).



## Esquemas <a name=id2></a>

### Esquema E/R <a name=id2.1></a>

<image src="images/esquema_ER_final.png">


En este modelo he supuesto las siguientes características:

 - TIPO: Es una jerarquía parcial solapada. Un practicante puede ser tanto maestro como estudiante a la vez (un maestro que quiera aprender nuevos estilos) y además no todos los practicantes tienen porqué ser de alguno de los dos tipos, pues se puede dar por ejemplo el caso de que un estudiante halla terminado su entrenamiento y esté en proceso de ser maestro, pero en ese momento no es ninguno de los dos (si fuera jerarquía total, en ese momento habría que eliminarlo de practicantes y perderíamos todos sus datos: nombre, apellidos... y tendríamos que volver a pedírselos y añadirlos cuando se haga maestro).
 - PRACTICAR $(N/M)$: Cada maestro tiene que practicar al menos un estilo (obvio, pues de lo contrario de qué sería maestro). Por otro lado, un estilo puede no ser practicado por ningún maestro, en el caso de que fuera antiguo y con el paso del tiempo se haya perdido.
 - FUNDAR $(1/1)$: Cada estilo puede ser fundado por 1 maestro (o ninguno) y cada maestro puede fundar a lo sumo, un estilo, pues este será el que representa su forma de hacer Kung Fu, no tiene sentido que pueda fundar más de un estilo.
 - DERIVAR $(N/M)$: Cada estilo puede derivar de varios otros estilos. Como la mayoría (según mi suposición) no derivan de otros estilos es mejor crear una relación derivar, en vez de tener un atributo *derivados* en la entidad *estilo*, para así poder evitarnos la aparición de muchos nulos. Además, un estilo podría derivar de más de un estilo, por lo que el atributo *derivados* tendría que ser multivaluado, y nos daría problemas a la hora de hacer la tablas.
 - GUIAR $(N/M)$: Cada estudiante sigue mínimo un entrenamiento, de lo contrario no sería estudiante y sería un practicante. Y cada entrenamiento puede ser seguido por varios estudiantes, aunque también se puede dar el caso de que ninguno lo siga, *clase vacía*.



### Esquema Relacional <a name=id2.2></a>

Notación: **clave primaria**, *clave alternativa*.

 - PRACTICANTES (**NIF**, nombre, primer_apellido, segundo_apellido, fecha_nacimiento)
 - ESTILOS (**codigo**, nombre, origen, tipo)
 - ENTRENAMIENTOS (**NIF_maestro, codigo_estilo**)
	- entrenamientos(NIF_maestro) $\longrightarrow$ practicantes(NIF)
	- entrenamientos(codigo_estilo) $\longrightarrow$ estilos(codigo)
 - GUIAR (**NIF_estudiante, NIF_maestro, codigo_estilo**)
	- guiar(NIF_estudiante) $\longrightarrow$ practicantes(NIF)
	- guiar(NIF_maestro,codigo_estilo) $\longrightarrow$ entrenamientos(NIF\_maestro,codigo\_estilo)
 - ESTUDIANTES (**NIF**)
	- estudiantes(NIF) $\longrightarrow$ guiar(NIF\_estudiante)
 - MAESTROS (**NIF**)
	- maestros(NIF) $\longrightarrow$ entrenamientos(NIF\_maestro)
 - DERIVAR (**codigo_estilo_nuevo, codigo_estilo_derivador**)
	- derivar(codigo_estilo_nuevo) $\longrightarrow$ estilos(codigo)
	- derivar(codigo_estilo_derivador) $\longrightarrow$ estilos(codigo)
 - FUNDAR (**NIF_maestro**, *codigo_estilo*)
	- fundar(NIF_maestro) $\longrightarrow$ maestros(NIF)
	- fundar(codigo_estilo) $\longrightarrow$ estilos(codigo)


En todas las relaciones el borrado y la modificación está puesto en cascade. Los motivos de borrado son claros:

 - Si un practicante se borra de todos sus entrenamientos entonces es obvio que se borrará de estudiantes.
 - Si un maestro se borra de todos los entrenamientos que daba, entonces es obvio que ya no será maestro (esto puede ocurrir si por ejemplo se cambia de aldea y pasa a entrenar en otra escuela, en la nueva seguirá siendo maestro pero aquí ya no tiene sentido que siga siendo maestro si no imparte ninguna clase).
 - Si eliminamos un estilo, entonces se borrarían las respectivas derivaciones, pues ese estilo ya no existiría.
 - En fundar, si ya no existe ese estilo o ese maestro, tampoco tiene sentido la tupla fundar.
 - Análogamente en entrenamientos, si no existen dichos estilos (por que se introdujeron mal los datos o por cualquier motivo) también eliminaremos la respectivas tuplas, pues de lo contrario estaríamos entrenando un estilo que no existe.

y los de modificación seguirían un razonamiento análogo al de borrado.



Para llevar a cabo las tablas he supuesto que, al contrario que el enunciado, la tabla 'PRACTICANTES' puede contener individuos que no estén en ningún entrenamiento. ¿Por qué? El hecho es el siguiente, imaginemos que hay un personaje apuntado a un entrenamiento y cuando lo termina, en el proceso de apuntarse a otro o hacerse maestro, lo eliminamos de *PRACTICANTES*. Entonces habremos borrado todos sus datos (NIF, nombre, ...) y al volverlo a introducir (a lo mejor minutos más tarde) tendríamos que volver a introducir todos sus datos. Por este motivo he querido mantener una tabla *PRACTICANTES* con todos los datos personales, y luego individualmente según sean *ESTUDIANTES* o *MAESTROS* se les va añadiendo a un lado o a otro.


## Tablas <a name=id3></a>

El código que genera las tablas es el siguiente. Lo dividiremos en dos partes.

*Nota: El siguiente código no está escrito en el mismo orden que en el del script SQL, para que se ejecute bien, por motivos de claves ajenas, la tabla guiar se debe ejecutar antes que la de estudiantes (en el script está en el órden correcto) pero aquí lo he separado así para tener una lectura más ordenada.*

### Entidades (y superentidades) <a name=id3.1></a>

```sql
CREATE TABLE IF NOT EXISTS practicantes (
	NIF VARCHAR(9),
	nombre VARCHAR(40) NOT NULL,
	primer_apellido VARCHAR(40) NOT NULL,
	segundo_apellido VARCHAR(40) NOT NULL,
	fecha_nacimiento DATE NOT NULL,
	PRIMARY KEY (NIF)
);

CREATE TABLE IF NOT EXISTS estilos (
	codigo INT AUTO_INCREMENT,
	nombre VARCHAR(40) NOT NULL UNIQUE,
	origen ENUM('S','N') NOT NULL, -- S = sur, N = norte
	tipo ENUM('I','E','IE') NOT NULL, -- I = interno, E = externo, IE = ambos estilos (interno y externo).
	PRIMARY KEY (codigo)
);

CREATE TABLE IF NOT EXISTS entrenamientos (
	NIF_maestro VARCHAR(9),
	codigo_estilo INT,
	PRIMARY KEY (NIF_maestro, codigo_estilo),
	FOREIGN KEY (NIF_maestro) REFERENCES practicantes(NIF) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (codigo_estilo) REFERENCES estilos(codigo) ON DELETE CASCADE ON UPDATE CASCADE	
);

CREATE TABLE IF NOT EXISTS estudiantes (
	NIF VARCHAR(9),
	PRIMARY KEY (NIF),
	FOREIGN KEY (NIF) REFERENCES guiar(NIF_estudiante) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS maestros (
	NIF VARCHAR(9),
	PRIMARY KEY (NIF),
	FOREIGN KEY (NIF) REFERENCES entrenamientos(NIF_maestro) ON DELETE CASCADE ON UPDATE CASCADE
);
```

### Relaciones <a name=id3.2></a>

```sql
CREATE TABLE IF NOT EXISTS guiar (
	NIF_estudiante VARCHAR(9),
	NIF_maestro VARCHAR(9),
	codigo_estilo INT,
	PRIMARY KEY (NIF_estudiante, NIF_maestro, codigo_estilo),
	FOREIGN KEY (NIF_estudiante) REFERENCES practicantes(NIF) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (NIF_maestro,codigo_estilo) REFERENCES entrenamientos(NIF_maestro,codigo_estilo) 
	ON DELETE CASCADE ON UPDATE CASCADE
);
	
CREATE TABLE IF NOT EXISTS derivar (
	codigo_estilo_nuevo INT,
	codigo_estilo_derivador INT,
	PRIMARY KEY (codigo_estilo_nuevo, codigo_estilo_derivador),
	FOREIGN KEY (codigo_estilo_nuevo) REFERENCES estilos(codigo) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (codigo_estilo_derivador) REFERENCES estilos(codigo) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS fundar (
	NIF_maestro VARCHAR(9),
	codigo_estilo INT,
	PRIMARY KEY (NIF_maestro),
	UNIQUE (codigo_estilo),
	FOREIGN KEY (NIF_maestro) REFERENCES maestros(NIF) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (codigo_estilo) REFERENCES estilos(codigo) ON DELETE CASCADE ON UPDATE CASCADE
);
```



## Funciones y procedimientos <a name=id4></a>

Por otro lado tenemos una serie de funciones para poder sacar información de nuestra base de datos. El código en SQL para crear estas funciones es el siguiente. Primero redefinimos DELIMITER para poder utilizar el punto y coma en el interior de las funciones, procedimientos y triggers y al final de sus definiciones lo volvemos a redefinir.

```sql
DELIMITER $$
```

Ahora iremos definiendo una por una las funciones y procedimientos creados:

 - Hallar los personajes que no son ni maestros ni están asignados a ningún entrenamiento por el momento:

```sql
CREATE PROCEDURE get_0_training()
	BEGIN
	SELECT * FROM practicantes 
		WHERE NIF NOT IN (SELECT NIF FROM estudiantes) AND NIF NOT IN (SELECT NIF FROM maestros);
	END$$
```

 - Hallar el número de entrenamientos que sigue un estudiante:
	
```sql
CREATE FUNCTION get_num(var_NIF VARCHAR(9)) RETURNS INT
	BEGIN
	RETURN (SELECT COUNT(NIF_estudiante) FROM guiar WHERE NIF_estudiante = var_NIF);
	END$$
```

 - Mostrar los estudiantes que siguen un cierto entrenamiento:
	
```sql
CREATE PROCEDURE show_students(NIF VARCHAR(9), codigo INT)
	BEGIN
	SELECT * FROM practicantes
		WHERE NIF IN (SELECT NIF_estudiante FROM guiar WHERE NIF_maestro = NIF AND codigo_estilo = codigo);
	END$$
```

 - Mostrar los estudiantes con más de $ n $ entrenamientos:
	
```sql
CREATE PROCEDURE students_n(n INT)
	BEGIN
	SELECT * FROM practicantes
		WHERE get_num(NIF) > n;
	END$$
```

 - Hallar el porcentaje de estudiantes que sigue algún entrenamiento de un estilo sin fundador:
	
```sql
CREATE FUNCTION get_percentage_no_founder() RETURNS FLOAT
	BEGIN
	DECLARE n INT;
	DECLARE total INT;
	DECLARE p FLOAT;
	SET n = (SELECT COUNT(NIF_estudiante) FROM 
				(SELECT DISTINCT NIF_estudiante FROM guiar 
					WHERE codigo_estilo NOT IN (SELECT DISTINCT codigo_estilo FROM fundar)) AS T);
	SET total = (SELECT COUNT(NIF) FROM estudiantes);
	SET p = n/total;
	RETURN p;
	END$$
```


## Disparadores <a name=id5></a>

Por último definiremos los disparadores, que nos ayudarán mantener nuestra base de datos más dinámica.


 - Después de insertar algún valor en la tabla guiar nos aseguramos de añadirla luego a la tabla estudiantes (el trigger tiene que ser después de la acción pues si no daría un error de foreign key, pues estudiantes(NIF) apunta a guiar(NIF_estudiante)). Es decir, para no tener que estar insertando valores manualmente cada vez que insertemos en guiar, este disparador nos asegura que todos los practicantes que estén apuntados en algún entrenamiento, estén guardados en la tabla de estudiantes.

```sql
	CREATE TRIGGER after_insert_guiar AFTER INSERT ON guiar FOR EACH ROW
	BEGIN
	IF NEW.NIF_estudiante NOT IN (SELECT NIF FROM estudiantes) THEN 
		INSERT INTO estudiantes VALUES (NEW.NIF_estudiante);
	END IF;
	END$$
```
	
 - Después de insertar valores en la tabla de entrenamientos, si el maestro en cuestión no está en la tabla de maestros, entonces lo añadimos (este trigger daría errores si lo pondríamos antes de la ejecución pues daría un error de foreing key de que maestro(NIF) no 'encuentra' entrenamientos(NIF_maestro))

```sql
	CREATE TRIGGER after_insert_entrenamientos AFTER INSERT ON entrenamientos FOR EACH ROW 
	BEGIN
	IF NEW.NIF_maestro NOT IN (SELECT NIF FROM maestros) THEN
		INSERT INTO maestros VALUES (NEW.NIF_maestro);
	END IF;
	END$$
```
	
 - Antes de insertar una tupla en la tabla fundar, es decir, introducir que un cierto practicante ha fundado un cierto estilo, añadiríamos antes a la tabla entrenamientos que ese practicante practica ese nuevo estilo (ya que no tendría sentido que no lo practique si él mismo es el que lo ha fundado). Como podemos observar, para que un practicante funde un estilo, este no ha de ser maestro previamente aunque fundar(NIF_maestro) apunte a maestros(NIF), pues antes de insertar en fundar, este trigger inserta un entrenamiento y otro disparador,*after_insert_entrenamientos*, inserta el NIF en maestros. Lo que nos asegura que fundar(NIF_maestro) apunte a maestros(NIF) es, que este proceso se ha ejecutado correctamente y que si hay un practicante en fundar, este está en la tabla maestros también.

	Este disparador se lanza si ya existe dicho estilo (para no añadir un entrenamiento antes de lanzar un error y cambiar datos) y obviamente si dicho entrenamiento no está ya añadido en la tabla entrenamientos (que quien manipule la base de datos no sepa que eso era automático y lo haya añadido antes manualmente).

```sql
CREATE TRIGGER before_insert_fundar BEFORE INSERT ON fundar FOR EACH ROW 
	BEGIN
	IF (NEW.NIF_maestro, NEW.codigo_estilo) NOT IN 
		(SELECT NIF_maestro, codigo_estilo FROM entrenamientos) 
			AND codigo_estilo IN (SELECT codigo FROM estilos) THEN
				INSERT INTO entrenamientos VALUES (NEW.NIF_maestro, NEW.codigo_estilo);
	END IF;
	END$$
```
	
 - Depués de eliminar una tupla de la tabla fundar, eliminamos el entrenamiento que añadimos en su momento al añadir la tupla. Esta acción ha de hacerse después pues en el caso de ser antes, se lanzaría este disparador eliminaría el entrenamiento en cuestión y además la eliminación en cascada de mestros, si solo había ese entrenamiento con ese maestro, eliminaría el maestro de la tabla maestros y por lo tanto, es este mismo momento (y hasta que se ejecute finalmente la acción de eliminar la tupla de fundar) tendríamos que NEW.NIF_maestro no apunta a ningún maestro, por lo que obtendríamos un error.

```sql
	CREATE TRIGGER after_delete_fundar AFTER DELETE ON fundar FOR EACH ROW 
	BEGIN
	DELETE FROM entrenamientos WHERE NIF_maestro = OLD.NIF_maestro AND codigo_estilo = OLD.codigo_estilo;
	END$$
```
	
 - Antes de insertar en guiar nos aseguramos de que el estudiante no se apunte a aprender un estilo del cual ya es maestro y de que no se de clase a sí mismo (esto último se podría hacer con un check en la propia tabla, pero razones de SQL y que ya había claves foráneas no se podía (Error code: 3823)).

```sql
CREATE TRIGGER before_insert_guiar_check BEFORE INSERT ON guiar FOR EACH ROW
	BEGIN
	IF NEW.NIF_estudiante LIKE NEW.NIF_maestro THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un maestro no se puede dar clase a sí mismo';
	END IF;
	IF NEW.NIF_estudiante IN (SELECT NIF FROM maestros) THEN
		IF (NEW.codigo_estilo, NEW.NIF_estudiante) IN 
			(SELECT codigo_estilo, NIF_maestro FROM entrenamientos) THEN
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 
				'Un estudiante no puede entrenar un estilo del que ya es maestro';
		END IF;
	END IF;
	END$$
```
	
 - Antes de insertar en derivar, vemos que tenga sentido la tupla introducida, es decir, que un estilo no puede derivar de uno y a su vez ser derivador de ese mismo y tampoco, obviamente, derivar de sí mismo.

```sql
CREATE TRIGGER before_insert_derivar BEFORE INSERT ON derivar FOR EACH ROW 
	BEGIN
	IF NEW.codigo_estilo_nuevo LIKE NEW.codigo_estilo_derivador THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un estilo no puede derivar de sí mismo';
	END IF;
	IF (NEW.codigo_estilo_derivador, NEW.codigo_estilo_nuevo) IN 
		(SELECT codigo_estilo_nuevo, codigo_estilo_derivador FROM derivar) THEN 
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 
				'Un estilo no puede derivar de uno y a su vez ser derivador de ese mismo';
	END IF;
	END$$
```



## Inserción de datos <a name=id6></a>

Finalmente añadimos una serie de datos random para poder probar nuestra base de datos. Para ello creamos la tabla practicantes y los estilos desde la página <a href="https://www.mockaroo.com/">mockaroo</a> y apartir de esas dos tablas, con un script de python, nos rellenamos las demás tablas con sentido, es decir, cumpliendo todas las restricciones impuestas y finalmente generamos una función (en ese mismo script) que nos devuelva un texto para poder introducir todos estos datos por SQL. El código en python sin entrar en detalles sería el siguiente y gracias a él generamos el código en SQL de *insertar_datos.sql*.

```python
import pandas as pd
import numpy as np

main_path = "data/"
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
```



## Conclusión <a name=id7></a>

En esta base de datos la tabla *estudiantes* y la tabla *maestros* no se manipulan manualmente en ningún momento, los disparadores *after_insert_guiar* y *after_insert_entrenamientos* se encangan de eso y además las claves foráneas se encargan de que no se puedan añadir estudiantes ni maestros que no esten ni en la tabla guiar ni entrenamientos respectivamente y por ser borrado en cascada, se tiene que si se eliminar tuplas de guiar o de entrenamientos se eliminarán automaticamente los estudiantes y maestros necesarios. Con el comando: *call get_0_training()* también podemos ver de una forma rápida y fácil los datos de todos los practicantes que no son ni estudiantes ni maestros, y así hacer una valoración individual de si eliminarlos de la base de datos o no. Por último comentar que también al introducir valores en la tabla *fundar* ya se encarga un disparador de añadir el entrenamiento de ese maestro enseñando el estilo que ha fundado, aunque antes de eso habría que añadir el estilo nuevo a la tabla *estilos*.
