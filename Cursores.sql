-- ===========================================
-- CURSORES (LISTADOS)
-- ===========================================

/* 1) listar todos los estudiantes y sus notas finales por curso */
IF OBJECT_ID('dbo.sp_EstudiantesNotasFinalesPorCurso') IS NOT NULL
  DROP PROCEDURE dbo.sp_EstudiantesNotasFinalesPorCurso;
GO
CREATE PROCEDURE dbo.sp_EstudiantesNotasFinalesPorCurso
AS
BEGIN
  SET NOCOUNT ON;

  IF OBJECT_ID('tempdb..#Notas') IS NOT NULL DROP TABLE #Notas;
  CREATE TABLE #Notas(
    id_curso INT,
    nombre_curso VARCHAR(200),
    id_estudiante INT,
    nombre VARCHAR(200),
    apellido VARCHAR(200),
    nota_final DECIMAL(5,2)
  );

  DECLARE @id_curso INT, @nombre_curso VARCHAR(200);

  DECLARE cur CURSOR FOR
    SELECT id_curso, nombre_curso FROM Curso;

  OPEN cur;
  FETCH NEXT FROM cur INTO @id_curso, @nombre_curso;
  WHILE @@FETCH_STATUS = 0
  BEGIN
    INSERT INTO #Notas
    SELECT @id_curso, @nombre_curso, e.id_estudiante, e.nombre, e.apellido, i.nota_final
    FROM Inscripcion i
    INNER JOIN Estudiante e ON e.id_estudiante = i.id_estudiante
    WHERE i.id_curso = @id_curso;

    FETCH NEXT FROM cur INTO @id_curso, @nombre_curso;
  END
  CLOSE cur; DEALLOCATE cur;

  SELECT * FROM #Notas ORDER BY id_curso, apellido, nombre;
END
GO

/* 2) historial de pagos de cada estudiante */
IF OBJECT_ID('dbo.sp_HistorialPagosPorEstudiante') IS NOT NULL
  DROP PROCEDURE dbo.sp_HistorialPagosPorEstudiante;
GO
CREATE PROCEDURE dbo.sp_HistorialPagosPorEstudiante
AS
BEGIN
  SET NOCOUNT ON;

  IF OBJECT_ID('tempdb..#Pagos') IS NOT NULL DROP TABLE #Pagos;
  CREATE TABLE #Pagos(
    id_estudiante INT,
    nombre VARCHAR(200),
    apellido VARCHAR(200),
    tipo VARCHAR(20),
    id_doc INT,
    anio INT NULL,
    mes INT NULL,
    fecha_emision DATE NULL,
    fecha_vencimiento DATE NULL,
    monto DECIMAL(12,2) NULL,
    estado_pago VARCHAR(50) NULL
  );

  DECLARE @id_est INT, @nom VARCHAR(200), @ape VARCHAR(200);

  DECLARE cur CURSOR FOR
    SELECT id_estudiante, nombre, apellido FROM Estudiante;

  OPEN cur;
  FETCH NEXT FROM cur INTO @id_est, @nom, @ape;
  WHILE @@FETCH_STATUS = 0
  BEGIN
    INSERT INTO #Pagos
    SELECT @id_est, @nom, @ape, 'FACTURA', f.id_factura, f.anio, f.mes,
           f.fecha_emision, f.fecha_vencimiento, f.monto_total, f.estado_pago
    FROM Factura f
    WHERE f.id_estudiante = @id_est;

    INSERT INTO #Pagos
    SELECT @id_est, @nom, @ape, 'CUOTA', c.id_cuota, NULL, c.mes,
           NULL, c.fecha_vencimiento, c.monto, c.estado_pago
    FROM Cuota c
    WHERE c.id_estudiante = @id_est;

    FETCH NEXT FROM cur INTO @id_est, @nom, @ape;
  END
  CLOSE cur; DEALLOCATE cur;

  SELECT * FROM #Pagos
  ORDER BY id_estudiante, tipo, anio, mes, fecha_emision, fecha_vencimiento;
END
GO

/* 3) Materias con sus profesores y cursos */
IF OBJECT_ID('dbo.sp_MateriasProfesoresCursos') IS NOT NULL
  DROP PROCEDURE dbo.sp_MateriasProfesoresCursos;
