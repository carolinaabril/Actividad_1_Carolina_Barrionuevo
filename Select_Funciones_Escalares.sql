-- 1.Crear una funci�n que permita conocer el saldo de la cuenta corriente de un alumno determinado.

select dbo.ObtenerSaldoEstudiante(100) as SaldoPendiente


-- 2.Crear una funci�n de devuelva la cantidad de vacantes de un curso, tomando como par�metro que cada curso puede tener como m�ximo 35 alumnos.

select dbo.ObtenerVacantesDisponibles (9004) as VacantesDisponibles 


-- 3. Obtener el nombre completo de un estudiante dado su ID. 

select dbo.ObtenerNombreCompleto (500) as Nombre_completo

-- 4. Calcular el promedio final de un estudiante en un curso espec�fico. 

select dbo.ObtenerPromedioFinal(100,9001) as promedio_final

select dbo.ObtenerPromedioFinal(200, 9001) as promedio_final

-- 5. Determinar el estado de pago de una cuota espec�fica de un estudiante. 

select.dbo.ObtenerEstadoPagoCuenta(200,3) as EstadoCuotaMarzo
-- 6.  La especialidad de un profesor dado el nombre del profesor. 

select dbo.ObtenerEspecialidad ('Laura', 'Lopez') as EspecialidadProfesor

-- 7. Calcular el monto total adeudado por un estudiante pas�ndole el nombre como par�metro. Si existe m�s de un estudiante con ese nombre devolver -1. 
select dbo.ObtenerMontoAdeudado ('Ana') as MontoAdeudado