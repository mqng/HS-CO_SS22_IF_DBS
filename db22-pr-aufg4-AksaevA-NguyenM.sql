DROP DATABASE IF EXISTS wwfakng;
CREATE DATABASE IF NOT EXISTS wwfakng;
USE wwfakng;
CREATE TABLE Modelle(
	Modellnummer VARCHAR(45) NOT NULL,
	Hersteller VARCHAR(45),
    MaxBetriebsstunden INT NOT NULL,
    PRIMARY KEY(Modellnummer)
);

CREATE TABLE Maschine(
	Kennzeichen VARCHAR(45) NOT NULL,
    BetriebsstundenSeitWartung INT NOT NULL,
    BetriebsstundenGesamt INT NOT NULL,
    DatumInDienstStellung DATE NOT NULL,
    IstImBetrieb BOOLEAN NOT NULL,
    Modelle_Modellnummer VARCHAR(45) NOT NULL,
    PRIMARY KEY(Kennzeichen),
    FOREIGN KEY(Modelle_Modellnummer) REFERENCES Modelle(Modellnummer)
);

CREATE TABLE Ausstattung(
	idAusstattung INT NOT NULL AUTO_INCREMENT,
    AusstattungsTyp VARCHAR(45),
    PRIMARY KEY(idAusstattung)
);

CREATE TABLE Maschine_has_Ausstattung(
	Maschine_Kennzeichen VARCHAR(45) NOT NULL,
    Maschine_Modelle_Modellnummer VARCHAR(45) NOT NULL,
    Ausstattung_idAusstattung INT NOT NULL,
    FOREIGN KEY(Maschine_Kennzeichen) REFERENCES Maschine(Kennzeichen),
    FOREIGN KEY(Maschine_Modelle_Modellnummer) REFERENCES Maschine(Modelle_Modellnummer),
    FOREIGN KEY(Ausstattung_idAusstattung) REFERENCES Ausstattung(idAusstattung)
);

CREATE TABLE Kunden(
	idKunden INT NOT NULL AUTO_INCREMENT,
    PRIMARY KEY(idKunden)
);
  
CREATE TABLE Buchungsklasse(
	Bezeichnung VARCHAR(45) NOT NULL,
    Stufe INT,
    PRIMARY KEY(Bezeichnung)
  );
  
CREATE TABLE Tarif(
	idTarif INT NOT NULL AUTO_INCREMENT,
    Preis DECIMAL(6,2) NOT NULL,
    Tarifart VARCHAR(45),
    Buchungsklasse_Bezeichnung VARCHAR(45) NOT NULL,
    PRIMARY KEY(idTarif),
    FOREIGN KEY(Buchungsklasse_Bezeichnung) REFERENCES Buchungsklasse(Bezeichnung)
);

CREATE TABLE Flughafen(
	Kürzel VARCHAR(3) NOT NULL,
    Sicherheitsgebühren DECIMAL(5,2) NOT NULL,
    Steuern DECIMAL(5,2) NOT NULL,
    FlughafenTimezone VARCHAR(6) NOT NULL,
    Flughafen_Kürzel VARCHAR(3),
    PRIMARY KEY(Kürzel),
    FOREIGN KEY(Flughafen_Kürzel) REFERENCES Flughafen(Kürzel)
);

CREATE TABLE Flugverbindung(
	Flugnummer INT NOT NULL,
    Abflugszeit TIME NOT NULL,
    Ankunftszeit TIME NOT NULL,
    Wochentage VARCHAR(45) NOT NULL,
    Kerosinzuschlag DECIMAL(5,2) NOT NULL,
	LängeDerStrecke INT,
    FLUGHAFEN1_Kürzel VARCHAR(3) NOT NULL,
    FLUGHAFEN2_Kürzel VARCHAR(3) NOT NULL,
    Modelle_Modellnummer VARCHAR(45) NOT NULL,
    PRIMARY KEY(Flugnummer),
    FOREIGN KEY(FLUGHAFEN1_Kürzel) REFERENCES Flughafen(Kürzel),
    FOREIGN KEY(FLUGHAFEN2_Kürzel) REFERENCES Flughafen(Kürzel),
    FOREIGN KEY(Modelle_Modellnummer) REFERENCES Modelle(Modellnummer)
);

CREATE TABLE Flug(
	BuchungsNummer VARCHAR(10) NOT NULL,
    FlugDatum DATE NOT NULL,
    Maschine_Kennzeichen VARCHAR(45),
    Maschine_Modelle_Modellnummer VARCHAR(45),
    Flugverbindung_Flugnummer INT NOT NULL,
    Tarif_idTarif INT NOT NULL,
    PRIMARY KEY(Buchungsnummer),
    FOREIGN KEY(Maschine_Kennzeichen) REFERENCES Maschine(Kennzeichen),
    FOREIGN KEY(Maschine_Modelle_Modellnummer) REFERENCES Maschine(Modelle_Modellnummer),
    FOREIGN KEY(Flugverbindung_Flugnummer) REFERENCES Flugverbindung(Flugnummer),
    FOREIGN KEY(Tarif_idTarif) REFERENCES Tarif(idTarif)
);

