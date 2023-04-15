# SQL-tables

## Pasos para seguir el trabajo:

   1. Ejecutar el script completo 'kung_fu_panda.sql' para crear la base de datos.
   2. Ejecutar el script completo: 'insertar_datos.sql' para rellenar la base de datos.
   3. Abrir 'pruebas.sql' para que el profesor pueda probar y escribir el código que 
  crea necesario para probar la base de datos (seguir los comentarios).



## Esquemas

### Esquema E/R.

\begin{figure}[h!]
	\centering
	\includegraphics[scale=0.75]{imagenes/esquema_ER_final.png}
\end{figure}


En este modelo he supuesto las siguientes características:

 - TIPO: Es una jerarquía parcial solapada. Un practicante puede ser tanto maestro como estudiante a la vez (un maestro que quiera aprender nuevos estilos) y además no todos los practicantes tienen porqué ser de alguno de los dos tipos, pues se puede dar por ejemplo el caso de que un estudiante halla terminado su entrenamiento y esté en proceso de ser maestro, pero en ese momento no es ninguno de los dos (si fuera jerarquía total, en ese momento habría que eliminarlo de practicantes y perderíamos todos sus datos: nombre, apellidos... y tendríamos que volver a pedírselos y añadirlos cuando se haga maestro).
 - PRACTICAR $(N/M)$: Cada maestro tiene que practicar al menos un estilo (obvio, pues de lo contrario de qué sería maestro). Por otro lado, un estilo puede no ser practicado por ningún maestro, en el caso de que fuera antiguo y con el paso del tiempo se haya perdido.
 - FUNDAR $(1/1)$: Cada estilo puede ser fundado por 1 maestro (o ninguno) y cada maestro puede fundar a lo sumo, un estilo, pues este será el que representa su forma de hacer Kung Fu, no tiene sentido que pueda fundar más de un estilo.
 - DERIVAR $(N/M)$: Cada estilo puede derivar de varios otros estilos. Como la mayoría (según mi suposición) no derivan de otros estilos es mejor crear una relación derivar, en vez de tener un atributo “derivados” en la entidad “estilo”, para así poder evitarnos la aparición de muchos nulos. Además, un estilo podría derivar de más de un estilo, por lo que el atributo “derivados” tendría que ser multivaluado, y nos daría problemas a la hora de hacer la tablas.
 - GUIAR $(N/M)$: Cada estudiante sigue mínimo un entrenamiento, de lo contrario no sería estudiante y sería un practicante. Y cada entrenamiento puede ser seguido por varios estudiantes, aunque también se puede dar el caso de que ninguno lo siga, 'clase vacía'.



### Esquema relacional.

Notación: \underline{clave primaria}, \uwave{clave alternativa}.

 - PRACTICANTES (\underline{NIF}, nombre, primer\_apellido, segundo\_apellido, fecha\_nacimiento)
 - ESTILOS (\underline{codigo}, nombre, origen, tipo)
 - ENTRENAMIENTOS (\underline{NIF\_maestro, codigo\_estilo} )
		- entrenamientos(NIF\_maestro) $ \longrightarrow $ practicantes(NIF)
		- entrenamientos(codigo\_estilo) $ \longrightarrow $ estilos(codigo)
 - GUIAR (\underline{NIF\_estudiante, NIF\_maestro, codigo\_estilo})
		- guiar(NIF\_estudiante) $ \longrightarrow $ practicantes(NIF)
		- guiar(NIF\_maestro,codigo\_estilo) $ \longrightarrow $ entrenamientos(NIF\_maestro,codigo\_estilo)
 - ESTUDIANTES (\underline{NIF})
		- estudiantes(NIF) $ \longrightarrow $ guiar(NIF\_estudiante)
 - MAESTROS (\underline{NIF})
		- maestros(NIF) $ \longrightarrow $ entrenamientos(NIF\_maestro)
 - DERIVAR (\underline{codigo\_estilo\_nuevo, codigo\_estilo\_derivador})
		- derivar(codigo\_estilo\_nuevo) $ \longrightarrow $ estilos(codigo)
		- derivar(codigo\_estilo\_derivador) $ \longrightarrow $ estilos(codigo)
 - FUNDAR (\underline{NIF\_maestro}, \uwave{codigo\_estilo})
		- fundar(NIF\_maestro) $ \longrightarrow $ maestros(NIF)
		- fundar(codigo\_estilo) $ \longrightarrow $ estilos(codigo)


