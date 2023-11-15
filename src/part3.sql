--task 1)
create or replace function transferredpoints_humanreadable()
returns table ("Peer1" varchar, "Peer2" varchar, "PointsAmount" integer) as
$$
begin
    return query
    select checkingpeer, checkedpeer, pointsamount from transferredpoints;
end;
$$ language plpgsql;
select * from transferredpoints_humanreadable();

--task 2)
create or replace function successful_checks()
returns table ("Peer" varchar, "Task" varchar, "XP" integer) as
$$
begin
    return query
    select peer, task, xpamount from checks
        join xp on checks.id = xp."Check"
        join p2p on checks.id = p2p."Check"
    where state = 'Success';
end;
$$ language plpgsql;
select * from successful_checks();

--task 3)
create or replace function peers_not_left_campus(day_to_check date)
returns table ("Peer" varchar) as
$$
begin
    return query
    select peer from timetracking where date = day_to_check
    group by peer, state
    having count(state) = 1 and state = '2';
end;
$$ language plpgsql;
select * from peers_not_left_campus('2023-10-26');--the only day that doesn't meet the condition
select * from peers_not_left_campus('2023-10-13');
select * from peers_not_left_campus('2023-11-11');--not existing day

--task 4)
create or replace function calculate_prp_change()
returns table ("Peer" varchar, "PointsChange" bigint) as
$$
begin
    return query
    select checkingpeer, sum(pointsamount) as pointschange
    from transferredpoints
    group by checkingpeer
    order by pointschange desc;
end;
$$ language plpgsql;
select * from calculate_prp_change();

--task 5)
create or replace function calculate_prp_change_for_peers_not_left_campus(day_to_check date)
returns table ("Peer" varchar, "PointsChange" bigint) as
$$
begin
    return query
    select task3."Peer", sum(pointsamount)
    from peers_not_left_campus(day_to_check) task3
        left join transferredpoints on task3."Peer" = transferredpoints.checkingpeer
    group by task3."Peer"
    order by "PointsChange" desc;
end;
$$ language plpgsql;
select * from calculate_prp_change_for_peers_not_left_campus('2023-10-13');
select * from calculate_prp_change_for_peers_not_left_campus('2023-10-10');--null
select * from calculate_prp_change_for_peers_not_left_campus('2023-11-11');--not existing day

--task 6)
create or replace function most_reviewed_task_per_day()
returns table ("Day" date, "Task" varchar) as
$$
begin
    return query
    with task_ranking as (
        select date, task,
            rank() over (partition by date order by count(*) desc) as task_rank
        from checks
        group by checks.date, checks.task
    )
    select date, task from task_ranking where task_rank = 1;
end;
$$ language plpgsql;
--every day had only one check, so added in part1 some to prove that func works fine
select * from most_reviewed_task_per_day();

--task 7)
create or replace function peer_completed_whole_block(blockname varchar)
returns table ("Peer" varchar, "Day" date) as
$$
begin
    return query
    with completedtasks as (
        select peer, title, date from checks
        join tasks on checks.task = tasks.title
        where title ~ (blockname || '\d+')
        order by title desc
    ), blocktasks as (
        select title from tasks
        where title ~ (blockname || '\d+')
    )
    select peer, date
    from completedtasks
    where title = (select max(title) from blocktasks)
    group by peer, date
    order by date;
end;
$$ language plpgsql;
select * from peer_completed_whole_block('C');
select * from peer_completed_whole_block('CPP');--no one meets the condition
select * from peer_completed_whole_block('SQL');--not existing

--task 8)
create or replace function most_recommended_peers()
returns table ("Peer" varchar, "RecommendedPeer" varchar) as
$$
begin
    return query
    with recommendationcount as (
        select
            peer1, recommendedpeer,
            count(*) as recommendationcount,
            row_number() over (partition by peer1 order by count(*) desc) as row
        from friends
        join recommendations on friends.peer2 = recommendations.peer
        group by peer1, recommendedpeer
    )
    select peer1, recommendedpeer from recommendationcount where row = 1;
