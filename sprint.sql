
-- Creación de tablas

CREATE TABLE IF NOT EXISTS Categoria (
  id SERIAL PRIMARY KEY,
  detalle_categoria VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS Cliente (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  apellido VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS Producto (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(255),
  precio DECIMAL(10, 2) NOT NULL,
  color VARCHAR(50) NOT NULL,
  stock INTEGER NOT NULL CHECK (stock >= 0)
);

CREATE TABLE IF NOT EXISTS Proveedor (
  id SERIAL PRIMARY KEY,
  nombre_corporativo VARCHAR(255) NOT NULL,
  representante_legal VARCHAR(255) NOT NULL,
  nombre_contacto VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS Correo (
  id SERIAL PRIMARY KEY,
  detalle_correo VARCHAR(255) NOT NULL,
  proveedor_id INTEGER REFERENCES Proveedor(id)
);

CREATE TABLE IF NOT EXISTS Direccion (
  id SERIAL PRIMARY KEY,
  detalle_direccion VARCHAR(255) NOT NULL,
  cliente_id INTEGER REFERENCES Cliente(id)
);

CREATE TABLE IF NOT EXISTS Telefono (
  id SERIAL PRIMARY KEY,
  numero VARCHAR(20) NOT NULL
);

-- Tablas de relación
CREATE TABLE IF NOT EXISTS ClienteProducto (
  cliente_id INTEGER REFERENCES Cliente(id),
  producto_id INTEGER REFERENCES Producto(id),
  PRIMARY KEY (cliente_id, producto_id)
);

CREATE TABLE IF NOT EXISTS ProveedorProducto (
  proveedor_id INTEGER REFERENCES Proveedor(id),
  producto_id INTEGER REFERENCES Producto(id),
  PRIMARY KEY (proveedor_id, producto_id)
);

CREATE TABLE IF NOT EXISTS TelefonoCliente (
  telefono_id INTEGER REFERENCES Telefono(id),
  cliente_id INTEGER REFERENCES Cliente(id),
  PRIMARY KEY (telefono_id, cliente_id)
);

CREATE TABLE IF NOT EXISTS TelefonoProveedor (
  telefono_id INTEGER REFERENCES Telefono(id),
  proveedor_id INTEGER REFERENCES Proveedor(id),
  PRIMARY KEY (telefono_id, proveedor_id)
);



-- INSERCIÓN DE DATOS

-- Se insertan 5 proveedores
INSERT INTO Proveedor (nombre_corporativo, representante_legal, nombre_contacto) VALUES
('TechnoSupply S.A.', 'Ana Martínez', 'Carlos Soto'),
('GlobalGoods Ltda.', 'Pedro Ramírez', 'Laura Vega'),
('MegaDistribuciones SpA', 'Sofía López', 'Diego Morales'),
('InnovateTrade Inc.', 'Javier Torres', 'Valentina Ruiz'),
('EcoProducts Chile', 'Isabel Navarro', 'Andrés Pinto');

-- Se insertan 5 clientes
INSERT INTO Cliente (nombre, apellido) VALUES
('María', 'González'),
('Juan', 'Rodríguez'),
('Camila', 'Fernández'),
('Roberto', 'Silva'),
('Carolina', 'Muñoz');

-- Se Insertan 10 productos con su respectivo stock y precio en dólares para hacerlo internacional jeje.
INSERT INTO Producto (nombre, precio, color, stock) VALUES
('Smartphone X1', 299.99, 'Negro', 100),
('Laptop UltraSlim', 899.99, 'Plata', 50),
('Auriculares Inalámbricos', 79.99, 'Blanco', 200),
('Smartwatch FitPro', 149.99, 'Negro', 75),
('Tablet Education', 199.99, 'Azul', 80),
('Cámara Digital 4K', 449.99, 'Negro', 30),
('Impresora Multifuncional', 129.99, 'Blanco', 40),
('Monitor Gaming 27"', 299.99, 'Negro', 25),
('Teclado Mecánico RGB', 89.99, 'Negro', 60),
('Mouse Ergonómico', 39.99, 'Gris', 100);

-- Insertamos categorías de ejemplo
INSERT INTO Categoria (detalle_categoria) VALUES
('Smartphones y Accesorios'),
('Laptops y Notebooks'),
('Componentes de PC'),
('Periféricos'),
('Audio y Video'),
('Gaming'),
('Redes y Conectividad'),
('Almacenamiento'),
('Tablets y E-readers'),
('Software');

-- También agregamos datos a las tablas de relación para mantener congruencia.
-- Por ejemplo el asociar algunos productos con proveedores:
INSERT INTO ProveedorProducto (proveedor_id, producto_id) VALUES
(1, 1), -- TechnoSupply provee Smartphone X1
(1, 2), -- TechnoSupply provee Laptop UltraSlim
(2, 3), -- GlobalGoods provee Auriculares Inalámbricos
(3, 4), -- MegaDistribuciones provee Smartwatch FitPro
(4, 5); -- InnovateTrade provee Tablet Education

-- Y asociar algunos productos con clientes (esto simula compras):
INSERT INTO ClienteProducto (cliente_id, producto_id) VALUES
(1, 1), -- María González compró un Smartphone X1
(2, 2), -- Juan Rodríguez compró una Laptop UltraSlim
(3, 3), -- Camila Fernández compró Auriculares Inalámbricos
(4, 4), -- Roberto Silva compró un Smartwatch FitPro
(5, 5); -- Carolina Muñoz compró una Tablet Education



-- ARREGLO EN EL CAMINO

-- EN EL "MER" NOS FALTÓ ESTA COLUMA EN LA TABLA PRODUCTO, LO NOTAMOS AL MOMENTO DE REALIZAR LAS CONSULTAS
-- Añadir columna categoria_id a la tabla Producto
ALTER TABLE Producto ADD COLUMN categoria_id INTEGER;

-- Crear la restricción de clave foránea
ALTER TABLE Producto ADD CONSTRAINT fk_producto_categoria 
FOREIGN KEY (categoria_id) REFERENCES Categoria(id);

-- DESPUÉS NOTAMOS QUE NO PODÍA SER NULA
ALTER TABLE Producto ALTER COLUMN categoria_id SET NOT NULL;



-- CONSULTAS

-- 1. Categoría de productos que más se repite
SELECT c.detalle_categoria, COUNT(*) as cantidad
FROM Producto p
JOIN Categoria c ON p.categoria_id = c.id
GROUP BY c.detalle_categoria
ORDER BY cantidad DESC
LIMIT 1;


-- 2. Productos con mayor stock
SELECT nombre, stock
FROM Producto
ORDER BY stock DESC
LIMIT 5;  -- Puedes ajustar este número para ver más o menos productos

-- 3. Color de producto más común en la tienda
SELECT color, COUNT(*) as cantidad
FROM Producto
GROUP BY color
ORDER BY cantidad DESC
LIMIT 1;

-- 4. Proveedores con menor stock de productos
SELECT pr.nombre_corporativo, COALESCE(SUM(p.stock), 0) as stock_total
FROM Proveedor pr
LEFT JOIN ProveedorProducto pp ON pr.id = pp.proveedor_id
LEFT JOIN Producto p ON pp.producto_id = p.id
GROUP BY pr.id, pr.nombre_corporativo
ORDER BY stock_total ASC
LIMIT 5;  -- Muestra los 5 proveedores con menor stock

-- 5. Cambiar la categoría de productos más popular por 'Electrónica y computación'
-- ESTA CONSULTA NO HA SIDO EJECUTADA EN ESTE SCRIPT, PUEDEN EJECUTARLA PARA VER QUE FUNCIONA.
WITH categoria_popular AS (
    SELECT c.id
    FROM Producto p
    JOIN Categoria c ON p.categoria_id = c.id
    GROUP BY c.id
    ORDER BY COUNT(*) DESC
    LIMIT 1
)
UPDATE Categoria
SET detalle_categoria = 'Electrónica y computación'
WHERE id = (SELECT id FROM categoria_popular);
