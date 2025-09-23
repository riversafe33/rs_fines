CREATE TABLE IF NOT EXISTS `multas` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) DEFAULT NULL,
  `apellido` varchar(50) DEFAULT NULL,
  `id_multado` varchar(50) DEFAULT NULL,
  `motivo` text DEFAULT NULL,
  `monto` decimal(10,2) DEFAULT NULL,
  `autor` varchar(100) DEFAULT NULL,
  `pagada` tinyint(1) DEFAULT 0,
  `recolectada` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`)
);

INSERT IGNORE INTO `items` (`item`, `label`, `limit`, `can_remove`, `type`, `usable`, `metadata`, `desc`, `weight`) VALUES 
('fine_book', 'Fine Book', 200, 1, 'item_standard', 1, '{}', 'book used to issue fines', 0.1);
