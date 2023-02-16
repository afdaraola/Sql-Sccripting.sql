/*
Syntax: 
 CURSOR cursor_name(parameter_name datatype,  )
 IS
 Select_statement;
1)Pass parameter values to a cursor when the cursor is opened and the query is executed

2) Open an explicit cursor several times with different active sets each time
*/



declare
    cursor curl(pid number) is select * from championship where  id = pid;
    champ_data  championship%rowtype;
    l_id number := 221;
begin
    open curl(221);
  loop
    fetch curl into champ_data;
   if curl%Found then
    update  championship set score = champ_data.score+1
    where id = champ_data.id;
 else
       exit;
   end if;
    end loop;
    close curl;

    open  curl(l_id);
    loop
        fetch curl into champ_data;
        IF curl%found then
            update  championship set score = champ_data.score+1
            where id = champ_data.id;
            else
            exit;
        end if;
    end loop;
    close curl;
end;

