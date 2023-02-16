
/*
 How to use Oracle PLSQL Tables (Associative array or index-by table)

 a)
 DECLARE
 TYPE DEPTTabTyp IS TABLE OF dept.location%TYPE NOT NULL INDEX BY BINARY_INTEGER;

 b)  FETCH statement

With the FETCH statement, you can fetch an entire column of Oracle data into a PL/SQL table of scalars.

Or you can fetch an entire table of Oracle data into a PL/SQL table of records.

 */


declare
    type  empType is table of championship%rowtype index by PLS_INTEGER;
    empData empType;
    cursor  c1 is select * from championship;
    i pls_integer :=0;

    begin
    open c1;
    loop
        i := i+1;

    fetch c1 into empData(i);
        exit when c1%notfound;
    update championship set score = 200
       where id = empData(i).id;
    commit;
    end loop;
  close c1;

end;
