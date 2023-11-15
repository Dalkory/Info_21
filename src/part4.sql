--/////////////////////////////////////////////////////////////////////////////////////////////////////////////Part1
--/////////////////////////////////////////////////////////////////////////////////////////////////////////////Part1
--/////////////////////////////////////////////////////////////////////////////////////////////////////////////Part1

create table Peers
(
  Nickname varchar not null primary key,
  Birthday  date not null
);

insert into Peers values('florentq','1999-10-14');
insert into Peers values('pickling', '2000-08-21');
insert into Peers values('kaycekey', '1995-12-02');
insert into Peers values('raylhigh','2004-05-01');
insert into Peers values('hizdahri','1986-01-08');
insert into Peers values('guitarof','1995-03-31');
insert into Peers values('lorinoh','1987-12-24');

create table Tasks
(
 Title varchar not null primary key,
 ParentTask varchar,
 MaxXP integer,
 constraint fk_TasksParentT foreign key (ParentTask) references Tasks (Title)
);

insert into Tasks values('C6_s21_matrix', NULL, 500);
insert into Tasks values('C7_SmartCalc_v1','C6_s21_matrix' , 650);
insert into Tasks values('C8_3DViewer_v1', 'C7_SmartCalc_v1',1043);
insert into Tasks values('CPP1_s21_matrix', 'C8_3DViewer_v1', 500);
insert into Tasks values('CPP2_s21_containers', 'CPP1_s21_matrix', 500);
insert into Tasks values('CPP3_SmartCalc_v2.0', 'CPP2_s21_containers', 650);

create table Checks
(
  id bigint primary key,
  Peer varchar not null,
  Task varchar not null,
  Date date not null,

  constraint fk_check_peer foreign key (Peer) references Peers (Nickname),
  constraint fk_check_task foreign key (Task) references Tasks (Title)
);

insert into Checks
 values(1,'raylhigh', 'CPP2_s21_containers','2023-06-05'),
       (2, 'kaycekey', 'C8_3DViewer_v1', '2023-08-22'),
       (3, 'florentq', 'C7_SmartCalc_v1', '2023-09-03'),
       (4, 'hizdahri', 'C8_3DViewer_v1','2023-10-01'),
       (5, 'lorinoh', 'C7_SmartCalc_v1', '2023-09-01'),
       (6, 'guitarof', 'C7_SmartCalc_v1', '2023-08-30'),
       (7, 'pickling','CPP1_s21_matrix', '2023-09-10');

create table TableName_Checks
(
  id bigint primary key,
  Peer varchar not null,
  Task varchar not null,
  Date date not null,

  constraint fk_check_peer foreign key (Peer) references Peers (Nickname),
  constraint fk_check_task foreign key (Task) references Tasks (Title)
);

insert into TableName_Checks
 values(1,'raylhigh', 'CPP2_s21_containers','2023-06-05'),
       (2, 'kaycekey', 'C8_3DViewer_v1', '2023-08-22'),
       (3, 'florentq', 'C7_SmartCalc_v1', '2023-09-03'),
       (4, 'hizdahri', 'C8_3DViewer_v1','2023-10-01'),
       (5, 'lorinoh', 'C7_SmartCalc_v1', '2023-09-01'),
       (6, 'guitarof', 'C7_SmartCalc_v1', '2023-08-30'),
       (7, 'pickling','CPP1_s21_matrix', '2023-09-10');

create table P2P
(
    id bigint primary key,
    "Check" bigint not null,
    CheckingPeer varchar not null,
    State varchar not null,
    "Time" time not null,

    constraint fk_p2p_check foreign key ("Check") references Checks (id),
    constraint fk_p2p_checking_peer foreign key (CheckingPeer) references Peers (Nickname)
);

alter table P2P add constraint ch_st check ( State in ('Start', 'Failure', 'Success'));

insert into P2P values (1,1,'florentq','Start','9:00');
insert into P2P values (2,1,'florentq','Success','9:45');
insert into P2P values (3,2,'pickling','Start','11:15');
insert into P2P values (4,2,'pickling','Failure','12:00');
insert into P2P values (5,3,'kaycekey','Start','14:25');
insert into P2P values (6,3,'kaycekey','Success','15:24');
insert into P2P values (7,4,'raylhigh','Start','20:00');
insert into P2P values (8,4,'raylhigh','Failure','20:37');
insert into P2P values (9,5,'hizdahri','Start','20:45');
insert into P2P values (10,5,'hizdahri','Success','21:12');
insert into P2P values (11,6,'lorinoh','Start','23:10');
insert into P2P values (12,6,'lorinoh','Success','23:55');
insert into P2P values (13,7,'guitarof','Start', '22:39');
insert into P2P values (14,7,'guitarof','Success','23:12');

