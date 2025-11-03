--1. Crear un procedimiento almacenado (uno para cada uno) para cargar datos los conceptos de alumnos, 
--materias, cursos, profesores, cuatrimestres e intereses por mora (este solo carga un registro 
--para cada año de la carrera, si el año existe se actualiza.)
CREATE PROCEDURE cargaAlumnos
@id int,
@nombre varchar(50),
@apellido varchar(50),
@email varchar(50),
@anio_ingreso int

as
begin
	insert into ESTUDIANTES (id_estudiante,nombre,apellido,email,anio_ingreso)
	values (@id,@nombre,@apellido,@email,@anio_ingreso);
end;

CREATE PROCEDURE cargaMateria
@id int,
@nombre_materia varchar(50),
@creditos int

as 
begin
	insert into MATERIAS (id_materia,nombre_materia,creditos)
	values(@id,@nombre_materia,@creditos);
end

CREATE PROCEDURE cargaCurso
@id int,
@nombre varchar(100),
@descripcion varchar(100),
@anio int,
@id_prof int,
@id_materia int
AS
BEGIN
    INSERT INTO CURSOS (id_curso, nombre_curso, descripcion, anio, id_profesor, id_materia)
    VALUES (@id, @nombre, @descripcion, @anio, @id_prof, @id_materia);
END;

CREATE PROCEDURE cargaProfesor
@id int,
@nombre varchar(30),
@apellido varchar(30),
@especialidad varchar(60)
as 
begin
	insert into PROFESORES(id_profesor,nombre,apellido,especialidad)
	values(@id,@nombre,@apellido,@especialidad);
end

CREATE PROCEDURE cargaCuatrimestre
@id int,
@nombre varchar(100),
@inicio date,
@fin date
as 
begin
	insert into CUATRIMESTRE(id_cuatrimestre,nombre,fecha_inicio,fecha_fin)
	values(@id,@nombre,@inicio,@fin);
end

CREATE PROCEDURE cargaInteresPorMora
@anio int,
@porcentaje decimal(5,2)
AS
BEGIN
IF EXISTS(Select* from INTERESPORMORA where anio_carrera = @anio)
	BEGIN
		UPDATE INTERESPORMORA
		set porcentaje_interes = @porcentaje
		where anio_carrera = @anio;
	END
	ELSE 
	BEGIN
		insert into INTERESPORMORA(anio_carrera,porcentaje_interes)
		values (@anio,@porcentaje)
	END
END

--2.Crear un procedimiento que permita dar de baja a un alumno. 
--El mismo debe contemplar que la cuenta corriente este en cero  para hacerlo. No debe borrarse el historial del alumno, solo indicar que esta de baja.
CREATE PROCEDURE darBaja
@ID_ESTUDIANTE int

AS
BEGIN
	DECLARE @total_deuda decimal(6,2);
	if exists(select * from ESTUDIANTES where @ID_ESTUDIANTE = ID_ESTUDIANTE)
	BEGIN
		SELECT @total_deuda = ISNULL(SUM(monto),0) 
		from CUENTACORRIENTE 
		where id_estudiante = @ID_ESTUDIANTE 
		and id_estado_pago in(1,3)--DEUDA O PAGO PENDIENTE
		
		IF @total_deuda = 0
		BEGIN
			UPDATE ESTUDIANTES
			set estado = 'B'
			where id_estudiante = @id_estudiante;
		END
		ELSE
			PRINT('El alumno posee deudas y no puede ser dado de baja')
	END
	ELSE
	BEGIN
		PRINT('El alumno no existe');
	END
END

--3.Crear un procedimiento que permita volver a dar de alta a un alumno
CREATE PROCEDURE darAlta
@id int
AS
BEGIN
	UPDATE ESTUDIANTES
	SET estado = 'A'
	WHERE @id = id_estudiante
	