CREATE TABLE Flug_has_Kunden(
	Flug_Buchungsnummer VARCHAR(10) NOT NULL, 
    Kunden_idKunden INT NOT NULL,
    FOREIGN KEY(Flug_Buchungsnummer) REFERENCES Flug(Buchungsnummer),
    FOREIGN KEY(Kunden_idKunden) REFERENCES Kunden(idKunden)
);

CREATE TABLE Platzangebot(
	AnzahlPlätze INT NOT NULL,
    VerfügbarePlätze VARCHAR(45) NOT NULL,
    Modelle_Modellnummer VARCHAR(45) NOT NULL,
    Buchungsklasse_Bezeichnung VARCHAR(45) NOT NULL,
    Flugverbindung_Flugnummer INT NOT NULL,
    FOREIGN KEY (Modelle_Modellnummer) REFERENCES Modelle(Modellnummer),
    FOREIGN KEY (Buchungsklasse_Bezeichnung) REFERENCES Buchungsklasse(Bezeichnung),
    FOREIGN KEY (Flugverbindung_Flugnummer) REFERENCES Flugverbindung(Flugnummer)
);

CREATE TABLE Rechnung(
	Rechnungsnummer INT NOT NULL,
    Flugverbindung_Flugnummer INT NOT NULL,
    Flugverbindung_Flughafen1_Kürzel VARCHAR(3) NOT NULL,
    Flugverbindung_Flughafen2_Kürzel VARCHAR(3) NOT NULL,
    Tarif_idTarif INT NOT NULL,
    PRIMARY KEY (Rechnungsnummer),
    FOREIGN KEY (Flugverbindung_Flugnummer) REFERENCES Flugverbindung(Flugnummer),
    FOREIGN KEY (Flugverbindung_Flughafen1_Kürzel) REFERENCES Flugverbindung(Flughafen1_Kürzel),
    FOREIGN KEY (Flugverbindung_Flughafen2_Kürzel) REFERENCES Flugverbindung(Flughafen2_Kürzel),
    FOREIGN KEY (Tarif_idTarif) REFERENCES Tarif(idTarif)
);



### ÄNDERUNGEN VOM MODELL


/*
*	Lösche FK aus Entity Flughafen und erstelle rekursive n:m Beziehung anstelle 1:n
*/
ALTER TABLE Flughafen DROP FOREIGN KEY flughafen_ibfk_1;
ALTER TABLE Flughafen DROP COLUMN Flughafen_Kürzel;
CREATE TABLE Nachbar_Flughäfen(
	Flughafen1_Kürzel VARCHAR(3) NOT NULL,
	Flughafen2_Kürzel VARCHAR(3) NOT NULL,
    FOREIGN KEY(Flughafen1_Kürzel) REFERENCES Flughafen(Kürzel),
	FOREIGN KEY(Flughafen2_Kürzel) REFERENCES Flughafen(Kürzel)
);

/*
* Erstelle Liste von Wochentagen an denen Flugverbindungen fliegen	
*/
ALTER TABLE Flugverbindung DROP COLUMN Wochentage;
CREATE TABLE Wochentage(
	Wochentag VARCHAR(20) NOT NULL,
    PRIMARY KEY(Wochentag)
);
 CREATE TABLE Flugverbindung_Tage( # Erstelle n:m Beziehung zwischen den Flugverbindungen und Wochentagen 
	Flugverbindung_Flugnummer INT NOT NULL,
    Wochentage_Wochentag VARCHAR(20) NOT NULL,
    FOREIGN KEY(Flugverbindung_Flugnummer) REFERENCES Flugverbindung(Flugnummer),
    FOREIGN KEY(Wochentage_Wochentag) REFERENCES Wochentage(Wochentag)
 );


/*
* Kunde wird gelöscht da nicht benötigt
*/
DROP TABLE Flug_has_Kunden;
DROP TABLE Kunden;

/*
* Flug wird Anforderungen angepasst
*/
ALTER TABLE Flug DROP PRIMARY KEY, DROP COLUMN Buchungsnummer,
 DROP COLUMN FlugDatum,
 DROP FOREIGN KEY flug_ibfk_2, DROP COLUMN Maschine_Modelle_Modellnummer,
 DROP FOREIGN KEY flug_ibfk_4, DROP COLUMN Tarif_idTarif,
 ADD Wochentag VARCHAR(20), ADD FOREIGN KEY(Wochentag) REFERENCES Wochentage(Wochentag);

/*
* Tarif benötigt noch Flugnummer als Foreign Key
*/
ALTER TABLE Tarif ADD Flugnummer INT NOT NULL, ADD FOREIGN KEY(Flugnummer) REFERENCES Flugverbindung(Flugnummer);



### BESTANDSDATEN EINFÜGEN


INSERT INTO Modelle VALUES ('A321', 'Airbus', 50000),
	('A340-600', 'Airbus', 60000),
	('747-400', 'Boeing', 50000),
	('737-300', 'Boeing', 45000),
	('CRJ900', 'Bombardier', 55000);

