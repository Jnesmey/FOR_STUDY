select city, count(airports) 
from airports
group by city
having count(airports) > 1;

select  distinct ad.airport_name 
from flights f 
join aircrafts a on a.aircraft_code = f.aircraft_code
join airports_data ad on ad.airport_code = f.departure_airport 
where range = (select max(range)
from aircrafts a2);

select flight_id, flight_no, (actual_arrival - scheduled_arrival) as late
from flights f2
where actual_arrival > scheduled_arrival 
order by late desc
limit 10;

select * from 
tickets t
right join boarding_passes bp on t.ticket_no = bp.ticket_no
where bp.boarding_no is null;

select f.flight_id, a2.all_seats-f2.taken_seats as free_seats, 
cast((a2.all_seats-f2.taken_seats)as float)/cast (a2.all_seats as float)*100 as perFree,
sum (f2.taken_seats) over (partition by f.departure_airport, cast (f.actual_departure as date) order by f.actual_departure) as sum
from flights f
join 
	(select s.aircraft_code, 
	count (s.seat_no) as all_seats
	from seats s
	group by s.aircraft_code) as a2
	on a2.aircraft_code = f.aircraft_code 
join
	(select flight_id, count(seat_no) as taken_seats
	from boarding_passes bp
	group by flight_id) as f2
	on f2.flight_id = f.flight_id ;

select f2.aircraft_code, count(f2.flight_id) as flightscraft, (select count(flight_id)
from flights f2),
round (cast (count(f2.flight_id)as numeric)/cast ((select count(flight_id)
from flights f2) as numeric) * 100, 2) as "%"
from flights f2 
group by f2.aircraft_code;


with cte1 as (
select max (tf.amount) as maxec, tf.flight_id 
from ticket_flights tf 
where tf.fare_conditions = 'Economy'
group by tf.flight_id),
cte2 as(
select min (tf.amount) as minb, tf.flight_id 
from ticket_flights tf  
where tf.fare_conditions = 'Business'
group by tf.flight_id)
select cte2.minb - cte1.maxec, cte1.flight_id
from cte1
join cte2 on cte1.flight_id=cte2.flight_id
where cte2.minb - cte1.maxec<0;
