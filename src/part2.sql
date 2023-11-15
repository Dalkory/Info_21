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



CALL add_p2p_check('raylhigh', 'florentq', 'C8_3DViewer_v1', 'Start', '10:00');
CALL add_p2p_check('raylhigh', 'florentq', 'C8_3DViewer_v1', 'Success', '10:12');
SELECT * FROM Checks WHERE Peer = 'raylhigh' AND Task = 'C8_3DViewer_v1' ORDER BY Date DESC LIMIT 2;
SELECT * FROM P2P WHERE CheckingPeer = 'florentq' AND "Time" BETWEEN '10:00' AND '10:13' ORDER BY "Time" DESC;

DELETE FROM P2P WHERE "Check" IN (SELECT id FROM Checks WHERE Peer = 'raylhigh' AND Task = 'C8_3DViewer_v1' AND Date = CURRENT_DATE);
DELETE FROM xp WHERE "Check" IN (SELECT id FROM Checks WHERE Peer = 'raylhigh' AND Task = 'C8_3DViewer_v1' AND Date = CURRENT_DATE);
DELETE FROM Checks WHERE Peer = 'raylhigh' AND Task = 'C8_3DViewer_v1' AND Date = CURRENT_DATE;


CALL add_p2p_check('raylhigh', 'florentq', 'C8_3DViewer_v1', 'Start', '9:48');
CALL add_p2p_check('raylhigh', 'florentq', 'C8_3DViewer_v1', 'Failure', '9:52');
SELECT * FROM Checks WHERE Peer = 'raylhigh' AND Task = 'C8_3DViewer_v1' ORDER BY Date DESC LIMIT 2;
SELECT * FROM P2P WHERE CheckingPeer = 'florentq' AND "Time" BETWEEN '10:00' AND '10:13' ORDER BY "Time" DESC;

DELETE FROM P2P WHERE "Check" IN (SELECT id FROM Checks WHERE Peer = 'raylhigh' AND Task = 'C8_3DViewer_v1' AND Date = CURRENT_DATE);
DELETE FROM xp WHERE "Check" IN (SELECT id FROM Checks WHERE Peer = 'raylhigh' AND Task = 'C8_3DViewer_v1' AND Date = CURRENT_DATE);
DELETE FROM Checks WHERE Peer = 'raylhigh' AND Task = 'C8_3DViewer_v1' AND Date = CURRENT_DATE;


CALL add_p2p_check('raylhigh', 'florentq', 'C8_3DViewer_v1', 'Start', '8:55');
CALL add_p2p_check('raylhigh', 'florentq', 'C8_3DViewer_v1', 'Start', '8:58');
SELECT * FROM Checks WHERE Peer = 'raylhigh' AND Task = 'C8_3DViewer_v1' ORDER BY Date DESC LIMIT 2;
SELECT * FROM P2P WHERE CheckingPeer = 'florentq' AND "Time" BETWEEN '10:00' AND '10:13' ORDER BY "Time" DESC;

DELETE FROM P2P WHERE "Check" IN (SELECT id FROM Checks WHERE Peer = 'raylhigh' AND Task = 'C8_3DViewer_v1' AND Date = CURRENT_DATE);
DELETE FROM xp WHERE "Check" IN (SELECT id FROM Checks WHERE Peer = 'raylhigh' AND Task = 'C8_3DViewer_v1' AND Date = CURRENT_DATE);
DELETE FROM Checks WHERE Peer = 'raylhigh' AND Task = 'C8_3DViewer_v1' AND Date = CURRENT_DATE;


CALL add_p2p_check('raylhigh', 'florentq', 'abrakadabra', 'Start', '10:00');
CALL add_p2p_check('raylhigh', 'florentq', 'abrakadabra', 'Success', '10:12');
SELECT * FROM Checks WHERE Peer = 'raylhigh' AND Task = 'abrakadabra' ORDER BY Date DESC LIMIT 2;
SELECT * FROM P2P WHERE CheckingPeer = 'florentq' AND "Time" BETWEEN '10:00' AND '10:13' ORDER BY "Time" DESC;

DELETE FROM P2P WHERE "Check" IN (SELECT id FROM Checks WHERE Peer = 'raylhigh' AND Task = 'abrakadabra' AND Date = CURRENT_DATE);
DELETE FROM xp WHERE "Check" IN (SELECT id FROM Checks WHERE Peer = 'raylhigh' AND Task = 'abrakadabra' AND Date = CURRENT_DATE);
DELETE FROM Checks WHERE Peer = 'raylhigh' AND Task = 'abrakadabra' AND Date = CURRENT_DATE;