INSERT INTO Maschine VALUES ('D-ABYZ',643, 12345, '2005-04-09', TRUE, 'A321'),
	('D-CDUX', 804, 15223, '2005-04-09', TRUE, 'A321'),
	('D-BAXY', 231, 45632, '2001-03-27', TRUE, 'A321'),
	('D-EFST', 998, 4102, '2007-02-02', TRUE, 'A340-600'),
	('D-GHQR', 654, 2023, '2009-10-05', TRUE, 'A340-600'),
	('D-IKOP', 821, 45632, '2002-03-04', TRUE, '747-400'),
	('D-BORD', 678, 9854, '2003-08-10', TRUE, '737-300'),
	('D-LMNA', 70, 1432, '2007-03-08', TRUE, 'CRJ900');

INSERT INTO Ausstattung(Ausstattungstyp) VALUES ('Internet-Anbindung'), ('Satelliten-Telefon');

INSERT INTO Maschine_has_Ausstattung VALUES ('D-EFST', 'A340-600', 1),
	('D-EFST', 'A340-600', 2),
	('D-GHQR', 'A340-600', 1),
	('D-IKOP', '747-400', 1),
	('D-IKOP', '747-400', 2);

INSERT INTO Flughafen VALUES ('NUE', 20.00, 30.00, '+1'),
	('MUC', 25.00, 30.00, '+1'),
	('STR', 20.00, 30.00, '+1'),
	('FRA', 25.00, 30.00, '+1'),
	('TXL', 20.00, 30.00, '+1'),
	('CDG', 25.00, 35.00, '+1'),
	('LHR', 30.00, 40.00, '0'),
	('LCY', 30.00, 40.00, '0'),
	('SFO', 30.00, 50.00, '-8');

INSERT INTO Nachbar_Flughäfen VALUES ('NUE', 'MUC'), ('STR', 'FRA'), ('LHR', 'LCY');

INSERT INTO Flugverbindung VALUES (925, '9:40:00', '10:30:00', '10.00', NULL, 'NUE', 'FRA', 'A321'),
	(926, '12:00:00', '13:10:00', '10.00', NULL, 'FRA', 'NUE', 'A321'),
	(929, '9:40:00', '10:30:00', '10.00', NULL, 'NUE', 'FRA', 'CRJ900'),
	(310, '6:45:00', '8:00:00', '10.00', NULL, 'NUE', 'TXL', 'A321'),
	(312, '9:15:00', '10:30:00', '10.00', NULL, 'TXL', 'NUE', 'A321'),
	(4756, '13:05:00', '14:05:00', '20.00', NULL, 'MUC', 'LHR', 'A340-600'),
	(9488, '16:00:00', '17:20:00', '20.00', NULL, 'MUC', 'LCY', '737-300'),
	(4210, '16:00:00', '17:20:00', '20.00', NULL, 'MUC', 'CDG', 'A340-600'),
	(5210, '17:50:00', '21:00:00', '40.00', NULL, 'CDG', 'SFO', 'A340-600'),
	(4711, '10:00:00', '13:50:00', '40.00', NULL, 'MUC', 'SFO', '747-400');

INSERT INTO Wochentage VALUES ('Montag'), ('Dienstag'), ('Mittwoch'), ('Donnerstag'), ('Freitag'), ('Samstag'), ('Sonntag');

INSERT INTO Flugverbindung_Tage VALUES (925, 'Montag'), (925, 'Dienstag'), (925, 'Mittwoch'), (925, 'Donnerstag'), (925, 'Freitag'),
	(926, 'Montag'), (926, 'Dienstag'), (926, 'Mittwoch'), (926, 'Donnerstag'), (926, 'Freitag'),
	(929, 'Samstag'), (929, 'Sonntag'),
	(310, 'Montag'), (310, 'Dienstag'), (310, 'Mittwoch'), (310, 'Donnerstag'), (310, 'Freitag'),
	(312, 'Montag'), (312, 'Dienstag'), (312, 'Mittwoch'), (312, 'Donnerstag'), (312, 'Freitag'),
	(4756, 'Montag'), (4756, 'Dienstag'), (4756, 'Mittwoch'), (4756, 'Donnerstag'), (4756, 'Freitag'), (4756, 'Samstag'), (4756, 'Sonntag'),
	(9488, 'Montag'), (9488, 'Dienstag'), (9488, 'Mittwoch'), (9488, 'Donnerstag'), (9488, 'Freitag'),
	(4210, 'Montag'), (4210, 'Mittwoch'), (4210, 'Freitag'),
	(5210, 'Montag'), (5210, 'Mittwoch'), (5210, 'Freitag'),
	(4711, 'Dienstag'), (4711, 'Donnerstag');

INSERT INTO Flug VALUES ('D-ABYZ', 925, 'Montag'),
	('D-CDUX', 926, 'Montag'),
	('D-LMNA', 929, 'Samstag'),
	('D-BAXY', 310, 'Freitag'),
	('D-BAXY', 312, 'Freitag'),
	('D-EFST', 4756, 'Mittwoch'),
	('D-BORD', 9488, 'Donnerstag'),
	('D-GHQR', 4210, 'Mittwoch'),
	('D-GHQR', 5210, 'Mittwoch'),
	('D-IKOP', 4711, 'Dienstag');

