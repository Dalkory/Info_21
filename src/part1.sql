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
insert into Peers values('chesterh','2000-11-12'), ('masticcu', '2001-03-09');--by kaycekey for task 3.6


create table Tasks
(
 Title varchar not null primary key,
 ParentTask varchar,
 MaxXP integer,
 constraint fk_TasksParentT foreign key (ParentTask) references Tasks (Title)
);

insert into Tasks values('CPP1_s21_matrix', NULL,300);
insert into Tasks values('C6_s21_matrix',NULL , 350);
insert into Tasks values('C7_SmartCalc_v1','C6_s21_matrix' , 650);
insert into Tasks values('CPP2_s21_containers', 'CPP1_s21_matrix', 500);
insert into Tasks values('C8_3DViewer_v1', 'C7_SmartCalc_v1',1043);
insert into Tasks values('CPP3_SmartCalc_v2.0', 'CPP2_s21_containers', 650);
insert into Tasks values('DO2_LinuxNetwork_v1',NULL , 350);
-- insert into Tasks values(,);

create table Checks
(
  id serial primary key,
  Peer varchar not null,
  Task varchar not null,
  Date date not null,

  constraint fk_check_peer foreign key (Peer) references Peers (Nickname),
  constraint fk_check_task foreign key (Task) references Tasks (Title)
);
 insert into Checks(Peer, Task, Date)
 values('raylhigh', 'CPP2_s21_containers','2023-06-05'),
       ('kaycekey', 'C8_3DViewer_v1', '2023-08-22'),
       ('florentq', 'C7_SmartCalc_v1', '2023-09-03'),
       ('hizdahri', 'C8_3DViewer_v1','2023-10-01'),
       ('lorinoh', 'C7_SmartCalc_v1', '2023-09-01'),
       ('guitarof', 'C7_SmartCalc_v1', '2023-08-30'),
       ('pickling','CPP1_s21_matrix', '2023-09-10'),
       ('chesterh', 'C6_s21_matrix', '2023-08-30'),--by kaycekey for task 3.6
       ('masticcu', 'C6_s21_matrix', '2023-08-30'),
       ('chesterh', 'CPP1_s21_matrix', '2023-11-12'),--by kaycekey for task 3.10
       ('pickling', 'C8_3DViewer_v1', '2023-08-21'),
       ('kaycekey', 'C7_SmartCalc_v1', '2023-07-01');--by kaycekey for task 3.1


create table P2P
(
    id serial primary key,
    "Check" bigint not null,
    CheckingPeer varchar not null,
    State varchar not null,
    "Time" time not null,

    constraint fk_p2p_check foreign key ("Check") references Checks (id),
    constraint fk_p2p_checking_peer foreign key (CheckingPeer) references Peers (Nickname)
);

alter table P2P add constraint ch_st check ( State in ('Start', 'Failure', 'Success'));

insert into P2P("Check",CheckingPeer,State,"Time") values (1,'florentq','Start','9:00');
insert into P2P("Check",CheckingPeer,State,"Time") values (1,'florentq','Success','9:45');
insert into P2P("Check",CheckingPeer,State,"Time") values (2,'pickling','Start','11:15');
insert into P2P("Check",CheckingPeer,State,"Time") values (2,'pickling','Failure','12:00');
insert into P2P("Check",CheckingPeer,State,"Time") values (3,'kaycekey','Start','14:25');
insert into P2P("Check",CheckingPeer,State,"Time") values (3,'kaycekey','Success','15:24');
insert into P2P("Check",CheckingPeer,State,"Time") values (4,'raylhigh','Start','20:00');
insert into P2P("Check",CheckingPeer,State,"Time") values (4,'raylhigh','Failure','20:37');
insert into P2P("Check",CheckingPeer,State,"Time") values (5,'hizdahri','Start','20:45');
insert into P2P("Check",CheckingPeer,State,"Time") values (5,'hizdahri','Success','21:12');
insert into P2P("Check",CheckingPeer,State,"Time") values (6,'lorinoh','Start','23:10');
insert into P2P("Check",CheckingPeer,State,"Time") values (6,'lorinoh','Success','23:55');
insert into P2P("Check",CheckingPeer,State,"Time") values (7,'guitarof','Start', '22:39');
insert into P2P("Check",CheckingPeer,State,"Time") values (7,'guitarof','Success','23:12');
insert into P2P("Check",CheckingPeer,State,"Time") values (8, 'masticcu', 'Start', '21:30'),--by kaycekey for task 3.10
                       ( 8, 'masticcu', 'Success', '21:40'),
                       ( 9, 'kaycekey', 'Start', '22:00'),
                       ( 9, 'kaycekey', 'Success', '22:20'),
                       ( 10, 'raylhigh', 'Start', '12:30'),
                       ( 10, 'raylhigh', 'Success', '13:00'),
                       ( 11, 'lorinoh', 'Start', '21:30'),
                       ( 11, 'lorinoh', 'Failure', '22:30'),
                       ( 12, 'pickling', 'Start', '03:30'),--by kaycekey for task 3.14
                       ( 12, 'pickling', 'Success', '04:15');


