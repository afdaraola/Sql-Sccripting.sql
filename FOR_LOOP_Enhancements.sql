--stepped range interation 

begin
  for i in 1 .. 10 by 2 loop
    dbms_output.put_line(i);
  end loop;
end;

--fractional range iteration 
begin
  for i number(5,2) in 1.6 .. 5.6   loop
    dbms_output.put_line(i);
  end loop;
end;


--fractional stepped range iteration 
begin
  for i number(5,2) in 1.6 .. 5.6 by 0.2 loop
    dbms_output.put_line(i);
  end loop;
end;

--single expression iteration 

begin
  for i in 100 loop
    dbms_output.put_line(i);
  end loop;
end;


--multiple iteration (chaining of iteration 

begin
  for i number(5,2) in 1..10 by 2 , 1.6..5.6 , 11.6..15.6 by 0.2, 80, reverse 90..95 loop
    dbms_output.put_line(i);
  end loop;
end;