INSERT INTO Buchungsklasse VALUES ('Economy', 3), ('Business', 2), ('First', 1);

INSERT INTO Tarif(Preis, Tarifart, Buchungsklasse_Bezeichnung, Flugnummer) VALUES ('190.00', 'Normaltarif', 'Economy', 925), ('140.00', 'Frühbucher', 'Economy', 925), ('100.00', 'Last Minute', 'Economy', 925),
	('190.00', 'Normaltarif', 'Economy', 926), ('140.00', 'Frühbucher', 'Economy', 926), ('100.00', 'Last Minute', 'Economy', 926),
	('190.00', 'Normaltarif', 'Economy', 929), ('140.00', 'Frühbucher', 'Economy', 929), ('100.00', 'Last Minute', 'Economy', 929),
	('210.00', 'Normaltarif', 'Economy', 310), ('165.00', 'Frühbucher', 'Economy', 310), ('120.00', 'Last Minute', 'Economy', 310),
	('210.00', 'Normaltarif', 'Economy', 312), ('165.00', 'Frühbucher', 'Economy', 312), ('120.00', 'Last Minute', 'Economy', 312),
	('240.00', 'Normaltarif', 'Economy', 4756), ('210.00', 'Frühbucher', 'Economy', 4756), ('160.00', 'Last Minute', 'Economy', 4756),
	('470.00', 'Normaltarif', 'Business', 4756), ('390.00', 'Frühbucher', 'Business', 4756),
	('690.00', 'Normaltarif', 'First', 4756), ('590.00', 'Frühbucher', 'First', 4756),
	('240.00', 'Normaltarif', 'Economy', 4210), ('210.00', 'Frühbucher', 'Economy', 4210), ('160.00', 'Last Minute', 'Economy', 4210),
	('490.00', 'Normaltarif', 'Business', 4210), ('400.00', 'Frühbucher', 'Business', 4210),
	('700.00', 'Normaltarif', 'First', 4210), ('600.00', 'Frühbucher', 'First', 4210),
	('350.00', 'Normaltarif', 'Economy', 5210), ('300.00', 'Frühbucher', 'Economy', 5210), ('290.00', 'Last Minute', 'Economy', 5210),
	('690.00', 'Normaltarif', 'Business', 5210), ('630.00', 'Frühbucher', 'Business', 5210),
	('810.00', 'Normaltarif', 'First', 5210), ('750.00', 'Frühbucher', 'First', 5210),
	('610.00', 'Normaltarif', 'Economy', 4711), ('540.00', 'Frühbucher', 'Economy', 4711), ('480.00', 'Last Minute', 'Economy', 4711),
	('1050.00', 'Normaltarif', 'Business', 4711), ('890.00', 'Frühbucher', 'Business', 4711), ('950.00', 'Last Minute', 'Business', 4711),
	('1820.00', 'Normaltarif', 'First', 4711), ('1500.00', 'Frühbucher', 'First', 4711),
	('240.00', 'Normaltarif', 'Economy', 9488), ('210.00', 'Frühbucher', 'Economy', 9488), ('160.00', 'Last Minute', 'Economy', 9488);


-- Aufgabenblatt 03 --

-- Füge Bezeichnungen der Flughäfen zur Tabelle Flughafen hinzu --
ALTER TABLE Flughafen ADD Bezeichnung VARCHAR(45);
UPDATE Flughafen SET Bezeichnung = 'Nürnberg' WHERE Kürzel = 'NUE';
UPDATE Flughafen SET Bezeichnung = 'München' WHERE Kürzel = 'MUC';
UPDATE Flughafen SET Bezeichnung = 'Stuttgart' WHERE Kürzel = 'STR';
UPDATE Flughafen SET Bezeichnung = 'Frankfurt' WHERE Kürzel = 'FRA';
UPDATE Flughafen SET Bezeichnung = 'Berlin-Tegel' WHERE Kürzel = 'TXL';
UPDATE Flughafen SET Bezeichnung = 'Paris-Charles De Gaulle' WHERE Kürzel = 'CDG';
UPDATE Flughafen SET Bezeichnung = 'London-Heathrow' WHERE Kürzel = 'LHR';
UPDATE Flughafen SET Bezeichnung = 'London-City' WHERE Kürzel = 'LCY';
UPDATE Flughafen SET Bezeichnung = 'San Francisco' WHERE Kürzel = 'SFO';

-- Spalten VerfügbarePlätze und Flugnummer werden so geändert, dass sie null-Werte zulassen, da diese nicht sofort gefüllt werden müssen --
ALTER TABLE Platzangebot
	MODIFY COLUMN VerfügbarePlätze int,
	DROP FOREIGN KEY platzangebot_ibfk_3,
	MODIFY COLUMN Flugverbindung_Flugnummer int,
	ADD FOREIGN KEY(Flugverbindung_Flugnummer) REFERENCES Flugverbindung(Flugnummer);

