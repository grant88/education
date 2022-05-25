select
    UserID
from homework.metrika
group by
    UserID
order by
    count() desc
limit 1;