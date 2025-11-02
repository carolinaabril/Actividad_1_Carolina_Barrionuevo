
/* =============================================================
   Transacciones_TP
============================================================= */

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/* 4) matricularAlumno (versión transaccional simple) */
CREATE OR ALTER PROCEDURE matricularAlumno_TX
  @id_alumno INT,
  @anio_a_matricular INT,
  @id_estado_pago INT = 1
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @fecha DATE = CAST(GETDATE() AS DATE);
  DECLARE @monto DECIMAL(10,2) = 9500.00;
  DECLARE @id_mat INT, @id_fact INT, @mes INT, @fecha_venc DATE, @id_mov INT;

  BEGIN TRY
    BEGIN TRAN;

    IF NOT EXISTS (SELECT 1 FROM ESTUDIANTES WHERE id_estudiante=@id_alumno AND estado='A')
    BEGIN RAISERROR('El alumno no existe o no está activo.',16,1); ROLLBACK; RETURN; END

    IF EXISTS (SELECT 1 FROM MATRICULACION WHERE id_estudiante=@id_alumno AND anio=@anio_a_matricular)
    BEGIN RAISERROR('El alumno ya está matriculado en ese año.',16,1); ROLLBACK; RETURN; END

    SELECT @id_mat = ISNULL(MAX(id_matricula),0)+1 FROM MATRICULACION;
    SELECT @id_fact = ISNULL(MAX(id_factura),0)+1 FROM FACTURA;
    SELECT @id_mov = ISNULL(MAX(id_movimiento),0)+1 FROM CUENTACORRIENTE;
    SET @mes = MONTH(@fecha);
    SET @fecha_venc = DATEADD(MONTH,3,@fecha);

    INSERT INTO MATRICULACION(id_matricula,id_estudiante,anio,fecha_pago,monto,id_estado_pago)
    VALUES(@id_mat,@id_alumno,@anio_a_matricular,@fecha,@monto,@id_estado_pago);

    INSERT INTO FACTURA(id_factura,id_estudiante,mes,anio,fecha_emision,fecha_vencimiento,monto_total,id_estado_pago)
    VALUES(@id_fact,@id_alumno,@mes,@anio_a_matricular,@fecha,@fecha_venc,@monto,@id_estado_pago);

    INSERT INTO CUENTACORRIENTE(id_movimiento,id_estudiante,fecha,concepto,monto,id_estado_pago)
    VALUES(@id_mov,@id_alumno,@fecha,'Matricula',@monto,@id_estado_pago);

    COMMIT;
    PRINT 'Matrícula generada correctamente.';
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;
    RAISERROR('Error en matricularAlumno_TX: %s',16,1,ERROR_MESSAGE());
  END CATCH
END
GO

/* 5) inscribirAlumno (versión transaccional simple) */
CREATE OR ALTER PROCEDURE inscribirAlumno_TX
  @id_estudiante INT,
  @id_curso INT
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @id_materia INT, @id_cuat INT;

  BEGIN TRY
    BEGIN TRAN;

    IF NOT EXISTS (SELECT 1 FROM ESTUDIANTES WHERE id_estudiante=@id_estudiante AND estado='A')
    BEGIN RAISERROR('El estudiante no existe o no está activo.',16,1); ROLLBACK; RETURN; END

    IF NOT EXISTS (SELECT 1 FROM CURSOS WHERE id_curso=@id_curso)
    BEGIN RAISERROR('El curso no existe.',16,1); ROLLBACK; RETURN; END

    IF EXISTS (SELECT 1 FROM INSCRIPCIONES WHERE id_estudiante=@id_estudiante AND id_curso=@id_curso)
    BEGIN RAISERROR('Ya está inscripto en este curso.',16,1); ROLLBACK; RETURN; END

    SELECT @id_materia=id_materia, @id_cuat=id_cuatrimestre FROM CURSOS WHERE id_curso=@id_curso;

    IF EXISTS (
      SELECT 1
      FROM INSCRIPCIONES i
      JOIN CURSOS c ON c.id_curso=i.id_curso
      WHERE i.id_estudiante=@id_estudiante
        AND c.id_materia=@id_materia
        AND ISNULL(c.id_cuatrimestre,-1)=ISNULL(@id_cuat,-1)
    )
    BEGIN RAISERROR('Ya inscripto a una cursada de la misma materia en el mismo cuatrimestre.',16,1); ROLLBACK; RETURN; END

    INSERT INTO INSCRIPCIONES(id_estudiante,id_curso,fecha_inscripcion,nota_teorica_1,nota_teorica_2,nota_practica,nota_teorica_recuperatorio,nota_final)
    VALUES(@id_estudiante,@id_curso,CAST(GETDATE() AS DATE),NULL,NULL,NULL,NULL,NULL);

    COMMIT;
    PRINT 'Inscripción realizada correctamente.';
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;
    RAISERROR('Error en inscribirAlumno_TX: %s',16,1,ERROR_MESSAGE());
  END CATCH