create table Verter
(
    id serial primary key,
    "Check" bigint not null,
    State varchar not null,
    "Time" time not null,

    constraint fk_verter_check foreign key ("Check") references Checks (id)
);

insert into Verter("Check", State, "Time") values(2,'Start','16:05'),
(2,'Failure' ,'16:50'),
(4,'Start','12:00'),
(4,'Success', '12:45'),
(5,'Start','10:15'),
(5,'Success','17:00'),
(1,'Start','17:55'),
(1,'Success','19:00'),
(7,'Start','19:52'),
(7,'Success','20:44'),
(6,'Start','9:00'),
(6,'Failure', '9:50');
insert into Verter("Check", State, "Time") values ( 10, 'Start','13:00'),--by kaycekey for task 3.10
                          ( 10, 'Success', '13:25'),
                          ( 11, 'Start','22:45'),
                          ( 11, 'Failure', '23:05'),
                          ( 3, 'Start','15:25'),--this was just omitted
                          ( 3, 'Success', '15:45'),--this was just omitted
                          (8, 'Start','21:45'),
                          (8, 'Failure', '22:10'),
                          (9, 'Start', '22:25'),
                          (9, 'Failure', '22:45'),
                          (12, 'Start','04:20'),--by kaycekey for task 3.14
                          (12, 'Success', '04:25');


create table TransferredPoints
(
    id serial primary key,
    CheckingPeer varchar not null,
    CheckedPeer varchar not null,
    PointsAmount integer default (0),

    constraint fk_friends_ch_peer foreign key (CheckingPeer) references Peers (Nickname),
    constraint fk_friends_checked_peer foreign key (CheckedPeer) references Peers (Nickname)
);

insert into TransferredPoints(CheckingPeer, CheckedPeer, PointsAmount) values('florentq','hizdahri',1),
('hizdahri','guitarof' ,2),
('guitarof','kaycekey',3),
('pickling','raylhigh',2),
('raylhigh','lorinoh',1),
('kaycekey','florentq',2),
('hizdahri','lorinoh',3),
('florentq','pickling',3);


create table Friends
(
    id serial primary key,
    Peer1 varchar not null,
    Peer2 varchar not null,
    constraint fk_FriendsPeer1 foreign key (Peer1) references Peers (Nickname),
    constraint fk_FriendsPeer2 foreign key (Peer2) references Peers (Nickname)
);

insert into Friends(Peer1, Peer2) values('florentq','hizdahri');
insert into Friends(Peer1, Peer2) values( 'hizdahri','lorinoh');
insert into Friends(Peer1, Peer2) values( 'pickling', 'kaycekey');
insert into Friends(Peer1, Peer2) values( 'florentq', 'guitarof');
insert into Friends(Peer1, Peer2) values( 'raylhigh', 'pickling');
insert into Friends(Peer1, Peer2) values ( 'chesterh', 'masticcu'),--by kaycekey for task 3.8
                           ( 'chesterh', 'pickling'),
                           ( 'kaycekey', 'chesterh'),
                           ('kaycekey', 'florentq'),
                           ('kaycekey', 'guitarof');



create table Recommendations
(
     id serial primary key,
     Peer varchar not null,
     RecommendedPeer varchar not null,
     constraint fr_RecommendationPeer foreign key (Peer) references Peers (Nickname),
     constraint fr_RecommendationRecommendedPeer foreign key (RecommendedPeer) references Peers (Nickname)
);