create table TransferredPoints
(
    id bigint primary key,
    CheckingPeer varchar not null,
    CheckedPeer varchar not null,
    PointsAmount integer default (0),

    constraint fk_friends_ch_peer foreign key (CheckingPeer) references Peers (Nickname),
    constraint fk_friends_checked_peer foreign key (CheckedPeer) references Peers (Nickname)
);

insert into TransferredPoints values(1,'florentq','hizdahri',1);
insert into TransferredPoints values(2, 'hizdahri','guitarof' ,2);
insert into TransferredPoints values(3,'guitarof','kaycekey',3);
insert into TransferredPoints values(4,'pickling','raylhigh',2);
insert into TransferredPoints values(5,'raylhigh','lorinoh',1);
insert into TransferredPoints values(6,'kaycekey','florentq',2);
insert into TransferredPoints values(7,'hizdahri','lorinoh',3);
insert into TransferredPoints values(8,'florentq','pickling',3);


create table Friends
(
    id bigint primary key,
    Peer1 varchar not null,
    Peer2 varchar not null,
    constraint fk_FriendsPeer1 foreign key (Peer1) references Peers (Nickname),
    constraint fk_FriendsPeer2 foreign key (Peer2) references Peers (Nickname)
);

insert into Friends values(1,'florentq','hizdahri');
insert into Friends values(2, 'hizdahri','lorinoh');
insert into Friends values(3, 'pickling', 'kaycekey');
insert into Friends values(4, 'florentq', 'guitarof');
insert into Friends values(5, 'raylhigh', 'pickling');

create table TableName_Friends
(
    id bigint primary key,
    Peer1 varchar not null,
    Peer2 varchar not null,
    constraint fk_FriendsPeer1 foreign key (Peer1) references Peers (Nickname),
    constraint fk_FriendsPeer2 foreign key (Peer2) references Peers (Nickname)
);

insert into TableName_Friends values(1,'florentq','hizdahri');
insert into TableName_Friends values(2, 'hizdahri','lorinoh');
insert into TableName_Friends values(3, 'pickling', 'kaycekey');
insert into TableName_Friends values(4, 'florentq', 'guitarof');
insert into TableName_Friends values(5, 'raylhigh', 'pickling');

create table TableName_Recommendations
(
     id bigint primary key,
     Peer varchar not null,
     RecommendedPeer varchar not null,
     constraint fr_RecommendationsPeer foreign key (Peer) references Peers (Nickname),
     constraint fr_RecommendationsRecommendedPeer foreign key (RecommendedPeer) references Peers (Nickname)
);

insert into TableName_Recommendations values(1,'florentq', 'guitarof');
insert into TableName_Recommendations values(2,'hizdahri','lorinoh');
insert into TableName_Recommendations values(3,'kaycekey','florentq');
insert into TableName_Recommendations values(4,'raylhigh','hizdahri');
insert into TableName_Recommendations values(5,'pickling', 'florentq');
insert into TableName_Recommendations values(6,'lorinoh','guitarof');

create table Recommendations
(
     id bigint primary key,
     Peer varchar not null,
     RecommendedPeer varchar not null,
     constraint fr_RecommendationsPeer foreign key (Peer) references Peers (Nickname),
     constraint fr_RecommendationsRecommendedPeer foreign key (RecommendedPeer) references Peers (Nickname)
);

insert into Recommendations values(1,'florentq', 'guitarof');
insert into Recommendations values(2,'hizdahri','lorinoh');
insert into Recommendations values(3,'kaycekey','florentq');
insert into Recommendations values(4,'raylhigh','hizdahri');
insert into Recommendations values(5,'pickling', 'florentq');
insert into Recommendations values(6,'lorinoh','guitarof');

create table TimeTracking
(
    id bigint primary key,
    Peer varchar not null,
    Date date not null,
    "Time" time not null,
    State varchar not null,

    constraint fk_TimeTrackingPeer foreign key (Peer) references Peers (Nickname)
);

