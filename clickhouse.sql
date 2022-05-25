select
    UserID
from homework.metrika
group by
    UserID
order by
    count() desc
limit 1;

Result:
1313448155240738815