END
GO

/* 6) cargarNota (versión transaccional simple) */
CREATE OR ALTER PROCEDURE cargarNota_TX
  @id_estudiante INT,
  @id_curso INT,
  @tipo_examen CHAR(3),
  @nota DECIMAL(4,2)
AS
BEGIN
  SET NOCOUNT ON;

  BEGIN TRY
    BEGIN TRAN;

    IF NOT EXISTS (SELECT 1 FROM INSCRIPCIONES WHERE id_estudiante=@id_estudiante AND id_curso=@id_curso)
    BEGIN RAISERROR('No existe la inscripción del alumno al curso.',16,1); ROLLBACK; RETURN; END

    IF @nota < 1 OR @nota > 10
    BEGIN RAISERROR('La nota debe estar entre 1 y 10.',16,1); ROLLBACK; RETURN; END

    IF @tipo_examen='T1'
      UPDATE INSCRIPCIONES SET nota_teorica_1=@nota WHERE id_estudiante=@id_estudiante AND id_curso=@id_curso;
    ELSE IF @tipo_examen='T2'
      UPDATE INSCRIPCIONES SET nota_teorica_2=@nota WHERE id_estudiante=@id_estudiante AND id_curso=@id_curso;
    ELSE IF @tipo_examen='PR'
      UPDATE INSCRIPCIONES SET nota_practica=@nota WHERE id_estudiante=@id_estudiante AND id_curso=@id_curso;
    ELSE IF @tipo_examen='REC'
    BEGIN
      DECLARE @fallas INT = (
        SELECT (CASE WHEN ISNULL(nota_teorica_1,0) < 4 THEN 1 ELSE 0 END) +
               (CASE WHEN ISNULL(nota_teorica_2,0) < 4 THEN 1 ELSE 0 END) +
               (CASE WHEN ISNULL(nota_practica ,0) < 4 THEN 1 ELSE 0 END)
        FROM INSCRIPCIONES WHERE id_estudiante=@id_estudiante AND id_curso=@id_curso
      );
      IF @fallas IS NULL OR @fallas=0 BEGIN RAISERROR('No hay instancia previa desaprobada (<4).',16,1); ROLLBACK; RETURN; END
      IF @fallas >= 2 BEGIN RAISERROR('Existen dos o más instancias previas <4.',16,1); ROLLBACK; RETURN; END

      UPDATE INSCRIPCIONES SET nota_teorica_recuperatorio=@nota WHERE id_estudiante=@id_estudiante AND id_curso=@id_curso;
    END
    ELSE
    BEGIN RAISERROR('Tipo de examen inválido (T1,T2,PR,REC).',16,1); ROLLBACK; RETURN; END

    DECLARE @n1 DECIMAL(4,2), @n2 DECIMAL(4,2), @np DECIMAL(4,2), @nr DECIMAL(4,2);
    SELECT @n1=nota_teorica_1, @n2=nota_teorica_2, @np=nota_practica, @nr=nota_teorica_recuperatorio
    FROM INSCRIPCIONES WHERE id_estudiante=@id_estudiante AND id_curso=@id_curso;

    IF @nr IS NULL
      UPDATE INSCRIPCIONES SET nota_final = ROUND((@n1+@n2+@np)/3.0,2) WHERE id_estudiante=@id_estudiante AND id_curso=@id_curso;
    ELSE
      UPDATE INSCRIPCIONES SET nota_final = ROUND((@n1+@n2+@np+@nr)/4.0,2) WHERE id_estudiante=@id_estudiante AND id_curso=@id_curso;

    COMMIT;
    PRINT 'Nota cargada y promedio recalculado.';
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;
    RAISERROR('Error en cargarNota_TX: %s',16,1,ERROR_MESSAGE());
  END CATCH