insert into TimeTracking values(1,'florentq', '2023-10-13','9:45', 1);
insert into TimeTracking values(2,'florentq', '2023-10-13', '19:12',2);
insert into TimeTracking values(3,'hizdahri', '2023-11-07', '19:30', 1);
insert into TimeTracking values(4,'hizdahri','2023-11-07', '23:30', 2);
insert into TimeTracking values(5,'kaycekey', '2023-11-06','15:25', 1);
insert into TimeTracking values(6,'kaycekey', '2023-11-06','23:25', 2);
insert into TimeTracking values(7,'pickling', '2023-10-26', '13:00', 1);
insert into TimeTracking values(8,'pickling', '2023-10-26', '16:00',2);
insert into TimeTracking values(9,'pickling', '2023-10-26', '19:00', 1);
insert into TimeTracking values(10,'pickling', '2023-10-26', '23:16', 2);
insert into TimeTracking values(11,'lorinoh','2023-10-10', '17:00',1);
insert into TimeTracking values(12, 'lorinoh','2023-10-10', '17:00',2);
insert into TimeTracking values(13,'raylhigh', '2023-11-01', '10:00', 1);
insert into TimeTracking values(14,'raylhigh', '2023-11-01', '17:00', 2);
insert into TimeTracking values(15,'florentq', '2023-10-20','12:45', 1);
insert into TimeTracking values(16,'florentq', '2023-10-20','19:45', 2);



create table Verter
(
    id bigint primary key,
    "Check" bigint not null,
    State varchar not null,
    "Time" time not null
);

insert into Verter values(1, 2,'Start','16:05');
insert into Verter values(2,2,'Failure' ,'16:50');
insert into Verter values(3,4,'Start','12:00');
insert into Verter values(4,4,'Success', '12:45');
insert into Verter values(5, 5,'Start','10:15');
insert into Verter values(6,5,'Success','17:00');
insert into Verter values(7, 1,'Start','17:55');
insert into Verter values(8,1,'Success','19:00');
insert into Verter values(9,7,'Start','19:52');
insert into Verter values(10,7,'Success','20:44');
insert into Verter values(11,6,'Start','9:00');
insert into Verter values(12, 6,'Failure', '9:50');


create table XP
(
    id bigint primary key,
    "Check" bigint not null,
    XPAmount integer,
    constraint fk_XPCheck foreign key ("Check") references Checks (id)
);

insert into XP values(1,1,600);
insert into XP values(2,3,575);
insert into XP values(3,4,900);
insert into XP values(4,5, 600);
insert into XP values(5,6, 600);


-- insert into Tasks values(,);
-- insert into Tasks values(,);

create or replace function fnc_ok_check()
    returns table
            (
                check_id     bigint,
                CheckedPeer  varchar,
                CheckingPeer varchar,
                State        varchar,
                Task         varchar,
                "Time"       date
            )
AS
$$
with succes_check as ((select "Check"
                          from p2p)
                         except
                         (select "Check"
                          from p2p
                          where State = 'Failure')
                         except
                         (select "Check"
                          from verter
                          where state = 'Failure'))

select Checks.id, Peer as CheckedPeer, p2p.CheckingPeer, State, Task, date
from succes_check
         inner join p2p on P2P."Check" = succes_check."Check"
         inner join Checks on Checks.id = succes_check."Check"
$$ language sql;

--import & export



-- drop table Tasks, XP, Verter, TimeTracking, Recommendations, Friends, TransferredPoints, P2P, Peers, Checks;
--truncate  Tasks, XP, Verter, TimeTracking, Recommendations, Friends, TransferredPoints, P2P, Peers, Checks;



--/////////////////////////////////////////////////////////////////////////////////////////////////////////////Part1
--/////////////////////////////////////////////////////////////////////////////////////////////////////////////Part1
--/////////////////////////////////////////////////////////////////////////////////////////////////////////////Part1

--/////////////////////////////////////////////////////////////////////////////////////////////////////////////Part2
--/////////////////////////////////////////////////////////////////////////////////////////////////////////////Part2
--/////////////////////////////////////////////////////////////////////////////////////////////////////////////Part2



CREATE OR REPLACE PROCEDURE add_p2p_check(
    IN p_nickname VARCHAR,
    IN p_checker_nickname VARCHAR,
    IN p_task_name VARCHAR,
    IN p_check_status VARCHAR,
    IN p_time TIME
)
LANGUAGE plpgsql
AS $$
DECLARE 
    new_check_id BIGINT;
    new_p2p_id BIGINT;