CALL add_p2p_check('raylhigh', 'abobik', 'C8_3DViewer_v1', 'Start', '10:00');
CALL add_p2p_check('raylhigh', 'abobik', 'C8_3DViewer_v1', 'Success', '10:12');
SELECT * FROM Checks WHERE Peer = 'raylhigh' AND Task = 'C8_3DViewer_v1' ORDER BY Date DESC LIMIT 2;
SELECT * FROM P2P WHERE CheckingPeer = 'abobik' AND "Time" BETWEEN '10:00' AND '10:13' ORDER BY "Time" DESC;

DELETE FROM P2P WHERE "Check" IN (SELECT id FROM Checks WHERE Peer = 'raylhigh' AND Task = 'C8_3DViewer_v1' AND Date = CURRENT_DATE);
DELETE FROM xp WHERE "Check" IN (SELECT id FROM Checks WHERE Peer = 'raylhigh' AND Task = 'C8_3DViewer_v1' AND Date = CURRENT_DATE);
DELETE FROM Checks WHERE Peer = 'raylhigh' AND Task = 'C8_3DViewer_v1' AND Date = CURRENT_DATE;


CALL add_p2p_check('lorinoh', 'kaycekey', 'CPP2_s21_containers', 'Start', '10:00');
CALL add_p2p_check('lorinoh', 'kaycekey', 'CPP2_s21_containers', 'Success', '10:12');
SELECT * FROM Checks WHERE Peer = 'lorinoh' AND Task = 'C8_3DViewer_v1' ORDER BY Date DESC LIMIT 2;
SELECT * FROM P2P WHERE CheckingPeer = 'kaycekey' AND "Time" BETWEEN '10:00' AND '10:13' ORDER BY "Time" DESC;

DELETE FROM P2P WHERE "Check" IN (SELECT id FROM Checks WHERE Peer = 'lorinoh' AND Task = 'CPP2_s21_containers' AND Date = CURRENT_DATE);
DELETE FROM xp WHERE "Check" IN (SELECT id FROM Checks WHERE Peer = 'lorinoh' AND Task = 'CPP2_s21_containers' AND Date = CURRENT_DATE);
DELETE FROM Checks WHERE Peer = 'lorinoh' AND Task = 'CPP2_s21_containers' AND Date = CURRENT_DATE;



CALL add_verter_check('raylhigh', 'C8_3DViewer_v1', 'Start', '10:13');
CALL add_verter_check('raylhigh', 'C8_3DViewer_v1', 'Success', '10:15');
SELECT * FROM Verter WHERE "Check" IN ((SELECT id FROM Checks WHERE Peer = 'raylhigh' AND Task = 'C8_3DViewer_v1')) AND "Time" BETWEEN '10:14' AND '10:16';

DELETE FROM Verter WHERE "Check" IN ((SELECT id FROM Checks WHERE Peer = 'raylhigh' AND Task = 'C8_3DViewer_v1')) AND "Time" BETWEEN '10:12' AND '10:16';


CALL add_verter_check('raylhigh', 'C8_3DViewer_v1', 'Start', '10:02');
CALL add_verter_check('raylhigh', 'C8_3DViewer_v1', 'Success', '10:05');
SELECT * FROM Verter WHERE "Check" IN ((SELECT id FROM Checks WHERE Peer = 'raylhigh' AND Task = 'C8_3DViewer_v1')) AND "Time" BETWEEN '10:04' AND '10:06';

DELETE FROM Verter WHERE "Check" IN ((SELECT id FROM Checks WHERE Peer = 'raylhigh' AND Task = 'C8_3DViewer_v1')) AND "Time" BETWEEN '10:01' AND '10:06';


CALL add_verter_check('raylhigh', 'C8_3DViewer_v1', 'Start', '10:00');
CALL add_verter_check('raylhigh', 'C8_3DViewer_v1', 'Success', '9:55');
SELECT * FROM Verter WHERE "Check" IN ((SELECT id FROM Checks WHERE Peer = 'raylhigh' AND Task = 'C8_3DViewer_v1')) AND "Time" BETWEEN '9:54' AND '9:56';

DELETE FROM Verter WHERE "Check" IN ((SELECT id FROM Checks WHERE Peer = 'raylhigh' AND Task = 'C8_3DViewer_v1')) AND "Time" BETWEEN '9:54' AND '9:56';


CALL add_verter_check('raylhigh', 'C8_3DViewer_v1', 'Start', '10:13');
CALL add_verter_check('abobik', 'C8_3DViewer_v1', 'Success', '10:15');
SELECT * FROM Verter WHERE "Check" IN ((SELECT id FROM Checks WHERE Peer = 'abobik' AND Task = 'C8_3DViewer_v1')) AND "Time" BETWEEN '10:12' AND '10:16';