-- Fülle Platzangebot mit gegebenen Werten
INSERT INTO Platzangebot(AnzahlPlätze, Modelle_Modellnummer, Buchungsklasse_Bezeichnung) VALUES 
	(190, 'A321', 'Economy'),
    (238, 'A340-600', 'Economy'), (60, 'A340-600', 'Business'), (238, 'A340-600', 'First'),
    (270, '747-400', 'Economy'), (66, '747-400', 'Business'), (16, '747-400', 'First'),
    (127, '737-300', 'Economy'), (86, 'CRJ900', 'Economy');
    
-- Ändere Indienststellungsdatum --
UPDATE Maschine SET DatumInDienstStellung = '2010-04-09' WHERE Kennzeichen = 'D-ABYZ';
UPDATE Maschine SET DatumInDienstStellung = '2010-04-09' WHERE Kennzeichen = 'D-CDUX';
UPDATE Maschine SET DatumInDienstStellung = '2006-03-27' WHERE Kennzeichen = 'D-BAXY';
UPDATE Maschine SET DatumInDienstStellung = '2012-02-02' WHERE Kennzeichen = 'D-EFST';
UPDATE Maschine SET DatumInDienstStellung = '2014-10-05' WHERE Kennzeichen = 'D-GHQR';
UPDATE Maschine SET DatumInDienstStellung = '2007-03-04' WHERE Kennzeichen = 'D-IKOP';
UPDATE Maschine SET DatumInDienstStellung = '2008-08-10' WHERE Kennzeichen = 'D-BORD';
UPDATE Maschine SET DatumInDienstStellung = '2012-03-08' WHERE Kennzeichen = 'D-LMNA';

-- Ändere Werte für die Zeitzone um Uhrzeit mit Zeitzone berechnen zu können --
ALTER TABLE Flughafen MODIFY FlughafenTimezone VARCHAR(10);
UPDATE Flughafen SET FlughafenTimezone = "1:00:00" WHERE FlughafenTimezone = "+1";
UPDATE Flughafen SET FlughafenTimezone = "-8:00:00" WHERE FlughafenTimezone = "-8";



### ABFRAGEN ERSTELLEN


CREATE OR REPLACE VIEW abfrage01 AS 
	SELECT Kürzel, Bezeichnung, FlughafenTimezone FROM Flughafen 
    ORDER BY Bezeichnung;
    
CREATE OR REPLACE VIEW abfrage02 AS
	SELECT Maschine.Kennzeichen FROM Maschine 
    INNER JOIN Modelle ON Maschine.Modelle_Modellnummer = Modelle.Modellnummer
    WHERE Modelle.Hersteller != 'Boeing';
    
CREATE OR REPLACE VIEW abfrage03 AS
	SELECT DISTINCT Modelle.Hersteller, Modelle.Modellnummer, Maschine.Kennzeichen FROM Modelle
	LEFT JOIN Maschine ON Modelle.Modellnummer = Maschine.Modelle_Modellnummer 
	INNER JOIN Maschine_has_Ausstattung ON Modelle.Modellnummer = Maschine_has_Ausstattung.Maschine_Modelle_Modellnummer
    ORDER BY Hersteller, Modellnummer, Kennzeichen ASC;
    
CREATE OR REPLACE VIEW abfrage04 AS
	SELECT count(*) AS Anzahl_mit_Satellitentelefon FROM Maschine_has_Ausstattung
    WHERE Ausstattung_idAusstattung = 2;

CREATE OR REPLACE VIEW abfrage05 AS
	SELECT count(*) AS Anzahl, Modelle.Hersteller FROM Maschine
	INNER JOIN Modelle ON Modelle.Modellnummer = Maschine.Modelle_Modellnummer	
    GROUP BY Hersteller ORDER BY Hersteller ASC;
    
CREATE OR REPLACE VIEW abfrage06 AS
    SELECT  Modelle.Hersteller, Modelle_Modellnummer AS Modell FROM Flugverbindung
    INNER JOIN Modelle ON Flugverbindung.Modelle_Modellnummer = Modelle.Modellnummer
    GROUP BY Modelle_Modellnummer HAVING count(*) = 1 ORDER BY Hersteller, Modell ASC;

CREATE OR REPLACE VIEW abfrage07 AS 
	SELECT Hersteller, Modellnummer, SUM(Platzangebot.AnzahlPlätze) AS Gesamtanzahl_Plätze FROM Modelle
    INNER JOIN Platzangebot ON Modelle.Modellnummer = Platzangebot.Modelle_Modellnummer
    GROUP BY Modellnummer HAVING Gesamtanzahl_Plätze > 150
    ORDER BY Hersteller, Modellnummer ASC;

