INSERT INTO Account_phone values
('I1', '7259939624'),
('I2', '7259939625'),
('I2', '7259939626'),
('C1', '7259939627'),
('C2', '7259939628'),
('C2', '7259939629')

INSERT INTO Account_type values
('C1', 'Company1', 100, '12-01-2020'),
('C2', 'Company2', 150, '11-05-2020'),
('C3', 'Company3', 200, '11-01-2020'),
('I1', 'Indivual1', 1, '11-29-2020'),
('I2', 'Individual1', 3, '12-03-2020')

INSERT INTO Call_time values
('Call_id_1', '10:02:02', '10:10:00'),
('Call_id_2', '11:02:02', '11:10:00'),
('Call_id_3', '11:02:00', '12:10:00'),
('Call_id_4', '1:10:00', '1:10:02'),
('Call_id_5', '05:15:00', '05:30:00')

INSERT INTO Geography values
('G1', 1, 'India', 'Karnataka', 'Bangalore', 'HSR Layout', '560102'),
('G2', 2, 'India', 'Karnataka', 'Bangalore', 'Koramangala', '560105'),
('G3', 3, 'India', 'Karnataka', 'Bangalore', 'BTM Layout', '560106'),
('G4', 4, 'India', 'Karnataka', 'Bangalore', 'JP Nagar', '560112'),
('G5', 5, 'India', 'Karnataka', 'Bangalore', 'HSR Layout', '560102')

INSERT INTO Rate_plan values
('RP1', 'T', 84, NULL, 199.0),
('RP2', 'D', 84, 3.0, 100.0),
('RP3', 'H', 84, 3.0, 249.0)

INSERT INTO FACT values
('7259939624', 'Call_id_1', 'I1', 'G1', '9731599552', 'G2', 'RP1', '00:07:58'),
('7259939625', 'Call_id_2', 'I2', 'G1', '7259939624', 'G1', 'RP3', '00:07:58'),
('7259939626', 'Call_id_3', 'I2', 'G1', '7259939624', 'G1', 'RP1', '00:58:00'),
('7259939627', 'Call_id_4', 'C1', 'G3', '8759939624', 'G4', 'RP1', '00:00:02'),
('7259939628', 'Call_id_5', 'C2', 'G2', '7259939629', 'G1', 'RP3', '00:15:58')