DELETE FROM Verter WHERE "Check" IN ((SELECT id FROM Checks WHERE Peer = 'abobik' AND Task = 'C8_3DViewer_v1')) AND "Time" BETWEEN '10:12' AND '10:16';


CALL add_verter_check('raylhigh', 'C8_3DViewer_v1', 'Start', '10:13');
CALL add_verter_check('raylhigh', 'abrakadabra', 'Success', '10:15');
SELECT * FROM Verter WHERE "Check" IN ((SELECT id FROM Checks WHERE Peer = 'raylhigh' AND Task = 'abrakadabra')) AND "Time" BETWEEN '10:12' AND '10:16';

DELETE FROM Verter WHERE "Check" IN ((SELECT id FROM Checks WHERE Peer = 'raylhigh' AND Task = 'abrakadabra')) AND "Time" BETWEEN '10:12' AND '10:16';


CALL add_verter_check('lorinoh', 'CPP2_s21_containers', 'Start', '10:13');
CALL add_verter_check('lorinoh', 'CPP2_s21_containers', 'Failure', '10:15');
SELECT * FROM Verter WHERE "Check" IN ((SELECT id FROM Checks WHERE Peer = 'lorinoh' AND Task = 'CPP2_s21_containers')) AND "Time" BETWEEN '10:12' AND '10:16';

DELETE FROM Verter WHERE "Check" IN ((SELECT id FROM Checks WHERE Peer = 'lorinoh' AND Task = 'CPP2_s21_containers')) AND "Time" BETWEEN '10:12' AND '10:16';



INSERT INTO P2P (id, "Check", CheckingPeer, State, "Time") VALUES ((SELECT COALESCE(MAX(id), 0) + 1 FROM P2P), (SELECT id FROM Checks WHERE Peer = 'raylhigh' AND Task = 'C8_3DViewer_v1' ORDER BY Date DESC LIMIT 1), 'florentq', 'Start', CURRENT_TIME);
SELECT * FROM TransferredPoints WHERE CheckingPeer = 'florentq' ORDER BY id DESC LIMIT 1;

UPDATE TransferredPoints SET PointsAmount = PointsAmount - 1 WHERE CheckingPeer = 'abobik' AND PointsAmount > 0;



INSERT INTO XP (id, "Check", XPAmount) VALUES ((SELECT COALESCE(MAX(id), 0) + 1 FROM XP), (SELECT id FROM Checks WHERE Peer = 'raylhigh' AND Task = 'C8_3DViewer_v1' ORDER BY Date DESC LIMIT 1), 10000);
SELECT * FROM XP;

DELETE FROM XP WHERE id = (SELECT MAX(id) FROM XP);


INSERT INTO XP (id, "Check", XPAmount) VALUES ((SELECT COALESCE(MAX(id), 0) + 1 FROM XP), (SELECT id FROM Checks WHERE Peer = 'raylhigh' AND Task = 'C8_3DViewer_v1' ORDER BY Date DESC LIMIT 1), 1043);
SELECT * FROM XP;

DELETE FROM XP WHERE id = (SELECT MAX(id) FROM XP);


INSERT INTO XP (id, "Check", XPAmount) VALUES ((SELECT COALESCE(MAX(id), 0) + 1 FROM XP), (SELECT id FROM Checks WHERE Peer = 'raylhigh' AND Task = 'C8_3DViewer_v1' ORDER BY Date DESC LIMIT 1), -1000);
SELECT * FROM XP;

DELETE FROM XP WHERE id = (SELECT MAX(id) FROM XP);


INSERT INTO XP (id, "Check", XPAmount) VALUES ((SELECT COALESCE(MAX(id), 0) + 1 FROM XP), (SELECT id FROM Checks WHERE Peer = 'raylhigh' AND Task = 'abrakadabra' ORDER BY Date DESC LIMIT 1), 10);
SELECT * FROM XP;

DELETE FROM XP WHERE id = (SELECT MAX(id) FROM XP);


INSERT INTO XP (id, "Check", XPAmount) VALUES ((SELECT COALESCE(MAX(id), 0) + 1 FROM XP), (SELECT id FROM Checks WHERE Peer = 'abobik' AND Task = 'C8_3DViewer_v1' ORDER BY Date DESC LIMIT 1), 10);
SELECT * FROM XP;

DELETE FROM XP WHERE id = (SELECT MAX(id) FROM XP);


INSERT INTO XP (id, "Check", XPAmount) VALUES ((SELECT COALESCE(MAX(id), 0) + 1 FROM XP), (SELECT id FROM Checks WHERE Peer = 'lorinoh' AND Task = 'CPP2_s21_containers' ORDER BY Date DESC LIMIT 1), 0);
SELECT * FROM XP;

DELETE FROM XP WHERE id = (SELECT MAX(id) FROM XP);