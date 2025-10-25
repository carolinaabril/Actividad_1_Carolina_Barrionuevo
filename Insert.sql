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

--agregamos a�o ingreso
UPDATE ESTUDIANTES SET anio_ingreso = 2023 WHERE id_estudiante = 100; 
UPDATE ESTUDIANTES SET anio_ingreso = 2023 WHERE id_estudiante = 200; 
UPDATE ESTUDIANTES SET anio_ingreso = 2024 WHERE id_estudiante = 300; 
UPDATE ESTUDIANTES SET anio_ingreso = 2025 WHERE id_estudiante = 400; 
UPDATE ESTUDIANTES SET anio_ingreso = 2025 WHERE id_estudiante = 500; 
UPDATE ESTUDIANTES SET anio_ingreso = 2025 WHERE id_estudiante = 600; 

--cursos
insert into CURSOS	(id_curso,nombre_curso,descripcion,anio,id_profesor,id_materia)
values
(9001,	'Curso Matem�tica I',	'B�sico',	2023,	1111,	501),
(9002,	'Curso Literatura Cl�sica',	'Te�rico',	2024,	2222,	502),
(9003,	'Curso Biolog�a General',	'Experimental',	2025,	3333,	503),
(9004,	'Curso Ingl�s T�cnico',	'Comunicaciones',	2025,	6666,	504),
(9005,	'Curso Literatura Moderna',	'Avanzado',	2025,	2222,	505);

INSERT INTO CURSOS (id_curso,nombre_curso,descripcion,anio,id_profesor,id_materia)
VALUES 
(9107,'Curso Matematica Estadistica','Noctuno',2025,5555,501),
(9108,'Curso Analisis Matematico','Noctuno',2025,7777,501),
(9106,'Curso Matem�tica I Noche','Noctuno',2025,1111,501);

--inscripciones
insert into INSCRIPCIONES(id_estudiante,id_curso,fecha_inscripcion,nota_teorica_1,nota_practica)
values

(100,	9001,	'2023-05-10',	7,	9),
(100, 	9002,	'2024-06-20',	9,	8),
(200,	9001,	'2023-07-01',	5,	6),
(200,	9003,	'2025-03-12',	8,	9),
(300,	9002,	'2024-04-15',	4,	6),
(300,	9004,	'2025-01-10',	9,	10),
(400,	9003,	'2025-02-01',	6,	7),
(400,	9004,	'2025-02-15',	3,	5),
(500,	9005,	'2025-07-01',	2,	4),
(500,	9004,	'2025-07-10',	10,	10);

insert into INSCRIPCIONES(id_estudiante,id_curso,fecha_inscripcion,nota_teorica_1,nota_practica)
values
(600,9004,'2025-06-12',10,10),
(100,9004,'2024-05-13',10,10),
(200,9004,'2025-07-14',10,10),
(400,9005, '2023-10-01', 8, 9); 

--modificaciones a inscripciones

-- Estudiante 100
UPDATE INSCRIPCIONES SET nota_teorica_2 = 8 WHERE id_estudiante = 100 AND id_curso = 9001;
UPDATE INSCRIPCIONES SET nota_teorica_2 = 9 WHERE id_estudiante = 100 AND id_curso = 9002;
UPDATE INSCRIPCIONES SET nota_teorica_2 = 10 WHERE id_estudiante = 100 AND id_curso = 9004;
-- Estudiante 200
UPDATE INSCRIPCIONES SET nota_teorica_2 = 6 WHERE id_estudiante = 200 AND id_curso = 9001;
UPDATE INSCRIPCIONES SET nota_teorica_2 = 9 WHERE id_estudiante = 200 AND id_curso = 9003;
UPDATE INSCRIPCIONES SET nota_teorica_2 = 10 WHERE id_estudiante = 200 AND id_curso = 9004;
-- Estudiante 300
UPDATE INSCRIPCIONES SET nota_teorica_2 = 7 WHERE id_estudiante = 300 AND id_curso = 9002;
UPDATE INSCRIPCIONES SET nota_teorica_2 = 9 WHERE id_estudiante = 300 AND id_curso = 9004;
-- Estudiante 400
UPDATE INSCRIPCIONES SET nota_teorica_2 = 8 WHERE id_estudiante = 400 AND id_curso = 9003;
UPDATE INSCRIPCIONES SET nota_teorica_2 = 5 WHERE id_estudiante = 400 AND id_curso = 9004;
UPDATE INSCRIPCIONES SET nota_teorica_2 = 9 WHERE id_estudiante = 400 AND id_curso = 9005;
-- Estudiante 500
UPDATE INSCRIPCIONES SET nota_teorica_2 = 3 WHERE id_estudiante = 500 AND id_curso = 9005;
UPDATE INSCRIPCIONES SET nota_teorica_2 = 10 WHERE id_estudiante = 500 AND id_curso = 9004;
-- Estudiante 600
UPDATE INSCRIPCIONES SET nota_teorica_2 = 9 WHERE id_estudiante = 600 AND id_curso = 9004;