insert into Recommendations(Peer, RecommendedPeer) values('florentq', 'guitarof');
insert into Recommendations(Peer, RecommendedPeer) values('hizdahri','lorinoh');
insert into Recommendations(Peer, RecommendedPeer) values('kaycekey','florentq');
insert into Recommendations(Peer, RecommendedPeer) values('raylhigh','hizdahri');
insert into Recommendations(Peer, RecommendedPeer) values('pickling', 'florentq');
insert into Recommendations(Peer, RecommendedPeer) values('lorinoh','guitarof');
insert into Recommendations(Peer, RecommendedPeer) values('chesterh','guitarof'),--by kaycekey for task 3.8
                                                         ('masticcu','pickling'),
                                                         ('guitarof','kaycekey'),
                                                         ('hizdahri','guitarof'),
                                                         ('kaycekey','guitarof'),
                                                         ('hizdahri','kaycekey');



create table XP
(
    id serial primary key,
    "Check" bigint not null,
    XPAmount integer,
    constraint fk_XPCheck foreign key ("Check") references Checks (id)
);

insert into XP("Check", XPAmount) values(1,600);
insert into XP("Check", XPAmount) values(3,575);
insert into XP("Check", XPAmount) values(4,900);
insert into XP("Check", XPAmount) values(5, 600);
insert into XP("Check", XPAmount) values(6, 600);
insert into XP("Check", XPAmount) values(12, 650);--by kaycekey for task 3.14

create table TimeTracking
(
    id serial primary key,
    Peer varchar not null,
    Date date not null,
    "Time" time not null,
    State varchar not null,

    constraint fk_TimeTrackingPeer foreign key (Peer) references Peers (Nickname)
);

insert into TimeTracking(Peer, Date, "Time", State) values('florentq', '2023-10-13','9:45', 1);
insert into TimeTracking(Peer, Date, "Time", State) values('florentq', '2023-10-13', '19:12',2);
insert into TimeTracking(Peer, Date, "Time", State) values('hizdahri', '2023-11-07', '19:30', 1);
insert into TimeTracking(Peer, Date, "Time", State) values('hizdahri','2023-11-07', '23:30', 2);
insert into TimeTracking(Peer, Date, "Time", State) values('kaycekey', '2023-11-06','15:25', 1);
insert into TimeTracking(Peer, Date, "Time", State) values('kaycekey', '2023-11-06','23:25', 2);
insert into TimeTracking(Peer, Date, "Time", State) values('pickling', '2023-10-26', '13:00', 1);
insert into TimeTracking(Peer, Date, "Time", State) values('pickling', '2023-10-26', '16:00',2);
insert into TimeTracking(Peer, Date, "Time", State) values('pickling', '2023-10-26', '19:00', 1);
insert into TimeTracking(Peer, Date, "Time", State) values('pickling', '2023-10-26', '23:16', 2);
insert into TimeTracking(Peer, Date, "Time", State) values('lorinoh','2023-10-10', '17:00',1);
insert into TimeTracking(Peer, Date, "Time", State) values( 'lorinoh','2023-10-10', '17:00',2);
insert into TimeTracking(Peer, Date, "Time", State) values('raylhigh', '2023-11-01', '10:00', 1);
insert into TimeTracking(Peer, Date, "Time", State) values('raylhigh', '2023-11-01', '17:00', 2);
insert into TimeTracking(Peer, Date, "Time", State) values('florentq', '2023-10-20','12:45', 1);
insert into TimeTracking(Peer, Date, "Time", State) values('florentq', '2023-10-20','19:45', 2);




--import & export

CREATE OR REPLACE PROCEDURE ImportDataFromCSV(directory text) AS $$
declare
     copy_cmd text;