CREATE OR REPLACE VIEW abfrage08 AS
	SELECT Flugverbindung.Flugnummer, 
    (SELECT Bezeichnung FROM Flughafen WHERE Kürzel = Flugverbindung.FLUGHAFEN1_Kürzel) AS Startflughafen,
    (SELECT Bezeichnung FROM Flughafen WHERE Kürzel = Flugverbindung.FLUGHAFEN2_Kürzel) AS Zielflughafen, Tarif.Preis FROM Flugverbindung
    INNER JOIN Tarif ON Flugverbindung.Flugnummer = Tarif.Flugnummer
    INNER JOIN Flughafen ON Flugverbindung.FLUGHAFEN1_Kürzel = Flughafen.Kürzel
    HAVING Tarif.Preis > 250
    ORDER BY Startflughafen, Zielflughafen;

CREATE OR REPLACE VIEW abfrage09 AS
	SELECT Modelle.Hersteller, Modelle_Modellnummer, Kennzeichen
    FROM Maschine INNER JOIN Modelle ON Maschine.Modelle_Modellnummer = Modelle.Modellnummer
    WHERE (YEAR(CURDATE()) - YEAR(Maschine.DatumInDienstStellung)) <= 10
    AND (YEAR(CURDATE()) - YEAR(Maschine.DatumInDienstStellung)) >= 5;

CREATE OR REPLACE VIEW abfrage10 AS
	SELECT Kürzel, Bezeichnung, (Sicherheitsgebühren + Steuern) AS Zusatzkosten FROM Flughafen 
    HAVING Zusatzkosten = (SELECT MIN((Sicherheitsgebühren + Steuern)) FROM Flughafen) 
    ORDER BY Bezeichnung ASC;
    
CREATE OR REPLACE VIEW abfrage11 AS 
	SELECT Modelle.Hersteller, Maschine.Modelle_Modellnummer, Maschine.Kennzeichen FROM Maschine
	INNER JOIN Modelle ON Maschine.Modelle_Modellnummer = Modelle.Modellnummer
	LEFT OUTER JOIN Maschine_has_Ausstattung ON Maschine.Kennzeichen = Maschine_has_Ausstattung.Maschine_Kennzeichen
	WHERE Maschine_has_Ausstattung.Maschine_Kennzeichen IS NULL
	ORDER BY Modelle.Hersteller, Maschine.Modelle_Modellnummer, Maschine.Kennzeichen ASC;

CREATE OR REPLACE VIEW abfrage12 AS 
	SELECT (Kerosinzuschlag + Preis + Flughafen.Steuern + Flughafen.Sicherheitsgebühren) AS Preis, (SELECT Bezeichnung FROM Flughafen WHERE Flugverbindung.FLUGHAFEN2_Kürzel = Flughafen.Kürzel) AS Ziel
    FROM Flughafen INNER JOIN Flugverbindung ON Flughafen.Kürzel = Flugverbindung.FLUGHAFEN1_KÜRZEL
    INNER JOIN Tarif ON Flugverbindung.Flugnummer = Tarif.Flugnummer
    WHERE (Flugverbindung.FLUGHAFEN1_KÜRZEL = 'MUC' OR Flugverbindung.FLUGHAFEN1_KÜRZEL = 'FRA')
    AND Tarif.Tarifart = 'Normaltarif' AND Tarif.Buchungsklasse_Bezeichnung = 'Economy';

CREATE OR REPLACE VIEW abfrage13 AS   
	SELECT Flughafen.Bezeichnung, Flughafen.Kürzel, IFNULL(Anzahl_Start,0) AS Anzahl_startender_Flugverbindungen, IFNULL(Anzahl_Ziel,0) AS Anzahl_endender_Flugverbindungen FROM Flughafen 
	LEFT JOIN (SELECT Flughafen1_Kürzel, count(*) AS Anzahl_Start FROM Flugverbindung GROUP BY FLUGHAFEN1_Kürzel) AS Start 
		ON Start.FLUGHAFEN1_Kürzel = Flughafen.Kürzel
	LEFT JOIN (SELECT Flughafen2_Kürzel, count(*) AS Anzahl_Ziel FROM Flugverbindung GROUP BY FLUGHAFEN2_Kürzel) AS Ziel 
		ON Ziel.FLUGHAFEN2_Kürzel = Flughafen.Kürzel
	ORDER BY Flughafen.Kürzel ASC;   

CREATE OR REPLACE VIEW abfrage14 AS
	SELECT Modelle.Hersteller, Modelle.Modellnummer, Maschine.Kennzeichen, Modelle.MaxBetriebsstunden - Maschine.BetriebsstundenGesamt AS VerbleibendeStunden
    FROM Maschine INNER JOIN Modelle ON Maschine.Modelle_Modellnummer = Modelle.Modellnummer
    HAVING VerbleibendeStunden = (SELECT MIN(Modelle.MaxBetriebsstunden - Maschine.BetriebsstundenGesamt)
    FROM Maschine INNER JOIN Modelle ON Maschine.Modelle_Modellnummer = Modelle.Modellnummer);