GO
CREATE PROCEDURE dbo.sp_MateriasProfesoresCursos
AS
BEGIN
  SET NOCOUNT ON;

  IF OBJECT_ID('tempdb..#MPC') IS NOT NULL DROP TABLE #MPC;
  CREATE TABLE #MPC(
    id_materia INT,
    nombre_materia VARCHAR(200),
    id_profesor INT,
    profesor VARCHAR(250),
    id_curso INT,
    nombre_curso VARCHAR(200),
    anio INT
  );

  DECLARE @id_materia INT, @nombre_materia VARCHAR(200);

  DECLARE cur CURSOR FOR
    SELECT id_materia, nombre_materia FROM Materia;

  OPEN cur;
  FETCH NEXT FROM cur INTO @id_materia, @nombre_materia;
  WHILE @@FETCH_STATUS = 0
  BEGIN
    INSERT INTO #MPC
    SELECT m.id_materia, @nombre_materia,
           p.id_profesor, CONCAT(p.apellido, ', ', p.nombre) AS profesor,
           c.id_curso, c.nombre_curso, c.anio
    FROM Curso c
    INNER JOIN Profesor p ON p.id_profesor = c.id_profesor
    INNER JOIN Materia  m ON m.id_materia  = c.id_materia
    WHERE m.id_materia = @id_materia;

    FETCH NEXT FROM cur INTO @id_materia, @nombre_materia;
  END
  CLOSE cur; DEALLOCATE cur;

  SELECT * FROM #MPC ORDER BY nombre_materia, profesor, nombre_curso;
END
GO

/* 4) Inscripciones por cuatrimestre y curso */
IF OBJECT_ID('dbo.sp_InscripcionesPorCuatrimestreYCurso') IS NOT NULL
  DROP PROCEDURE dbo.sp_InscripcionesPorCuatrimestreYCurso;
GO
CREATE PROCEDURE dbo.sp_InscripcionesPorCuatrimestreYCurso
AS
BEGIN
  SET NOCOUNT ON;

  IF OBJECT_ID('tempdb..#Insc') IS NOT NULL DROP TABLE #Insc;
  CREATE TABLE #Insc(
    id_cuatrimestre INT,
    cuatrimestre VARCHAR(200),
    id_curso INT,
    nombre_curso VARCHAR(200),
    id_estudiante INT,
    estudiante VARCHAR(250),
    fecha_inscripcion DATE
  );

  DECLARE @id_cuat INT, @nom_cuat VARCHAR(200), @fi DATE, @ff DATE;

  DECLARE cur CURSOR FOR
    SELECT id_cuatrimestre, nombre, fecha_inicio, fecha_fin
    FROM Cuatrimestre;

  OPEN cur;
  FETCH NEXT FROM cur INTO @id_cuat, @nom_cuat, @fi, @ff;
  WHILE @@FETCH_STATUS = 0
  BEGIN
    INSERT INTO #Insc
    SELECT @id_cuat, @nom_cuat, c.id_curso, c.nombre_curso,
           e.id_estudiante, CONCAT(e.apellido, ', ', e.nombre),
           i.fecha_inscripcion
    FROM Inscripcion i
    INNER JOIN Estudiante e ON e.id_estudiante = i.id_estudiante
    INNER JOIN Curso     c ON c.id_curso     = i.id_curso
    WHERE i.fecha_inscripcion BETWEEN @fi AND @ff;

    FETCH NEXT FROM cur INTO @id_cuat, @nom_cuat, @fi, @ff;
  END
  CLOSE cur; DEALLOCATE cur;

  SELECT * FROM #Insc
  ORDER BY id_cuatrimestre, id_curso, estudiante, fecha_inscripcion;
END
GO

/* 5) estudiantes con cuotas vencidas */
IF OBJECT_ID('dbo.sp_EstudianteConCuotasVencidas') IS NOT NULL
  DROP PROCEDURE dbo.sp_EstudianteConCuotasVencidas;