end;
$$ language plpgsql;
--every peer had only one recommendation, so added in part1 some to prove that func works fine
select * from most_recommended_peers();

--task 9)
create or replace function blocks_completion_percentage(block1 varchar, block2 varchar)
returns table ("StartedBlock1" numeric, "StartedBlock2" numeric, "StartedBothBlocks" numeric, "DidntStartAnyBlock" numeric) as
$$
begin
    return query
    with completion_status as (
        select nickname,
            case when count(distinct case when title like block1 || '%' then title end) > 0
                  and count(distinct case when title like block2 || '%' then title end) = 0
                 then 1 else 0 end as started_block1,
            case when count(distinct case when title like block1 || '%' then title end) = 0
                  and count(distinct case when title like block2 || '%' then title end) > 0
                 then 1 else 0 end as started_block2,
            case when count(distinct case when title like block1 || '%' then title end) > 0
                  and count(distinct case when title like block2 || '%' then title end) > 0
                 then 1 else 0 end as started_both_blocks,
            case when count(distinct case when title like block1 || '%' then title end) = 0
                  and count(distinct case when title like block2 || '%' then title end) = 0
                 then 1 else 0 end as didnt_start_any_block
        from peers
        left join checks on peers.nickname = checks.peer
        left join tasks on checks.task = tasks.title
        group by nickname
    )
    select round(100 * sum(started_block1) / count(*), 0),
           round(100 * sum(started_block2) / count(*), 0),
           round(100 * sum(started_both_blocks) / count(*), 0),
           round(100 * sum(didnt_start_any_block) / count(*), 0) from completion_status;
end;
$$ language plpgsql;
select * from blocks_completion_percentage('C', 'CPP');
select * from blocks_completion_percentage('C', 'C');
select * from blocks_completion_percentage('C', 'SQL');
select * from blocks_completion_percentage('A', 'DO');

--task 10)
create or replace function successful_birthday_reviews()
returns table ("SuccessfulChecks" numeric, "UnsuccessfulChecks" numeric)
as $$
begin
    return query
    select
        round(100 *
            count(distinct case when
                extract(month from date) * 100 + extract(day from date)
              = extract(month from birthday) * 100 + extract(day from birthday)
                    and p2p.state = 'Success'
                    and verter.state = 'Success' then peer
            end) / count(distinct nickname),
        0),
        round(100 *
            count(distinct case when
                extract(month from date) * 100 + extract(day from date)
              = extract(month from birthday) * 100 + extract(day from birthday)
                    and p2p.state = 'Failure'
                    or verter.state = 'Failure' then peer
            end) / count(distinct nickname),
        0)
    from peers
    left join checks on peers.nickname = checks.peer
    left join p2p on checks.id = p2p."Check"
    left join verter on checks.id = verter."Check";
end;
$$ language plpgsql;
-- no peer has ever been on a review on their birthday. added some to the database
select * from successful_birthday_reviews();

--task 11)
create or replace function peers_completed_tasks(task1 varchar, task2 varchar, task3 varchar)
returns table ("Peer" varchar) as
$$
begin
    return query
    select distinct nickname from peers
    where (nickname in
            (select distinct c1.peer from checks c1
            join tasks t1 on c1.task = t1.title
            where t1.title = task1)
        or nickname in
            (select distinct c2.peer from checks c2
            join tasks t2 on c2.task = t2.title
            where t2.title = task2)
        ) and (nickname not in
            (select distinct c3.peer from checks c3
            join tasks t3 on c3.task = t3.title
            where t3.title = task3)
        and nickname in
            (select distinct c3pt.peer from checks c3pt
            join tasks t3pt on c3pt.task = t3pt.title
            where t3pt.title = (select parenttask from tasks where title = task3)
            )
        );
