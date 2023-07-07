
declare
  type pdt_rec is record(
    pdt_id   number,
    pdt_name varchar2(10));
  procedure display_rec(p_rec in pdt_rec default pdt_rec(1, null)) as
  begin
    dbms_output.put_line(p_rec.pdt_id);
  end;
begin
  display_rec;
end;


declare
  type pdt_nt_tab is table of varchar2(10);
  pdt_name pdt_nt_tab;
begin
  pdt_name:=pdt_nt_tab(null);
  pdt_name.extend;
  pdt_name(1) := 'wheat';
  dbms_output.put_line(pdt_name(1));
end;
  


declare
  cursor c_prod is
    select id from datas;
  type c_list is table of datas.id%type index by binary_integer;
  prod_list c_list;
begin
  prod_list(1) := 2;
  dbms_output.put_line(prod_list(1));
end;


declare
  type pdt_tab is table of number index by pls_integer;
  l_pdt pdt_tab := pdt_tab(1, 2, 3);
begin
  dbms_output.put_line(l_pdt.count);
end;


declare
  type pdt_var is Varray(3) of varchar2(6);
  pdt_list pdt_var:=pdt_var(null,null,null);
begin
  pdt_list(1) := 'A';
  dbms_output.put_line(pdt_list(1));
end;