END
--4.Crear un procedimiento que permita matricular un alumno a un  año. Solo se acepta una matricula por año por alumno. 
--El procedimiento además de validar los datos ingresados  debe generar la factura correspondiente y el cargo 
--en la cuenta corriente.
CREATE PROCEDURE matricularAlumno
@id_alumno int,
@anio_a_matricular int,
@monto_mat DECIMAL(6,2),
@fecha_emision date = null
AS
BEGIN
if @fecha_emision is null
	set @fecha_emision = GETDATE()

DECLARE @id_mat int = ISNULL((SELECT MAX(id_matricula) FROM matriculacion),0) + 1;
DECLARE @id_factura int = ISNULL((SELECT MAX(id_factura) FROM FACTURA),0) + 1;
DECLARE @id_mov int = ISNULL((SELECT MAX(id_movimiento) FROM CUENTACORRIENTE),0) + 1;
DECLARE @fecha_due date = DATEADD(month, 3, @fecha_emision);

	if NOT exists(select * from ESTUDIANTES where @id_alumno = ID_ESTUDIANTE and estado = 'A')
		BEGIN
			PRINT('EL ALUMNO NO EXISTE O NO ESTA ACTIVO')
			RETURN;
		END
			
	--si ya esta matriculado para ese año
	if exists(select * from matriculacion where @id_alumno = id_estudiante and @anio_a_matricular = anio)
		BEGIN
			print('El alumno ya esta matriculado para el año ingresado')
			RETURN;
		END
		
	BEGIN TRY
		BEGIN TRAN
			INSERT INTO MATRICULACION(id_matricula,id_estudiante,anio,fecha_pago,monto,id_estado_pago)
			VALUES(@id_mat,@id_alumno,@anio_a_matricular,@fecha_emision,@monto_mat,1)
				
			INSERT INTO FACTURA(id_factura,id_estudiante,mes,anio,fecha_emision,fecha_vencimiento,monto_total,id_estado_pago)
			VALUES(@id_factura,@id_alumno,month(@fecha_emision),@anio_a_matricular,@fecha_emision,@fecha_due,@monto_mat,1)
				
			INSERT INTO CUENTACORRIENTE(id_movimiento,id_estudiante,fecha,concepto,monto,id_estado_pago)
			VALUES(@id_mov,@id_alumno,@fecha_emision,'Matriculacion',@monto_mat,1)
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		print(error_message())
	END CATCH
END

--5.Crear un procedimiento que permita inscribir a un alumno a un curso. Además de verificar los datos ingresados, 
--debe verificar que el alumno no encuentre inscripto es ese  u otro curso de la misma materia en ese cuatrimestre.
CREATE PROCEDURE inscribirAlumno
@id_alumno int,
@id_curso int

AS
BEGIN
DECLARE @id_materia INT;
DECLARE @anio INT;

	if exists(select * from ESTUDIANTES where @id_alumno = id_estudiante) and
	exists(select * from CURSOS where @id_curso = id_curso)
		BEGIN
			SELECT @ID_materia = id_materia, @anio = anio
			FROM CURSOS
			where id_curso = @id_curso;

			IF NOT exists(select * from INSCRIPCIONES where @id_alumno = id_estudiante AND @id_curso = id_curso)
			AND NOT EXISTS(
			SELECT * FROM INSCRIPCIONES
			where id_estudiante = @id_alumno 
			and id_curso in(
				SELECT id_curso from CURSOS
				WHERE id_materia = @id_materia
				and anio = @anio)
			)

			BEGIN
				insert into INSCRIPCIONES(id_estudiante,id_curso,fecha_inscripcion,nota_teorica_1,nota_practica,nota_teorica_2,nota_final)
				values(@id_alumno,@id_curso,getdate(),null,null,null,null);
			END
			ELSE
			BEGIN
				PRINT('El alumno ya esta inscripto en un curso de esta materia')
			END
	END
	ELSE
	BEGIN
		PRINT('El curso o alumno no existen')
	END