end;
$$ language plpgsql;
--fixed, various requests to prove:
select * from peers_completed_tasks('C7_SmartCalc_v1', 'C8_3DViewer_v1', 'CPP1_s21_matrix');
select * from peers_completed_tasks('C7_SmartCalc_v1', 'C8_3DViewer_v1', 'C6_s21_matrix');
select * from peers_completed_tasks('C6_s21_matrix', 'C7_SmartCalc_v1', 'C8_3DViewer_v1');

--task 12)
create or replace function number_of_preceding_tasks_for_each_task()
returns table ("Task" varchar, "PrevCount" integer) as
$$
begin
    return query
    with recursive hierarchy as (
        select title, 0 as counter from tasks where parenttask is null
    union all
        select current.title, hierarchy.counter + 1 from tasks current
        join hierarchy on current.parenttask = hierarchy.title
    ) select title, counter from hierarchy order by title;
end;
$$ language plpgsql;
select * from number_of_preceding_tasks_for_each_task();

--task 13)
create or replace function get_lucky_days(N integer)
returns table (lucky_day date) as
$$
declare
    consecutive_successes integer := 0;
    last_check_date date;
    check_record record;
begin
    for check_record in (
        select distinct date, "Time", xpamount, maxxp from checks
        join p2p on checks.id = p2p."Check" and p2p.state = 'Success'
        join xp on checks.id = xp."Check"
        join tasks on checks.task = tasks.title
        order by date, "Time")
    loop
        if last_check_date is null
            or check_record.date = last_check_date + 1 then-- consecutive day
            if check_record.xpamount >= 0.8 * check_record.maxxp then
                consecutive_successes := consecutive_successes + 1;
            end if;
        else consecutive_successes := 1;-- not consecutive day, reset counter
        end if;

        if consecutive_successes >= n then
            return query select distinct check_record.date;-- this is a lucky day
        end if;

        last_check_date := check_record.date;
    end loop;
    return;
end;
$$ language plpgsql;
select * from get_lucky_days(1);
select * from get_lucky_days(0);
select * from get_lucky_days(2);

--task 14)
create or replace function peer_having_highest_xp()
returns table ("Peer" varchar, "XP" bigint) as
$$
begin
    return query
    select peer, sum(xpamount) sum_xp from xp
    join checks on xp."Check" = checks.id
    group by peer
    order by sum_xp desc limit 1;
end;
$$ language plpgsql;
--had three peers with equal xp of 600, so i added some extra data to the database
select * from peer_having_highest_xp();

--task 15)
create or replace function peers_coming_before_time(given_time time, N integer)
returns table ("Peer" varchar) as
$$
begin
    return query
    with condition as (
        select peer, count(*) from timetracking
        where "Time" < given_time and state = 1
        group by peer
        having count(*) >= N
    ) select distinct peer from condition;
end;
$$ language plpgsql;
select * from peers_coming_before_time('13:00:00', 1);
select * from peers_coming_before_time('20:00:00', 2);
select * from peers_coming_before_time('10:00:00', 0);

--task 16)
create or replace function peers_leaving_campus(N integer, M integer)
returns table ("Peer" varchar) as
$$
begin
    return query
    with condition as (
        select peer, count(*) from timetracking
        where date >= current_date - (N || ' days')::interval and state = 2
        group by peer
        having count(*) > M
    ) select distinct peer from condition;
end;
$$ language plpgsql;
select * from peers_leaving_campus(365, 1);
select * from peers_leaving_campus(365, 2);
select * from peers_leaving_campus(14, 0);

--task 17)
create or replace function monthly_early_entries_percentage()
returns table ("Month" text, "EarlyEntries" bigint) as
$$
begin
    return query
    select to_char(month, 'month'),
        100 * sum(case when extract(hour from "Time") < 12 then 1 else 0 end) / count(*)
    from (select date_trunc('month', date) as month, "Time" from timetracking where state = 1) as subquery
    group by to_char(month, 'month');
end;
$$ language plpgsql;
select * from monthly_early_entries_percentage();
