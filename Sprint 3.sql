-- Nivel 1

-- Ejercicio 1:

-- La teva tasca és dissenyar i crear una taula anomenada "credit_card" que emmagatzemi detalls crucials sobre les 
-- targetes de crèdit. La nova taula ha de ser capaç d'identificar de manera única cada targeta i establir una relació 
-- adequada amb les altres dues taules ("transaction" i "company"). Després de crear la taula serà necessari que ingressis 
-- la informació del document denominat "dades_introduir_credit". Recorda mostrar el diagrama i realitzar una breu 
-- descripció d'aquest.

-- Primero creé la la tabla
CREATE TABLE IF NOT EXISTS credit_card(
id VARCHAR(20) PRIMARY KEY,
iban VARCHAR(50) NULL,
pan VARCHAR(30) NULL,
pin VARCHAR(4) NULL,
cvv VARCHAR(4) NULL,
expiring_date VARCHAR(15) NULL);

-- Le había asignado el tipo de datos DATE a la columna expiring_date, pero me di cuenta que el formato de los datos proporcionados
-- no coincide con el formato de los datos que espera el tipo DATE(YYYY-MM-DD), así que por eso le di formato VARCHAR a esta columna.
     
-- Luego cargué los datos
-- Y luego creé las conexiones entre las tablas

ALTER TABLE transaction
ADD FOREIGN KEY (credit_card_id)
REFERENCES credit_card(id);

-- Ejercicio 2:
-- El departament de Recursos Humans ha identificat un error en el número de compte de l'usuari amb ID CcU-2938. La informació que ha de 
-- mostrar-se per a aquest registre és: R323456312213576817699999. Recorda mostrar que el canvi es va realitzar.

UPDATE credit_card
SET iban = "R323456312213576817699999"
WHERE id = "CcU-2938";

SELECT *
FROM credit_card
WHERE id = "CcU-2938";

-- Ejercicio 3:
-- En la taula "transaction" ingressa un nou usuari amb la següent informació:


-- Primero agregamos los ID a sus respectivas tablas
INSERT INTO company(id)
VALUES('b-9999');

INSERT INTO credit_card(id)
VALUES('CcU-9999');
-- Y luego si agregamos los valores indicados
INSERT INTO transaction(id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
VALUES('108B1D1D-5B23-A76C-55EF-C568E49A99DD','CcU-9999','b-9999','9999','829.999','-117.999','111.11','0');

SELECT *
FROM transaction
WHERE id = '108B1D1D-5B23-A76C-55EF-C568E49A99DD';

-- 👀 Se observa que el campo timestamp queda en NULL ya que no se nos ha proporcionado este dato

-- Ejercicio 4:
-- Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_card. Recorda mostrar el canvi realitzat.
ALTER TABLE credit_card
DROP COLUMN pan; 

SELECT*
FROM credit_card;

-- Nivel 2

-- Ejercicio 1:
-- Elimina de la taula transaction el registre amb ID 02C6201E-D90A-1859-B4EE-88D2986D3B02 de la base de dades.

DELETE FROM transaction
WHERE ID = '02C6201E-D90A-1859-B4EE-88D2986D3B02';

SELECT *
FROM transaction
WHERE ID = '02C6201E-D90A-1859-B4EE-88D2986D3B02';

-- Ejercicio 2:
-- La secció de màrqueting desitja tenir accés a informació específica per a realitzar anàlisi i estratègies efectives. S'ha 
-- sol·licitat crear una vista que proporcioni detalls clau sobre les companyies i les seves transaccions. Serà necessària que 
-- creïs una vista anomenada VistaMarketing que contingui la següent informació: Nom de la companyia. Telèfon de contacte. País 
-- de residència. Mitjana de compra realitzat per cada companyia. Presenta la vista creada, ordenant les dades de major a menor 
-- mitjana de compra.

CREATE VIEW VistaMarketing AS
SELECT c.company_name, c.phone, c.country, AVG(t.amount) AS MediaCompras
FROM transaction t JOIN company c
ON t.company_id = c.id
GROUP BY c.company_name, c.phone, c.country
ORDER BY MediaCompras ASC;

SELECT * FROM VistaMarketing;

-- Ejercicio 3:
-- Filtra la vista VistaMarketing per a mostrar només les companyies que tenen el seu país de residència en "Germany"
SELECT * 
FROM VistaMarketing
WHERE country = 'Germany';

-- Nivel 3:

-- Ejercicio 1:
-- La setmana vinent tindràs una nova reunió amb els gerents de màrqueting. Un company del teu equip va realitzar modificacions 
-- en la base de dades, però no recorda com les va realitzar. Et demana que l'ajudis a deixar els comandos executats per a obtenir 
-- el següent diagrama:

-- Primero crearé la tabla user:
CREATE INDEX idx_user_id ON transaction(user_id);
 
CREATE TABLE IF NOT EXISTS user (
        id INT PRIMARY KEY,
        name VARCHAR(100),
        surname VARCHAR(100),
        phone VARCHAR(150),
        email VARCHAR(150),
        birth_date VARCHAR(100),
        country VARCHAR(150),
        city VARCHAR(150),
        postal_code VARCHAR(100),
        address VARCHAR(255));
        
-- Cargamos los datos, dentro de ellos agregué el id '9999' el cual corresponde a uno de los ejercicios anteriores
-- Hacemos la conexión entre las tablas

ALTER TABLE transaction
ADD FOREIGN KEY (user_id)
REFERENCES user(id);

-- Ahora pasamos a comparar los cambios realizados:
-- Con respecto a la tabla 'company', vemos que se ha eliminado la columna 'website', por lo tanto:

ALTER TABLE company
DROP COLUMN website;

-- Con respecto a la tabla 'credit_card', vemos que el 'cvv' tiene formato INT y que se crea la columna 'fecha_actual', por lo tanto lo ajustamos:
ALTER TABLE credit_card
MODIFY COLUMN cvv INT,
MODIFY COLUMN expiring_date VARCHAR(10),
ADD COLUMN fecha_actual DATE DEFAULT(CURDATE());

-- Con respecto a la tabla 'user', la tabla tiene un nombre diferente  y la columna 'email' tiene el nombre 'personal_email', por lo tanto: 
ALTER TABLE user 
RENAME TO data_user,
CHANGE COLUMN email personal_email VARCHAR(150);

-- Ejercicio 2:
-- L'empresa també et sol·licita crear una vista anomenada "InformeTecnico" que contingui la següent informació:
-- ID de la transacció, Nom de l'usuari/ària, Cognom de l'usuari/ària, IBAN de la targeta de crèdit usada.
-- Nom de la companyia de la transacció realitzada.
-- Assegura't d'incloure informació rellevant de totes dues taules i utilitza àlies per a canviar de nom columnes segons sigui necessari.
-- Mostra els resultats de la vista, ordena els resultats de manera descendent en funció de la variable ID de transaction.

CREATE VIEW InformeTecnico AS
SELECT t.id AS TransactionID, t.timestamp AS TransactionDate, t.amount AS Amount, u.name UserName, 
u.surname AS UserSurname, cc.iban AS IBAN, c.company_name AS Company
FROM transaction t
JOIN company c
ON t.company_id = c.id
JOIN data_user u
ON t.user_id = u.id
JOIN credit_card cc
ON t.credit_card_id = cc.id
GROUP BY t.id, t.timestamp, t.amount
ORDER BY TransactionID DESC;

SELECT *
FROM InformeTecnico;