
--   Triggers_TP.sql 

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/* 1) Pago -> actualiza CUOTA y FACTURA */
CREATE OR ALTER TRIGGER trg_CC_PagoCuota_TP
ON CUENTACORRIENTE
AFTER INSERT
AS
BEGIN
  SET NOCOUNT ON;

  UPDATE c
    SET c.id_estado_pago = 2
  FROM CUOTA c
  JOIN inserted i
    ON i.id_estado_pago=2
   AND i.concepto LIKE 'Pago cuota #%'
   AND c.id_cuota = TRY_CAST(REPLACE(i.concepto,'Pago cuota #','') AS INT);

  UPDATE f
     SET f.id_estado_pago = 2
  FROM FACTURA f
  WHERE EXISTS (SELECT 1 FROM CUOTA c WHERE c.id_factura=f.id_factura)
    AND NOT EXISTS (SELECT 1 FROM CUOTA c WHERE c.id_factura=f.id_factura AND c.id_estado_pago<>2);
END
GO

/* 2) Recalcular nota_final cuando cambia recuperatorio */
CREATE OR ALTER TRIGGER trg_Inscripciones_RecalculoFinal_TP
ON INSCRIPCIONES
AFTER INSERT, UPDATE
AS
BEGIN
  SET NOCOUNT ON;
  IF UPDATE(nota_teorica_recuperatorio)
  BEGIN
    UPDATE i
       SET nota_final =
         CASE
           WHEN i.nota_teorica_recuperatorio IS NULL
             THEN ROUND((ISNULL(i.nota_teorica_1,0)+ISNULL(i.nota_teorica_2,0)+ISNULL(i.nota_practica,0))/3.0,2)
           ELSE ROUND((ISNULL(i.nota_teorica_1,0)+ISNULL(i.nota_teorica_2,0)+ISNULL(i.nota_practica,0)+i.nota_teorica_recuperatorio)/4.0,2)
         END
    FROM INSCRIPCIONES i
    JOIN inserted x ON x.id_estudiante=i.id_estudiante AND x.id_curso=i.id_curso;
  END
END
GO

/* 3) Borrar última inscripción -> alumno en BAJA */
CREATE OR ALTER TRIGGER trg_Inscripciones_Baja_TP
ON INSCRIPCIONES
AFTER DELETE
AS
BEGIN
  SET NOCOUNT ON;

  UPDATE e
     SET e.estado='B'
  FROM ESTUDIANTES e
  WHERE e.id_estudiante IN (SELECT DISTINCT id_estudiante FROM deleted)
    AND NOT EXISTS (SELECT 1 FROM INSCRIPCIONES i WHERE i.id_estudiante=e.id_estudiante);
END
GO

/* 4) Insertar FACTURA -> movimiento en CC */
CREATE OR ALTER TRIGGER trg_Factura_Movimiento_TP
ON FACTURA
AFTER INSERT
AS
BEGIN
  SET NOCOUNT ON;

  INSERT INTO CUENTACORRIENTE(id_movimiento,id_estudiante,fecha,concepto,monto,id_estado_pago)
  SELECT ISNULL((SELECT MAX(id_movimiento) FROM CUENTACORRIENTE),0) + ROW_NUMBER() OVER(ORDER BY (SELECT 1)),
         i.id_estudiante,
         i.fecha_emision,
         CONCAT('Factura #', i.id_factura),
         i.monto_total,
         i.id_estado_pago
  FROM inserted i;
END
GO

