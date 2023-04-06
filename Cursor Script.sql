-- Este ejemplo crea una base de datos llamada "empresa" con tres tablas: 
-- "empleados", "proyectos" y "asignaciones". Luego, se hacen algunas inserciones de ejemplo en cada tabla.

-- Despues, se crea un procedimiento almacenado llamado "obtener_asignaciones_proyecto" que recibe un parámetro de entrada "proyecto_id" 
-- y utiliza un cursor para obtener las asignaciones de horas para cada empleado por proyecto.
Drop database empresa;
CREATE DATABASE empresa;

USE empresa;

CREATE TABLE empleados (
  id INT NOT NULL AUTO_INCREMENT,
  nombre VARCHAR(50) NOT NULL,
  salario VARCHAR (20) NOT NULL,
  fecha_contratacion DATE NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE proyectos (
  id INT NOT NULL AUTO_INCREMENT,
  nombre VARCHAR(50) NOT NULL,
  fecha_inicio DATE NOT NULL,
  fecha_fin DATE,
  PRIMARY KEY (id)
);

CREATE TABLE asignaciones (
  id INT NOT NULL AUTO_INCREMENT,
  empleado_id INT NOT NULL,
  proyecto_id INT NOT NULL,
  horas_asignadas INT NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (empleado_id) REFERENCES empleados(id),
  FOREIGN KEY (proyecto_id) REFERENCES proyectos(id)
);

INSERT INTO empleados (nombre, salario, fecha_contratacion) VALUES 
('Juan Perez', '3.000.000', '2023-01-01'),
('Ana Garcia', '2.500.000', '2015-05-01'),
('Pedro Ramirez', '4.000.000', '2008-10-01'),
('Maria Rodriguez', '3.500.000', '2015-02-01');

INSERT INTO proyectos (nombre, fecha_inicio, fecha_fin) VALUES 
('Proyecto A', '2020-01-01', '2022-06-30'),
('Proyecto B', '2021-05-01', '2022-12-31'),
('Proyecto C', '2019-10-01', '2023-03-31');

INSERT INTO asignaciones (empleado_id, proyecto_id, horas_asignadas)VALUES 
(1, 1, 80),
(2, 1, 60),
(3, 1, 100),
(1, 2, 40),
(2, 2, 80),
(4, 2, 60),
(2, 3, 120),
(3, 3, 80),
(4, 3, 100);

-- Este cursor  define el numero de horas al que esta asignado cada empleado en un proyecto especifico 
Delimiter $$ -- Delimitador de nuestro cursor
CREATE PROCEDURE obtener_asignaciones_proyecto(IN proyecto_id INT) -- se crea un procedimiento alamacenado llamado obtener_asignaciones_proyecto "IN" que se utiliza  para comparar una columna con una lista de valores que en este caso es (Proyecto_id)
BEGIN -- para inicializar nuestro procedimiento
  DECLARE empleado_nombre VARCHAR(50); -- declaro 3 varibles con sus respectivos nombres y tipo de datos
  DECLARE horas_asignadas INT;
  DECLARE done INT DEFAULT FALSE;
  DECLARE cur_asignaciones CURSOR FOR SELECT empleados.nombre, asignaciones.horas_asignadas FROM asignaciones  -- declaro el nombre del cursor, que se llama "cur_asignaciones" y selecciono los campos y las tablas empleados junto con el campo "nombre", seguido de la tabla asignaciones con el campo "horas_asignadas" de la tabla "asignaciones"
  INNER JOIN empleados ON asignaciones.empleado_id = empleados.id WHERE asignaciones.proyecto_id = proyecto_id; -- INNER JOIN lo estoy utlizando ya que en la anterior sentencia estoy combinando filas de dos tablas completamente diferentes, ON  para especificar la condición de unión entre dos tablas, donde asignaciones.proyecto_id sea igual al proyecto_id
  
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE; -- Para declarar el controlador que maneja la excepción "no encontrado".
  
  OPEN cur_asignaciones; -- para abrir el cursor y preparlo para la consulta 
  
  read_loop: LOOP -- Bucle que permite repetir la secuencia de instrucciones hasta que se cumpla la condición
    FETCH cur_asignaciones INTO empleado_nombre, horas_asignadas; -- Nos permite acceder a la primera fila generada por la consulta. INTO para relacionarlo con la consulta
    IF done THEN -- sentencia  utlizada dentro de un bucle 
      LEAVE read_loop; -- para salir del Loop
    END IF; -- Finalización de la sentencia condiconal IF
    SELECT CONCAT('Empleado: ', empleado_nombre, ', Horas asignadas: ', horas_asignadas) AS asignacion; -- Para seleccionar y concatenar texto con los campos de la tablas llamadas y lo muestre al ejecutar el procedimiento
  END LOOP; -- Dar por terminado el ciclo 
  
  CLOSE cur_asignaciones; -- Cierre del cursor
END; -- Fin del procedimiento

-- Este comando llama al procedimiento almacenado "obtener_asignaciones_proyecto" y le pasa el valor 1,2,3,4 como argumento para el parámetro "proyecto_id". 
-- Devolverá los resultados del cursor, que en este caso mostrará las asignaciones de empleados para el proyecto con ID 1, ID 2 , ID 3 Que serian los proyectos A, B, C.
CALL obtener_asignaciones_proyecto(2);


  
  