En todas las relaciones el borrado y la modificación está puesto en cascade. Los motivos de borrado son claros:

 - Si un practicante se borra de todos sus entrenamientos entonces es obvio que se borrará de estudiantes.
 - Si un maestro se borra de todos los entrenamientos que daba, entonces es obvio que ya no será maestro (esto puede ocurrir si por ejemplo se cambia de aldea y pasa a entrenar en otra escuela, en la nueva seguirá siendo maestro pero aquí ya no tiene sentido que siga siendo maestro si no imparte ninguna clase).
 - Si eliminamos un estilo, entonces se borrarían las respectivas derivaciones, pues ese estilo ya no existiría.
 - En fundar, si ya no existe ese estilo o ese maestro, tampoco tiene sentido la tupla fundar.
 - Análogamente en entrenamientos, si no existen dichos estilos (por que se introdujeron mal los datos o por cualquier motivo) también eliminaremos la respectivas tuplas, pues de lo contrario estaríamos entrenando un estilo que no existe.

y los de modificación seguirían un razonamiento análogo al de borrado.



Para llevar a cabo las tablas he supuesto que, al contrario que el enunciado, la tabla 'PRACTICANTES' puede contener individuos que no estén en ningún entrenamiento. ¿Por qué? El hecho es el siguiente, imaginemos que hay un personaje apuntado a un entrenamiento y cuando lo termina, en el proceso de apuntarse a otro o hacerse maestro, lo eliminamos de 'PRACTICANTES'. Entonces habremos borrado todos sus datos (NIF, nombre, …) y al volverlo a introducir (a lo mejor minutos más tarde) tendríamos que volver a introducir todos sus datos. Por este motivo he querido mantener una tabla 'PRACTICANTES' con todos los datos personales, y luego individualmente según sean 'ESTUDIANTES' o 'MAESTROS' se les va añadiendo a un lado o a otro.


## Tablas

El código que genera las tablas es el siguiente. Lo dividiremos en dos partes.

*Nota: El siguiente código no está escrito en el mismo orden que en el del script SQL, para que se ejecute bien, por motivos de claves ajenas, la tabla guiar se debe ejecutar antes que la de estudiantes (en el script está en el órden correcto) pero aquí lo he separado así para tener una lectura más ordenada.*

### Entidades (y superentidades).

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

### Relaciones

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



## Funciones y procedimientos

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


## Disparadores

Por último definiremos los disparadores, que nos ayudarán mantener nuestra base de datos más dinámica.


 - Después de insertar algún valor en la tabla guiar nos aseguramos de añadirla luego a la tabla estudiantes (el trigger tiene que ser después de la acción pues si no daría un error de foreign key, pues estudiantes(NIF) apunta a guiar(NIF\_estudiante)). Es decir, para no tener que estar insertando valores manualmente cada vez que insertemos en guiar, este disparador nos asegura que todos los practicantes que estén apuntados en algún entrenamiento, estén guardados en la tabla de estudiantes.

```sql
	CREATE TRIGGER after_insert_guiar AFTER INSERT ON guiar FOR EACH ROW
	BEGIN
	IF NEW.NIF_estudiante NOT IN (SELECT NIF FROM estudiantes) THEN 
		INSERT INTO estudiantes VALUES (NEW.NIF_estudiante);
	END IF;
	END$$
```
	
 - Después de insertar valores en la tabla de entrenamientos, si el maestro en cuestión no está en la tabla de maestros, entonces lo añadimos (este trigger daría errores si lo pondríamos antes de la ejecución pues daría un error de foreing key de que maestro(NIF) no 'encuentra' entrenamientos(NIF\_maestro))

