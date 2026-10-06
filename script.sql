-- =====================================================================
-- CASO 01 · Panadería La Espiga
-- Checkpoint Unidades 2 y 3 | Bases de Datos II
-- Panadería de barrio que vende pan y repostería, y recibe pedidos para eventos.
-- =====================================================================
CREATE DATABASE IF NOT EXISTS checkpoint_caso_01;
USE checkpoint_caso_01;
CREATE TABLE producto (
    id_producto INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    categoria VARCHAR(50),
    precio DECIMAL(10, 2) NOT NULL,
    stock INT NOT NULL DEFAULT 0
);
CREATE TABLE cliente (
    id_cliente INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(100),
    telefono VARCHAR(20)
);
CREATE TABLE pedido (
    id_pedido INT PRIMARY KEY AUTO_INCREMENT,
    fecha DATE NOT NULL,
    id_cliente INT NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente)
);
CREATE TABLE detalle_pedido (
    id_detalle_pedido INT PRIMARY KEY AUTO_INCREMENT,
    id_pedido INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido),
    FOREIGN KEY (id_producto) REFERENCES producto(id_producto)
);
INSERT INTO producto (nombre, categoria, precio, stock)
VALUES ('Pan francés', 'pan', 800, 120),
    ('Torta de chocolate', 'reposteria', 45000, 8),
    ('Croissant', 'pan', 2500, 60),
    ('Pan de bono', 'pan', 1500, 90),
    ('Torta de zanahoria', 'reposteria', 42000, 6),
    ('Galletas de avena', 'reposteria', 6000, 40);
INSERT INTO cliente (nombre, correo, telefono)
VALUES (
        'Julián Restrepo',
        'julián.restrepo@mail.com',
        '3000100000'
    ),
    (
        'Valentina Ríos',
        'valentina.ríos@mail.com',
        '3000100001'
    ),
    (
        'Santiago Ospina',
        'santiago.ospina@mail.com',
        '3000100002'
    ),
    (
        'Mariana Cárdenas',
        'mariana.cárdenas@mail.com',
        '3000100003'
    ),
    (
        'Felipe Zapata',
        'felipe.zapata@mail.com',
        '3000100004'
    ),
    (
        'Isabella Correa',
        'isabella.correa@mail.com',
        '3000100005'
    );
-- Nota: el último cliente (Isabella Correa) queda sin transacciones a propósito,
-- para practicar LEFT JOIN igual que en la Sesión 4.
INSERT INTO pedido (fecha, id_cliente)
VALUES ('2026-09-02', 1),
    ('2026-09-05', 2),
    ('2026-09-08', 3),
    ('2026-09-11', 4),
    ('2026-09-14', 5),
    ('2026-09-17', 1),
    ('2026-09-20', 2);
INSERT INTO detalle_pedido (
        id_pedido,
        id_producto,
        cantidad,
        precio_unitario
    )
VALUES (1, 2, 1, 45000),
    (1, 3, 2, 2500),
    (2, 4, 2, 1500),
    (2, 5, 3, 42000),
    (3, 6, 3, 6000),
    (3, 1, 1, 800),
    (4, 2, 1, 45000),
    (4, 3, 2, 2500),
    (5, 4, 2, 1500),
    (5, 5, 3, 42000),
    (6, 6, 3, 6000),
    (6, 1, 1, 800),
    (7, 2, 1, 45000),
    (7, 3, 2, 2500);
-- CONSULTAS
1.
SELECT c.nombre AS cliente,
    p.fecha,
    pr.nombre AS producto,
    dp.cantidad
FROM cliente c
    INNER JOIN pedido p ON c.id_cliente = p.id_cliente
    INNER JOIN detalle_pedido dp ON p.id_pedido = dp.id_pedido
    INNER JOIN producto pr ON dp.id_producto = pr.id_producto
ORDER BY c.nombre,
    p.fecha;
-- 
SELECT c.nombre AS cliente,
    SUM(dp.cantidad * dp.precio_unitario) AS total_gastado
FROM cliente c
    INNER JOIN pedido p ON c.id_cliente = p.id_cliente
    INNER JOIN detalle_pedido dp ON p.id_pedido = dp.id_pedido
    INNER JOIN producto pr ON dp.id_producto = pr.id_producto
GROUP BY c.id_cliente,
    c.nombre
ORDER BY total_gastado DESC;
--
SELECT pr.nombre AS producto,
    pr.categoria,
    p.fecha,
    dp.cantidad
FROM producto pr
    INNER JOIN detalle_pedido dp ON pr.id_producto = dp.id_producto
    INNER JOIN pedido p ON dp.id_pedido = p.id_pedido
WHERE pr.categoria = 'reposteria'
ORDER BY p.fecha;
--
SELECT c.nombre AS cliente,
    p.id_pedido,
    p.fecha,
    pr.nombre AS producto,
    dp.cantidad,
    (dp.cantidad * dp.precio_unitario) AS subtotal
FROM cliente c
    INNER JOIN pedido p ON c.id_cliente = p.id_cliente
    INNER JOIN detalle_pedido dp ON p.id_pedido = dp.id_pedido
    INNER JOIN producto pr ON dp.id_producto = pr.id_producto
ORDER BY p.fecha,
    c.nombre;
2.
SELECT c.nombre AS cliente,
    (
        SELECT COUNT(*)
        FROM pedido p
        WHERE p.id_cliente = c.id_cliente
    ) AS cantidad_pedidos
FROM cliente c;
--
SELECT c.nombre AS cliente,
    (
        SELECT SUM(dp.cantidad * dp.precio_unitario)
        FROM pedido p
            INNER JOIN detalle_pedido dp ON p.id_pedido = dp.id_pedido
        WHERE p.id_cliente = c.id_cliente
    ) AS total_gastado
FROM cliente c;
--
SELECT c.nombre AS cliente,
    c.correo
FROM cliente c
WHERE EXISTS (
        SELECT 1
        FROM pedido p
            INNER JOIN detalle_pedido dp ON p.id_pedido = dp.id_pedido
        WHERE p.id_cliente = c.id_cliente
            AND dp.id_producto = 2
    );
3.
SELECT nombre,
    categoria,
    precio
FROM producto
WHERE categoria = 'pan'
UNION
SELECT nombre,
    categoria,
    precio
FROM producto
WHERE categoria = 'reposteria'
ORDER BY categoria,
    nombre;
--
SELECT nombre,
    'producto caro' AS tipo
FROM producto
WHERE precio >= 10000
UNION
SELECT nombre,
    'stock bajo' AS tipo
FROM producto
WHERE stock < 10
ORDER BY nombre;
--
SELECT nombre,
    'cliente frecuente' AS tipo
FROM cliente
WHERE id_cliente IN (
        SELECT id_cliente
        FROM pedido
        GROUP BY id_cliente
        HAVING COUNT(*) > 1
    )
UNION
SELECT nombre,
    'cliente sin pedidos' AS tipo
FROM cliente
WHERE id_cliente NOT IN (
        SELECT id_cliente
        FROM pedido
    )
ORDER BY nombre;