END				
--6.Crear un procedimiento de le permita cargar nota a un alumno, debe recibir el curso, el alumno, el examen y la nota. Debe validar los datos ingresados. 
--Si la nota corresponde al recuperatorio verificar que al menos una de las instancias anteriores es menor a 4. 
--Si la nota corresponde al recuperatorio verificar que no existan dos o más instancias de evaluaciones anteriores menores a 4.
CREATE PROCEDURE cargarNota
@id_curso INT,
@id_alumno INT,
@examen varchar(30),
@nota decimal(4,2)
AS
BEGIN
    DECLARE @cantidad_bajas INT;

    -- Validar existencia de inscripción
    IF NOT EXISTS(SELECT 1 FROM INSCRIPCIONES WHERE id_estudiante = @id_alumno AND id_curso = @id_curso)
    BEGIN
        PRINT('El ID del curso o del alumno no existen');
        RETURN;
    END

    -- Validar examen
    IF @examen NOT IN ('nota_teorica_1','nota_teorica_2','nota_practica','nota_teorica_recuperatorio','nota_final')
    BEGIN
        PRINT('El examen ingresado no es valido');
        RETURN;
    END

    IF @examen = 'nota_teorica_recuperatorio'
    BEGIN
        SELECT @cantidad_bajas =
            (CASE WHEN nota_teorica_1 < 4 THEN 1 ELSE 0 END) +
            (CASE WHEN nota_teorica_2 < 4 THEN 1 ELSE 0 END) +
            (CASE WHEN nota_practica < 4 THEN 1 ELSE 0 END)
        FROM INSCRIPCIONES
        WHERE id_estudiante = @id_alumno AND id_curso = @id_curso;

        IF @cantidad_bajas <> 1
        BEGIN
            PRINT('No cumple la condicion para rendir recuperatorio');
            RETURN;
        END
    END

    -- SQL dinamico para actualizar la nota
    DECLARE @SENTENCIA NVARCHAR(1000);
    SET @SENTENCIA = 'UPDATE INSCRIPCIONES
                      SET ' + @examen + ' = @nota
                      WHERE id_estudiante = @id_alumno AND id_curso = @id_curso';

    EXEC sp_executesql @SENTENCIA,
                       N'@nota DECIMAL(4,2), @id_alumno INT, @id_curso INT',
                       @nota, @id_alumno, @id_curso;

    PRINT('Nota cargada correctamente');
END

--7.Crear un procedimiento que permita generar las cuotas de todos los alumnos cada mes del cuatrimestre actual, 
--generando para ello la facturación y el cargo correspondiente a la cuenta corriente.