END
GO

/* 7) generarCuotasAlumnos (versión transaccional simple - por lote) */
CREATE OR ALTER PROCEDURE generarCuotasAlumnos_TX
  @anio INT,
  @mes_facturacion INT,
  @id_estado_pago INT = 1
AS
BEGIN
  SET NOCOUNT ON;
  IF @mes_facturacion NOT BETWEEN 1 AND 12 BEGIN RAISERROR('Mes inválido (1-12).',16,1); RETURN; END

  DECLARE @hoy DATE = GETDATE();
  DECLARE @id_cuat INT = (SELECT TOP 1 id_cuatrimestre FROM CUATRIMESTRE WHERE @hoy BETWEEN fecha_inicio AND fecha_fin ORDER BY fecha_inicio);

  IF @id_cuat IS NULL BEGIN RAISERROR('No hay cuatrimestre actual definido.',16,1); RETURN; END

  DECLARE @id_est INT;
  DECLARE cur CURSOR FOR
    SELECT DISTINCT e.id_estudiante
    FROM ESTUDIANTES e
    JOIN INSCRIPCIONES i ON i.id_estudiante=e.id_estudiante
    JOIN CURSOS c ON c.id_curso=i.id_curso
    WHERE e.estado='A' AND c.id_cuatrimestre=@id_cuat AND c.anio=@anio;

  OPEN cur; FETCH NEXT FROM cur INTO @id_est;
  WHILE @@FETCH_STATUS = 0
  BEGIN
    BEGIN TRY
      BEGIN TRAN;

      IF NOT EXISTS (SELECT 1 FROM CUOTA WHERE id_estudiante=@id_est AND mes=@mes_facturacion)
      BEGIN
        DECLARE @nuevo_id_cuota INT = (SELECT ISNULL(MAX(id_cuota),0)+1 FROM CUOTA);
        DECLARE @nuevo_id_fact INT = (SELECT ISNULL(MAX(id_factura),0)+1 FROM FACTURA);
        DECLARE @nuevo_id_mov  INT = (SELECT ISNULL(MAX(id_movimiento),0)+1 FROM CUENTACORRIENTE);
        DECLARE @monto DECIMAL(10,2) =
          (SELECT ISNULL(SUM(c.costo_mensual),0)
           FROM INSCRIPCIONES i
           JOIN CURSOS c ON c.id_curso=i.id_curso
           WHERE i.id_estudiante=@id_est AND c.id_cuatrimestre=@id_cuat AND c.anio=@anio);

        DECLARE @fec_emision DATE = DATEFROMPARTS(@anio,@mes_facturacion,1);
        DECLARE @fec_venc DATE = DATEADD(DAY,15,@fec_emision);

        INSERT INTO FACTURA(id_factura,id_estudiante,mes,anio,fecha_emision,fecha_vencimiento,monto_total,id_estado_pago)
        VALUES(@nuevo_id_fact,@id_est,@mes_facturacion,@anio,@fec_emision,@fec_venc,@monto,@id_estado_pago);

        INSERT INTO CUOTA(id_cuota,id_estudiante,id_cuatrimestre,id_factura,mes,monto,fecha_vencimiento,id_estado_pago)
        VALUES(@nuevo_id_cuota,@id_est,@id_cuat,@nuevo_id_fact,@mes_facturacion,@monto,@fec_venc,@id_estado_pago);

        INSERT INTO CUENTACORRIENTE(id_movimiento,id_estudiante,fecha,concepto,monto,id_estado_pago)
        VALUES(@nuevo_id_mov,@id_est,@fec_emision,CONCAT('Cuota ',RIGHT('00'+CAST(@mes_facturacion AS VARCHAR(2)),2),'/',@anio),@monto,@id_estado_pago);
      END

      COMMIT;
    END TRY
    BEGIN CATCH
      IF @@TRANCOUNT > 0 ROLLBACK;
      PRINT 'Error en generarCuotasAlumnos_TX para id_estudiante=' + CAST(@id_est AS VARCHAR(20)) + ': ' + ERROR_MESSAGE();
    END CATCH;

    FETCH NEXT FROM cur INTO @id_est;
  END
  CLOSE cur; DEALLOCATE cur;
