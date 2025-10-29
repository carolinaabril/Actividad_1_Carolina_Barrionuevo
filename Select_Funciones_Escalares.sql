-- 1.Crear una función que permita conocer el saldo de la cuenta corriente de un alumno determinado.

select dbo.ObtenerSaldoEstudiante(100) as SaldoPendiente


-- 2.Crear una función de devuelva la cantidad de vacantes de un curso, tomando como parámetro que cada curso puede tener como máximo 35 alumnos.

select dbo.ObtenerVacantesDisponibles (9004) as VacantesDisponibles 


-- 3. Obtener el nombre completo de un estudiante dado su ID. 

select dbo.ObtenerNombreCompleto (500) as Nombre_completo

-- 4. Calcular el promedio final de un estudiante en un curso específico. 

select dbo.ObtenerPromedioFinal(100,9001) as promedio_final

select dbo.ObtenerPromedioFinal(200, 9001) as promedio_final

-- 5. Determinar el estado de pago de una cuota específica de un estudiante. 

select.dbo.ObtenerEstadoPagoCuenta(200,3) as EstadoCuotaMarzo
-- 6.  La especialidad de un profesor dado el nombre del profesor. 

select dbo.ObtenerEspecialidad ('Laura', 'Lopez') as EspecialidadProfesor

-- 7. Calcular el monto total adeudado por un estudiante pasándole el nombre como parámetro. Si existe más de un estudiante con ese nombre devolver -1. 
select dbo.ObtenerMontoAdeudado ('Ana') as MontoAdeudado