--recuperatorios
UPDATE INSCRIPCIONES
SET nota_teorica_recuperatorio = 7
WHERE id_estudiante = 200 AND id_curso = 9001;

UPDATE INSCRIPCIONES
SET nota_teorica_recuperatorio = 6
WHERE id_estudiante = 300 AND id_curso = 9002;

UPDATE INSCRIPCIONES
SET nota_teorica_recuperatorio = 8
WHERE id_estudiante = 400 AND id_curso = 9004;

UPDATE INSCRIPCIONES
SET nota_teorica_recuperatorio = 7
WHERE id_estudiante = 500 AND id_curso = 9005;

-- nota final de alumnos SIN recuperatorio
UPDATE INSCRIPCIONES
SET nota_final = (nota_teorica_1 + nota_teorica_2 + nota_practica) / 3.0
WHERE nota_teorica_recuperatorio IS NULL;

-- nota final de alumnos CON recuperatorio
UPDATE INSCRIPCIONES
SET nota_final = (nota_teorica_1 + nota_teorica_2 + nota_practica + nota_teorica_recuperatorio) / 4.0
WHERE nota_teorica_recuperatorio IS NOT NULL;

--TODAVIA NO INSERTE TODO ESTO!!!!!!
--nuevas tablas
INSERT INTO CUATRIMESTRE(id_cuatrimestre, nombre, fecha_inicio, fecha_fin)
VALUES 
(1,'Cuatrimestre 1 2025','2025-03-01','2025-06-30'),
(2,'Cuatrimestre 2 2025','2025-07-01','2025-10-31');

INSERT INTO MATRICULACION(id_matricula, id_estudiante, anio, fecha_pago, monto, id_estado_pago)
VALUES
(1,100,2025,'2025-03-01',5000,2),
(2,200,2025,'2025-03-02',5000,2);


-- factura
INSERT INTO FACTURA(id_factura, id_estudiante, mes, anio, fecha_emision, fecha_vencimiento, monto_total, id_estado_pago)
VALUES
(1,100,3,2025,'2025-03-01','2025-03-15',1000,1),
(2,200,3,2025,'2025-03-01','2025-03-15',1000,1);

-- cuotas
INSERT INTO CUOTA(id_cuota, id_estudiante, id_cuatrimestre, id_factura, mes, monto, fecha_vencimiento, id_estado_pago)
VALUES
(1,100,1,1,3,1000,'2025-03-15',1),
(2,200,1,2,3,1000,'2025-03-15',1);

-- item factura
INSERT INTO ITEMFACTURA(id_factura, id_curso)
VALUES
(1,9001),
(2,9003);

INSERT INTO CUENTACORRIENTE(id_movimiento, id_estudiante, fecha, concepto, monto, id_estado_pago)
VALUES
(1,100,'2025-03-01','Matr�cula',5000,2),
(2,100,'2025-03-01','Cuota marzo',1000,1),
(3,200,'2025-03-01','Matr�cula',5000,2),
(4,200,'2025-03-01','Cuota marzo',1000,1);

INSERT INTO INTERESPORMORA(anio_carrera, porcentaje_interes)
VALUES
(1,2.5),
(2,2.0),
(3,1.5);