GO
CREATE PROCEDURE dbo.sp_EstudianteConCuotasVencidas
AS
BEGIN
  SET NOCOUNT ON;

  IF OBJECT_ID('tempdb..#Vencidas') IS NOT NULL DROP TABLE #Vencidas;
  CREATE TABLE #Vencidas(
    id_estudiante INT,
    estudiante VARCHAR(250),
    id_cuota INT,
    mes INT,
    fecha_vencimiento DATE,
    monto DECIMAL(12,2),
    estado_pago VARCHAR(50)
  );

  DECLARE @id_est INT, @nom VARCHAR(200), @ape VARCHAR(200);

  DECLARE cur CURSOR FOR
    SELECT id_estudiante, nombre, apellido FROM Estudiante;

  OPEN cur;
  FETCH NEXT FROM cur INTO @id_est, @nom, @ape;
  WHILE @@FETCH_STATUS = 0
  BEGIN
    INSERT INTO #Vencidas
    SELECT @id_est, CONCAT(@ape, ', ', @nom),
           c.id_cuota, c.mes, c.fecha_vencimiento, c.monto, c.estado_pago
    FROM Cuota c
    WHERE c.id_estudiante = @id_est
      AND c.fecha_vencimiento < CAST(GETDATE() AS DATE)
      AND (c.estado_pago IS NULL OR c.estado_pago <> 'Pagado');

    FETCH NEXT FROM cur INTO @id_est, @nom, @ape;
  END
  CLOSE cur; DEALLOCATE cur;

  SELECT * FROM #Vencidas ORDER BY estudiante, fecha_vencimiento;
END
GO

/* 6) cursos con su cantidad de inscriptos */
IF OBJECT_ID('dbo.sp_CursosConCantidadInscriptos') IS NOT NULL
  DROP PROCEDURE dbo.sp_CursosConCantidadInscriptos;
GO
CREATE PROCEDURE dbo.sp_CursosConCantidadInscriptos
AS
BEGIN
  SET NOCOUNT ON;

  IF OBJECT_ID('tempdb..#Cant') IS NOT NULL DROP TABLE #Cant;
  CREATE TABLE #Cant(
    id_curso INT,
    nombre_curso VARCHAR(200),
    inscriptos INT
  );

  DECLARE @id_curso INT, @nom_curso VARCHAR(200);

  DECLARE cur CURSOR FOR
    SELECT id_curso, nombre_curso FROM Curso;

  OPEN cur;
  FETCH NEXT FROM cur INTO @id_curso, @nom_curso;
  WHILE @@FETCH_STATUS = 0
  BEGIN
    INSERT INTO #Cant
    SELECT @id_curso, @nom_curso,
           (SELECT COUNT(*) FROM Inscripcion i WHERE i.id_curso = @id_curso);

    FETCH NEXT FROM cur INTO @id_curso, @nom_curso;
  END
  CLOSE cur; DEALLOCATE cur;

  SELECT * FROM #Cant ORDER BY inscriptos DESC, nombre_curso;
END
GO

/* 7) Facturas agrupadas por estado de pago */
IF OBJECT_ID('dbo.sp_FacturasAgrupadasPorEstado') IS NOT NULL
  DROP PROCEDURE dbo.sp_FacturasAgrupadasPorEstado;
GO
CREATE PROCEDURE dbo.sp_FacturasAgrupadasPorEstado
AS
BEGIN
  SET NOCOUNT ON;

  IF OBJECT_ID('tempdb..#Fact') IS NOT NULL DROP TABLE #Fact;
  CREATE TABLE #Fact(
    estado_pago VARCHAR(50),
    cantidad INT,
    total DECIMAL(14,2)
  );

  DECLARE @estado VARCHAR(50);

  DECLARE cur CURSOR FOR
    SELECT DISTINCT COALESCE(estado_pago,'(sin estado)') FROM Factura;

  OPEN cur;
  FETCH NEXT FROM cur INTO @estado;
  WHILE @@FETCH_STATUS = 0
  BEGIN
    INSERT INTO #Fact
    SELECT @estado,
           COUNT(*),
           SUM(monto_total)
    FROM Factura
    WHERE COALESCE(estado_pago,'(sin estado)') = @estado;

    FETCH NEXT FROM cur INTO @estado;
  END
  CLOSE cur; DEALLOCATE cur;

  SELECT * FROM #Fact ORDER BY cantidad DESC;