BEGIN
    copy_cmd:='copy Peers(Nickname, Birthday) from ''' || directory || '/peer.csv''  DELIMITER '','' CSV HEADER';
    EXECUTE (copy_cmd);
    copy_cmd:='copy Tasks(Title, ParentTask, MaxXP) from ''' || directory || '/task.csv'' DELIMITER '','' CSV HEADER';
    EXECUTE (copy_cmd);
    copy_cmd:='copy Checks(Peer, Task, Date) from ''' || directory || '/check.csv'' DELIMITER '','' CSV HEADER';
    EXECUTE (copy_cmd);
    copy_cmd:='copy P2P("Check", CheckingPeer, State, "Time") from ''' || directory || '/p2p.csv'' DELIMITER '','' CSV HEADER';
    EXECUTE (copy_cmd);
    copy_cmd:='copy Verter("Check", State, "Time") from ''' || directory || '/verter.csv'' DELIMITER '','' CSV HEADER';
    EXECUTE (copy_cmd);
    copy_cmd:='copy TransferredPoints(CheckingPeer, CheckedPeer, PointsAmount) from ''' || directory || '/TransferredPoint.csv'' DELIMITER '','' CSV HEADER';
    EXECUTE (copy_cmd);
    copy_cmd:='copy Friends(Peer1, Peer2) from ''' || directory || '/friend.csv'' DELIMITER '','' CSV HEADER';
    EXECUTE (copy_cmd);
    copy_cmd:='copy Recommendations(Peer, RecommendedPeer) from ''' || directory || '/recommendation.csv'' DELIMITER '','' CSV HEADER';
    EXECUTE (copy_cmd);
    copy_cmd:='copy XP("Check", XPAmount) from ''' || directory || '/xp.csv'' DELIMITER '','' CSV HEADER';
    EXECUTE (copy_cmd);
    copy_cmd:='copy TimeTracking(Peer, Date, "Time", State) from ''' || directory || '/time_tracking.csv'' DELIMITER '','' CSV HEADER';
    EXECUTE (copy_cmd);
END;
$$
    language plpgsql;

call ImportDataFromCSV('/Users/florentq/Projects/SQL/SQL2_Info21_v1.0-3/src/csv');


CREATE  OR REPLACE PROCEDURE ExportDataToCSV(directory text) AS $$
declare
     copy_cmd text;
BEGIN
    copy_cmd:='copy Peers(Nickname, Birthday) to ''' || directory || '/peer.csv'' DELIMITER '','' CSV HEADER';
    EXECUTE (copy_cmd);
    copy_cmd:='copy Tasks(Title, ParentTask, MaxXP) to ''' || directory || '/task.csv'' DELIMITER '','' CSV HEADER';
    EXECUTE (copy_cmd);
    copy_cmd:='copy Checks(Peer, Task, Date) to ''' || directory || '/check.csv'' DELIMITER '','' CSV HEADER';
    EXECUTE (copy_cmd);
    copy_cmd:='copy P2P("Check", CheckingPeer, State, "Time") to ''' || directory || '/p2p.csv'' DELIMITER '','' CSV HEADER';
    EXECUTE (copy_cmd);
    copy_cmd:='copy Verter("Check", State, "Time") to ''' || directory || '/verter.csv'' DELIMITER '','' CSV HEADER';
    EXECUTE (copy_cmd);
    copy_cmd:='copy TransferredPoints(CheckingPeer, CheckedPeer, PointsAmount) to ''' || directory || '/TransferredPoint.csv'' DELIMITER '','' CSV HEADER';
    EXECUTE (copy_cmd);
    copy_cmd:='copy Friends(Peer1, Peer2) to ''' || directory || '/friend.csv'' DELIMITER '','' CSV HEADER';
    EXECUTE (copy_cmd);
    copy_cmd:='copy Recommendations(Peer, RecommendedPeer) to ''' || directory || '/recommendation.csv'' DELIMITER '','' CSV HEADER';
    EXECUTE (copy_cmd);
    copy_cmd:='copy XP("Check", XPAmount) to ''' || directory || '/xp.csv'' DELIMITER '','' CSV HEADER';
    EXECUTE (copy_cmd);
    copy_cmd:='copy TimeTracking(Peer, Date, "Time", State) to ''' || directory || '/time_tracking.csv'' DELIMITER '','' CSV HEADER';
    EXECUTE (copy_cmd);
END;
$$
    language plpgsql;

call ExportDataToCSV('/Users/florentq/Projects/SQL/SQL2_Info21_v1.0-3/src/csv');



drop table IF EXISTS Tasks, XP, Verter, TimeTracking, Recommendations, Friends, TransferredPoints, P2P, Peers, Checks;
--truncate Tasks, XP, Verter, TimeTracking, Recommendations, Friends, TransferredPoints, P2P, Peers, Checks;

