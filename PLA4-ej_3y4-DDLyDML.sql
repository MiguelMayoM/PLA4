/*Para ejecutar todo el script sin preocuparnos de posibles errores por elementos que
  ya existan, destruimos toda la base de datos en cada prueba*/
-- DROP DATABASE empresa;

CREATE DATABASE IF NOT EXISTS empresa;
USE empresa;

/* --------- */
/* PROVEEDOR */
/* --------- */
/*En principio sé que el NIF habría de ser UNIQUE, pero se podría considerar que un
  mismo NIF pudiera tener empresas en diferentes direcciones. En ese caso, me gustaría
  implementar la tabla de esta forma, pero no sé como hacer lo tercero:
  OK -> "direccion" única, no puede haber dos empresas ocupando el mismo lugar.
  OK -> "nombre" se puede repetir si es muy común
  ¿? -> Que el NIF se pueda repetir pero ligado siempre a un mismo nombre (lo usaría
		si el proveedor tiene empresas a su nombre en direcciones distintas). Supongo
        que una forma de conseguirlo sería uniendo las dos columnas o algo así...
*/
CREATE TABLE proveedor (
	id_proveedor INT AUTO_INCREMENT PRIMARY KEY,
    NIF VARCHAR(9) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(100) NOT NULL UNIQUE,
    /*Esto sería para que se pueda repetir NIF pero en otra direccion. Ahora me faltaria
	  condicionar que el nombre que vaya ligado a ese NIF siempre sea el mismo*/
    CONSTRAINT uc_NIF_direccion UNIQUE (NIF, direccion)
);

/* -------- */
/* PRODUCTO */
/* -------- */
/*Recordamos que proveedor tiene cardinalidad 1 en su relación con producto, por ello
  añadimos la clave primaria del primero como campo normal a la tabla del segundo*/
/*Para probar más funciones, creamos un CONSTRAINT UNIQUE entre "codigo" y "nombre"
  producto, lo cual tiene sentido. El precio, sin embargo, puede darse también en
  cualquier otro producto*/
/*Comprobamos que el precio sea mayor que cero*/
CREATE TABLE producto (
	id_producto INT AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(15) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    precioUd DECIMAL(10,4) NOT NULL CHECK (precioUd > 0),
    id_proveedor INT NOT NULL,
    /*Nombre que damos al constraint para referirnos a él si queremos eliminarlo*/
    CONSTRAINT uc_codigo_nombre UNIQUE (codigo, nombre)
);
/*Al constraint le hemos dado un nombre para referirnos a él en caso de querer
  eliminarlo, pudiendo hacer:*/
  -- DROP INDEX uc_codigo_nombre ON producto;	/*O bien*/
  -- ALTER TABLE producto
  -- DROP INDEX uc_codigo_nombre;

/* ------- */
/* CLIENTE */
/* ------- */
/*Dejo opcional los apellidos, direccion. Aunque haya un campo para apellidos,
  doy 100 posiciones a nombre por si acaso es un nombre largo de empresa*/
/*Sólo hago UNIQUE el DNI. Así estoy permitiendo hermanos gemelos que viven en la
  misma dirección, si por ejemplo estoy considerando clientes particulares*/
/*Para algún caso especial, se podría chequear que los clientes sean mayores de
  edad. En este caso la fNacimiento habrá de ser obligatoria. He intentado hacer
  un CHECK de varias formas, como:
  fNacimiento DATE CHECK (TIMESTAMPDIFF(YEAR, fNacimiento, CURRENT_TIMESTAMP) >= 18)
														   NOW()
  Pero me da error: "An expression of a check constraint contains a disallowed function."
  Creo que tengo que hacer la comprobación en el INSERT o UPDATE*/
CREATE TABLE cliente (
	id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    DNI VARCHAR(9) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100),
    direccion VARCHAR(100),
    fNacimiento DATE NOT NULL
);

/* ------------------ */
/* CLIENTE - PRODUCTO */
/* ------------------ */
/*La relación entre cliente y producto tiene una cardinalidad N:M y por ello hemos
  de crear una nueva tabla "intermedia" para reflejar esta relación, en la cual habrá
  una nueva clave primaria para esta tabla y las dos claves primarias, ahora como
  campos normales, de las entidades que se relacionan. Si la relación tuviera
  atributos, también irían aquí*/
CREATE TABLE cliente_producto (
	id_cliente_producto INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    id_producto INT NOT NULL
);

/* ------------ */
/* FOREIGN KEYS */
/* ------------ */
/*Creamos las restricciones de las 3 claves externas usadas. Seguimos los criterios
  "ON DELETE" y "ON UPDATE" presentados en el ejemplo*/
/*Para la relación proveedor-producto*/
ALTER TABLE producto ADD
FOREIGN KEY fk_proveedor(id_proveedor)
REFERENCES proveedor(id_proveedor)
ON DELETE RESTRICT
ON UPDATE CASCADE;

/*Para la relación cliente-producto*/
ALTER TABLE cliente_producto ADD
FOREIGN KEY fk_cliente(id_cliente)
REFERENCES cliente(id_cliente)
ON DELETE RESTRICT
ON UPDATE CASCADE;

ALTER TABLE cliente_producto ADD
FOREIGN KEY fk_producto(id_producto)
REFERENCES producto(id_producto)
ON DELETE RESTRICT
ON UPDATE CASCADE;

/* ------------------------ */
/* INSERTAR AGLUNOS VALORES */
/* ------------------------ */
INSERT INTO proveedor (NIF, nombre, direccion)
VALUES ("A77M", "Hiper Mega Ultra Supermercados Miguel", "En una ciudad muy grande"),
       ("B11J", "Grandes Almacenes donde hay de todo", "");

INSERT INTO producto (codigo, nombre, precioUd, id_proveedor)
VALUES ("HOR_COND1-5","Horchata Condensada de 1l para hacer 5l",3.89, 1),
       ("TON_SCH33","Tónica Schweppes 33cl", 0.75, 1),
       ("CER_PAU500","Cerveza Paulaner Weissbier 500ml", 1.67, 2);

INSERT INTO cliente (DNI, nombre, apellidos, direccion, fNacimiento)
VALUES ("45F", "Miguel", "", "", 01/01/1980);

/*Uniendo tablas con JOIN para mostrar todos los proveedores, cada uno con todos sus productos*/
SELECT * FROM proveedor JOIN producto
  /*Con este, vuelve a repetir la columna id_proveedor al final de la tabla de resultados,
    pues así se encuentra en la tabla producto*/
  -- ON proveedor.id_proveedor = producto.id_proveedor;
  /*Para el operador "=" y columnas que se llamen iguales en ambas tablas, podemos
	hacer (así no repite una columna id_proveedor al final de la tabla de resultados):*/
  USING(id_proveedor);

/*Mostrando sólo algunos campos, como se hace en el pdf de ejemplo. Además, en el SELECT se
  se añade detrás de cada campo escogido el texto para el encabezamiento de la columna. Así,
  si sólo pusiera:
  SELECT proveedor.nombre, producto.nombre, precioUd ...
  En el resultado que arrojaría la consulta tendría dos columnas con el texto "nombre", ya
  que ambos campos se llaman así en sus respectivas tablas. Para evitar confusión, se hace:
  */
SELECT proveedor.nombre proveedor, producto.nombre producto, precioUd
  FROM proveedor JOIN producto
  -- ON proveedor.id_proveedor = producto.id_proveedor;
  USING(id_proveedor);