CREATE PROCEDURE generarCuotasAlumnos
AS
BEGIN
    DECLARE @id_alumno INT,
            @id_cuatrimestre INT,
            @mes INT,
            @monto DECIMAL(6,2) = 1000, -- monto fijo por alumno
            @fecha_emision DATE = GETDATE(),
            @id_cuota INT,
            @id_factura INT,
            @id_mov INT,
            @fecha_venc DATE;

    -- Cursor para recorrer todos los alumnos activos
    DECLARE alumnos_cursor CURSOR FOR
        SELECT id_estudiante
        FROM ESTUDIANTES
        WHERE estado = 'A';

    OPEN alumnos_cursor;
    FETCH NEXT FROM alumnos_cursor INTO @id_alumno;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Cursor para recorrer los cuatrimestres actuales
        DECLARE cuatri_cursor CURSOR FOR
            SELECT id_cuatrimestre, DATEPART(MONTH, fecha_inicio) AS mes_inicio
            FROM CUATRIMESTRE
            WHERE fecha_inicio <= @fecha_emision AND fecha_fin >= @fecha_emision;

        OPEN cuatri_cursor;
        FETCH NEXT FROM cuatri_cursor INTO @id_cuatrimestre, @mes;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- Verificar si ya existe la cuota para este mes y cuatrimestre
            IF NOT EXISTS (
                SELECT *
                FROM CUOTA
                WHERE id_estudiante = @id_alumno
                  AND id_cuatrimestre = @id_cuatrimestre
                  AND mes = @mes
            )
            BEGIN
                -- Calcular IDs nuevos
                SELECT @id_cuota = ISNULL(MAX(id_cuota),0)+1 FROM CUOTA;
                SELECT @id_factura = ISNULL(MAX(id_factura),0)+1 FROM FACTURA;
                SELECT @id_mov = ISNULL(MAX(id_movimiento),0)+1 FROM CUENTACORRIENTE;

                -- Fecha de vencimiento a 30 días de hoy
                SET @fecha_venc = DATEADD(DAY,30,@fecha_emision);

                BEGIN TRY
                    BEGIN TRAN
                        -- Insertar FACTURA primero (para no violar FK)
                        INSERT INTO FACTURA(id_factura, id_estudiante, mes, anio, fecha_emision, fecha_vencimiento, monto_total, id_estado_pago)
                        VALUES(@id_factura, @id_alumno, @mes, YEAR(@fecha_emision), @fecha_emision, @fecha_venc, @monto, 1);

                        -- Insertar CUOTA luego
                        INSERT INTO CUOTA(id_cuota, id_estudiante, id_cuatrimestre, id_factura, mes, monto, fecha_vencimiento, id_estado_pago)
                        VALUES(@id_cuota, @id_alumno, @id_cuatrimestre, @id_factura, @mes, @monto, @fecha_venc, 1);

                        -- Insertar en CUENTACORRIENTE
                        INSERT INTO CUENTACORRIENTE(id_movimiento, id_estudiante, fecha, concepto, monto, id_estado_pago)
                        VALUES(@id_mov, @id_alumno, @fecha_emision, 'Cuota', @monto, 1);
                    COMMIT TRAN
                END TRY
                BEGIN CATCH
                    ROLLBACK TRAN
                    PRINT(ERROR_MESSAGE())
                END CATCH
            END

            FETCH NEXT FROM cuatri_cursor INTO @id_cuatrimestre, @mes;
        END

        CLOSE cuatri_cursor;
        DEALLOCATE cuatri_cursor;

        FETCH NEXT FROM alumnos_cursor INTO @id_alumno;
    END

    CLOSE alumnos_cursor;
    DEALLOCATE alumnos_cursor;
END


--8.Crear un procedimiento que permita generar la cuota de un alumno determinado para un mes del cuatrimestre actual, 
--generando para ello la facturación y el cargo correspondiente a la cuenta corriente.

CREATE PROCEDURE generarCuota
@id_alumno INT,
@id_cuatri INT,
@mes INT,
@monto decimal(6,2),
@fecha_emision DATE,
@anio INT
AS
BEGIN
DECLARE @id_cuota int = ISNULL((SELECT MAX(id_cuota) FROM cuota),0) + 1;
DECLARE @id_factura int = ISNULL((SELECT MAX(id_factura) FROM FACTURA),0) + 1;
DECLARE @id_mov int = ISNULL((SELECT MAX(id_movimiento) FROM CUENTACORRIENTE),0) + 1;
DECLARE @fecha_venc DATE = DATEADD(DAY,30,@fecha_emision);

	IF NOT EXISTS(select * from ESTUDIANTES where @id_alumno = id_estudiante AND estado = 'A') 
	BEGIN
		print('No hay alumnos activos con ese ID')
		RETURN;
	END
	IF EXISTS(SELECT * FROM CUOTA where id_estudiante = @id_alumno and  id_cuatrimestre  = @id_cuatri and mes = @mes)
		BEGIN
		PRINT('Ya existe una factura de cuota de este mes para el estudiante')
		RETURN;
		END

	BEGIN TRY
		BEGIN TRAN
			INSERT INTO FACTURA(id_factura,id_estudiante,mes,anio,fecha_emision,fecha_vencimiento,monto_total,id_estado_pago)
			VALUES(@id_factura,@id_alumno,month(@fecha_emision),@anio,@fecha_emision,@fecha_venc,@monto,1)
			
			INSERT INTO CUOTA(id_cuota, id_estudiante, id_cuatrimestre, id_factura, mes, monto, fecha_vencimiento, id_estado_pago)
			VALUES(@id_cuota, @id_alumno, @id_cuatri, @id_factura, @mes, @monto, @fecha_venc, 1);
				
			INSERT INTO CUENTACORRIENTE(id_movimiento,id_estudiante,fecha,concepto,monto,id_estado_pago)
			VALUES(@id_mov,@id_alumno,@fecha_emision,'Cuota',@monto,1)
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		print(error_message())
	END CATCH