```sql
	CREATE TRIGGER after_insert_entrenamientos AFTER INSERT ON entrenamientos FOR EACH ROW 
	BEGIN
	IF NEW.NIF_maestro NOT IN (SELECT NIF FROM maestros) THEN
		INSERT INTO maestros VALUES (NEW.NIF_maestro);
	END IF;
	END$$
```
	
 - Antes de insertar una tupla en la tabla fundar, es decir, introducir que un cierto practicante ha fundado un cierto estilo, añadiríamos antes a la tabla entrenamientos que ese practicante practica ese nuevo estilo (ya que no tendría sentido que no lo practique si él mismo es el que lo ha fundado). Como podemos observar, para que un practicante funde un estilo, este no ha de ser maestro previamente aunque fundar(NIF\_maestro) apunte a maestros(NIF), pues antes de insertar en fundar, este trigger inserta un entrenamiento y otro disparador,'after\_insert\_entrenamientos', inserta el NIF en maestros. Lo que nos asegura que fundar(NIF\_maestro) apunte a maestros(NIF) es, que este proceso se ha ejecutado correctamente y que si hay un practicante en fundar, este está en la tabla maestros también.

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
	
 - Depués de eliminar una tupla de la tabla fundar, eliminamos el entrenamiento que añadimos en su momento al añadir la tupla. Esta acción ha de hacerse después pues en el caso de ser antes, se lanzaría este disparador eliminaría el entrenamiento en cuestión y además la eliminación en cascada de mestros, si solo había ese entrenamiento con ese maestro, eliminaría el maestro de la tabla maestros y por lo tanto, es este mismo momento (y hasta que se ejecute finalmente la acción de eliminar la tupla de fundar) tendríamos que NEW.NIF\_maestro no apunta a ningún maestro, por lo que obtendríamos un error.

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



## Inserción de datos

Finalmente añadimos una serie de datos random para poder probar nuestra base de datos. Para ello creamos la tabla practicantes y los estilos desde la página Mockaroo y apartir de esas dos tablas con un script de python nos rellenamos las demás tablas con sentido, es decir, cumpliendo todas las restricciones impuestas y finalmente generamos una función (en ese mismo script) que nos devuelva un texto para poder introducir todos estos datos por SQL. El código en python sin entrar en detalles sería el siguiente y gracias a él generamos el código en SQL de insertar\_datos.sql.

\begin{figure}[h!]
	\centering
	\includegraphics[width=8cm, height=8cm]{imagenes/python1}
	\includegraphics[width=8cm, height=8cm]{imagenes/python2}
\end{figure}



## Conclusión

En esta base de datos la tabla 'estudiantes' y la tabla 'maestros' no se manipulan manualmente en ningún momento, los disparadores 'after\_insert\_guiar' y 'after\_insert\_entrenamientos' se encangan de eso y además las claves foráneas se encargan de que no se puedan añadir estudiantes ni maestros que no esten ni en la tabla guiar ni entrenamientos respectivamente y por ser borrado en cascada, se tiene que si se eliminar tuplas de guiar o de entrenamientos se eliminarán automaticamente los estudiantes y maestros necesarios. Con el comando: 'call get\_0\_training()' también podemos ver de una forma rápida y fácil los datos de todos los practicantes que no son ni estudiantes ni maestros, y así hacer una valoración individual de si eliminarlos de la base de datos o no. Por último comentar que también al introducir valores en la tabla 'fundar' ya se encarga un disparador de añadir el entrenamiento de ese maestro enseñando el estilo que ha fundado, aunque antes de eso habría que añadir el estilo nuevo a la tabla 'estilos'.