CREATE OR REPLACE VIEW abfrage15 AS
	SELECT Start.Bezeichnung AS Von, Ziel.Bezeichnung AS Nach, T.Günstigster_Preis FROM Flugverbindung 
	INNER JOIN Flughafen AS Start ON Flugverbindung.FLUGHAFEN1_Kürzel = Start.Kürzel
	INNER JOIN Flughafen AS Ziel ON Flugverbindung.FLUGHAFEN2_Kürzel = Ziel.Kürzel
	INNER JOIN (SELECT MIN(preis) AS Günstigster_Preis, Flugnummer FROM Tarif GROUP BY Flugnummer) AS T 
		ON T.Flugnummer = Flugverbindung.Flugnummer
	ORDER BY Von, Nach ASC;
    
CREATE OR REPLACE VIEW abfrage16 AS
    SELECT 
        Flugverbindung.Flugnummer,
        Abflugflughafen,
        Ankunftsflughafen,
        Zeit.Gesamtzeit
    FROM
        Flugverbindung
            INNER JOIN
        (SELECT 
            Flughafen.Bezeichnung AS Abflugflughafen, Flughafen.Kürzel
        FROM
            Flughafen) AS F1 ON Flugverbindung.FLUGHAFEN1_Kürzel = F1.Kürzel
            INNER JOIN
        (SELECT 
            Flughafen.Bezeichnung AS Ankunftsflughafen, Flughafen.Kürzel
        FROM
            Flughafen) AS F2 ON Flugverbindung.FLUGHAFEN2_Kürzel = F2.Kürzel
            INNER JOIN
        (SELECT 
            TIME(ABS(TIMEDIFF(Z_An.Ankunftszeit, Z_Ab.Abflugszeit))) AS Gesamtzeit,
                Z_Ab.Flugnummer
        FROM
            (SELECT 
            CONVERT( SUBTIME(Flugverbindung.Ankunftszeit, Flughafen.FlughafenTimezone) , TIME) AS Ankunftszeit,
                Flugnummer
        FROM
            Flugverbindung
        INNER JOIN Flughafen ON Flugverbindung.FLUGHAFEN2_Kürzel = Flughafen.Kürzel) AS Z_An
        INNER JOIN (SELECT 
            CONVERT( SUBTIME(Flugverbindung.Abflugszeit, Flughafen.FlughafenTimezone) , TIME) AS Abflugszeit,
                Flugnummer
        FROM
            Flugverbindung
        INNER JOIN Flughafen ON Flugverbindung.FLUGHAFEN1_Kürzel = Flughafen.Kürzel) AS Z_Ab ON Z_An.Flugnummer = Z_Ab.Flugnummer) AS Zeit ON Zeit.Flugnummer = Flugverbindung.Flugnummer
    ORDER BY Abflugflughafen , Ankunftsflughafen ASC;

CREATE OR REPLACE VIEW abfrage17 AS 
	SELECT Flugverbindung.Flugnummer, Abflugflughafen, Ankunftsflughafen, Flugverbindung.Abflugszeit, Flugverbindung.Ankunftszeit FROM Flugverbindung
		INNER JOIN (SELECT Flughafen.Bezeichnung AS Abflugflughafen, Flughafen.Kürzel FROM Flughafen) AS F1 ON Flugverbindung.FLUGHAFEN1_Kürzel = F1.Kürzel
		INNER JOIN (SELECT Flughafen.Bezeichnung AS Ankunftsflughafen, Flughafen.Kürzel FROM Flughafen) AS F2 ON Flugverbindung.FLUGHAFEN2_Kürzel = F2.Kürzel
		RIGHT JOIN (SELECT Bezeichnung_Flughafen1, Bezeichnung_Flughafen2 FROM Nachbar_Flughäfen 
						INNER JOIN (SELECT Flughafen.Bezeichnung AS Bezeichnung_Flughafen1,Flughafen.Kürzel FROM Flughafen) AS NB1 ON NB1.Kürzel = Nachbar_Flughäfen.Flughafen1_Kürzel
						INNER JOIN (SELECT Flughafen.Bezeichnung AS Bezeichnung_Flughafen2,Flughafen.Kürzel FROM Flughafen) AS NB2 ON NB2.Kürzel = Nachbar_Flughäfen.Flughafen2_Kürzel HAVING Bezeichnung_Flughafen1="London-City" OR Bezeichnung_Flughafen2 = "London-City") AS NB
		ON (F2.Ankunftsflughafen = NB.Bezeichnung_Flughafen1 OR F2.Ankunftsflughafen = NB.Bezeichnung_Flughafen2)
		HAVING Abflugflughafen = "München";