/* 5) Validar inscripción (alumno activo + materia/cuatri) */
CREATE OR ALTER TRIGGER trg_Inscripcion_Duplicada
ON INSCRIPCIONES
AFTER INSERT
AS
BEGIN
   
    IF EXISTS (
        SELECT 1
        FROM inserted i, CURSOS c_new, INSCRIPCIONES ins_old, CURSOS c_old
        WHERE c_new.id_curso = i.id_curso
          AND ins_old.id_estudiante = i.id_estudiante
          AND c_old.id_curso = ins_old.id_curso
          AND c_new.id_materia = c_old.id_materia
          AND ISNULL(c_new.id_cuatrimestre, -1) = ISNULL(c_old.id_cuatrimestre, -1)
          AND ins_old.id_curso <> i.id_curso
    )
    BEGIN
        RAISERROR('Ya está inscripto a una cursada de la misma materia en el mismo cuatrimestre.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

/* 6) Todas las CUOTAS pagas -> FACTURA paga */
CREATE OR ALTER TRIGGER trg_Cuota_FacturaPaga_TP
ON CUOTA
AFTER UPDATE
AS
BEGIN
  SET NOCOUNT ON;
  IF UPDATE(id_estado_pago)
  BEGIN
    UPDATE f
      SET f.id_estado_pago=2
    FROM FACTURA f
    WHERE EXISTS (SELECT 1 FROM CUOTA c WHERE c.id_factura=f.id_factura)
      AND NOT EXISTS (SELECT 1 FROM CUOTA c WHERE c.id_factura=f.id_factura AND c.id_estado_pago<>2);
  END
END
GO

/* 7) Al insertar FACTURA -> crear CUOTA (simple) */
CREATE OR ALTER TRIGGER trg_Factura_AutoCuota_TP
ON FACTURA
AFTER INSERT
AS
BEGIN
  SET NOCOUNT ON;

  INSERT INTO CUOTA(id_cuota,id_estudiante,id_cuatrimestre,id_factura,mes,monto,fecha_vencimiento,id_estado_pago)
  SELECT ISNULL((SELECT MAX(id_cuota) FROM CUOTA),0) + ROW_NUMBER() OVER(ORDER BY (SELECT 1)),
         i.id_estudiante,
         (SELECT TOP 1 id_cuatrimestre FROM CUATRIMESTRE
          WHERE i.fecha_emision BETWEEN fecha_inicio AND fecha_fin
          ORDER BY fecha_inicio),
         i.id_factura,
         i.mes,
         i.monto_total,
         i.fecha_vencimiento,
         i.id_estado_pago
  FROM inserted i
  WHERE NOT EXISTS (SELECT 1 FROM CUOTA c WHERE c.id_factura=i.id_factura);
END
GO

-- 8) Trigger para impedir la inscripción si el estudiante está dado de baja

CREATE TRIGGER impedirInscripcion
ON INSCRIPCIONES
AFTER INSERT
AS
BEGIN
    -- Verificamos si algún estudiante insertado está dado de baja
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN ESTUDIANTES e ON e.id_estudiante = i.id_estudiante
        WHERE e.estado = 'B'
    )
    BEGIN
        RAISERROR('No se puede inscribir: el estudiante está dado de baja.', 16, 1);
        ROLLBACK TRAN; -- Cancelamos el INSERT original
        RETURN;
    END
END
GO

--9 Trigger para actualizar el monto total de la factura al insertar un ítem de factura.

CREATE OR ALTER TRIGGER actualizarMontoFactura
ON itemFactura
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE f
    SET f.monto_total = (
        SELECT SUM(c.costo_mensual)
        FROM itemFactura i, cursos c
        WHERE i.id_curso = c.id_curso
          AND i.id_factura = f.id_factura
    )
    FROM factura f, inserted ins
    WHERE f.id_factura = ins.id_factura;
END;
GO


/* 10) CUOTA -> pasa a VENCIDA -> interés por mora (simple) */
CREATE OR ALTER TRIGGER trg_Cuota_InteresMora_TP
ON CUOTA
AFTER UPDATE
AS
BEGIN
  SET NOCOUNT ON;
  IF UPDATE(id_estado_pago)
  BEGIN
    INSERT INTO CUENTACORRIENTE(id_movimiento,id_estudiante,fecha,concepto,monto,id_estado_pago)
    SELECT ISNULL((SELECT MAX(id_movimiento) FROM CUENTACORRIENTE),0) + ROW_NUMBER() OVER(ORDER BY (SELECT 1)),
           c.id_estudiante,
           CAST(GETDATE() AS DATE),
           CONCAT('Interés por mora cuota #', c.id_cuota),
           ROUND(c.monto * ISNULL(ipm.porcentaje_interes,2.0) / 100.0, 2),
           1
    FROM CUOTA c
    JOIN inserted i ON i.id_cuota=c.id_cuota
    JOIN FACTURA f ON f.id_factura=c.id_factura
    LEFT JOIN ESTUDIANTES e ON e.id_estudiante=c.id_estudiante
    LEFT JOIN INTERESPORMORA ipm ON ipm.anio_carrera = CASE WHEN e.anio_ingreso IS NULL THEN 1 ELSE (YEAR(GETDATE())-e.anio_ingreso+1) END
    WHERE c.id_estado_pago=3
      AND f.fecha_vencimiento < CAST(GETDATE() AS DATE)
      AND NOT EXISTS (
        SELECT 1 FROM CUENTACORRIENTE cc
        WHERE cc.id_estudiante=c.id_estudiante AND cc.concepto=CONCAT('Interés por mora cuota #', c.id_cuota)
      );
  END
END
GO