END
GO

/* 8) intereses por mora aplicados por año de carrera */
IF OBJECT_ID('dbo.sp_InteresesPorMora') IS NOT NULL
  DROP PROCEDURE dbo.sp_InteresesPorMora;
GO
CREATE PROCEDURE dbo.sp_InteresesPorMora
AS
BEGIN
  SET NOCOUNT ON;

  IF OBJECT_ID('tempdb..#Mora') IS NOT NULL DROP TABLE #Mora;
  CREATE TABLE #Mora(
    anio_carrera INT,
    porcentaje_interes DECIMAL(5,2)
  );

  DECLARE @anio INT, @porc DECIMAL(5,2);

  DECLARE cur CURSOR FOR
    SELECT anio_carrera, porcentaje_interes FROM Interes_por_Mora;

  OPEN cur;
  FETCH NEXT FROM cur INTO @anio, @porc;
  WHILE @@FETCH_STATUS = 0
  BEGIN
    INSERT INTO #Mora VALUES(@anio, @porc);
    FETCH NEXT FROM cur INTO @anio, @porc;
  END
  CLOSE cur; DEALLOCATE cur;

  SELECT * FROM #Mora ORDER BY anio_carrera;
END
GO

/* 9) cursos cn mayor cantidad de inscripciones */
IF OBJECT_ID('dbo.sp_TopCursosPorInscripciones') IS NOT NULL
  DROP PROCEDURE dbo.sp_TopCursosPorInscripciones;
GO
CREATE PROCEDURE dbo.sp_TopCursosPorInscripciones
  @Top INT = 5
AS
BEGIN
  SET NOCOUNT ON;

  IF OBJECT_ID('tempdb..#TopC') IS NOT NULL DROP TABLE #TopC;
  CREATE TABLE #TopC(
    id_curso INT,
    nombre_curso VARCHAR(200),
    inscripciones INT
  );

  DECLARE @id_curso INT, @nom_curso VARCHAR(200);

  DECLARE cur CURSOR FOR
    SELECT id_curso, nombre_curso FROM Curso;

  OPEN cur;
  FETCH NEXT FROM cur INTO @id_curso, @nom_curso;
  WHILE @@FETCH_STATUS = 0
  BEGIN
    INSERT INTO #TopC
    SELECT @id_curso, @nom_curso,
           (SELECT COUNT(*) FROM Inscripcion i WHERE i.id_curso = @id_curso);

    FETCH NEXT FROM cur INTO @id_curso, @nom_curso;
  END
  CLOSE cur; DEALLOCATE cur;

  SELECT TOP (@Top) * FROM #TopC ORDER BY inscripciones DESC, nombre_curso;
END
GO

/* 10) Estudiantes que no tienen matrícula en el año actual */
IF OBJECT_ID('dbo.sp_EstudiantesSinMatriculaActual') IS NOT NULL
  DROP PROCEDURE dbo.sp_EstudiantesSinMatriculaActual;
GO
CREATE PROCEDURE dbo.sp_EstudiantesSinMatriculaActual
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @anio INT = YEAR(GETDATE());

  IF OBJECT_ID('tempdb..#SinMat') IS NOT NULL DROP TABLE #SinMat;
  CREATE TABLE #SinMat(
    id_estudiante INT,
    nombre VARCHAR(200),
    apellido VARCHAR(200)
  );

  DECLARE @id_est INT, @nom VARCHAR(200), @ape VARCHAR(200);

  DECLARE cur CURSOR FOR
    SELECT id_estudiante, nombre, apellido FROM Estudiante;

  OPEN cur;
  FETCH NEXT FROM cur INTO @id_est, @nom, @ape;
  WHILE @@FETCH_STATUS = 0
  BEGIN
    IF NOT EXISTS (SELECT 1
                   FROM Matriculacion m
                   WHERE m.id_estudiante = @id_est AND m.anio = @anio)
    BEGIN
      INSERT INTO #SinMat VALUES(@id_est, @nom, @ape);
    END

    FETCH NEXT FROM cur INTO @id_est, @nom, @ape;
  END
  CLOSE cur; DEALLOCATE cur;

  SELECT * FROM #SinMat ORDER BY apellido, nombre;
END
GO
