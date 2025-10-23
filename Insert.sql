--profesores
INSERT INTO PROFESORES (id_profesor,nombre,apellido,especialidad)
VALUES (1111, 'Juan', 'Perez', 'Matematica');

INSERT INTO PROFESORES(id_profesor,nombre,apellido,especialidad)
VALUES(2222,'Sara','Gomez','Literatura');

INSERT INTO PROFESORES(id_profesor,nombre,apellido,especialidad)
VALUES(4444,'Laura','Lopez','Literatura');

INSERT INTO PROFESORES(id_profesor,nombre,apellido,especialidad)
VALUES(3333,'Felipe','Gonzalez','Literatura');

INSERT INTO PROFESORES(id_profesor,nombre,apellido,especialidad)
VALUES(6666,'Andrea','Fernandez','Ingles');

INSERT INTO PROFESORES(id_profesor,nombre,apellido,especialidad)
VALUES(5555,'Juan Martin','Fernandez','Especialidad1');

INSERT INTO PROFESORES(id_profesor,nombre,apellido,especialidad)
VALUES(7777,'Sofia','Rodriguez','Especialidad5');

UPDATE PROFESORES
SET especialidad = 'Ingles'
WHERE id_profesor = 4444;

UPDATE PROFESORES
set especialidad = 'Biologia'
where id_profesor = 3333;

--materias
insert into MATERIAS (id_materia,nombre_materia,creditos)
values 
(501, 'Matematica I', 5),
(502,'Literatura Clasica',3),
(503,'Biologia General', 4),
(504,'Ingles Tecnico',6),
(505,'Literatura Moderna',5);

--estudiantes
insert into ESTUDIANTES(id_estudiante,nombre,apellido,email)
values
(600,'Matias','Martinez','matias@examplo.com'),
(100,	'Ana',	'Blanco',	'ana@example.com'),
(200,	'Luis',	'Gomez',	'luis@example.com'),
(300,	'Carla',	'Diaz',	'carla@example.com'),
(400,	'Mateo',	'Suarez',	'mateo@example.com'),
(500,	'Sofia',	'Torres',	'sofia@example.com');
--cursos
insert into CURSOS	(id_curso,nombre_curso,descripcion,anio,id_profesor,id_materia)
values
(9001,	'Curso Matemática I',	'Básico',	2023,	1111,	501),
(9002,	'Curso Literatura Clásica',	'Teórico',	2024,	2222,	502),
(9003,	'Curso Biología General',	'Experimental',	2025,	3333,	503),
(9004,	'Curso Inglés Técnico',	'Comunicaciones',	2025,	6666,	504),
(9005,	'Curso Literatura Moderna',	'Avanzado',	2025,	2222,	505);

INSERT INTO CURSOS (id_curso,nombre_curso,descripcion,anio,id_profesor,id_materia)
VALUES 
(9107,'Curso Matematica Estadistica','Noctuno',2025,5555,501),
(9108,'Curso Analisis Matematico','Noctuno',2025,7777,501),
(9106,'Curso Matemática I Noche','Noctuno',2025,1111,501);

--inscripciones
insert into INSCRIPCIONES(id_estudiante,id_curso,fecha_inscripcion,nota_teorica,nota_practica)
values

(100,	9001,	'2023-05-10',	7,	9),
(100,	9002,	'2024-06-20',	9,	8),
(200,	9001,	'2023-07-01',	5,	6),
(200,	9003,	'2025-03-12',	8,	9),
(300,	9002,	'2024-04-15',	4,	6),
(300,	9004,	'2025-01-10',	9,	10),
(400,	9003,	'2025-02-01',	6,	7),
(400,	9004,	'2025-02-15',	3,	5),
(500,	9005,	'2025-07-01',	2,	4),
(500,	9004,	'2025-07-10',	10,	10);

insert into INSCRIPCIONES(id_estudiante,id_curso,fecha_inscripcion,nota_teorica,nota_practica)
values
(600,9004,'2025-06-12',10,10),
(100,9004,'2024-05-13',10,10),
(200,9004,'2025-07-14',10,10),
(400,9005, '2023-10-01', 8, 9); 