END
GO

/* 8) generarCuotas (alumno específico, transacción simple) */
CREATE OR ALTER PROCEDURE generarCuotas_TX
  @id_estudiante INT,
  @anio INT,
  @mes_facturacion INT,
  @id_estado_pago INT = 1
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRY
    BEGIN TRAN;
    EXEC generarCuotasAlumnos_TX @anio=@anio, @mes_facturacion=@mes_facturacion, @id_estado_pago=@id_estado_pago;
    COMMIT;
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;
    RAISERROR('Error en generarCuotas_TX: %s',16,1,ERROR_MESSAGE());
  END CATCH
END
GO

/* 9) calculoInteresPorMora (transacción simple por lote) */
CREATE OR ALTER PROCEDURE calculoInteresPorMora_TX
  @anio INT
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRY
    BEGIN TRAN;

    DECLARE @tmp TABLE(id_estudiante INT, deuda DECIMAL(18,2), anio_carrera INT);

    INSERT INTO @tmp(id_estudiante,deuda,anio_carrera)
    SELECT c.id_estudiante,
           SUM(c.monto) AS deuda,
           CASE WHEN e.anio_ingreso IS NULL THEN 1 ELSE (@anio - e.anio_ingreso + 1) END AS anio_carrera
    FROM CUOTA c
    JOIN FACTURA f ON f.id_factura=c.id_factura
    JOIN ESTUDIANTES e ON e.id_estudiante=c.id_estudiante
    WHERE f.fecha_vencimiento < CAST(GETDATE() AS DATE)
      AND c.id_estado_pago IN (1,3)
    GROUP BY c.id_estudiante, e.anio_ingreso
    HAVING COUNT(*) > 1;

    DECLARE @id_est INT, @deuda DECIMAL(18,2), @anio_carr INT, @porc DECIMAL(5,2), @interes DECIMAL(18,2);
    DECLARE cur CURSOR FOR SELECT id_estudiante,deuda,anio_carrera FROM @tmp;
    OPEN cur; FETCH NEXT FROM cur INTO @id_est,@deuda,@anio_carr;
    WHILE @@FETCH_STATUS = 0
    BEGIN
      SELECT @porc = porcentaje_interes FROM INTERESPORMORA WHERE anio_carrera=@anio_carr;
      IF @porc IS NULL SET @porc = 2.0;
      SET @interes = ROUND(@deuda * (@porc/100.0), 2);

      IF @interes > 0 AND NOT EXISTS (
        SELECT 1 FROM CUENTACORRIENTE WHERE id_estudiante=@id_est AND concepto='Interés por mora (batch)' AND monto=@interes AND id_estado_pago=1
      )
      BEGIN
        DECLARE @id_mov INT = (SELECT ISNULL(MAX(id_movimiento),0)+1 FROM CUENTACORRIENTE);
        INSERT INTO CUENTACORRIENTE(id_movimiento,id_estudiante,fecha,concepto,monto,id_estado_pago)
        VALUES(@id_mov,@id_est,GETDATE(),'Interés por mora (batch)',@interes,1);
      END

      FETCH NEXT FROM cur INTO @id_est,@deuda,@anio_carr;
    END
    CLOSE cur; DEALLOCATE cur;

    COMMIT;
    PRINT 'Intereses por mora calculados.';
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;
    RAISERROR('Error en calculoInteresPorMora_TX: %s',16,1,ERROR_MESSAGE());
  END CATCH
END
GO

/* 10) registrarPago (transacción simple) */
CREATE OR ALTER PROCEDURE registrarPago_TX
  @id_estudiante INT,
  @monto DECIMAL(12,2),
  @fecha DATE = NULL
