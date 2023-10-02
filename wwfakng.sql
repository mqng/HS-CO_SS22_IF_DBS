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