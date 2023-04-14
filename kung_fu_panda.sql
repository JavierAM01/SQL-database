CREATE SCHEMA IF NOT EXISTS Kung_Fu_Panda;
USE Kung_Fu_Panda;


/* ------------------------------------------- CREACIÓN DE TABLAS ------------------------------------------- */
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

CREATE TABLE IF NOT EXISTS guiar (
	NIF_estudiante VARCHAR(9),
	NIF_maestro VARCHAR(9),
    codigo_estilo INT,
    PRIMARY KEY (NIF_estudiante, NIF_maestro, codigo_estilo),
    FOREIGN KEY (NIF_estudiante) REFERENCES practicantes(NIF) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (NIF_maestro, codigo_estilo) REFERENCES entrenamientos(NIF_maestro, codigo_estilo) ON DELETE CASCADE ON UPDATE CASCADE
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


/* ------------------------------------------- FUNCIONES ------------------------------------------- */

SET GLOBAL log_bin_trust_function_creators = 1;
DELIMITER $$

-- hallar los personajes que no están asignados a ningún entrenamiento por el momento
CREATE PROCEDURE get_0_training()
BEGIN
	SELECT * FROM practicantes 
		WHERE NIF NOT IN (SELECT NIF FROM estudiantes) AND NIF NOT IN (SELECT NIF FROM maestros);
END$$

-- hallar el número de entrenamientos que sigue un estudiante
CREATE FUNCTION get_num(var_NIF VARCHAR(9)) RETURNS INT
BEGIN
	RETURN (SELECT COUNT(NIF_estudiante) FROM guiar WHERE NIF_estudiante = var_NIF);
END$$

-- mostrar los estudiantes que siguen un cierto entrenamiento
CREATE PROCEDURE show_students(NIF VARCHAR(9), codigo INT)
BEGIN
	SELECT * FROM practicantes
		WHERE NIF IN (SELECT NIF_estudiante FROM guiar WHERE NIF_maestro = NIF AND codigo_estilo = codigo);
END$$

-- mostrar los estudiantes con más de n entrenamientos
CREATE PROCEDURE students_n(n INT)
BEGIN
	SELECT * FROM practicantes
		WHERE get_num(NIF) > n;
END$$

-- hallar el porcentaje de estudiantes que sigue algún entrenamiento de un estilo sin fundador
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

/* ------------------------------------------- DISPARADORES ------------------------------------------- */

CREATE TRIGGER after_insert_guiar AFTER INSERT ON guiar FOR EACH ROW  # DEFINER = CURRENT_USER
BEGIN
	IF NEW.NIF_estudiante NOT IN (SELECT NIF FROM estudiantes) THEN 
		INSERT INTO estudiantes VALUES (NEW.NIF_estudiante);
	END IF;
END$$


CREATE TRIGGER after_insert_entrenamientos AFTER INSERT ON entrenamientos FOR EACH ROW 
BEGIN
	IF NEW.NIF_maestro NOT IN (SELECT NIF FROM maestros) THEN
		INSERT INTO maestros VALUES (NEW.NIF_maestro);
	END IF;
END$$


CREATE TRIGGER before_insert_fundar BEFORE INSERT ON fundar FOR EACH ROW 
BEGIN
	IF (NEW.NIF_maestro, NEW.codigo_estilo) NOT IN (SELECT NIF_maestro, codigo_estilo FROM entrenamientos) 
			AND
		NEW.codigo_estilo IN (SELECT codigo FROM estilos) 
    THEN
		INSERT INTO entrenamientos VALUES (NEW.NIF_maestro, NEW.codigo_estilo);
	END IF;
END$$


CREATE TRIGGER after_delete_fundar AFTER DELETE ON fundar FOR EACH ROW 
BEGIN
	DELETE FROM entrenamientos WHERE NIF_maestro = OLD.NIF_maestro AND codigo_estilo = OLD.codigo_estilo;
END$$

/* ------------------------------------- DISPARADORES PARA COMPROBAR TUPLAS CON SENTIDO (revisar) ------------------------------------- */

CREATE TRIGGER before_insert_guiar_check BEFORE INSERT ON guiar FOR EACH ROW
BEGIN
	IF NEW.NIF_estudiante LIKE NEW.NIF_maestro THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un maestro no se puede dar clase a sí mismo';
    END IF;
	IF NEW.NIF_estudiante IN (SELECT NIF FROM maestros) THEN
		IF (NEW.codigo_estilo, NEW.NIF_estudiante) IN (SELECT codigo_estilo, NIF_maestro FROM entrenamientos) THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un estudiante no puede entrenar un estilo del que ya es maestro';
		END IF;
	END IF;
END$$


CREATE TRIGGER before_insert_derivar BEFORE INSERT ON derivar FOR EACH ROW 
BEGIN
	IF NEW.codigo_estilo_nuevo LIKE NEW.codigo_estilo_derivador THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un estilo no puede derivar de sí mismo';
    END IF;
	IF (NEW.codigo_estilo_derivador, NEW.codigo_estilo_nuevo) IN (SELECT codigo_estilo_nuevo, codigo_estilo_derivador FROM derivar) THEN 
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Un estilo no puede derivar de uno y a su vez ser derivador de ese mismo';
	END IF;
END$$

DELIMITER ;