AS
BEGIN
  SET NOCOUNT ON;

  BEGIN TRY
    IF @monto <= 0 BEGIN RAISERROR('Monto inválido.',16,1); RETURN; END
    IF @fecha IS NULL SET @fecha = CAST(GETDATE() AS DATE);

    BEGIN TRAN;

    DECLARE @resto DECIMAL(12,2) = @monto;
    DECLARE @id_cuota INT, @monto_cuota DECIMAL(12,2), @id_fact INT;

    DECLARE cur CURSOR FOR
      SELECT c.id_cuota, c.monto, c.id_factura
      FROM CUOTA c
      JOIN FACTURA f ON f.id_factura=c.id_factura
      WHERE c.id_estudiante=@id_estudiante AND c.id_estado_pago IN (1,3)
      ORDER BY f.fecha_vencimiento ASC, c.id_cuota ASC;

    OPEN cur; FETCH NEXT FROM cur INTO @id_cuota,@monto_cuota,@id_fact;
    WHILE @@FETCH_STATUS = 0 AND @resto > 0
    BEGIN
      IF @resto >= @monto_cuota
      BEGIN
        UPDATE CUOTA   SET id_estado_pago=2 WHERE id_cuota=@id_cuota;
        UPDATE FACTURA SET id_estado_pago=2 WHERE id_factura=@id_fact;

        DECLARE @id_mov1 INT = (SELECT ISNULL(MAX(id_movimiento),0)+1 FROM CUENTACORRIENTE);
        INSERT INTO CUENTACORRIENTE(id_movimiento,id_estudiante,fecha,concepto,monto,id_estado_pago)
        VALUES(@id_mov1,@id_estudiante,@fecha,CONCAT('Pago cuota #',@id_cuota),@monto_cuota,2);

        SET @resto = @resto - @monto_cuota;
      END
      ELSE
      BEGIN
        DECLARE @id_mov2 INT = (SELECT ISNULL(MAX(id_movimiento),0)+1 FROM CUENTACORRIENTE);
        INSERT INTO CUENTACORRIENTE(id_movimiento,id_estudiante,fecha,concepto,monto,id_estado_pago)
        VALUES(@id_mov2,@id_estudiante,@fecha,CONCAT('Pago parcial cuota #',@id_cuota),@resto,2);
        SET @resto = 0;
      END

      FETCH NEXT FROM cur INTO @id_cuota,@monto_cuota,@id_fact;
    END
    CLOSE cur; DEALLOCATE cur;

    IF @resto > 0
    BEGIN
      DECLARE @id_mov INT, @monto_mov DECIMAL(12,2);
      DECLARE cur2 CURSOR FOR
        SELECT id_movimiento, monto
        FROM CUENTACORRIENTE
        WHERE id_estudiante=@id_estudiante AND id_estado_pago=1 AND concepto LIKE 'Interés por mora%'
        ORDER BY fecha ASC, id_movimiento ASC;

      OPEN cur2; FETCH NEXT FROM cur2 INTO @id_mov,@monto_mov;
      WHILE @@FETCH_STATUS = 0 AND @resto > 0
      BEGIN
        IF @resto >= @monto_mov
        BEGIN
          UPDATE CUENTACORRIENTE SET id_estado_pago=2 WHERE id_movimiento=@id_mov;
          SET @resto = @resto - @monto_mov;
        END
        ELSE
        BEGIN
          DECLARE @id_mov3 INT = (SELECT ISNULL(MAX(id_movimiento),0)+1 FROM CUENTACORRIENTE);
          INSERT INTO CUENTACORRIENTE(id_movimiento,id_estudiante,fecha,concepto,monto,id_estado_pago)
          VALUES(@id_mov3,@id_estudiante,@fecha,CONCAT('Pago parcial interés mov#',@id_mov),@resto,2);
          SET @resto=0;
        END
        FETCH NEXT FROM cur2 INTO @id_mov,@monto_mov;
      END
      CLOSE cur2; DEALLOCATE cur2;
    END

    COMMIT;
    PRINT 'Pago registrado.';
  END TRY
  BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;
    RAISERROR('Error en registrarPago_TX: %s',16,1,ERROR_MESSAGE());
  END CATCH
END
GO