END

--9.Crear un procedimiento que calcule los intereses por mora para los alumnos que adeudan más de un mes de cuota.
CREATE PROCEDURE calculoInteresPorMora
AS
BEGIN
    DECLARE @id_cuota INT,
            @id_estudiante INT,
            @monto DECIMAL(6,2),
            @fecha_venc DATE,
            @anio_carrera INT,
            @interes DECIMAL(6,2),
            @id_mov INT;

    -- Cursor para recorrer todas las cuotas pendientes (id_estado_pago = 3)
    DECLARE cuotas_cursor CURSOR FOR
    SELECT id_cuota, id_estudiante, monto,
           (SELECT DATEDIFF(YEAR, anio_ingreso, GETDATE()) + 1
            FROM ESTUDIANTES
            WHERE id_estudiante = c.id_estudiante) AS anio_carrera
    FROM CUOTA c
    WHERE id_estado_pago = 3;

    OPEN cuotas_cursor;
    FETCH NEXT FROM cuotas_cursor INTO @id_cuota, @id_estudiante, @monto, @anio_carrera;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Calcular interes según año de carrera
        SELECT @interes = ISNULL(@monto * i.porcentaje_interes / 100, 0)
        FROM INTERESPORMORA i
        WHERE i.anio_carrera = @anio_carrera;

        -- Evitar insertar NULL en caso de que no haya porcentaje definido
        IF @interes IS NULL
            SET @interes = 0;

        -- Nuevo ID para cuenta corriente
        SELECT @id_mov = ISNULL(MAX(id_movimiento),0) + 1 FROM CUENTACORRIENTE;

        -- Insertar interés en cuenta corriente solo si es mayor a 0
        IF @interes > 0
        BEGIN
            INSERT INTO CUENTACORRIENTE(id_movimiento, id_estudiante, fecha, concepto, monto, id_estado_pago)
            VALUES(@id_mov, @id_estudiante, GETDATE(), 'Interes por mora', @interes, 3);
        END

        FETCH NEXT FROM cuotas_cursor INTO @id_cuota, @id_estudiante, @monto, @anio_carrera;
    END

    CLOSE cuotas_cursor;
    DEALLOCATE cuotas_cursor;
END



--10.Crear un procedimiento que permita registrar un pago a un alumno determinado.
CREATE PROCEDURE registrarPago
@id_alumno int,
@id_factura int,
@concepto varchar(30)
AS
BEGIN
DECLARE @monto decimal(6,2); 
select @monto = monto_total 
from FACTURA 
where id_factura = @id_factura;

DECLARE @id_mov int 
SELECT @id_mov = ISNULL(MAX(id_movimiento),0)+1
from CUENTACORRIENTE;
	
	IF @monto IS NULL
    BEGIN
        PRINT('Factura no encontrada');
        RETURN;
    END

	IF EXISTS(SELECT * FROM FACTURA WHERE ID_ESTUDIANTE = @id_alumno and id_factura = @id_factura AND (id_estado_pago IN (1,3)))
	BEGIN
		BEGIN TRY
			BEGIN TRAN
				UPDATE FACTURA
				SET ID_ESTADO_PAGO = 2 
				where id_factura = @id_factura
			
				INSERT INTO CUENTACORRIENTE(ID_MOVIMIENTO,ID_ESTUDIANTE,FECHA,CONCEPTO,MONTO,ID_ESTADO_PAGO)
				VALUES(@id_mov,@id_alumno,getdate(),@concepto,@monto,2)
			COMMIT TRAN
		END TRY
		BEGIN CATCH
			ROLLBACK TRAN
			PRINT(ERROR_MESSAGE())
		END CATCH
	END
END 
--fin