CREATE OR REPLACE VIEW abfrage18 AS
	SELECT Flugverbindung.Flugnummer AS Flugnummer1, von1, Flugverbindung.Abflugszeit AS Abflug1,nach1, Flugverbindung.Ankunftszeit AS Ankunft1, "-" AS Flugnummer2, "-" AS von2, "-" AS Abflug2, "-" AS nach2,  "-" AS Ankunft2 FROM Flugverbindung  
		INNER JOIN (SELECT Flughafen.Bezeichnung AS von1, Flughafen.Kürzel FROM Flughafen) AS F1 ON Flugverbindung.FLUGHAFEN1_Kürzel = F1.Kürzel  
		INNER JOIN (SELECT Flughafen.Bezeichnung AS nach1, Flughafen.Kürzel FROM Flughafen) AS F2 ON Flugverbindung.FLUGHAFEN2_Kürzel = F2.Kürzel        
		HAVING von1 = "München" AND nach1 = "San Francisco"
	UNION
	SELECT F1.Flugnummer AS Flugnummer1, von1, F1.Abflugszeit AS Abflug1, nach1, F1.Ankunftszeit AS Ankunft1, 
		F2.Flugnummer AS Flugnummer2, von2, F2.Abflugszeit AS Abflug2, nach2, F2.Ankunftszeit AS Ankunft2 
		FROM Flugverbindung AS F1 INNER JOIN Flugverbindung AS F2 ON F1.FLUGHAFEN2_Kürzel = F2.FLUGHAFEN1_Kürzel    
		INNER JOIN (SELECT Flughafen.Bezeichnung AS von1, Flughafen.Kürzel FROM Flughafen) AS FH11 ON F1.FLUGHAFEN1_Kürzel = FH11.Kürzel 
		INNER JOIN (SELECT Flughafen.Bezeichnung AS nach1, Flughafen.Kürzel FROM Flughafen) AS FH22 ON F1.FLUGHAFEN2_Kürzel = FH22.Kürzel   
		INNER JOIN (SELECT Flughafen.Bezeichnung AS von2, Flughafen.Kürzel FROM Flughafen) AS FH21 ON F2.FLUGHAFEN1_Kürzel = FH21.Kürzel 
		INNER JOIN (SELECT Flughafen.Bezeichnung AS nach2, Flughafen.Kürzel FROM Flughafen) AS FH12 ON F2.FLUGHAFEN2_Kürzel = FH12.Kürzel    
		HAVING von1 = 'München' AND nach2 = 'San Francisco';

###
#	Aufgabenblatt 04
###

### 1
ALTER TABLE Maschine_has_Ausstattung DROP FOREIGN KEY maschine_has_ausstattung_ibfk_1,
DROP FOREIGN KEY maschine_has_ausstattung_ibfk_2,
ADD FOREIGN KEY(Maschine_Kennzeichen) REFERENCES Maschine(Kennzeichen) ON DELETE CASCADE;

### 4
DELIMITER $$
CREATE PROCEDURE informationenandatum(krz1 VARCHAR(3), krz2 VARCHAR(3), datum DATE)
	BEGIN
		SET @@lc_time_names = "de_DE";
        SELECT Flugnummer, Abflugszeit, Ankunftszeit, VerfügbarePlätze FROM Flugverbindung 
			INNER JOIN (SELECT * FROM Flug WHERE Wochentag = DAYNAME(datum)) AS F 
				ON F.Flugverbindung_Flugnummer = Flugverbindung.Flugnummer
			INNER JOIN (SELECT VerfügbarePlätze, Modelle_Modellnummer FROM Platzangebot WHERE Buchungsklasse_Bezeichnung = "Economy") AS PA 
				ON PA.Modelle_Modellnummer = Flugverbindung.Modelle_Modellnummer
			WHERE (Flugverbindung.FLUGHAFEN1_Kürzel = krz1 AND Flugverbindung.FLUGHAFEN2_Kürzel = krz2) 
				OR (Flugverbindung.FLUGHAFEN2_Kürzel = krz1 AND Flugverbindung.FLUGHAFEN1_Kürzel = krz2);
	END$$
DELIMITER ;

### 5
DELIMITER $$
CREATE FUNCTION gesamtzeit(flugnr INT)
	RETURNS TIME
    DETERMINISTIC
    BEGIN
		DECLARE result TIME;
        SELECT dieZeit INTO result FROM (
			SELECT Flugverbindung.Flugnummer, Zeit.Gesamtzeit as dieZeit FROM Flugverbindung
				INNER JOIN (SELECT TIME(ABS(TIMEDIFF(Z_An.Ankunftszeit,Z_Ab.Abflugszeit))) AS Gesamtzeit, Z_Ab.Flugnummer FROM 
					(SELECT CONVERT(SUBTIME(Flugverbindung.Ankunftszeit, Flughafen.FlughafenTimezone),TIME) AS Ankunftszeit, Flugnummer FROM Flugverbindung
						INNER JOIN Flughafen ON Flugverbindung.FLUGHAFEN2_Kürzel = Flughafen.Kürzel) AS Z_An 
						INNER JOIN (SELECT CONVERT(SUBTIME(Flugverbindung.Abflugszeit, Flughafen.FlughafenTimezone),TIME) AS Abflugszeit, Flugnummer FROM Flugverbindung INNER JOIN Flughafen ON Flugverbindung.FLUGHAFEN1_Kürzel = Flughafen.Kürzel) AS Z_Ab 
						ON Z_An.Flugnummer = Z_Ab.Flugnummer) AS Zeit
			ON Zeit.Flugnummer = Flugverbindung.Flugnummer HAVING Flugnummer = flugnr) as Time;
		return result;
        END$$
DELIMITER ;