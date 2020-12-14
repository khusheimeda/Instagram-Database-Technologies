Create table Account_phone(
Account_id varchar(10) NOT NULL,
Phone_number varchar(20) PRIMARY KEY 
)

Create table Account_type(
Account_type_id varchar(2) PRIMARY KEY,
Name varchar(50) NOT NULL,
Number_of_connections int NOT NULL,
start_date date NOT NULL
)


Create table Call_time(
Call_time_id varchar(10) PRIMARY KEY,
Start_time time NOT NULL,
End_time time NOT NULL
)

Create table Geography(
Geography_id varchar(10) PRIMARY KEY,
Tower_id int NOT NULL,
Country varchar(50) NOT NULL,
State varchar(50) NOT NULL,
City varchar(50) NOT NULL,
Locality varchar(50) NOT NULL,
Postal_code varchar(10) NOT NULL
)

Create table Rate_Plan(
Rate_plan_id varchar(10) PRIMARY KEY,
Rate_plan_type char(1) NOT NULL,
Validity_days int,
Data_bandwidth float,
Cost float NOT NULL,
)


Create table Fact(
Caller_phone_number varchar(20), 
Call_time_key varchar(10),
Account_type_key varchar(2),
Caller_geography_key varchar(10),
Called_geography_key varchar(10),
Called_phone_number varchar(20),
Rate_plan_key varchar(10),
Call_duration time,
Foreign key (Caller_phone_number) references Account_phone(Phone_number ),
Foreign key (Caller_geography_key) references Geography(Geography_id ),
Foreign key (Call_time_key) references Call_time(Call_time_id ),
Foreign key (Account_type_key) references Account_type(Account_type_id),
Foreign key (Caller_geography_key) references Geography(Geography_id),
Foreign key (Rate_plan_key) references Rate_plan(Rate_plan_id),
)


DROP table FACT
DROP table Account_phone
DROP table Account_type
DROP table Call_time
DROP table Geography
DROP table Rate_Plan