BEGIN
    IF p_check_status = 'Start' THEN
        SELECT COALESCE(MAX(id), 0) + 1 INTO new_check_id FROM Checks;
        INSERT INTO Checks (id, Peer, Task, Date)
        VALUES (new_check_id, p_nickname, p_task_name, CURRENT_DATE);
        SELECT COALESCE(MAX(id), 0) + 1 INTO new_p2p_id FROM P2P;
        INSERT INTO P2P (id, "Check", CheckingPeer, State, "Time")
        VALUES (new_p2p_id,
                new_check_id,
                p_checker_nickname, 
                p_check_status, 
                p_time);
    ELSE
        SELECT COALESCE(MAX(id), 0) + 1 INTO new_p2p_id FROM P2P;
        INSERT INTO P2P (id, "Check", CheckingPeer, State, "Time")
        VALUES (new_p2p_id,
                (SELECT "Check"
                 FROM P2P
                 WHERE CheckingPeer = p_checker_nickname AND State = 'Start' AND "Check" NOT IN 
                   (SELECT "Check" FROM P2P WHERE State <> 'Start')
                 ORDER BY "Time" DESC LIMIT 1),
                p_checker_nickname, 
                p_check_status, 
                p_time);
    END IF;
END;
$$;


CREATE OR REPLACE PROCEDURE add_verter_check(
    IN p_nickname VARCHAR,
    IN p_task_name VARCHAR,
    IN p_check_status VARCHAR,
    IN p_time TIME
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_check_id BIGINT;
    new_verter_id BIGINT;
BEGIN
    PERFORM Nickname FROM Peers WHERE Nickname = p_nickname;
    IF NOT FOUND 
    THEN
        RAISE 'Peer % not found', p_nickname;
    END IF;
    SELECT c.id INTO v_check_id
    FROM Checks c
    JOIN P2P p ON c.id = p."Check"
    WHERE c.Task = p_task_name
    AND p.State = 'Success'
    ORDER BY p."Time" DESC
    LIMIT 1;
    SELECT COALESCE(MAX(id), 0) + 1 INTO new_verter_id FROM Verter;
    INSERT INTO Verter (id, "Check", State, "Time")
    VALUES (new_verter_id, v_check_id, p_check_status, p_time);
END;
$$;


CREATE OR REPLACE FUNCTION update_transferred_points()
RETURNS TRIGGER AS $$
DECLARE
    new_id BIGINT;
BEGIN
    SELECT COALESCE(MAX(id), 0) + 1 INTO new_id FROM TransferredPoints;
    IF NEW.State = 'Start' THEN
        UPDATE TransferredPoints
        SET PointsAmount = PointsAmount + 1
        WHERE CheckingPeer = NEW.CheckingPeer
        AND CheckedPeer = (
            SELECT Peer
            FROM Checks
            WHERE id = NEW."Check"
        );
        IF NOT FOUND THEN
            INSERT INTO TransferredPoints (id, CheckingPeer, CheckedPeer, PointsAmount)
            VALUES ( new_id, NEW.CheckingPeer, (
                SELECT Peer
                FROM Checks
                WHERE id = NEW."Check"
            ), 1);
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER update_transferred_points_trigger
AFTER INSERT ON P2P
FOR EACH ROW
EXECUTE FUNCTION update_transferred_points();



CREATE OR REPLACE FUNCTION check_xp_record()
RETURNS TRIGGER AS $$
DECLARE
    max_xp INTEGER;
BEGIN
    SELECT MaxXP INTO max_xp 
    FROM Tasks 
    WHERE Title=(SELECT Task FROM Checks WHERE id=NEW."Check");
    IF NEW.XPAmount > max_xp THEN
        RAISE EXCEPTION 'Number of XP exceeds the maximum available for the task';
    END IF;        
    IF NEW.XPAmount < 0 THEN
        RAISE EXCEPTION 'Number of XP cannot be less than zero';
    END IF;
    IF NOT EXISTS (
        SELECT 1 
        FROM Verter 
        WHERE "Check" = NEW."Check" AND State = 'Success'
        ) THEN
        RAISE EXCEPTION 'Check field does not refer to a successful check';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER check_xp_record_trigger
BEFORE INSERT ON XP
FOR EACH ROW
EXECUTE FUNCTION check_xp_record();



--/////////////////////////////////////////////////////////////////////////////////////////////////////////////Part2
--////////////////////////////////////////s/////////////////////////////////////////////////////////////////////Part2
--/////////////////////////////////////////////////////////////////////////////////////////////////////////////Part2

--/////////////////////////////////////////////////////////////////////////////////////////////////////////////Part4
--/////////////////////////////////////////////////////////////////////////////////////////////////////////////Part4
--/////////////////////////////////////////////////////////////////////////////////////////////////////////////Part4



CREATE OR REPLACE PROCEDURE drop_tables(pattern varchar DEFAULT 'tablename')
LANGUAGE plpgsql
AS $$
DECLARE
    name text;
BEGIN
    pattern := pattern || '%';
    FOR name IN SELECT table_name
                FROM information_schema.tables
                WHERE table_schema NOT IN ('information_schema', 'pg_catalog')
                    AND table_name LIKE pattern
    LOOP
        EXECUTE format('DROP table %I CASCADE', name);
    END LOOP;
END; $$;



CREATE OR REPLACE PROCEDURE get_function(ref REFCURSOR, count INOUT int DEFAULT 0)
LANGUAGE plpgsql
AS $$ BEGIN
OPEN ref FOR 
    SELECT t2.routine_name, t1.arg
    FROM (SELECT p.specific_name, string_agg(CONCAT(p.parameter_name, '::', p.data_type), ', ') AS arg
                    FROM information_schema.parameters AS p
                    WHERE p.specific_schema NOT IN ('information_schema', 'pg_catalog') AND p.parameter_mode = 'IN'
                    GROUP BY p.specific_name) AS t1
    JOIN
        (SELECT *
        FROM information_schema.routines
        WHERE routine_schema NOT IN ('information_schema', 'pg_catalog') AND routine_type = 'FUNCTION') AS t2
        ON t1.specific_name = t2.specific_name;
MOVE FORWARD ALL FROM ref;  
GET DIAGNOSTICS count := ROW_COUNT;  
MOVE BACKWARD ALL FROM ref;  
END; $$;



CREATE OR REPLACE PROCEDURE drop_triggers(INOUT count INTEGER DEFAULT 0)
LANGUAGE plpgsql AS $$
DECLARE
    trg_name text;
    table_name text;
BEGIN
    FOR trg_name, table_name IN SELECT trigger_name, event_object_table
                                  FROM information_schema.triggers
    LOOP
        EXECUTE format('DROP TRIGGER IF EXISTS %I ON %I ', trg_name, table_name);
        count := count + 1;
    END LOOP;
END;$$;



CREATE OR REPLACE PROCEDURE find_str(ref REFCURSOR, str varchar)
LANGUAGE plpgsql
AS $$ BEGIN
    OPEN ref FOR
        SELECT routine_name, routine_type
        FROM information_schema.routines AS p
        WHERE p.specific_schema NOT IN ('information_schema', 'pg_catalog')
          AND p.routine_definition ILIKE '%' || str ||'%';
END; $$;



SELECT tablename
FROM pg_catalog.pg_tables 
WHERE schemaname != 'pg_catalog' AND 
    schemaname != 'information_schema';

CALL drop_tables();

SELECT tablename
FROM pg_catalog.pg_tables 
WHERE schemaname != 'pg_catalog' AND 
    schemaname != 'information_schema';


CREATE OR REPLACE FUNCTION calculate_circle_radius(area numeric)
RETURNS numeric AS $$
BEGIN
    RETURN sqrt(area / PI());
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION calculate_hypotenuse(a numeric, b numeric)
RETURNS numeric AS $$
BEGIN
    RETURN sqrt(a*a + b*b);
END; $$ LANGUAGE plpgsql;

BEGIN;
    CALL get_function('ex2', 0);
    FETCH ALL IN "ex2";
COMMIT;

DO $$
DECLARE
    count int;
BEGIN
    CALL get_function('ex2', count);
    RAISE NOTICE 'count of functions = %', count;
END; $$;


CALL drop_triggers();


BEGIN;
CALL find_str('ex4', 'peer');
FETCH ALL IN "ex4";
COMMIT;



--/////////////////////////////////////////////////////////////////////////////////////////////////////////////Part4
--/////////////////////////////////////////////////////////////////////////////////////////////////////////////Part4
--/////////////////////////////////////////////////////////////////////////////////////////////////////////////Part4