/* 
	Nota: Compilar el código línea a línea para ir viendo los cambios. 
    Primero ir probando en orden (para no eliminar y añadir datos y luego que 
    los datos de los ejemplos no funcionen), unos pequeños ejemplos propuestos (1, 2, 3), 
    y luego hacer las pruebas que se necesiten.
*/

USE kung_fu_panda;


/* EJEMPLO 1: Probar el disparador de fundar */

INSERT INTO practicantes VALUES ("12345678A", "nombre", "primero", "segundo", "2000-01-01");
INSERT INTO estilos(nombre, origen, tipo) VALUES ("nombre", "S", "I");
SET @cod = (SELECT codigo FROM estilos WHERE nombre = "nombre");

-- ver que están vacíos
SELECT * FROM maestros WHERE NIF = "12345678A";
SELECT * FROM entrenamientos WHERE NIF_maestro = "12345678A";

INSERT INTO fundar VALUES ("12345678A", @cod);

-- ver que se han rellenado
SELECT * FROM maestros WHERE NIF = "12345678A";
SELECT * FROM entrenamientos WHERE NIF_maestro = "12345678A";


/* EJEMPLO 2: (FK Error) Insertar un estudiante que no esté apuntado en ningún entrenamiento */

CALL get_0_training();
SET @NIF_estudiante = "00090531L"; 
INSERT INTO estudiantes VALUES (@NIF_estudiante);


/* EJEMPLO 3: (Trigger Error) Apuntar a un estudiante a aprender un estilo del que ya es maestro */

SELECT * FROM entrenamientos;

-- escogemos dos maestros que enseñen un mismo estilo 
SET @NIF_estudiante = "21183912S";
SET @NIF_maestro = "29450841P";
SET @cod = 1;

INSERT INTO guiar VALUES (@NIF_estudiante, @NIF_maestro, @cod);


/* Pruebas del profesor */






